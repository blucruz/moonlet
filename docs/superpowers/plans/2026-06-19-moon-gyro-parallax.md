# Moon Gyroscope Parallax Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add calibrated, reverse-direction gyroscope parallax to the existing 3D moon, limited to two degrees per axis with dead-zone filtering and smooth response.

**Architecture:** Introduce a pure `MoonParallaxModel` that converts neutral and current attitudes into testable target rotations. Keep calibration and smoothing state inside `MoonMotionController`, then send final pitch/yaw offsets to the existing SceneKit coordinator. The SceneKit moon retains its current base orientation, lighting, material, camera, and atmospheric composition.

**Tech Stack:** Swift 6, Core Motion, SceneKit, XCTest, Xcode simulator tests, physical iPhone verification.

---

## File Structure

- Create `Moonlet/MoonPhase/MoonParallaxModel.swift`: pure angle wrapping, dead-zone, clamping, reverse mapping, and constants.
- Create `MoonletTests/MoonParallaxModelTests.swift`: verifies all parallax math independently from Core Motion.
- Modify `Moonlet/MoonPhase/MoonMotionController.swift`: first-sample calibration, low-pass smoothing, and final rotation callback.
- Modify `Moonlet/MoonPhase/MoonSceneKitMoonView.swift`: apply pitch/yaw offsets to the moon's fixed base orientation without Z-axis rotation.
- Modify `Moonlet.xcodeproj/project.pbxproj`: add the new model and test files to their targets.

### Task 1: Testable Parallax Mapping

**Files:**
- Create: `Moonlet/MoonPhase/MoonParallaxModel.swift`
- Create: `MoonletTests/MoonParallaxModelTests.swift`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: Write failing mapping tests**

Add tests equivalent to:

```swift
func testNeutralAttitudeProducesNoRotation() {
    let model = MoonParallaxModel()
    let output = model.rotation(
        neutralPitch: 0.4,
        neutralRoll: -0.2,
        pitch: 0.4,
        roll: -0.2
    )
    XCTAssertEqual(output.pitch, 0, accuracy: 0.0001)
    XCTAssertEqual(output.yaw, 0, accuracy: 0.0001)
}

func testTiltMapsInOppositeDirection() {
    let model = MoonParallaxModel()
    let output = model.rotation(
        neutralPitch: 0,
        neutralRoll: 0,
        pitch: 10.0.degreesToRadians,
        roll: 10.0.degreesToRadians
    )
    XCTAssertLessThan(output.pitch, 0)
    XCTAssertLessThan(output.yaw, 0)
}

func testDeadZoneSuppressesSmallTremor() {
    let output = MoonParallaxModel().rotation(
        neutralPitch: 0,
        neutralRoll: 0,
        pitch: 0.3.degreesToRadians,
        roll: -0.3.degreesToRadians
    )
    XCTAssertEqual(output.pitch, 0, accuracy: 0.0001)
    XCTAssertEqual(output.yaw, 0, accuracy: 0.0001)
}

func testRotationIsLimitedToTwoDegrees() {
    let output = MoonParallaxModel().rotation(
        neutralPitch: 0,
        neutralRoll: 0,
        pitch: .pi,
        roll: -.pi
    )
    XCTAssertEqual(abs(output.pitch), 2.0.degreesToRadians, accuracy: 0.0001)
    XCTAssertEqual(abs(output.yaw), 2.0.degreesToRadians, accuracy: 0.0001)
}

func testAngleDeltaWrapsAcrossPiBoundary() {
    let output = MoonParallaxModel().rotation(
        neutralPitch: 179.0.degreesToRadians,
        neutralRoll: 0,
        pitch: -179.0.degreesToRadians,
        roll: 0
    )
    XCTAssertGreaterThan(output.pitch, -1.0.degreesToRadians)
    XCTAssertLessThan(output.pitch, 0)
}
```

- [ ] **Step 2: Run focused tests and verify failure**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -destination 'platform=iOS Simulator,id=A502ACC4-2C85-45EA-84D8-5DE61ED069DD' \
  -only-testing:MoonletTests/MoonParallaxModelTests
```

Expected: compilation fails because `MoonParallaxModel` does not exist.

- [ ] **Step 3: Implement minimal pure mapping**

Define:

```swift
struct MoonParallaxRotation: Equatable, Sendable {
    let pitch: Double
    let yaw: Double
}

struct MoonParallaxModel: Sendable {
    static let maximumRotation = 2.0 * .pi / 180
    static let deadZone = 0.5 * .pi / 180
    static let fullInputRange = 15.0 * .pi / 180

    func rotation(
        neutralPitch: Double,
        neutralRoll: Double,
        pitch: Double,
        roll: Double
    ) -> MoonParallaxRotation
}
```

Wrap deltas into `[-π, π]`, remove the dead zone, normalize remaining input against `fullInputRange - deadZone`, clamp to `[-1, 1]`, reverse the sign, and multiply by `maximumRotation`.

- [ ] **Step 4: Run focused tests**

Expected: all `MoonParallaxModelTests` pass.

### Task 2: Calibrated and Smoothed Core Motion

**Files:**
- Modify: `Moonlet/MoonPhase/MoonMotionController.swift`
- Modify: `Moonlet/MoonPhase/MoonSceneKitMoonView.swift`

- [ ] **Step 1: Change the callback contract**

Replace raw pitch/roll/acceleration output with:

```swift
var onMotionUpdate: ((MoonParallaxRotation) -> Void)?
```

- [ ] **Step 2: Calibrate from the first sample**

Store the first valid attitude as:

```swift
private var neutralPitch: Double?
private var neutralRoll: Double?
```

The first sample sets both values and emits zero rotation, preventing an initial visual jump.

- [ ] **Step 3: Smooth mapped rotations**

Track `smoothedPitch` and `smoothedYaw`. Update each with:

```swift
smoothed += (target - smoothed) * 0.12
```

Emit only the smoothed `MoonParallaxRotation`.

- [ ] **Step 4: Reset state on stop**

When motion stops, clear neutral values and smoothed values so the next screen instance calibrates from its current device attitude.

- [ ] **Step 5: Apply offsets to SceneKit**

Use the existing base pitch `-0.055` radians. Set:

```swift
moonContainer.eulerAngles = SCNVector3(
    basePitch + Float(rotation.pitch),
    Float(rotation.yaw),
    0
)
```

Do not use acceleration or apply Z-axis rotation.

- [ ] **Step 6: Build**

Run a simulator build. Expected: successful build with unchanged static simulator appearance.

### Task 3: Regression and Device Verification

**Files:**
- Modify only prior files if verification identifies an issue.

- [ ] **Step 1: Run all automated tests**

Run the complete Xcode test suite. Expected: all unit and UI tests pass.

- [ ] **Step 2: Verify visual invariants on simulator**

Capture a first-quarter screenshot and confirm moon size, light direction, texture, halo, stars, clouds, typography, and metrics are unchanged.

- [ ] **Step 3: Verify on a physical iPhone**

Confirm:

- opening the screen produces no jump;
- phone-right produces moon-left;
- phone-forward produces moon-backward;
- small tremors are suppressed;
- both axes remain at or below `2°`;
- stopping and reopening recalibrates neutral attitude.

- [ ] **Step 4: Review final diff**

Run `git diff --check` and ensure no existing unrelated working-tree changes were staged or modified.
