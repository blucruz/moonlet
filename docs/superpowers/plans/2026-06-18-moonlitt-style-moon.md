# Moonlitt-Style Moon Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Render an astronomically accurate, Moonlitt-inspired 3D moon with detailed surface relief, a crisp terminator, restrained limb glow, sparse stars, and edge-confined clouds on the lunar detail screen.

**Architecture:** Keep lunar phase calculation unchanged. Add a small pure `MoonLightingModel` that converts cycle progress into deterministic SceneKit light coordinates, then let `MoonSceneKitMoonView` own the real-time moon, sunlight, rim light, material, camera, and motion lifecycle. Keep stars, clouds, halo, and layout in a focused SwiftUI background component behind the SceneKit view.

**Tech Stack:** Swift 6, SwiftUI, SceneKit, Core Motion, XCTest, XcodeBuildMCP.

---

## File Structure

- Create `Moonlet/MoonPhase/MoonLightingModel.swift`: pure normalized-progress and light-vector calculations.
- Create `MoonletTests/MoonLightingModelTests.swift`: verifies principal phases, waxing/waning orientation, and progress normalization.
- Modify `Moonlet/MoonPhase/MoonSceneKitMoonView.swift`: realistic material, directional key light, rim light, camera, fallback material, and safe motion lifecycle.
- Create `Moonlet/MoonPhase/MoonDetailAtmosphereView.swift`: deterministic stars, low-volume edge clouds, and halo.
- Modify `Moonlet/MoonPhase/MoonPhaseDetailView.swift`: compose atmosphere and larger moon while preserving content and accessibility.
- Modify `Moonlet.xcodeproj/project.pbxproj` only if the project does not automatically include the new Swift files.

### Task 1: Deterministic Astronomical Light Model

**Files:**
- Create: `Moonlet/MoonPhase/MoonLightingModel.swift`
- Create: `MoonletTests/MoonLightingModelTests.swift`

- [x] **Step 1: Write failing tests**

Add tests asserting:

```swift
func testFirstQuarterLightsFromViewerRight() {
    let vector = MoonLightingModel(cycleProgress: 0.25).keyLightPosition
    XCTAssertGreaterThan(vector.x, 0)
    XCTAssertEqual(vector.z, 0, accuracy: 0.0001)
}

func testFullMoonLightsFromCamera() {
    let vector = MoonLightingModel(cycleProgress: 0.5).keyLightPosition
    XCTAssertEqual(vector.x, 0, accuracy: 0.0001)
    XCTAssertGreaterThan(vector.z, 0)
}

func testLastQuarterLightsFromViewerLeft() {
    let vector = MoonLightingModel(cycleProgress: 0.75).keyLightPosition
    XCTAssertLessThan(vector.x, 0)
    XCTAssertEqual(vector.z, 0, accuracy: 0.0001)
}

func testProgressWrapsIntoUnitInterval() {
    XCTAssertEqual(MoonLightingModel(cycleProgress: 1.25).progress, 0.25, accuracy: 0.0001)
    XCTAssertEqual(MoonLightingModel(cycleProgress: -0.25).progress, 0.75, accuracy: 0.0001)
}
```

- [x] **Step 2: Run the focused tests and verify failure**

Run the `MoonLightingModelTests` suite with XcodeBuildMCP. Expected: compile failure because `MoonLightingModel` does not exist.

- [x] **Step 3: Implement the pure model**

Define `MoonLightVector` and `MoonLightingModel`. Normalize progress into `[0, 1)`, calculate `angle = progress * 2π - π/2`, and expose a fixed-radius key-light position where first quarter is viewer-right, full moon is camera-facing, and last quarter is viewer-left.

- [x] **Step 4: Run focused tests**

Run `MoonLightingModelTests`. Expected: all tests pass.

### Task 2: Realistic SceneKit Moon

**Files:**
- Modify: `Moonlet/MoonPhase/MoonSceneKitMoonView.swift`
- Modify: `Moonlet/MoonPhase/MoonMotionController.swift`

- [x] **Step 1: Replace the omni phase light with a directional key light**

Use `MoonLightingModel.keyLightPosition`, point the node at the moon, and keep ambient intensity low enough that the dark hemisphere remains nearly black.

- [x] **Step 2: Tune lunar material and geometry**

Keep the LROC diffuse and elevation textures, use a physically based material, high roughness, minimal specular response, subtle displacement, and a neutral-gray diffuse fallback when texture loading fails.

- [x] **Step 3: Add restrained limb separation**

Add a low-intensity cool directional rim light opposite the key-light azimuth. Keep the effect narrow by avoiding emissive material and broad bloom.

- [x] **Step 4: Fix motion lifecycle**

Install `onMotionUpdate` once during coordinator setup, start motion once when attached, and stop it in coordinator deinitialization. Do not replace the callback on every SwiftUI update.

- [x] **Step 5: Build**

Build the app with XcodeBuildMCP. Expected: successful simulator build with no SceneKit or concurrency errors.

### Task 3: Atmospheric Detail-Screen Frame

**Files:**
- Create: `Moonlet/MoonPhase/MoonDetailAtmosphereView.swift`
- Modify: `Moonlet/MoonPhase/MoonPhaseDetailView.swift`

- [x] **Step 1: Add the atmospheric component**

Implement a full-screen blue-black gradient, restrained radial halo, deterministic sparse star positions, and blurred cloud ellipses restricted to side and lower edges. Mark decorative layers accessibility-hidden and disable hit testing.

- [x] **Step 2: Compose the moon stage**

Place atmosphere behind the existing scroll content. Increase the SceneKit stage to approximately 286 points, preserve the date header, title, direction copy, metrics, navigation behavior, and existing accessibility identifiers.

- [x] **Step 3: Build and run**

Build and launch on the configured iPhone simulator using XcodeBuildMCP. Expected: the detail screen appears with a fully visible moon and unobstructed text.

### Task 4: Visual and Regression Verification

**Files:**
- Modify only files above if verification exposes mismatches.

- [x] **Step 1: Capture first-quarter reference state**

Launch with `-uiTesting-date` set to a date producing a first-quarter phase, capture the detail screen, and compare composition, lunar scale, terminator, surface contrast, glow width, star density, and cloud placement against the approved visual target.

- [x] **Step 2: Iterate on visible mismatches**

Adjust only measurable rendering values: camera field of view/distance, light intensity/temperature, ambient lift, displacement, moon frame, halo radius, star opacity, and cloud opacity/position.

- [x] **Step 3: Verify representative phases**

Capture new moon, first quarter, full moon, and last quarter states. Confirm that illuminated fraction and side remain correct and that atmosphere never obscures the disk.

- [x] **Step 4: Run regression tests**

Run all `MoonletTests` and `MoonletUITests` with XcodeBuildMCP. Expected: all tests pass.

- [x] **Step 5: Review the final diff**

Run `git diff --check` and inspect `git diff` to verify no unrelated user changes were modified.
