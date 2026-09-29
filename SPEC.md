# Autochrome — Build Specification

> Portfolio app 140, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Save a warm moment with a feeling, then open a past pane that matches today's emotion.

| Field | Value |
| --- | --- |
| Product name | Autochrome |
| Bundle identifier | `com.autochrome.strip` |
| Domain | https://autochrome-strip.pro |
| Contact URL | https://autochrome-strip.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Light |
| Asset prefix | `aut_` |
| User-Agent | `Autochrome/1.0 (iOS; +https://autochrome-strip.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Autochrome -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A keeper seats today's warm moment on the filmstrip so a hue-matched stained-glass pane can flare a past moment back.

### 2.1 User flow

1. On Moments, tap the already-lit pane whose hue matches today's seated frame so Flare stages that past moment.
2. Seat a new Frame by picking an emotion chip and optionally attaching a photo or short voice clip.
3. Develop cuts today's Frame into a Pane on the SceneKit mosaic and freezes its media.
4. Open Garden as a sheet to walk the mosaic of Panes and count FlareMarks.
5. Open Settings as a sheet to reset local data or adjust emotion labels.

### 2.2 Essential behaviour

- Filmstrip home that never leaves; Garden and Settings only as sheets
- Seat writes a Frame with emotion plus optional on-device photo or voice
- Develop cuts a Frame into a Pane on a SceneKit stained-glass mosaic and freezes media
- Flare lights only Panes whose emotion equals today's Frame; tap writes FlareMark; miss writes DimMark
- UserDefaults+Codable strip root; daykey Int YYYYMMDD; no network catalog; leftover scanner and cgi search unused

---

## 3. Uniqueness assignment for Autochrome

| Axis | Assigned value |
| --- | --- |
| Architecture | **Frame ADT fold (Bare | Seated | Cut); the strip is a fold over Frames; Seat writes a Frame with an emotion and optional media and folds Bare to Seated; Develop writes a Pane on the mosaic, freezes media, and folds Seated to Cut; Flare lights Panes whose emotion equals today's Frame; tapping a lit Pane writes a FlareMark and stages that past moment; a miss writes a DimMark and keeps the light; Flare on Bare is refused; Develop on Bare is refused; a second Seat while Seated is refused; empty strip writes Blank** |
| UI approach | **SwiftUI SceneKit integration · realitykit-lite** |
| Naming convention | **Autochrome / filmstrip lexicon** |
| File organization | **By strip role (Strip, Frame, Pane, FlareMark, DimMark)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **miro · filmstrip · duotone** |
| Typography | **Avenir Next** |
| Navigation pattern | **Strip-locked chrome (the filmstrip never leaves; Garden and Settings arrive as sheets; seat and flare fuse on Moments)** |
| AI art style | **Stained glass mosaic · tactile** |
| Functional twist | **Hue-then-flare (Seat writes a Frame; Develop cuts a Pane; Flare lights only same-emotion Panes; a lit tap writes a FlareMark; a miss writes a DimMark; Flare on Bare is refused)** |
| Persistence | **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — warm_moments

**Core** — A keeper seats today's warm moment on the filmstrip so a hue-matched stained-glass pane can flare a past moment back.

**Audience** — People who want private good days with emotion, photo or voice, and a stained-glass garden that only lights matching hues — not a social feed and not a year mood grid.

**User flow**

1. On Moments, tap the already-lit pane whose hue matches today's seated frame so Flare stages that past moment.
2. Seat a new Frame by picking an emotion chip and optionally attaching a photo or short voice clip.
3. Develop cuts today's Frame into a Pane on the SceneKit mosaic and freezes its media.
4. Open Garden as a sheet to walk the mosaic of Panes and count FlareMarks.
5. Open Settings as a sheet to reset local data or adjust emotion labels.

**Essential features**

- Filmstrip home that never leaves; Garden and Settings only as sheets
- Seat writes a Frame with emotion plus optional on-device photo or voice
- Develop cuts a Frame into a Pane on a SceneKit stained-glass mosaic and freezes media
- Flare lights only Panes whose emotion equals today's Frame; tap writes FlareMark; miss writes DimMark
- UserDefaults+Codable strip root; daykey Int YYYYMMDD; no network catalog; leftover scanner and cgi search unused

**Twist** — Hue-then-flare. Home is the filmstrip. Seat writes a Frame with an emotion and optional local photo or voice. Develop cuts that Frame into a Pane on the SceneKit garden mosaic and freezes its media. Flare lights only Panes whose emotion equals today's Frame; tapping a lit Pane writes a FlareMark and stages that past moment. Tapping an unlit Pane writes a DimMark and keeps the light. Flare on Bare is refused. Develop on Bare is refused. A second Seat while Seated is refused. Seed already Seats one Frame and Develops one matching Pane plus one other-emotion Pane, so the opening Flare can land. Home verb: flare-the-pane — not catch-the-glow and not draw-a-random-ray. Garden counts Panes and FlareMarks. Local only.

**Why this is not a repeat** — Not Aedicule: home verb is flare-the-pane under hue equality, not catch-then-Draw a random Wick/Capsule. No midnight Live→Wick or 30-day Capsule bloom. Revisit is constrained light on a SceneKit mosaic, not niche coverflow sampling. Chrome is strip-locked sheets, not niche segments. Closed leftovers (miro filmstrip duotone, stained glass · tactile, SceneKit · realitykit-lite) are unused by Aedicule and avoid the operator-ugly chalkthread/pendilia looks.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Coverflow of moments. Ray from the past.
- Invariant: Emotion color + optional local photo/voice. Ray = random moment not today. Year collage. Capsules = moments >30d.
- Never: No Drift lantern game. Garden tab is the living garden.
- Desk `film_meter_chain`: EV=log2(N²/t); reciprocity t'=t^exp; dev t*q10^((Tref−T)/10)*push^stops, clamp 30–3600s.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

The strip is a fold over Frames, each Frame an ADT in Bare, Seated, or Cut, and an empty strip writes Blank. Seat from Blank or Bare writes a Frame with one emotion id plus optional on-device photo or voice and folds to Seated, while a second Seat while Seated is refused. Develop writes a Pane on the mosaic, freezes that media, and folds Seated to Cut, and Develop on Bare is refused. Flare, allowed while Seated or Cut, lights only Panes whose emotion id equals today's Frame, a lit tap writes a FlareMark and stages that past moment, a miss writes a DimMark and keeps the light, and Flare or Develop on Bare or Blank is refused. A unit test locks hue equality on the emotion id, the optional local photo or voice, and those refusals, including a renamed label that still matches.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

SwiftUI hosts one SceneKit hero on Moments: a single SCNView of the stained-glass pane mosaic, which is the filmstrip playhead and fills the remaining height, including on iPad. Seat, Develop, and Flare are native SwiftUI buttons on that same screen, the whole control inside the label with contentShape and at least 44 points. RealityKit stays lite on that one hero only: no AR view, no world tracking, and no camera, one shared physically based glass material feeding the SceneKit panes. Garden and Settings are stock sheets of List, Form, and Button. There is no second custom surface, no WebView, and no TabView. Primary actions use the soft card control, radius 18 on surfaces and 8 on chips, material elevation. Grouped reveals step 40 to 60 milliseconds and cap at 360 milliseconds. Reduce Motion fades the group in at once. One haptic fires on a successful Seat, Develop, or Flare, and none on opening a sheet. Icon-only controls have VoiceOver labels. If a voice clip needs a system permission dialog, the button before it reads Continue or Next.

### 3.3 Naming contract

Convention: Autochrome / filmstrip lexicon.

Examples to follow: `StripFold`, `Pane`, `flareLitPane(_:)`, `DimMark`

### 3.4 Dependency contract

No Swift packages, no CocoaPods, and no vendored source. The only extra system frameworks are UIKit to host the SceneKit view, Core Graphics, AVFoundation, and URLSession. AVFoundation records and plays the short on-device voice clip and does not run a metadata capture session. URLSession stays unused because there is no network catalog and no cgi search. A photo attaches through the system photo picker. This product does not use the camera.

### 3.5 Navigation contract

Moments is the only root, and the filmstrip never leaves. There is no tab bar. Garden and Settings arrive as sheets over Moments. Seat, Develop, and Flare fuse on Moments. Read ProcessInfo arguments once, after onboarding is complete. The launch key today opens Moments, log opens the Garden sheet, and goals opens the Settings sheet, three different screens.

### 3.6 Screen composition contract

Strip-root fused moments (Moments holds the filmstrip and fused seat, develop, and flare; Garden and Settings arrive as sheets; no tab bar). Physical screens: Moments, Garden, Settings. Onboarding is three or four full pages with a full-width Continue at the bottom, then it writes the completion flag. Moments is the home mechanic: the filmstrip runs edge to edge, the SceneKit mosaic uses the remaining height, and the background fills the safe area. Blank is a full page with generated art, the headline Nothing saved yet, the line Seat a warm moment, and a full-width Seat button. Garden is a sheet that walks the panes and counts Panes and FlareMarks through NumberFormatter, with its own full-page empty state. Settings is a sheet for emotion labels, a confirmed reset that names the strip and erases moments on this device, re-running onboarding, and the contact link https://autochrome-strip.pro/contact-us. The simulator seed aut.demo.v1 runs once, marks onboarding complete, seats one Frame, and develops one matching Pane plus one other-emotion Pane so Flare is enabled. It never runs on a device.

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By strip role (Strip, Frame, Pane, FlareMark, DimMark)**

```
Autochrome/
  Strip/StripFold.swift
Strip/Frame.swift
Strip/Pane.swift
Strip/FlareMark.swift
Strip/DimMark.swift
Moments/MomentsView.swift
Moments/SceneMosaic.swift
Garden/GardenSheet.swift
Settings/SettingsSheet.swift
Store/StripStore.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Moments
A first-class screen for **Moments**. Must render empty, populated and error states.

### 5.3 Garden
A first-class screen for **Garden**. Must render empty, populated and error states.

### 5.4 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.5 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.6 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Moment** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **miro · filmstrip · duotone**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#EFE7EB` | Screen background |
| `surface` | `#F6F3F3` | Cards, rows, sheets |
| `ink` | `#29151F` | Primary text and icons |
| `accent` | `#C2292E` | Primary action, key figure, progress fill |
| `muted` | `#6D5561` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Autochrome/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **Avenir Next**

Avenir Next is the only family, through one Font accessor and six steps: display, title, headline, body, caption, and micro. The type move is soft geometric UI type with one playful moment and no serif. Avenir Next Heavy is that single short display word on the filmstrip, usually one or two lines. Avenir Next Demi Bold is titles, Medium is labels, and Regular is body at the 17 point step. Pane counts, FlareMark counts, and the daykey go through NumberFormatter. Every step uses ScaledMetric and Dynamic Type so headlines stay unclipped at the largest accessibility size. Day edges pass through Calendar.current.startOfDay before they become a YYYYMMDD Int.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **material** — SwiftUI `Material` (`.regularMaterial` / `.thinMaterial`), reused everywhere a surface sits above another.

Primary control: **soft card** — primary actions live inside a rounded card using the radius below, not a flat row with no fill.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI SceneKit integration · realitykit-lite**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI SceneKit integration · realitykit-lite** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **agency** (High-end agency: huge type, air, one accent, hairline depth.)

Reference system: **miro** — steal rhythm and restraint, not their colours or logos.

Mood: **Visual collaboration. Bright yellow accent, infinite canvas aesthetic.**.

Home rhythm (`filmstrip`, comfortable): A strip of frames, the playhead is the verb.

High-end agency: huge type, air, one accent, hairline depth. Layout `filmstrip`, density comfortable. Kit 18/8, material, soft card. Palette recipe `duotone`. Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Soft rounded UI type, one playful moment, no serif. Reference type feel: agency.

Motion (`stagger`): Grouped reveals step 40-60ms, cap 360ms total. Last item must not arrive late. Reduce Motion: the group appears at once.

Voice (`warm`): Human and brief. Empty states invite. Errors stay calm and useful.

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- The app is portrait-only on iPhone. Lock it in the Info settings and do not
  write rotation-dependent layout.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Chart root record holding Islands, Books, Sessions, Runs and Rhumbs, encoded under a single key with a debounced save after each mark**

UserDefaults holds one Codable root, StripRecord, under the single key aut.strip.v1, with schemaVersion 1. StripRecord holds the fold, the Frames, the Panes, the FlareMarks, the DimMarks, and the emotion labels. Today's hue comes from the Frame whose daykey equals today, the latest if several share that day. Each Seat, Develop, FlareMark, or DimMark schedules one debounced save about 400 milliseconds after the last mark, with an immediate flush when scenePhase leaves active and after reset. A mark stores its day as an Int in YYYYMMDD form from Calendar.current.startOfDay. Frozen photo and voice bytes are atomic files in Application Support named by Pane id, and the root stores only relative paths. Screens read and write only through StripStore. resetAllData deletes that key and those media files. If decoding fails, the strip starts Blank instead of crashing. The simulator seed aut.demo.v1 is a separate key and never writes on a device.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Autochrome/1.0 (iOS; +https://autochrome-strip.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.

---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- Portrait only, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.lifestyle`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Light
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.lifestyle
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Hue-then-flare (Seat writes a Frame; Develop cuts a Pane; Flare lights only same-emotion Panes; a lit tap writes a FlareMark; a miss writes a DimMark; Flare on Bare is refused)

Hue-then-flare is the persisted home verb: only Panes whose emotion id equals today's Frame light, a lit tap writes a FlareMark and stages that past moment, and a miss writes a DimMark without changing the light. Seat writes the Frame with an emotion and optional local photo or voice, and Develop cuts it into a Pane and freezes the media. Flare on Bare is refused, Develop on Bare is refused, and a second Seat while Seated is refused. The simulator seed seats one Frame and develops one matching Pane plus one other-emotion Pane so the opening Flare is enabled, and Garden counts Panes and FlareMarks. The unit-tested revisit rule is that hue equality, with emotion plus optional local photo or voice kept on device, in place of a random past draw, a year collage, or a 30-day capsule.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Stained glass mosaic · tactile**


Base prompt, reused and extended for every asset:

```
Tactile stained-glass mosaic, thick lead cames, hand-cut glass with real thickness and a slightly uneven surface, light passing through solid panes, physical and touchable, studio still life, no text, no letters, no logos, no interface chrome.
```

All 12 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `aut_` prefix.

### 13.1 App icon rules (strict)

The icon is rejected by App Store Connect if any of these are wrong:

- Exactly **1024 x 1024 px**.
- **No alpha channel.**
- sRGB colour profile, 8 bits per channel, PNG.
- **No text and no words** in the artwork.
- **No rounded corners and no built-in mask.**
- The subject stays inside the middle 80%.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `aut_AppIcon` | 1024x1024 | **NO** | App Store icon. NO alpha channel, NO transparency, NO text, NO rounded corners, NO drop shadow outside the canvas. |
| 2 | `aut_Splash` | 1290x2796 | fill | Launch background. The middle third must stay quiet so the wordmark reads on top. |
| 3 | `aut_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 4 | `aut_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 5 | `aut_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 6 | `aut_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 7 | `aut_EmptyList` | 1024x1024 | **required cutout** | Empty state: a secondary list has no rows. |
| 8 | `aut_CardBackdrop` | 1200x800 | fill | Backdrop art for a primary card. Low contrast so text stays readable. |
| 9 | `aut_ControlFace` | 512x512 | **required cutout** | Custom control artwork used for the primary interactive element. |
| 10 | `aut_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Hue-then-flare (Seat writes a Frame; Develop cuts a Pane; Flare lights only same-emotion Panes; a lit tap writes a FlareMark; a miss writes a DimMark; Flare on Bare is refused)' feature screen. |
| 11 | `aut_SuccessMark` | 512x512 | **required cutout** | Shown briefly when the primary action succeeds. |
| 12 | `aut_HeaderDecor` | 1200x600 | **required cutout** | Decorative header accent on the main screen. |

### Prompt per asset

**`aut_AppIcon`** — 1024x1024

```
A single solid stained-glass mosaic emblem filling the canvas edge to edge, thick lead cames, tactile glass thickness, no text, no letters, no rounded mask, no transparency.
```

**`aut_Splash`** — 1290x2796

```
A vertical stained-glass mosaic field filling the canvas, tactile leaded panes, a quiet uncluttered centre band, no text, no letters.
```

**`aut_Onboarding1`** — 1024x1536

```
A solid filmstrip frame holding one seated pane, tactile stained glass, isolated subject centred, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_Onboarding2`** — 1024x1536

```
A hand-like glass form seating one pane into a mosaic, mid gesture, tactile lead cames, isolated subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_Onboarding3`** — 1024x1536

```
Two solid glass panes side by side, one lit and one quiet, tactile thickness, isolated subjects, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_EmptyHome`** — 1024x1024

```
A solid folded cloth bundle, fully opaque, centred and waiting, isolated subject, no hollow centre, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_EmptyList`** — 1024x1024

```
A solid empty lead tray with no panes in it, opaque, isolated subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_CardBackdrop`** — 1200x800

```
An abstract leaded mosaic filling the canvas, low detail, quiet centre so type can sit on it, no text, no letters.
```

**`aut_ControlFace`** — 512x512

```
One tactile glass pane shaped as a control face, solid centre, thick edges, isolated, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_TwistHero`** — 1024x1024

```
One solid stained-glass pane caught mid flare, thick lead came, isolated subject, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_SuccessMark`** — 512x512

```
A small solid glass tessera as a confirmation emblem, tactile, isolated, no text, no letters.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`aut_HeaderDecor`** — 1200x600

```
A wide horizontal ornament of leaded mosaic pieces, tactile, isolated band, no text.

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`aut.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `AutochromeTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Autochrome/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Autochrome -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.

**Uniqueness**
- [ ] Architecture matches **Frame ADT fold (Bare | Seated | Cut); the strip is a fold over Frames; Seat writes a Frame with an emotion and optional media and folds Bare to Seated; Develop writes a Pane on the mosaic, freezes media, and folds Seated to Cut; Flare lights Panes whose emotion equals today's Frame; tapping a lit Pane writes a FlareMark and stages that past moment; a miss writes a DimMark and keeps the light; Flare on Bare is refused; Develop on Bare is refused; a second Seat while Seated is refused; empty strip writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI SceneKit integration · realitykit-lite**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Strip-locked chrome (the filmstrip never leaves; Garden and Settings arrive as sheets; seat and flare fuse on Moments)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **Avenir Next** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Autochrome
xcodegen generate
xcodebuild build-for-testing -scheme Autochrome -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.autochrome.strip/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Autochrome -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.autochrome.strip/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Autochrome -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.autochrome.strip/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
