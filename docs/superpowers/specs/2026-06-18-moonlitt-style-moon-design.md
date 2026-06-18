# Moonlitt-Style Moon Redesign

## Scope

Redesign only the moon presentation on `MoonPhaseDetailView`. The daily story screen and its existing artwork remain unchanged.

## Visual Target

The approved direction combines:

- the centered, restrained composition of “Orbital Portrait”;
- the crater relief and terminator detail of “Terminator Close-up”;
- sparse stars, very low-volume edge clouds, and restrained blue moon glow.

The result should feel close to the supplied Moonlitt reference: realistic, cinematic, cool-toned, and atmospheric. It must not become a generic glowing sphere.

## Astronomy Requirements

- The illuminated fraction and waxing/waning orientation must continue to derive from `MoonPhaseSnapshot.cycleProgress`.
- The moon remains a real-time 3D object rather than a static phase image.
- Lighting must produce a physically plausible terminator for every date.
- Visual polish may lift near-black detail but must not change the apparent lunar phase.

## Moon Rendering

`MoonSceneKitMoonView` remains the rendering boundary.

- Use the existing LROC color texture and lunar elevation map.
- Tune camera scale, material response, displacement, contrast, and light placement to expose maria and crater relief.
- Use directional sunlight so the terminator reads consistently across the sphere.
- Keep the dark hemisphere nearly black with only enough ambient lift to retain spherical depth.
- Add a narrow cool-white limb treatment without washing out the illuminated surface.
- Preserve subtle device-motion parallax and ensure motion updates are installed only once.

## Atmospheric Frame

Atmosphere belongs to the SwiftUI detail-screen layer, behind the SceneKit moon:

- deep blue-black vertical and radial gradients;
- sparse deterministic stars;
- soft, low-opacity cloud wisps confined to side and lower edges;
- restrained halo centered behind the moon.

Clouds must never obscure the lunar disk. The atmosphere must remain visually subordinate to lunar phase accuracy and surface detail.

## Layout

- Keep the moon fully visible and centered in the upper content region.
- Increase its visual presence without crowding the date header or phase title.
- Preserve the existing typography, metrics, scrolling behavior, and accessibility identifiers.
- Do not add controls, navigation, or unrelated UI.

## Runtime and Failure Handling

- Bundle texture loading remains local and deterministic.
- If a texture cannot load, SceneKit still renders a neutral gray moon rather than an empty view.
- Stop Core Motion updates when the view/coordinator is released.
- Avoid per-frame object creation and repeated motion callback installation.

## Verification

1. Build and run on the configured iPhone simulator.
2. Capture the detail view at representative new, quarter, full, and waning phases.
3. Compare the first-quarter capture against the approved visual target at the same viewport and state.
4. Verify:
   - illuminated side and fraction are correct;
   - crater detail and terminator remain visible;
   - glow is narrow and cool;
   - clouds do not cover the moon;
   - text and metrics retain their hierarchy;
   - scrolling and device-motion behavior remain stable.
5. Run existing unit and UI tests relevant to the lunar phase detail flow.

## Non-Goals

- Replacing the story-page moon artwork.
- Adding a live weather system.
- Copying Moonlitt branding, text, or proprietary assets.
- Trading astronomical accuracy for a more dramatic static silhouette.
