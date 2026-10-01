import {randomUUID} from "node:crypto";
import tls, {TLSSocket} from "node:tls";

const SMTP_HOST = "smtp.gmail.com";
const SMTP_PORT = 465;
const SMTP_USER = "johnacolani@gmail.com";
const FROM_ADDRESS = "4iDeas <info@4ideasapp.com>";
const REPLY_TO = "info@4ideasapp.com";

function readResponse(socket: TLSSocket): Promise<string> {
  return new Promise((resolve, reject) => {
    let buffer = "";

    const cleanup = () => {
      socket.off("data", onData);
      socket.off("error", onError);
      socket.off("close", onClose);
    };

    const onError = (error: Error) => {
      cleanup();
      reject(error);
    };

    const onClose = () => {
      cleanup();
      reject(new Error("SMTP connection closed unexpectedly."));
    };

    const onData = (chunk: Buffer) => {
      buffer += chunk.toString("utf8");
      const lines = buffer.split("\r\n").filter(Boolean);
      const last = lines.at(-1) ?? "";
      if (/^\d{3} /.test(last)) {
        cleanup();
        resolve(buffer);
      }
    };

    socket.on("data", onData);
    socket.once("error", onError);
    socket.once("close", onClose);
  });
}

function responseCode(response: string): number {
  const matches = [...response.matchAll(/(?:^|\r\n)(\d{3}) /g)];
  const last = matches.at(-1);
  return last ? Number(last[1]) : 0;
}

async function command(socket: TLSSocket, value: string, expected: number): Promise<string> {
  socket.write(value + "\r\n");
  const response = await readResponse(socket);
  const code = responseCode(response);
  if (code !== expected) {
    throw new Error("SMTP command failed with status " + (code || "unknown") + ".");
  }
  return response;
}

function normalizeLines(value: string): string {
  return value.replace(/\r?\n/g, "\r\n");
}

function dotStuff(value: string): string {
  return value.replace(/(^|\r\n)\./g, "$1..");
}

function buildMessage(args: {to: string; subject: string; text: string; html: string}): {mime: string; messageId: string} {
  const boundary = "4ideas_" + randomUUID().replace(/-/g, "");
  const messageId = "<" + randomUUID() + "@4ideasapp.com>";
  const headers = [
    "From: " + FROM_ADDRESS,
    "To: " + args.to,
    "Reply-To: " + REPLY_TO,
    "Subject: " + args.subject,
    "Date: " + new Date().toUTCString(),
    "Message-ID: " + messageId,
    "MIME-Version: 1.0",
    "Content-Type: multipart/alternative; boundary=\"" + boundary + "\"",
  ];
  const parts = [
    "--" + boundary,
    "Content-Type: text/plain; charset=\"UTF-8\"",
    "Content-Transfer-Encoding: 8bit",
    "",
    normalizeLines(args.text),
    "--" + boundary,
    "Content-Type: text/html; charset=\"UTF-8\"",
    "Content-Transfer-Encoding: 8bit",
    "",
    normalizeLines(args.html),
    "--" + boundary + "--",
    "",
  ];
  return {mime: normalizeLines([...headers, "", ...parts].join("\r\n")), messageId};
}

export async function sendGmailEmail(args: {
  to: string;
  subject: string;
  text: string;
  html: string;
  appPassword: string;
}): Promise<{messageId: string}> {
  const password = args.appPassword.replace(/\s/g, "");
  if (!password) throw new Error("Gmail App Password is not configured.");

  const socket = tls.connect({host: SMTP_HOST, port: SMTP_PORT, servername: SMTP_HOST, rejectUnauthorized: true});
  try {
    const greeting = await readResponse(socket);
    if (responseCode(greeting) !== 220) throw new Error("Gmail SMTP did not accept the connection.");

    await command(socket, "EHLO 4ideasapp.com", 250);
    await command(socket, "AUTH LOGIN", 334);
    await command(socket, Buffer.from(SMTP_USER, "utf8").toString("base64"), 334);
    await command(socket, Buffer.from(password, "utf8").toString("base64"), 235);
    await command(socket, "MAIL FROM:<" + SMTP_USER + ">", 250);
    await command(socket, "RCPT TO:<" + args.to + ">", 250);
    await command(socket, "DATA", 354);

    const built = buildMessage(args);
    socket.write(dotStuff(built.mime) + "\r\n.\r\n");
    const accepted = await readResponse(socket);
    if (responseCode(accepted) !== 250) throw new Error("Gmail SMTP did not accept the email.");

    try { await command(socket, "QUIT", 221); } catch { /* already accepted */ }
    return {messageId: built.messageId};
  } finally {
    socket.end();
  }
}
