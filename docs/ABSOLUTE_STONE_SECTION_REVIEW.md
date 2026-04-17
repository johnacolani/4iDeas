# Absolute Stone Design Section Review

## Overall assessment

Your `Absolute Stone Design (ASD)` section is strong and already presents senior-level product and engineering scope. It communicates systems thinking, multi-role architecture, governance, and measurable outcomes better than most portfolio case studies.

Short answer: **yes, you explain a lot of what this app deserves**.  
There are a few improvements that would make it even more credible and complete.

## What is already excellent

- Clearly positions ASD as a **multi-role operations platform**, not a simple CRUD app.
- Shows **strategy + architecture + implementation ownership** end-to-end.
- Includes **decision trade-offs** (unified app vs separate apps), which signals senior product thinking.
- Includes **quantified impact** (support reduction, onboarding speed, error reduction), which increases trust.
- Frames AI as **governed workflow** with human oversight, not hype.

## Gaps to close for full representation

### 1) Rename Amy to Rose consistently

The narrative still says "Amy AI" in places. In ASD delivery this capability is now Rose-branded.

Why it matters:
- Keeps portfolio consistent with production product language.
- Avoids confusion during interviews/reviews.

### 2) Add recently delivered seasonal campaign engine

Current case study does not explicitly mention this capability:
- backend-controlled seasonal campaigns
- Firestore + Firebase Storage + Remote Config control
- fallback logic and safe rollout controls
- intro popup/confetti/theming per campaign

This is high-value product/ops capability and should be listed.

### 3) Clarify evidence vs estimate on metrics

Some metrics are strong but could be challenged without context.
Add a line for each key metric:
- measured from analytics/logs, or
- operational estimate from team baseline.

### 4) Add a “Production Hardening” subsection

Include concrete reliability/safety engineering examples:
- Firestore security rules and role-safe controls
- index/performance optimizations
- web/mobile fallback behavior
- background refresh/loading state design

### 5) Add “What I built recently” timeline bullets

A short recent-delivery changelog under ASD helps show active ownership and evolution.

Suggested 4 bullets:
- Admin dashboard segmentation + drill-down user management
- Role-safe admin operations and rule hardening
- Rose seasonal campaign engine with backend controls
- Web UX/performance tuning and loading-state improvements

## Suggested edits to existing ASD section

### Replace/modernize AI wording

- Change "Amy AI" -> "Rose AI Assistant"
- Change "Amy Conversations" phrasing to "AI conversation governance and review pipeline"

### Add one new highlight bullet

Add under **Senior-Level Highlights**:

- **Backend-Controlled Seasonal Campaign Engine**: Designed and shipped a campaign system where admins can control seasonal greetings, imagery, intro experiences, and safety kill-switches from backend without app redeploys.

### Add one operational architecture bullet

- **Production Hardening**: Implemented role-safe security rules, performance-aware data access patterns, and resilient fallback handling across Web/iOS/Android.

## Optional short version for portfolio card

Absolute Stone Design is a production multi-role operations platform (Admin, Sales, Scheduler, Installer, Client) that unifies contracts, scheduling, field execution, communication, and AI support in one system. I led strategy through delivery, including governed Rose AI workflows, backend-controlled seasonal campaign engine, role-safe security architecture, and cross-platform production hardening with measurable operational impact.

## Conclusion

Your ASD section is already high quality and far above average.  
With branding consistency (Rose), explicit seasonal-engine mention, and clearer metric sourcing, it will better reflect the full depth of what you actually built.

## Add Rose Chat as a related project

This is a strong strategy. Rose Chat should be presented as a separate case study that is related to ASD, so your portfolio shows hands-on AI product design ownership (not just app implementation).

### Recommended positioning

- Keep **ASD** as the parent operations platform case study.
- Add **Rose Chat** as a related/child case study under ASD.
- Frame Rose Chat as: **AI Experience + Governance Layer inside ASD ecosystem**.

### What to emphasize in Rose Chat case study

- **Problem framing**: repetitive client questions overloaded the team and produced inconsistent responses.
- **Conversation experience design**: greeting strategy, trust-focused UI, retry/fallback behavior, and role-aware interaction patterns.
- **AI governance model**: admin training mode, knowledge-base curation, feedback/correction loop, and controlled rollout.
- **Backend control system**: campaign-driven chat experiences via Firestore/Storage/Remote Config (theme, greeting, intro, effects) without mandatory app redeploy.
- **Safety and resilience**: kill switch, preview mode, date windows, fallback content, and graceful failure handling.
- **Cross-functional value**: reduced support load while preserving human oversight for quality and compliance.

### Suggested Rose Chat portfolio structure

1. Context and business problem
2. My role (product design, UX decisions, governance strategy)
3. User journey and conversation flows
4. Trust, safety, and human-in-the-loop design
5. Backend control architecture (campaigns and release controls)
6. Outcomes and metrics
7. Future improvements

### Suggested title options

- **Rose Chat: Governed AI Assistant for Service Operations**
- **Designing Rose: Human-Centered AI Chat in a Multi-Role Platform**
- **Rose AI Experience: Product Design + Operational Governance**

### Optional short paragraph for direct use

Rose Chat is a governed AI assistant designed within the ASD operations platform to improve client communication and reduce support load without sacrificing trust or control. I led the product design of conversation experience, fallback and error flows, human-in-the-loop governance, and backend-controlled campaign behavior (seasonal theming, greetings, intro states, kill switch, and preview controls). This case study demonstrates hands-on AI product design beyond UI, including safety, rollout strategy, and measurable operational impact.
