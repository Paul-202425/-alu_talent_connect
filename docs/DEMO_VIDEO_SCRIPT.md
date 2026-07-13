# ALU Talent Connect — Demo Video Script

**Target length:** 9–12 minutes
**Grading focus (per rubric):** technical accuracy, clear structure, confident delivery, and — above all — your ability to explain *why* you made specific implementation decisions, how the app scales, how state is managed, and how the design supports real-world usability. Live demonstration matters less than what you say while doing it. Narrate your reasoning constantly; don't just click through screens silently.

Companion reference: `docs/TECHNICAL_REPORT.md` — every claim below is drawn from that report, so if you're asked a follow-up question, the answer is already written down there.

---

## Before You Record

- [ ] Emulator/device running, app fresh-installed (clear app data so the demo can show Register from scratch, not just an already-logged-in session)
- [ ] Have **two test accounts ready to create live**: one Student, one Startup Founder (don't pre-create them — creating them on camera is proof you understand the auth + Firestore write flow)
- [ ] Firebase Console open in a browser tab (Firestore Data tab + Authentication tab) so you can flip over and show documents appearing in real time
- [ ] `firestore.rules` and `lib/core/router/app_router.dart` open in your editor, ready to alt-tab to
- [ ] Do one silent dry run first — the goal is confident, unscripted-sounding delivery, not a read-aloud script. Use this document as talking points, not a teleprompter.

---

## Segment 1 — Introduction & Architecture Overview (≈90 seconds)

**[ON SCREEN: your editor, `lib/` folder tree expanded]**

**Say, in your own words, covering:**
- What the app does and for whom: "ALU Talent Connect is a two-sided marketplace — ALU students looking for internships, and ALU student-led startups posting roles."
- Name the stack and *why each piece*, not just what it is:
  - "I used **Flutter** because I need one codebase for the mobile client."
  - "**Firebase** — Auth + Firestore — because this is a small team building a real-time marketplace, and I don't want to build and host a custom backend just to get real-time updates and authentication. Firestore's live listeners map directly onto 'a founder accepts an application and the student sees it instantly' without me writing any polling or websocket code myself."
  - "**Riverpod** for state management — I'll justify this specifically in the state management segment, but the short version is: it converts Firestore streams into reactive UI state almost for free."
- Point at the folder structure and explain the **two organizational decisions stacked on top of each other**:
  1. "Feature-first at the top level — `auth`, `profiles`, `opportunities`, `applications` — each one is a vertical slice I can work on independently."
  2. "Inside each feature, a **layered architecture** — `data`, `domain`, `presentation`. This is Clean Architecture. The reason I did this instead of just calling Firestore directly from my widgets: I wanted a hard boundary so that if I ever needed to swap Firestore for something else, or write a test with a fake repository, only the `data` layer would need to change — the UI and business logic never import `cloud_firestore` directly."

**Show the architecture diagram** from `docs/TECHNICAL_REPORT.md` §2.2 (screen-share the rendered mermaid diagram, or describe it while pointing at the folder tree) — this is your visual anchor for "here's the shape of the system" before you dive into any one part.

---

## Segment 2 — Firebase Backend & Data Model (≈2 minutes)

**[ON SCREEN: Firebase Console → Firestore Data tab, plus `firestore.rules` in your editor]**

**Say:**
- "There are four top-level collections: `users`, `startups`, `opportunities`, `applications` — all flat, no subcollections."
- **Justify the flatness**: "Firestore doesn't support joins, so I denormalize instead — an opportunity document stores `startupName` directly, so rendering the feed is one query, not N+1 queries per card."
- **Walk through the ER diagram** (§3.2.1 of the report) briefly: users found startups, startups post opportunities, students submit applications against opportunities.
- **Explain the one deliberately clever bit — deterministic application IDs**: "An application's document ID isn't auto-generated — it's literally `{opportunityId}_{applicantId}`. That means 'has this student already applied to this job' becomes a single document lookup instead of a query, and it makes duplicate applications *structurally impossible* — Firestore itself won't let two documents share an ID."
- **Show the transaction**: open `application_remote_datasource.dart`, point at `runTransaction()`. "This is the one place I use a real Firestore transaction — checking the application doesn't already exist, checking the opportunity is still active, writing the application, and incrementing a counter, all atomically. If any step fails, none of it commits."
- **Pivot to security rules — this is a strong, examiner-friendly point**: "The Flutter client is not a trust boundary. Anyone can call Firestore's API directly and skip my Dart code entirely. So every rule that matters — one application per student, only the owning founder can accept/reject, students can only withdraw their own application — is enforced *again* in `firestore.rules`, not just in the app." Show the `applications` match block and specifically the line that mirrors the deterministic-ID check server-side.
- **Mention the role-storage trade-off**: "Role — student vs. founder — lives in a Firestore field, not a Firebase Auth custom claim. That's simpler to implement, but it costs an extra document read inside every security rule that needs to check role. At this scale that's the right trade-off; if this were processing thousands of writes a second I'd move role into a custom claim minted by a Cloud Function."

---

## Segment 3 — State Management, Live (≈2.5 minutes)

**[ON SCREEN: split — app on one side, `opportunity_providers.dart` or `application_providers.dart` on the other]**

This is the segment the rubric weights most heavily. Don't just say "I used Riverpod" — show the *chain*.

**Say, while pointing at actual provider code:**
- "Every feature follows the same chain: a raw Firebase singleton provider, wrapped by a data-source provider, wrapped by a repository provider that's typed to an *interface*, and then either a `StreamProvider` for reads or a `Notifier` for writes."
- **Demonstrate the read side live**: Open the app to the Explore feed. "This list is a `StreamProvider` wrapping a Firestore snapshot listener directly — there is no refresh button because there doesn't need to be one." Then, **in the Firebase Console, manually edit or add an opportunity document** and show it appear/update in the app in real time without touching the phone. This single moment is the clearest possible demonstration of "I understand how state flows through this app."
- **Demonstrate the write side**: Submit an application (or toggle an opportunity's Active switch). "This goes through a `Notifier<FormState>` controller — Riverpod 3's current API, not the older `StateNotifier`. The form state is a small immutable object with `isLoading`, `errorMessage`, `isSuccess` — the button you just saw disable itself and show a spinner is that state driving the UI directly, not a manual `setState` call."
- **Explain the router integration** — this is a good "tradeoff/debugging decision" story for the rubric: "Sign-out needed to work from any screen. `go_router`'s redirect logic re-runs automatically because I bridged Firebase's auth stream into a `ChangeNotifier` that go_router listens to — so the moment `FirebaseAuth` emits a signed-out state, every route re-evaluates and bounces you to `/login`, without me writing a manual navigation call at the sign-out button."

---

## Segment 4 — Core Workflows, Live (≈3 minutes)

**[ON SCREEN: the app, driven live]**

Narrate *decisions*, not just clicks.

1. **Register as a Student.** "Role is picked at sign-up and stored on the user document — I'll come back to why that single field drives almost all the role-conditional UI later." Show the form validate (trigger an error deliberately — e.g., mismatched passwords) to prove validation is real, not just decorative.
2. **Browse the feed.** Point out the "sorted by skill match" subtitle. "This re-sorts the fetched feed client-side by counting overlapping skills with the student's profile — deliberately simple for now; I call this out in my report as the first thing I'd upgrade to a weighted or server-side ranking."
3. **Open an opportunity, apply.** Submit a cover letter. Show the success dialog. Then flip to Firebase Console and show the new `applications/{opportunityId}_{uid}` document and the incremented `applicationCount` on the opportunity — proving the transaction from Segment 2 actually ran.
4. **Sign out, register as a Startup Founder.** Create a startup, then post an opportunity. "Creating a startup does two writes — creates the `startups` document, then links `startupId` back onto the founder's own user document. I'll flag in a moment that these two writes aren't currently wrapped in a single transaction — that's a known limitation, not an oversight I'm unaware of."
5. **Go to Applications Received, Accept the application you just submitted as the student.** Then **switch back to the student account (or a second emulator/window) and show the status update live** — this is your second "real-time state" proof point, from the opposite direction of Segment 3's feed demo.

---

## Segment 5 — Design Decisions, Trade-offs & Scaling (≈2 minutes)

**[ON SCREEN: you, or your editor with `docs/TECHNICAL_REPORT.md` open to §7/§10]**

This is where you directly answer "why did you build it this way" and "how does it scale" — say this section almost verbatim in your own words, it's the part graders are explicitly told to weight heavily.

- **Scaling the data layer:** "Three things let this scale past a toy demo: denormalized reads instead of joins, a counter field instead of aggregating the applications collection every time I need a count, and pre-provisioned composite indexes for every query I actually run — so query latency stays flat as the collections grow."
- **Scaling gaps I'm aware of, not surprised by:** "There's no pagination yet — the feed fetches the whole active-opportunities query in one shot. That's fine at hundreds of documents; before this hit production scale I'd add cursor-based pagination with `startAfterDocument`. I'd rather name that limitation explicitly than pretend it isn't there."
- **A concrete debugging story** (shows real engineering, not just a finished demo): "While developing, sign-in intermittently failed on the emulator with a `RecaptchaCallWrapper` network error. It looked like an auth bug at first. It turned out to be Firebase's Play Integrity attestation check failing to reach Google's servers from an under-provisioned emulator image — an environment issue, not a code issue. The lesson: when a Firebase network error shows up, check the environment before you start rewriting auth logic."
- **A trade-off you'd revisit:** "Sign-up isn't currently atomic — I create the Firebase Auth user, then write the Firestore profile as a second step. If that second write ever failed, you'd have an authenticated user with no profile. I know exactly how I'd fix it — move the profile write into a Cloud Function triggered on user creation — I just haven't built that yet, and I say so directly in my limitations section rather than hiding it."

---

## Segment 6 — Usability & Close (≈45 seconds)

**Say:**
- "The design system — one theme file, one spacing scale, shared widgets for buttons, error states, and loading skeletons — means every screen speaks the same visual language, which matters for a two-role app where students and founders are often looking at the same screen shape with different content."
- "Real-world usability here means: no manual refresh anywhere, because everything is a live Firestore listener; validation errors appear inline, not as toasts, so users don't lose context; and role-specific actions only ever show up for the role that can actually use them — a founder never sees an Apply button, a student never sees Accept/Reject."
- Close with one honest sentence on what you'd build next and why (pick one from §11 of the report that you can defend well, e.g., pagination or the Cloud Function atomic sign-up).

---

## Rubric Self-Check Before You Submit

Run through this once after recording:

- [ ] Did I explain **why**, not just **what**, for at least: Firebase choice, Riverpod choice, the deterministic application-ID trick, and the denormalization trade-off?
- [ ] Did I demonstrate **live, real-time state propagation** at least twice (feed update from console edit, and application status update across roles)?
- [ ] Did I name at least one **debugging story** and at least one **known limitation** unprompted, rather than only showing the happy path?
- [ ] Did I explicitly say how the app **scales** and where it currently **wouldn't** scale yet?
- [ ] Did I explain **state management** by pointing at actual provider code, not just saying "I used Riverpod"?
- [ ] Is the delivery structured (intro → architecture → backend → state → workflows → trade-offs → close) rather than a meandering click-through?
