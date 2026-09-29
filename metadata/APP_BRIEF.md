<!-- gf-brief source=a5c7e28b4be5eb1f4a94f164bca7ab6e8dd09cbbf2d7ecf61870937e46961fc3 written=2026-09-29T19:15:29+03:00 -->
# Autochrome

## What it is
Autochrome is a private daily journal for one warm moment at a time. You save today with a feeling, and you can attach a photo or a short voice clip, then keep that day with the others. It is for someone who wants matching days to stand out on this device, not a social feed.

## Launch and onboarding
Cold launch shows a system launch screen with no words, then a brief empty screen.

On a device that has not finished the introduction, three pages appear. Each page has an illustration with no words, a title, a line of body copy, page dots, a primary button, and **Skip**.

1. **Good days, kept close** — “Save today's warm moment with a feeling, a photo, or a short voice clip.” Primary button: **Next**. Also **Skip**.
2. **Days you can look back on** — “Keeping a day puts it with the others.” Primary button: **Next**. Also **Skip**.
3. **Open a matching day** — “Only days that share today's feeling stand out. Tap one to open it.” Primary button: **Continue**. Also **Skip**.

**Next** moves to the following page. **Continue** on the last page, or **Skip** on any page, ends the introduction and opens the home screen.

If the introduction was already finished, launch goes straight to home.

## Screens

### Home (called Moments)
There is no tab bar. After the introduction, this is the main screen. **Garden** and **Settings** are only on this screen once at least one moment has been saved (the first-save empty page does not show them).

**Empty home** (nothing saved yet):
- Title: **Nothing saved yet**
- Line: **Save a warm moment**
- **Save this moment** opens the save form on this page. It does not save until you tap **Save this moment** on the form.

**Home after something is saved**:
- A large verb at the top: **Save**, **Keep**, or **Open**, plus a line of guidance.
- A row of glass days. Days that share today’s feeling stand out. VoiceOver names a matching day “{feeling}, matches today” and a quiet day by the feeling name alone.
- **Garden** opens the Garden sheet.
- **Settings** opens the Settings sheet.
- Status lines can appear under the glass row (quoted under Features and Behaviours).
- A small glass confirmation mark can flash after a successful save, keep, or matching open. It has no words.

Guidance and controls by state:

- New day, with kept days already on the row: **Save** / “Save today, then keep it with your other days.” **Save today** shows or hides the save form.
- Today saved, and no kept day shares that feeling: **Keep** / “Keep this day so a matching one can stand out.” **Keep this day** puts today with the others.
- Today saved or kept, and at least one kept day shares that feeling: **Open** / “Today is {feeling}. Tap that day to open it.” (or “Tap the day that matches today.” if the name is missing). **Open {feeling}** opens the first matching day. **Keep this day** is not shown in this state.
- Empty home uses the empty page above, not this header.

**Save form** (title **Save a moment**):
- Feeling chips (starter names): **Amber**, **Harbor**, **Linen**, **Grove**. The first chip starts selected. Tap a chip to choose today’s feeling. Renamed names appear here instead.
- **Attach photo** opens the system photo picker. After a photo is chosen it reads **Photo attached**.
- **Add voice** starts the voice steps below. After a clip is taken it reads **Voice attached**.
- **Save this moment** saves today with the chosen feeling and any photo or clip. While work is in progress it reads **Saving** and will not take another tap.

Voice steps on the form:
- After **Add voice**: “A short voice clip stays on this device.” and **Continue**. **Continue** is the only in-app control before the system microphone dialog.
- While recording: **Stop voice** finishes the clip.
- If the microphone is off: “Voice stays off. Open Settings if you want a clip later.” and **Open Settings** (device Settings).

Tapping a glass day:
- If today is not saved yet: “Save today before a past day can open.”
- If the day shares today’s feeling: “{feeling} is open again.” (or “That moment is open again.” if the name is missing). This stays on home. It does not open Garden.
- If the day does not share today’s feeling: “That day does not match today.”

**Could not read** page (saved data did not open):
- **Saved moments could not be read**
- “They did not open, so this screen started empty.”
- **Try again** reloads saved moments.

### Garden
Sheet from **Garden**. Navigation title: **Garden**. Trailing **Close** (X) dismisses it and returns to home.

When there are kept days:
- **Past moments**
- “Open a saved day to read it.”
- A list, newest first. Each row shows the feeling name, **Saved {date}** (English month, day, year, for example **Saved Sep 26, 2026**), and **Open this moment**. Tap the row to open that Moment.

When nothing has been kept:
- **Nothing saved yet**
- “Keep today's moment and it will show up here.”
- **Back to Moments** dismisses Garden.

When the last write did not land:
- **Garden could not save**
- “The last write did not land on this device.”
- **Try again** retries the write.

### Moment
Sheet from a Garden row. Navigation title: **Moment**.
- The feeling name
- **Saved {date}**
- “This is the moment saved from that day.”
- If a photo was saved: “A photo is saved with this moment.” The photo is not shown.
- If a voice clip was saved: “A voice clip is saved with this moment.” There is no play control.
- **Close** closes Moment and leaves Garden open.

### Settings
Sheet from **Settings**. Navigation title: **Settings**. Trailing **Close** (X) dismisses it and returns to home.

Usual form:
- Section **Emotion labels**: a text field for each feeling (starter names **Amber**, **Harbor**, **Linen**, **Grove**), and **Save labels**. Keyboard **Done** saves that field. Empty or space-only names are ignored.
- Section **On this device**:
  - **Show introduction again** closes the working app into the three introduction pages. Saved days stay. **Skip** or **Continue** returns to home.
  - **Erase saved moments** opens a confirmation.
- Section **Contact**: **Contact Autochrome** opens the support page.
- If the last save did not land: “The last save did not land.” and **Try again**.

Erase confirmation:
- Title: **Erase saved moments?**
- “This removes every saved moment on this device, then opens the introduction again.”
- **Erase moments on this device** clears every saved moment and photo and voice clip on this device, restores the starter feeling names, and shows the introduction.
- **Keep moments** cancels.

If feeling names are missing:
- **No emotion labels**
- “Erase saved moments to restore the starter names.”
- **Erase saved moments** (same confirmation).

If Settings cannot load:
- **Settings could not load**
- “The saved file did not open.”
- **Try again** reloads.

## Features
- Save one warm moment for today with a feeling
- Feeling names **Amber**, **Harbor**, **Linen**, **Grove**, which you can rename
- Optional photo on a moment
- Optional short voice clip on a moment
- Keep this day so it joins the other days
- Glass row of kept days; only days that share today’s feeling stand out
- Open a matching day from the glass row or **Open {feeling}**
- Garden list of every kept day, newest first
- Read a saved Moment from Garden
- Show the introduction again without erasing
- Erase every saved moment on this device
- Contact Autochrome
- Work stays on this device (on-screen copy says so for voice, erase, and failed writes)

## Behaviours that can look like bugs
- **Nothing saved yet** / **Save a warm moment** is the first home. **Garden** and **Settings** are not on this page. Save a moment to reach them.
- On empty home, the first **Save this moment** only opens the form. Save by tapping **Save this moment** on the form (a feeling is already selected).
- You can save only one moment per local calendar day. After today is saved, **Save today** is gone. If a second save is refused, the line is “Today is already saved. Keep it before saving another.” After today is kept: “Today is already kept. Open the matching day.”
- **Keep this day** appears only when today is saved and no kept day shares that feeling. If a past day already uses that feeling, the screen switches to **Open** / **Open {feeling}** and there is no **Keep this day** control. To keep a day from home, choose a feeling that no kept day uses, or keep the first day before any match exists. Garden only lists days you have kept.
- On a new day, the glass row is visible but taps say “Save today before a past day can open.” Save today first. Then only matching days open; a miss says “That day does not match today.”
- Opening a matching day from the glass row or **Open {feeling}** does not leave home. It only shows “{feeling} is open again.” Use Garden to read a Moment page.
- Garden can still say **Nothing saved yet** after you have saved today but have not kept a day. **Keep this day** (when it is shown), then open Garden again. **Back to Moments** returns home.
- A photo or voice clip is not shown or played later. Moment only states that they were saved.
- **Add voice** always shows **Continue** first. The system microphone dialog appears only after **Continue**. If access is off, use **Open Settings**. You can still save the moment without a clip.
- **Save this moment**, **Keep this day**, and **Open {feeling}** dim and ignore taps while work is in progress. The save control reads **Saving**.
- Other refusal or failure lines: “Save a moment before you keep it.” / “Today is already kept.” / “Pick one of the feelings.” / “That moment is no longer saved.” / “This moment was not saved. Try again.” / “This day was not kept. Try again.” / “That moment did not open. Try again.”
- Feeling rename: a blank name does not save. Edits need **Save labels** or keyboard **Done**. Closing Settings without that keeps the old names.
- **Show introduction again** is meant to replay the three pages. **Erase saved moments** asks first; confirming wipes the device copy and returns to the introduction.
- After local midnight, an unkept today is no longer “today” and never appears in Garden. Home asks you to save the new day.
- **Saved moments could not be read** / **Settings could not load** / **Garden could not save** / “The last save did not land.” use **Try again**, or erase and start over if Settings offers that.

## Starter content and resume
Starter feeling names: **Amber**, **Harbor**, **Linen**, **Grove**.

On a physical device there are no sample days. Home is empty until you save.

On the Simulator only, four kept days are created once and the introduction is skipped: Harbor three days ago, Linen two days ago, Grove yesterday, Amber today. Home opens on **Open** / “Today is Amber. Tap that day to open it.” / **Open Amber**. Garden lists those four days.

Resume: kept days return after you leave and come back. Today’s saved-but-not-kept moment returns until local midnight. A photo or voice chosen on the form but not saved does not return. Feeling-name drafts that were not saved do not return.

## Permissions
Microphone, only after **Add voice** then **Continue**. Usage description: “A short voice clip stays on this device with the moment you save.”

Photo uses the system photo picker after **Attach photo**. The app does not show its own photo-permission screen and has no photo usage string.

No camera, photos-library, location, or tracking permission strings.

## Absent
Login or accounts, in-app purchase, ads, analytics, a public or shared feed of user-generated content, account deletion flow, App Tracking Transparency prompt.

## Data and support
Saved moments, photos, and voice clips stay on this device. Erase copy and the voice line say so.

Support control: **Contact Autochrome** in Settings.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
English copy only. “Today” follows the device’s local calendar day. Garden dates use an English month-day-year line.

Portrait only, on iPhone and iPad. Light appearance only. Requires the full screen on iPad. Minimum iOS 17.0.

## Category
Lifestyle
