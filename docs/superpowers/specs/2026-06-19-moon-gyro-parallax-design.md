# Moon Gyroscope Parallax Design

## Scope

Add subtle device-motion parallax to the existing 3D moon on the lunar detail screen. Do not change lunar phase lighting, camera composition, atmosphere, typography, metrics, or calendar behavior.

## Interaction

- When the lunar detail screen appears, the current device attitude becomes the neutral center.
- Subsequent phone tilt rotates the moon in the opposite direction, creating a window-like parallax effect.
- Pitch controls the moon's vertical rotation and roll controls its horizontal rotation.
- Each axis is limited to approximately `±2°`.
- Small hand tremors inside a dead zone do not move the moon.
- Motion is low-pass filtered so the moon settles smoothly instead of tracking sensor noise directly.
- Translation, zoom, lighting, and phase geometry remain unchanged.

## Motion Model

`MoonMotionController` owns sensor acquisition and relative-attitude calibration.

1. Start device-motion updates when the SceneKit view attaches.
2. Save the first valid pitch and roll as the neutral attitude.
3. Calculate wrapped angular deltas from that neutral attitude.
4. Apply a small dead zone.
5. Clamp each delta to the configured maximum input range.
6. Normalize the clamped delta and map it to `±2°`.
7. Smooth the mapped result before sending it to the SceneKit coordinator.

The callback exposes only the final parallax rotation values. The SceneKit view must not interpret raw accelerometer values.

## SceneKit Integration

- Preserve the moon's existing base orientation.
- Apply parallax as a small offset from that base orientation.
- Reverse both axes relative to device tilt.
- Keep the Z rotation fixed so the moon does not appear to spin like a flat card.
- Start motion once per coordinator attachment and stop updates when the view is dismantled.
- Reset calibration when a new detail-screen instance starts.

## Constants

- Maximum visible rotation: `2°` per axis.
- Dead zone: approximately `0.5°` of device attitude change.
- Full-input tilt range: approximately `15°`.
- Smoothing factor: tuned for a restrained response, initially `0.12` per update at 60 Hz.

These values may be adjusted slightly during physical-device verification, but the visible rotation must remain at or below `2°`.

## Fallback Behavior

- If device motion is unavailable, the moon remains at its base orientation.
- Simulator behavior remains static because it does not provide normal physical gyroscope input.
- Stopping and restarting the view creates a fresh neutral calibration.

## Verification

1. Add unit tests for angle wrapping, dead-zone behavior, clamping, reverse mapping, and the `±2°` output limit.
2. Run all existing unit and UI tests.
3. Verify on a physical iPhone:
   - opening the screen does not cause an initial jump;
   - tilting right makes the moon rotate left;
   - tilting forward makes the moon rotate backward;
   - normal hand tremor is not visible;
   - the moon never rotates more than approximately `2°`;
   - lunar lighting and illuminated fraction do not change.

## Non-Goals

- Moving the stars or clouds with device motion.
- Translating or zooming the moon.
- Adding inertial spinning after the phone stops.
- Persisting calibration between screen visits.
