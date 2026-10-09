// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> Because the cell is one shared battery, and a class is shared by reference while a struct would be copied

final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        if charge < 0 {
            self.charge = 0
        } else if charge > 100 {
            self.charge = 100
        } else {
            self.charge = charge
        }
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || amount > charge {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }
        charge += amount
        if charge > 100 {
            charge = 100
        }
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> iit stops subclasses from changing the shift ritual, so every drone always pays its powerCost before working
// class Drone { }
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        if cell.spend(powerCost) {
            return performTask()
        }
        return 0
    }

    var canRunAgain: Bool {
        return cell.level() >= powerCost
    }
}

// 2.2
// final class WelderDrone: Drone { }
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}
// class ScannerDrone: Drone { }
class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}
// final class CargoDrone: Drone { }
final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
// func makeDrone(kind: String, id: String, charge: Int) -> Drone? { }
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    if kind == "welder" {
        return WelderDrone(id: id, cell: cell)
    } else if kind == "scanner" {
        return ScannerDrone(id: id, cell: cell)
    } else if kind == "cargo" {
        return CargoDrone(id: id, cell: cell)
    }
    return nil
}
// let fleet: [Drone] = ...
var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: skipped \(record.id), unknown kind '\(record.kind)'")
    }
}


// MARK: Level 3 · The Shift
// func runShift(_ fleet: [Drone], rounds: Int) -> Int { }
func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}
// let A = ...
let A = runShift(fleet, rounds: 3)

var chargeSum = 0
var readyCount = 0
for drone in fleet {
    print(drone.statusLine)
    chargeSum += drone.cell.level()
    if drone.canRunAgain {
        readyCount += 1
    }
}
// let B = ...
let B = chargeSum
// let C = ...
let C = readyCount
print("Work units: \(A), charge left: \(B), drones ready for one more task: \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
// protocol Diagnosable { }
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
// protocol Rechargeable { }
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> because Drone is a class, so its method changes the object itself and not a copy, and only structs need `mutating`
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: chargeLevel) }

    mutating func recharge(by amount: Int) {
        if amount <= 0 {
            return
        }
        chargeLevel += amount
        if chargeLevel > 100 {
            chargeLevel = 100
        }
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}
//4.3
// Why could [Drone] never have held the sensors?  -> because SensorModule is a struct and cannot inherit from the Drone class, but it can conform to a protocol
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}

print("\n--- Diagnostics ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
// extension Diagnosable { }
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 {
            return 2
        } else if charge < 50 {
            return 1
        }
        return 0
    }
}

// 5.2 · the beacon you cannot edit
// extension LegacyBeacon: Diagnosable { }
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(forCharge: signalStrength) }

    func diagnose() -> String {
        return "LEGACY HARDWARE \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print("--- Diagnostics with beacon ---")
print(diagnosticsReport(components))

var codeSum = 0
for component in components {
    codeSum += component.statusCode
}
// let D = ...
let D = codeSum

// 5.3
// extension Int { }
extension Int {
    var powerBar: String {
        var filled = self / 10
        if filled < 0 {
            filled = 0
        }
        if filled > 10 {
            filled = 10
        }
        var bar = ""
        for _ in 0..<filled {
            bar += "#"
        }
        for _ in filled..<10 {
            bar += "."
        }
        return bar
    }
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
// Expected: a drone that does 30 work units
// Actual: does not compile,bbecause  "overriding declaration requires an 'override' keyword"
// Rule: a method that replaces a superclass method must be marked 'override'
// Fix: override func performTask() -> Int { return 30 }

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
// Expected: a stronger welder that returns 999
// Actual: does not compile, WelderDrone is final so it can't be inherited, and runOnce() is final so it can't be overridden
// Rule: 'final' forbids subclassing and overriding
// Fix: inherit from Drone instead and override powerCost / performTask, not runOnce():
//   final class HeavyWelder: Drone {
//       override var powerCost: Int { 25 }
//       override func performTask() -> Int { 999 }
//   }

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
// Expected: it is a WelderDrone so weldSeam() should work
// Actual: does not compile, cause value of type 'Drone' has no member 'weldSeam'
// Rule: the compiler only allows what the declared type (Drone) has
// Fix:
//   if let welder = first as? WelderDrone {
//       print(welder.weldSeam())
//   }
// as? returns an optional because the cast can fail if the object is not a WelderDrone

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
// Expected: "thruster T-1"
// Actual: compiles but prints "generic component"
// Rule: label() is not a protocol requirement, only an extension method, so it is chosen by the declared type (Labelled) and not by the real type
// Fix: add `func label() -> String` to the protocol itself.
*/


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?

    A class is a reference type, so its methods can change its properties without changing 'self'. A struct is a value type, so changing a property changes the struct itself, and the method must be marked 'mutating'

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:

    Inheritance can share stored properties(Drone stores id and cell for all subclasses), protocols can't.
    Protocols can unite a class, a struct and a type we can't edit (LegacyBeacon) in one array, inheritance can't.

 3. What does `final` prevent, and what did it protect in runOnce()?

    `final` prevents subclassing or overriding. On runOnce() it makes sure no subclass can skip
    spending the battery charge before working.

 4. In Report 4, why did the protocol extension's method win?

    Because label() was only in the extension and not a requirement of the protocol, so Swift picked it by
    the declared type Labelled. If it is a requirement, the struct's own method is used.

*/
