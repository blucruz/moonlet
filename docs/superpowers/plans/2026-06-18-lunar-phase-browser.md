# Moonlet 月相查询 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 Moonlet 的主流程改为离线月相查询工具，提供当前月相详情，以及今天前后各 30 天的自然月日历浏览。

**Architecture:** 用纯 Foundation 的 `MoonPhaseCalculator` 计算太阳/月球黄经、照明比例、月龄和下一个关键月相；`MoonPhaseDateRange` 管理可查询日期；`MoonPhaseStore` 管理今天、月份和选择状态。SwiftUI 根视图改为“今天 / 月历”双标签，详情页复用同一套月相组件，旧叙事与动画代码保留但不再进入主流程。

**Tech Stack:** Swift 6、SwiftUI、Observation、Foundation、XCTest、XCUITest、Xcode 26.5、iOS 17+

---

## 开始前约束

- 当前工作区已有用户改动：
  - `Moonlet.xcodeproj/project.pbxproj`
  - `Moonlet/Scene/BreathingStillView.swift`
  - `Moonlet/Resources/Images/moonlit-first-quarter.png`
- 不回退、不覆盖这些改动。
- `.DS_Store`、`moonlet-running.png` 和 workspace 用户状态不进入功能提交。
- 开发前创建隔离 worktree；如果必须在当前目录实施，每次修改 `project.pbxproj` 前后都检查现有图片资源条目仍然存在。
- 所有生产代码必须先有失败测试。
- 模拟器测试使用 `iPhone 17`，UDID `06613268-439F-4051-86D6-2613035F824F`。

## 文件结构

### 新增

- `Moonlet/Domain/MoonPhaseSnapshot.swift`：月相计算结果和关键月相类型。
- `Moonlet/Domain/MoonPhaseDateRange.swift`：前后 30 天范围与月历日期生成。
- `Moonlet/App/MoonPhaseStore.swift`：应用状态、缓存、刷新和日期选择。
- `Moonlet/MoonPhase/MoonPhaseShape.swift`：按周期进度绘制月面。
- `Moonlet/MoonPhase/MoonPhaseDetailView.swift`：今天与选定日期共用的详情内容。
- `Moonlet/MoonPhase/MoonPhaseMetricsView.swift`：照明、月龄和下一关键月相。
- `Moonlet/Calendar/MoonCalendarGridView.swift`：月份标题、翻月和日期网格。
- `Moonlet/Resources/Localizable.xcstrings`：中文界面文案和未来英文扩展结构。
- `MoonletTests/MoonPhaseDateRangeTests.swift`
- `MoonletTests/MoonPhaseStoreTests.swift`

### 修改

- `Moonlet/Domain/LunarPhase.swift`：保留八阶段枚举，增加显示键和相位区间。
- `Moonlet/Domain/LunarPhaseCalculator.swift`：替换故事分桶算法为连续天文计算。
- `Moonlet/App/AppModel.swift`：删除故事播放状态职责，或改为 `typealias AppModel = MoonPhaseStore` 后逐步移除。
- `Moonlet/App/AppRoute.swift`：改为 `today`、`calendar`。
- `Moonlet/MoonletApp.swift`：接入双标签主流程和前台刷新。
- `Moonlet/Calendar/MoonCalendarView.swift`：改为月历导航容器。
- `Moonlet/Calendar/MoonCalendarDayCell.swift`：显示日期、月相缩略图和禁用状态。
- `MoonletTests/LunarPhaseCalculatorTests.swift`：改为天文结果测试。
- `MoonletTests/ScenePlaybackViewModelTests.swift`：只保留叙事播放自身测试，删除旧 `AppModel` 断言。
- `MoonletUITests/MoonletDailyFlowUITests.swift`：替换为今天/月历主流程测试。
- `Moonlet.xcodeproj/project.pbxproj`：登记新增源码、测试和本地化资源。

---

### Task 1: 定义月相领域模型

**Files:**
- Create: `Moonlet/Domain/MoonPhaseSnapshot.swift`
- Modify: `Moonlet/Domain/LunarPhase.swift`
- Modify: `MoonletTests/LunarPhaseCalculatorTests.swift`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: 写失败测试，固定八阶段映射和中文本地化键**

在 `MoonletTests/LunarPhaseCalculatorTests.swift` 添加：

```swift
func testMapsCycleProgressIntoEightOrderedPhases() {
    XCTAssertEqual(LunarPhase(cycleProgress: 0.00), .newMoon)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.10), .waxingCrescent)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.25), .firstQuarter)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.40), .waxingGibbous)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.50), .fullMoon)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.65), .waningGibbous)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.75), .lastQuarter)
    XCTAssertEqual(LunarPhase(cycleProgress: 0.90), .waningCrescent)
}

func testSnapshotRejectsOutOfRangeAstronomicalValues() {
    XCTAssertNil(MoonPhaseSnapshot(
        date: .now,
        phase: .fullMoon,
        cycleProgress: 1.2,
        ageDays: 12,
        illumination: 0.8,
        direction: .waxing,
        nextPrincipalPhase: .lastQuarter,
        nextPrincipalPhaseDate: .now.addingTimeInterval(86_400)
    ))
}
```

- [ ] **Step 2: 运行测试并确认因缺少 API 失败**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -destination 'platform=iOS Simulator,id=06613268-439F-4051-86D6-2613035F824F' \
  -only-testing:MoonletTests/LunarPhaseCalculatorTests
```

Expected: 编译失败，提示 `MoonPhaseSnapshot`、`cycleProgress` 或新枚举成员未定义。

- [ ] **Step 3: 实现最小领域模型**

`MoonPhaseSnapshot.swift`：

```swift
import Foundation

enum MoonPhaseDirection: Equatable, Sendable {
    case waxing
    case waning
}

enum PrincipalMoonPhase: CaseIterable, Equatable, Sendable {
    case newMoon
    case firstQuarter
    case fullMoon
    case lastQuarter

    var localizationKey: String {
        switch self {
        case .newMoon: "phase.newMoon"
        case .firstQuarter: "phase.firstQuarter"
        case .fullMoon: "phase.fullMoon"
        case .lastQuarter: "phase.lastQuarter"
        }
    }
}

struct MoonPhaseSnapshot: Equatable, Sendable {
    let date: Date
    let phase: LunarPhase
    let cycleProgress: Double
    let ageDays: Double
    let illumination: Double
    let direction: MoonPhaseDirection
    let nextPrincipalPhase: PrincipalMoonPhase
    let nextPrincipalPhaseDate: Date

    var timeUntilNextPrincipalPhase: TimeInterval {
        nextPrincipalPhaseDate.timeIntervalSince(date)
    }

    init?(
        date: Date,
        phase: LunarPhase,
        cycleProgress: Double,
        ageDays: Double,
        illumination: Double,
        direction: MoonPhaseDirection,
        nextPrincipalPhase: PrincipalMoonPhase,
        nextPrincipalPhaseDate: Date
    ) {
        guard cycleProgress >= 0, cycleProgress < 1,
              ageDays >= 0,
              illumination >= 0, illumination <= 1,
              nextPrincipalPhaseDate > date else {
            return nil
        }

        self.date = date
        self.phase = phase
        self.cycleProgress = cycleProgress
        self.ageDays = ageDays
        self.illumination = illumination
        self.direction = direction
        self.nextPrincipalPhase = nextPrincipalPhase
        self.nextPrincipalPhaseDate = nextPrincipalPhaseDate
    }
}
```

在 `LunarPhase.swift` 增加 `init(cycleProgress:)` 和 `localizationKey`。八阶段边界采用相邻关键相位中点：

```swift
init(cycleProgress: Double) {
    let p = cycleProgress - floor(cycleProgress)
    switch p {
    case 0..<0.0625, 0.9375..<1: self = .newMoon
    case 0.0625..<0.1875: self = .waxingCrescent
    case 0.1875..<0.3125: self = .firstQuarter
    case 0.3125..<0.4375: self = .waxingGibbous
    case 0.4375..<0.5625: self = .fullMoon
    case 0.5625..<0.6875: self = .waningGibbous
    case 0.6875..<0.8125: self = .lastQuarter
    default: self = .waningCrescent
    }
}
```

- [ ] **Step 4: 将新文件加入 app target 并运行测试**

Expected: 新增测试通过；原有依赖 `phase(forCycleDay:)` 的测试仍可能通过或在 Task 2 统一迁移。

- [ ] **Step 5: 提交领域模型**

```bash
git add Moonlet/Domain/MoonPhaseSnapshot.swift \
  Moonlet/Domain/LunarPhase.swift \
  MoonletTests/LunarPhaseCalculatorTests.swift \
  Moonlet.xcodeproj/project.pbxproj
git commit -m "feat: define moon phase domain model"
```

---

### Task 2: 实现连续月相天文计算

**Files:**
- Modify: `Moonlet/Domain/LunarPhaseCalculator.swift`
- Modify: `MoonletTests/LunarPhaseCalculatorTests.swift`

- [ ] **Step 1: 用已知天文事件写失败测试**

使用 UTC 固定日期和容差。测试数据：

- 2024-04-08 18:21 UTC：新月。
- 2024-04-15 19:13 UTC：上弦月。
- 2024-04-23 23:49 UTC：满月。
- 2024-05-01 11:27 UTC：下弦月。

添加：

```swift
func testKnownNewMoonHasLowIlluminationAndNearZeroAge() throws {
    let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-08T18:21:00Z"))
    let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

    XCTAssertEqual(snapshot.phase, .newMoon)
    XCTAssertLessThan(snapshot.illumination, 0.02)
    XCTAssertTrue(snapshot.ageDays < 1 || snapshot.ageDays > 28.5)
}

func testKnownFullMoonHasHighIllumination() throws {
    let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-23T23:49:00Z"))
    let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

    XCTAssertEqual(snapshot.phase, .fullMoon)
    XCTAssertGreaterThan(snapshot.illumination, 0.98)
}

func testKnownQuarterPhasesHaveHalfIllumination() throws {
    let formatter = ISO8601DateFormatter()
    let waxing = try XCTUnwrap(LunarPhaseCalculator().snapshot(
        for: XCTUnwrap(formatter.date(from: "2024-04-15T19:13:00Z"))
    ))
    let waning = try XCTUnwrap(LunarPhaseCalculator().snapshot(
        for: XCTUnwrap(formatter.date(from: "2024-05-01T11:27:00Z"))
    ))

    XCTAssertEqual(waxing.phase, .firstQuarter)
    XCTAssertEqual(waxing.illumination, 0.5, accuracy: 0.04)
    XCTAssertEqual(waxing.direction, .waxing)
    XCTAssertEqual(waning.phase, .lastQuarter)
    XCTAssertEqual(waning.illumination, 0.5, accuracy: 0.04)
    XCTAssertEqual(waning.direction, .waning)
}

func testDirectionChangesFromWaxingToWaningAcrossFullMoon() throws {
    let formatter = ISO8601DateFormatter()
    let before = try XCTUnwrap(LunarPhaseCalculator().snapshot(
        for: XCTUnwrap(formatter.date(from: "2024-04-22T12:00:00Z"))
    ))
    let after = try XCTUnwrap(LunarPhaseCalculator().snapshot(
        for: XCTUnwrap(formatter.date(from: "2024-04-25T12:00:00Z"))
    ))

    XCTAssertEqual(before.direction, .waxing)
    XCTAssertEqual(after.direction, .waning)
}

func testNextPrincipalPhaseIsFutureAndChronologicallyCorrect() throws {
    let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-10T00:00:00Z"))
    let snapshot = try XCTUnwrap(LunarPhaseCalculator().snapshot(for: date))

    XCTAssertEqual(snapshot.nextPrincipalPhase, .firstQuarter)
    XCTAssertGreaterThan(snapshot.nextPrincipalPhaseDate, date)
    XCTAssertLessThan(
        abs(snapshot.nextPrincipalPhaseDate.timeIntervalSince(
            XCTUnwrap(ISO8601DateFormatter().date(from: "2024-04-15T19:13:00Z"))
        )),
        12 * 3_600
    )
}
```

- [ ] **Step 2: 运行测试并确认旧固定周期算法失败**

Expected: `snapshot(for:)` 不存在，测试编译失败。

- [ ] **Step 3: 实现太阳/月球黄经近似**

重写 `LunarPhaseCalculator`，核心常量与函数：

```swift
struct LunarPhaseCalculator: Sendable {
    private static let julianUnixEpoch = 2_440_587.5
    private static let julianJ2000 = 2_451_545.0
    private static let synodicMonth = 29.530588853

    func snapshot(for date: Date) -> MoonPhaseSnapshot? {
        let elongation = lunarElongationDegrees(at: date)
        let progress = elongation / 360
        let illumination = (1 - cos(elongation.radians)) / 2
        let direction: MoonPhaseDirection = progress < 0.5 ? .waxing : .waning
        let next = nextPrincipalPhase(after: date, progress: progress)

        return MoonPhaseSnapshot(
            date: date,
            phase: LunarPhase(cycleProgress: progress),
            cycleProgress: progress,
            ageDays: progress * Self.synodicMonth,
            illumination: illumination,
            direction: direction,
            nextPrincipalPhase: next.phase,
            nextPrincipalPhaseDate: next.date
        )
    }
}
```

黄经计算采用 J2000 天数和主要周期项：

```swift
private func solarLongitudeDegrees(daysSinceJ2000 d: Double) -> Double {
    let meanLongitude = normalize(280.46646 + 0.98564736 * d)
    let meanAnomaly = normalize(357.52911 + 0.98560028 * d)
    return normalize(
        meanLongitude
        + 1.914602 * sin(meanAnomaly.radians)
        + 0.019993 * sin((2 * meanAnomaly).radians)
        + 0.000289 * sin((3 * meanAnomaly).radians)
    )
}
```

月球黄经至少包含平均黄经、月球平近点角、日月距角及主要摄动项：

```swift
private func lunarLongitudeDegrees(daysSinceJ2000 d: Double) -> Double {
    let l = normalize(218.3164477 + 13.17639648 * d)
    let m = normalize(134.9633964 + 13.06499295 * d)
    let solarM = normalize(357.5291092 + 0.98560028 * d)
    let elongation = normalize(297.8501921 + 12.19074912 * d)

    return normalize(
        l
        + 6.289 * sin(m.radians)
        + 1.274 * sin((2 * elongation - m).radians)
        + 0.658 * sin((2 * elongation).radians)
        + 0.214 * sin((2 * m).radians)
        - 0.186 * sin(solarM.radians)
        - 0.059 * sin((2 * elongation - 2 * m).radians)
        - 0.057 * sin((2 * elongation - solarM - m).radians)
        + 0.053 * sin((2 * elongation + m).radians)
        + 0.046 * sin((2 * elongation - solarM).radians)
        + 0.041 * sin((solarM - m).radians)
        - 0.035 * sin(elongation.radians)
        - 0.031 * sin((solarM + m).radians)
    )
}
```

`lunarElongationDegrees` 返回 `normalize(moonLongitude - sunLongitude)`。

- [ ] **Step 4: 实现下一关键月相求解**

关键进度依次为 `0.25 / 0.5 / 0.75 / 1.0`。先按朔望月比例给出初始估算，再用数值迭代修正：

```swift
private func nextPrincipalPhase(
    after date: Date,
    progress: Double
) -> (phase: PrincipalMoonPhase, date: Date) {
    let candidates: [(Double, PrincipalMoonPhase)] = [
        (0.25, .firstQuarter),
        (0.50, .fullMoon),
        (0.75, .lastQuarter),
        (1.00, .newMoon),
    ]
    let target = candidates.first(where: { $0.0 > progress + 1e-8 }) ?? candidates[0]
    let delta = target.0 > progress ? target.0 - progress : 1 - progress + target.0
    var estimate = date.addingTimeInterval(delta * Self.synodicMonth * 86_400)

    for _ in 0..<8 {
        let error = signedAngularError(
            current: lunarElongationDegrees(at: estimate),
            target: target.0.truncatingRemainder(dividingBy: 1) * 360
        )
        let derivative = angularVelocityDegreesPerSecond(at: estimate)
        guard derivative.isFinite, abs(derivative) > 1e-8 else { break }
        estimate = estimate.addingTimeInterval(-error / derivative)
    }

    if estimate <= date {
        estimate = estimate.addingTimeInterval(Self.synodicMonth * 86_400)
    }
    return (target.1, estimate)
}
```

`angularVelocityDegreesPerSecond` 用估算时刻前后各 30 分钟的黄经差做中央差分；角度差必须归一到 `-180...180`，避免新月跨越 360° 时跳变。

- [ ] **Step 5: 运行计算器测试并按结果收紧实现**

Expected:

- 四个已知相位分类正确。
- 新月照明 `< 2%`。
- 满月照明 `> 98%`。
- 上/下弦照明在 `0.5 ± 0.04`。
- 下一关键月相误差 `< 12 小时`。

如果最后一项不通过，只调整黄经周期项或数值求解；不放宽到超过 12 小时。

- [ ] **Step 6: 删除故事分桶测试依赖**

移除 `contentDay(for:)`、`phase(forCycleDay:)`、`fragmentContext(for:)` 的旧测试。旧故事代码若仍需要周期日，新增独立 `StoryCycleCalculator`，不要把故事索引重新塞进 `LunarPhaseCalculator`。

- [ ] **Step 7: 提交天文计算**

```bash
git add Moonlet/Domain/LunarPhaseCalculator.swift \
  MoonletTests/LunarPhaseCalculatorTests.swift
git commit -m "feat: calculate lunar phase locally"
```

---

### Task 3: 实现前后 30 天日期范围和月历数据

**Files:**
- Create: `Moonlet/Domain/MoonPhaseDateRange.swift`
- Create: `MoonletTests/MoonPhaseDateRangeTests.swift`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: 写日期边界和夏令时失败测试**

```swift
final class MoonPhaseDateRangeTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar
    }

    func testIncludesExactlyThirtyLocalDaysBeforeAndAfterToday() throws {
        let today = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T19:00:00Z"))
        let range = MoonPhaseDateRange(today: today, calendar: calendar)

        XCTAssertEqual(range.days.count, 61)
        XCTAssertTrue(range.contains(range.startDate))
        XCTAssertTrue(range.contains(range.endDate))
        XCTAssertFalse(range.contains(calendar.date(byAdding: .day, value: -1, to: range.startDate)!))
        XCTAssertFalse(range.contains(calendar.date(byAdding: .day, value: 1, to: range.endDate)!))
    }

    func testCalendarSamplesEachDayAtLocalNoonAcrossDST() throws {
        let today = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-03-08T20:00:00Z"))
        let range = MoonPhaseDateRange(today: today, calendar: calendar)

        XCTAssertTrue(range.days.allSatisfy {
            calendar.component(.hour, from: $0) == 12
        })
    }
}
```

- [ ] **Step 2: 运行并确认缺少类型导致失败**

- [ ] **Step 3: 实现 `MoonPhaseDateRange`**

```swift
struct MoonPhaseDateRange: Equatable, Sendable {
    let today: Date
    let startDate: Date
    let endDate: Date
    let days: [Date]
    private let calendar: Calendar

    init(today: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        let todayStart = calendar.startOfDay(for: today)
        self.today = todayStart
        self.startDate = calendar.date(byAdding: .day, value: -30, to: todayStart)!
        self.endDate = calendar.date(byAdding: .day, value: 30, to: todayStart)!
        self.days = (-30...30).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: todayStart) else {
                return nil
            }
            return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day)
        }
    }

    func contains(_ date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return day >= startDate && day <= endDate
    }

    func sampleDate(for date: Date) -> Date? {
        guard contains(date) else { return nil }
        return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)
    }
}
```

增加 `monthStart(containing:)`、`daysInMonth(containing:)` 和 `canNavigate(to:)`，月历网格可以生成完整自然月，但范围外日期仍保留为禁用格。

- [ ] **Step 4: 运行全部日期范围测试**

Expected: 61 个有效日期；洛杉矶夏令时切换前后均为当地 12 点。

- [ ] **Step 5: 提交日期范围**

```bash
git add Moonlet/Domain/MoonPhaseDateRange.swift \
  MoonletTests/MoonPhaseDateRangeTests.swift \
  Moonlet.xcodeproj/project.pbxproj
git commit -m "feat: add bounded moon phase date range"
```

---

### Task 4: 实现 `MoonPhaseStore` 状态和缓存

**Files:**
- Create: `Moonlet/App/MoonPhaseStore.swift`
- Create: `MoonletTests/MoonPhaseStoreTests.swift`
- Modify: `Moonlet/App/AppModel.swift`
- Modify: `Moonlet/App/AppRoute.swift`
- Modify: `MoonletTests/ScenePlaybackViewModelTests.swift`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: 写状态、选择和跨日刷新失败测试**

```swift
@MainActor
final class MoonPhaseStoreTests: XCTestCase {
    func testBootstrapsOnTodayTabWithCurrentSnapshot() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-06-18T12:00:00Z"))
        let store = MoonPhaseStore(now: now)

        XCTAssertEqual(store.selectedTab, .today)
        XCTAssertEqual(store.selectedDate, nil)
        XCTAssertNotNil(store.todaySnapshot)
    }

    func testRejectsSelectionOutsideThirtyDayRange() throws {
        let formatter = ISO8601DateFormatter()
        let now = try XCTUnwrap(formatter.date(from: "2026-06-18T12:00:00Z"))
        let store = MoonPhaseStore(now: now)
        let invalid = try XCTUnwrap(formatter.date(from: "2026-08-01T12:00:00Z"))

        store.select(invalid)

        XCTAssertNil(store.selectedDate)
    }

    func testRefreshMovesDateWindowWhenLocalDayChanges() throws {
        let formatter = ISO8601DateFormatter()
        let first = try XCTUnwrap(formatter.date(from: "2026-06-18T12:00:00Z"))
        let next = try XCTUnwrap(formatter.date(from: "2026-06-19T12:00:00Z"))
        let store = MoonPhaseStore(now: first)
        let oldEnd = store.dateRange.endDate

        store.refresh(now: next)

        XCTAssertGreaterThan(store.dateRange.endDate, oldEnd)
    }
}
```

- [ ] **Step 2: 运行并确认 `MoonPhaseStore` 缺失**

- [ ] **Step 3: 实现最小 store**

```swift
import Foundation
import Observation

enum AppRoute: Hashable {
    case today
    case calendar
}

@MainActor
@Observable
final class MoonPhaseStore {
    var selectedTab: AppRoute = .today
    var displayedMonth: Date
    var selectedDate: Date?
    private(set) var now: Date
    private(set) var dateRange: MoonPhaseDateRange

    private let calendar: Calendar
    private let calculator: LunarPhaseCalculator
    private var cache: [Date: MoonPhaseSnapshot] = [:]

    init(
        now: Date = .now,
        calendar: Calendar = .current,
        calculator: LunarPhaseCalculator = .init()
    ) {
        self.now = now
        self.calendar = calendar
        self.calculator = calculator
        self.dateRange = MoonPhaseDateRange(today: now, calendar: calendar)
        self.displayedMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        )!
    }

    var todaySnapshot: MoonPhaseSnapshot? { snapshot(for: now) }
}
```

实现：

- `snapshot(for:)`：有效范围内按当地日历日缓存正午快照；今天页使用当前时刻。
- `select(_:)`：只接受有效范围日期。
- `clearSelection()`。
- `moveMonth(by:)`：只允许进入与有效范围相交的月份。
- `refresh(now:)`：只有本地日期变化时重建范围、清理缓存和修正月份。

- [ ] **Step 4: 清理旧 AppModel 依赖**

`AppModel.swift` 不再加载故事仓库。为降低一次性工程改动，可先写：

```swift
typealias AppModel = MoonPhaseStore
```

`ScenePlaybackViewModelTests.swift` 删除两个旧 `AppModel.bootstrap` 测试，保留播放状态测试，确保叙事代码仍能独立编译。

- [ ] **Step 5: 运行 store 测试和全部单元测试**

Expected: `MoonletTests` 全部通过；旧故事仓库测试仍通过。

- [ ] **Step 6: 提交状态管理**

```bash
git add Moonlet/App/MoonPhaseStore.swift \
  Moonlet/App/AppModel.swift \
  Moonlet/App/AppRoute.swift \
  MoonletTests/MoonPhaseStoreTests.swift \
  MoonletTests/ScenePlaybackViewModelTests.swift \
  Moonlet.xcodeproj/project.pbxproj
git commit -m "feat: manage moon phase browsing state"
```

---

### Task 5: 绘制月相并实现共享详情组件

**Files:**
- Create: `Moonlet/MoonPhase/MoonPhaseShape.swift`
- Create: `Moonlet/MoonPhase/MoonPhaseDetailView.swift`
- Create: `Moonlet/MoonPhase/MoonPhaseMetricsView.swift`
- Create: `Moonlet/Resources/Localizable.xcstrings`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: 写格式化行为失败测试**

在 `MoonPhaseStoreTests.swift` 或新增 `MoonPhaseFormattingTests.swift`：

```swift
func testChinesePhaseLabelsAndMetricFormatting() {
    XCTAssertEqual(LunarPhase.waxingCrescent.localizedName(locale: Locale(identifier: "zh-Hans")), "娥眉月")
    XCTAssertEqual(MoonPhaseFormatting.illumination(0.134), "13%")
    XCTAssertEqual(MoonPhaseFormatting.age(3.14), "3.1 天")
    XCTAssertEqual(MoonPhaseFormatting.countdown(4 * 86_400 + 8 * 3_600), "4 天 8 小时")
}
```

- [ ] **Step 2: 运行并确认格式化 API 缺失**

- [ ] **Step 3: 实现可本地化格式化层**

`Localizable.xcstrings` 至少包含：

- `tab.today` = `今天`
- `tab.calendar` = `月历`
- 八个月相名称
- `metric.illumination` = `照明比例`
- `metric.age` = `月龄`
- `metric.nextPhase` = `下一个关键月相`
- `error.calculation` = `暂时无法计算月相`

`MoonPhaseFormatting` 统一使用 `String(localized:)`、`Date.FormatStyle` 和 `FloatingPointFormatStyle`，生产视图不硬编码中文数据单位。

- [ ] **Step 4: 实现 `MoonPhaseShape`**

使用一个亮圆和一个偏移暗圆的相交效果表达月相：

- `progress == 0`：全暗。
- `0..<0.5`：右侧亮面逐渐增加。
- `0.5`：全亮。
- `0.5..<1`：左侧亮面逐渐减少。

Shape 输入为 `cycleProgress`，内部将进度限制在 `0..<1`。视图加柔和外发光，但在“减少动态效果”下不依赖动画。

- [ ] **Step 5: 实现详情组件**

`MoonPhaseDetailView` 接收：

```swift
struct MoonPhaseDetailView: View {
    let snapshot: MoonPhaseSnapshot
    let isToday: Bool
}
```

布局顺序：

1. `今天` 或完整日期。
2. 220–260 pt 月相图形。
3. 中文月相名称。
4. `MoonPhaseMetricsView` 三项数据。

为 UI 测试添加：

- `moon-phase-detail`
- `moon-phase-name`
- `moon-illumination`
- `moon-age`
- `next-principal-phase`

- [ ] **Step 6: 构建验证**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild build \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -destination 'platform=iOS Simulator,id=06613268-439F-4051-86D6-2613035F824F'
```

Expected: `BUILD SUCCEEDED`，无缺少本地化资源或 Shape 编译错误。

- [ ] **Step 7: 提交共享 UI**

```bash
git add Moonlet/MoonPhase \
  Moonlet/Resources/Localizable.xcstrings \
  MoonletTests \
  Moonlet.xcodeproj/project.pbxproj
git commit -m "feat: add reusable moon phase detail UI"
```

---

### Task 6: 实现自然月网格和日期详情导航

**Files:**
- Modify: `Moonlet/Calendar/MoonCalendarDayCell.swift`
- Modify: `Moonlet/Calendar/MoonCalendarView.swift`
- Create: `Moonlet/Calendar/MoonCalendarGridView.swift`
- Modify: `Moonlet.xcodeproj/project.pbxproj`

- [ ] **Step 1: 先修改 UI 测试描述月历行为**

将 `MoonletUITests.swift` 中月历测试写成：

```swift
@MainActor
func testCalendarAllowsSelectingAnInRangeDate() {
    let app = configuredApplication()
    app.launch()

    app.tabBars.buttons["月历"].tap()
    XCTAssertTrue(app.otherElements["moon-calendar-grid"].waitForExistence(timeout: 3))

    app.buttons["2026-06-20"].tap()
    XCTAssertTrue(app.otherElements["moon-phase-detail"].waitForExistence(timeout: 2))
    XCTAssertTrue(app.navigationBars.buttons["返回"].exists)
}
```

`configuredApplication()` 传入确定日期：

```swift
private func configuredApplication() -> XCUIApplication {
    let app = XCUIApplication()
    app.launchArguments = ["-uiTesting-date", "2026-06-18T12:00:00Z"]
    return app
}
```

- [ ] **Step 2: 运行 UI 测试并确认失败**

Expected: 找不到“月历”标签或 `moon-calendar-grid`。

- [ ] **Step 3: 重写日期单元格**

`MoonCalendarDayCell` 输入：

```swift
let date: Date
let snapshot: MoonPhaseSnapshot?
let isToday: Bool
let isEnabled: Bool
let calendar: Calendar
```

单元格显示日期数字和 22–28 pt `MoonPhaseShape`。范围外使用 `.disabled(true)` 和降低透明度。按钮 accessibility label 使用完整 `yyyy-MM-dd`，identifier 同样使用日期，确保 UI 测试稳定。

- [ ] **Step 4: 实现月份网格**

`MoonCalendarGridView`：

- 周一至周日表头。
- 7 列 `LazyVGrid`。
- 月初前和月末后的补位日期保留，但按范围规则禁用。
- 左右按钮调用 `store.moveMonth(by:)`。
- 月份标题使用中文本地化日期格式。
- 当前月份与有效范围无交集时，不允许继续翻页。

- [ ] **Step 5: 实现日期详情导航**

`MoonCalendarView` 使用 `NavigationStack`。日期按钮：

```swift
Button {
    store.select(date)
} label: {
    MoonCalendarDayCell(...)
}
.navigationDestination(
    isPresented: Binding(
        get: { store.selectedDate != nil },
        set: { if !$0 { store.clearSelection() } }
    )
) {
    if let date = store.selectedDate,
       let snapshot = store.snapshot(for: date) {
        MoonPhaseDetailView(snapshot: snapshot, isToday: false)
    }
}
```

- [ ] **Step 6: 运行 UI 测试**

Expected: 月历出现、范围内日期可进入详情并返回。

- [ ] **Step 7: 提交月历**

```bash
git add Moonlet/Calendar \
  MoonletUITests/MoonletDailyFlowUITests.swift \
  Moonlet.xcodeproj/project.pbxproj
git commit -m "feat: browse moon phases in calendar grid"
```

---

### Task 7: 切换应用主流程到“今天 / 月历”

**Files:**
- Modify: `Moonlet/MoonletApp.swift`
- Modify: `MoonletUITests/MoonletDailyFlowUITests.swift`

- [ ] **Step 1: 写启动和标签切换失败测试**

```swift
@MainActor
func testLaunchesIntoTodayMoonPhaseAndSwitchesTabs() {
    let app = configuredApplication()
    app.launch()

    XCTAssertTrue(app.otherElements["moon-phase-detail"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.tabBars.buttons["今天"].isSelected)
    XCTAssertTrue(app.staticTexts["moon-phase-name"].exists)

    app.tabBars.buttons["月历"].tap()

    XCTAssertTrue(app.otherElements["moon-calendar-grid"].waitForExistence(timeout: 2))
}
```

- [ ] **Step 2: 运行并确认旧叙事主流程导致失败**

- [ ] **Step 3: 重写 `MoonletApp`**

```swift
@main
struct MoonletApp: App {
    @State private var store: MoonPhaseStore
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let now = Self.testingDateFromArguments() ?? .now
        _store = State(initialValue: MoonPhaseStore(now: now))
    }

    var body: some Scene {
        WindowGroup {
            TabView(selection: $store.selectedTab) {
                NavigationStack {
                    if let snapshot = store.todaySnapshot {
                        MoonPhaseDetailView(snapshot: snapshot, isToday: true)
                    } else {
                        ContentUnavailableView(
                            "暂时无法计算月相",
                            systemImage: "moon.stars"
                        )
                    }
                }
                .tabItem { Label("今天", systemImage: "moon.fill") }
                .tag(AppRoute.today)

                MoonCalendarView(store: store)
                    .tabItem { Label("月历", systemImage: "calendar") }
                    .tag(AppRoute.calendar)
            }
            .tint(Color(red: 0.88, green: 0.84, blue: 0.74))
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    store.refresh(now: .now)
                }
            }
        }
    }
}
```

测试日期参数只在进程参数明确包含 `-uiTesting-date` 时生效；生产环境始终使用 `.now`。

- [ ] **Step 4: 明确断开旧播放主流程**

确认 `MoonletApp.swift` 不再引用：

- `ScenePlayerView`
- `ScenePlaybackViewModel`
- `StoryFragment`
- `AmbientAudioController`
- `HapticCuePlayer`

不要删除这些源码，也不要移除用户尚未提交的图片资源。

- [ ] **Step 5: 运行全部单元测试和 UI 测试**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -destination 'platform=iOS Simulator,id=06613268-439F-4051-86D6-2613035F824F'
```

Expected: 所有 `MoonletTests` 和 `MoonletUITests` 通过。

- [ ] **Step 6: 提交主流程切换**

```bash
git add Moonlet/MoonletApp.swift \
  MoonletUITests/MoonletDailyFlowUITests.swift
git commit -m "feat: make moon phase browser the main flow"
```

---

### Task 8: 完整验证、视觉检查和真机安装

**Files:**
- Modify only if verification finds a scoped defect.

- [ ] **Step 1: 检查工程文件和工作区边界**

```bash
git status --short
git diff --check
rg -n 'moonlit-first-quarter.png' Moonlet.xcodeproj/project.pbxproj
```

Expected: 图片资源条目仍存在；无空白错误；未误提交 `.DS_Store`、用户 workspace 状态或 `moonlet-running.png`。

- [ ] **Step 2: 执行完整测试**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -destination 'platform=iOS Simulator,id=06613268-439F-4051-86D6-2613035F824F'
```

Expected: `** TEST SUCCEEDED **`。

- [ ] **Step 3: 模拟器人工验收**

使用 XcodeBuildMCP：

1. 启动 iPhone 17 模拟器。
2. 验证首页显示当前月相，不出现彩色占位矩形。
3. 验证“今天 / 月历”标签。
4. 验证前后月份导航。
5. 验证范围外日期禁用。
6. 进入一个历史日期和一个未来日期详情。
7. 截图检查小屏下标题、指标卡和日历格无截断。

- [ ] **Step 4: 真机构建**

使用已确认的 Personal Team，仅通过命令行参数签名，不写入工程：

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Moonlet.xcodeproj \
  -scheme Moonlet \
  -configuration Debug \
  -destination 'platform=iOS,id=00008101-000865E22189001E' \
  -derivedDataPath /tmp/moonlet-device-build \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=NVU77H965J \
  CODE_SIGN_STYLE=Automatic \
  build
```

Expected: `** BUILD SUCCEEDED **`。

- [ ] **Step 5: 安装并启动到 THE HERMIT**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcrun devicectl device install app \
  --device AA49C799-54EC-566E-8889-F795F253218B \
  /tmp/moonlet-device-build/Build/Products/Debug-iphoneos/Moonlet.app

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcrun devicectl device process launch \
  --device AA49C799-54EC-566E-8889-F795F253218B \
  com.uriah.moonlet
```

Expected: 安装成功，应用启动后直接显示当前月相。

- [ ] **Step 6: 最终复核**

```bash
git log --oneline --max-count=10
git status --short
```

确认：

- 功能提交按任务拆分。
- 用户原有未提交改动仍完整保留。
- 无额外临时文件进入提交。
- 规格中的八项验收标准全部满足。
