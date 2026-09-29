# Autochrome

Autochrome is a private filmstrip for warm days. You seat today's moment with an emotion and an optional photo or voice clip, develop it into a stained-glass pane, then flare a past pane only when its emotion matches today's frame. It is for people who want those days on the device, not a social feed and not a year mood grid.

## Architecture

The strip is a fold over frames. Each frame is an ADT: seated after Seat, cut after Develop. An empty strip is blank, and a day with no frame of its own is bare. Seat writes one emotion id plus optional local media and folds blank or bare to seated. A second seat while seated is refused. Develop writes a pane, freezes the media paths, and folds seated to cut. Develop on bare is refused. Flare, while seated or cut, lights only panes whose emotion id equals today's frame. A lit tap writes a flare mark and stages that past moment. A miss writes a dim mark and leaves the light alone. Flare on bare is refused.

That fold fits this product because the home verb is a state change on one day, not a list append. The UI reads the phase and calls `StripStore`, which is the only seam to the UserDefaults record and the media files.

## Why someone would keep it

Hue-then-flare is the reason to open Autochrome. Home is the filmstrip. Matching panes light. Tapping a lit pane stages that moment. Tapping a quiet pane records a dim mark and the lit panes stay lit. Garden counts panes and flare marks. Nothing is uploaded.

## Art

Style: tactile stained-glass mosaic, thick lead cames, hand-cut glass, no text.

Shared base: "Tactile stained-glass mosaic, thick lead cames, hand-cut glass with real thickness and a slightly uneven surface, light passing through solid panes, physical and touchable, studio still life, no text, no letters, no logos, no interface chrome."

- `aut_AppIcon`: A single solid stained-glass mosaic emblem filling the canvas edge to edge, thick lead cames, tactile glass thickness, no text, no letters, no rounded mask, no transparency.
- `aut_Splash`: A vertical stained-glass mosaic field filling the canvas, tactile leaded panes, a quiet uncluttered centre band, no text, no letters.
- `aut_Onboarding1`: A solid filmstrip frame holding one seated pane, tactile stained glass, isolated subject centred, no text.
- `aut_Onboarding2`: A hand-like glass form seating one pane into a mosaic, mid gesture, tactile lead cames, isolated subject, no text.
- `aut_Onboarding3`: Two solid glass panes side by side, one lit and one quiet, tactile thickness, isolated subjects, no text.
- `aut_EmptyHome`: A solid folded cloth bundle, fully opaque, centred and waiting, isolated subject, no hollow centre, no text.
- `aut_EmptyList`: A solid empty lead tray with no panes in it, opaque, isolated subject, no text.
- `aut_CardBackdrop`: An abstract leaded mosaic filling the canvas, low detail, quiet centre so type can sit on it, no text, no letters.
- `aut_ControlFace`: One tactile glass pane shaped as a control face, solid centre, thick edges, isolated, no text.
- `aut_TwistHero`: One solid stained-glass pane caught mid flare, thick lead came, isolated subject, no text.
- `aut_SuccessMark`: A small solid glass tessera as a confirmation emblem, tactile, isolated, no text, no letters.
- `aut_HeaderDecor`: A wide horizontal ornament of leaded mosaic pieces, tactile, isolated band, no text.

## How this differs

Home verb is flare-the-pane under hue equality. Revisit is constrained light on one SceneKit mosaic. Garden and Settings are sheets. The filmstrip never leaves. There is no three-tab bar, no random past draw, and no year grid.

## Build

```
xcodegen generate
xcodebuild build-for-testing -scheme Autochrome -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

No Swift packages. System frameworks only.
