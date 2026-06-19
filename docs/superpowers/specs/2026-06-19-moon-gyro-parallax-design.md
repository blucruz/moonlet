# Moon Gyroscope Parallax Design

## Scope

Add subtle device-motion parallax to the existing 3D moon on the lunar detail screen. Do not change lunar phase lighting, camera composition, atmosphere, typography, metrics, or calendar behavior.

## Interaction

- When the lunar detail screen appears, the current device attitude becomes the neutral center.
- Subsequent phone tilt rotates the moon in the opposite direction, creating a window-like parallax effect.
- Pitch controls the moon's vertical rotation and roll controls its horizontal rotation.
- Horizontal rotation is limited to approximately `±4°`.
- Vertical rotation is limited to approximately `±3°`.
- Small hand tremors inside a dead zone do not move the moon.
- Motion is low-pass filtered so the moon settles smoothly instead of tracking sensor noise directly.
- Response eases near the neutral position, giving the moon a restrained sense of weight without spring overshoot.
- Translation, zoom, and phase geometry remain unchanged.
- The moon and its phase lights share the same parallax transform so the
  visible terminator and surface shadows move consistently with the sphere.

## Motion Model

`MoonMotionController` owns sensor acquisition and relative-attitude calibration.

1. Start device-motion updates when the SceneKit view attaches.
2. Save the first valid pitch and roll as the neutral attitude.
3. Calculate wrapped angular deltas from that neutral attitude.
4. Apply a small dead zone.
5. Clamp each delta to the configured maximum input range.
6. Normalize the clamped delta with a gentle ease-out curve near center.
7. Map roll to `±4°` horizontal rotation and pitch to `±3°` vertical rotation.
8. Smooth the mapped result before sending it to the SceneKit coordinator.

The callback exposes only the final parallax rotation values. The SceneKit view must not interpret raw accelerometer values.

## SceneKit Integration

- Preserve the moon's existing base orientation and phase-light positions.
- Put the moon, key light, and rim light under a shared parallax node.
- Apply parallax as a small offset to that shared node.
- Reverse both axes relative to device tilt.
- Keep the Z rotation fixed so the moon does not appear to spin like a flat card.
- Modulate only the rim-light intensity by at most `±5%` from its base value,
  using horizontal parallax as the input.
- Do not modulate the key light, ambient light, or illuminated fraction.
- Start motion once per coordinator attachment and stop updates when the view is dismantled.
- Reset calibration when a new detail-screen instance starts.

## Constants

- Maximum horizontal rotation: `4°`.
- Maximum vertical rotation: `3°`.
- Dead zone: approximately `0.5°` of device attitude change.
- Full-input tilt range: approximately `15°`.
- Smoothing factor: tuned for a restrained response, initially `0.12` per update at 60 Hz.
- Rim-light variation: no more than `5%` from its base intensity.

These values may be adjusted slightly during physical-device verification, but horizontal rotation must remain at or below `4°`, vertical rotation at or below `3°`, and rim-light variation at or below `5%`.

## Fallback Behavior

- If device motion is unavailable, the moon remains at its base orientation.
- Simulator behavior remains static because it does not provide normal physical gyroscope input.
- Stopping and restarting the view creates a fresh neutral calibration.

## Verification

1. Add unit tests for angle wrapping, dead-zone behavior, reverse mapping,
   eased center response, the `±4°` horizontal limit, the `±3°` vertical
   limit, and the `±5%` rim-light limit.
2. Run all existing unit and UI tests.
3. Verify on a physical iPhone:
   - opening the screen does not cause an initial jump;
   - tilting right makes the moon rotate left;
   - tilting forward makes the moon rotate backward;
   - normal hand tremor is not visible;
   - horizontal motion never exceeds approximately `4°`;
   - vertical motion never exceeds approximately `3°`;
   - motion settles gently near center without bounce;
   - the key and rim lights follow the same parallax transform;
   - rim-light intensity changes are subtle and never exceed `5%`;
   - the illuminated fraction remains unchanged while the terminator follows
     the rotated sphere.

## Non-Goals

- Moving the stars or clouds with device motion.
- Translating or zooming the moon.
- Adding inertial spinning after the phone stops.
- Persisting calibration between screen visits.
