/// Lead capture: Formspree and optional scheduling URLs.
///
/// **Formspree:** Create a form at [formspree.io](https://formspree.io) (or reuse your
/// existing order form endpoint). Custom fields from [ProjectInquiryForm] map to email body.
///
/// **Calendly:** Set [calendlyIntroUrl] to your booking link (e.g. `https://calendly.com/yourname/intro`).
/// Leave empty to hide the scheduling button on the contact page.
class LeadCaptureConfig {
  LeadCaptureConfig._();

  /// Same endpoint as [OrderHereScreen] is OK—use `form_source` to filter—or create a dedicated form.
  static const String projectInquiryFormspreeEndpoint =
      'https://formspree.io/f/maqwlqlq';

  /// Public Calendly (or other scheduler) URL. Empty string = hidden.
  static const String calendlyIntroUrl = '';
}
