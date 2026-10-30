// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
// enum Deck: String, CaseIterable { }
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case greenhouse
    case cargo
    case engine
}

// 1.2
// enum AlarmLevel: Int { }
enum AlarmLevel: Int {
    case normal = 0
    case warning = 1
    case critical = 2
 
    init(oxygen: Int) {
        if oxygen < 30 {
            self = .critical
        } else if oxygen < 60 {
            self = .warning
        } else {
            self = .normal
        }
    }
}

for reading in deckReadings {
    if let deck = Deck(rawValue: reading.deck) {
        let level = AlarmLevel(oxygen: reading.oxygen)
        print("\(deck): \(reading.oxygen) -> \(level) (\(level.rawValue))")
    } else {
        print("\(reading.deck): not a real deck, ignored")
    }
}

// MARK: Level 2 · The Manifest

// 2.1
// enum ManifestEntry { }
enum ManifestEntry {
    case crate(id: Int, mass: Int)
    case container(code: String, mass: Int)
    case livestock(name: String, count: Int, massEach: Int)
    case invalid(String)
}

// 2.2
// func parseEntry(_ line: String) -> ManifestEntry { }
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
 
    if parts[0] == "crate" && parts.count == 3 {
        if let id = Int(parts[1]), let mass = Int(parts[2]) {
            return .crate(id: id, mass: mass)
        }
    } else if parts[0] == "container" && parts.count == 3 {
        if let mass = Int(parts[2]) {
            return .container(code: parts[1], mass: mass)
        }
    } else if parts[0] == "livestock" && parts.count == 4 {
        if let count = Int(parts[2]), let each = Int(parts[3]) {
            return .livestock(name: parts[1], count: count, massEach: each)
        }
    }
    return .invalid(line)
}

// 2.3
// func mass(of entry: ManifestEntry) -> Int { }
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let mass):
        return mass
    case .container(_, let mass):
        return mass
    case .livestock(_, let count, let massEach):
        return count * massEach
    case .invalid:
        return 0
    }
}

// let A = ...
var totalMass = 0
for line in rawManifest {
    totalMass += mass(of: parseEntry(line))
}
let A = totalMass
print("A (total manifest mass) = \(A)")   // 1244

// MARK: Level 3 · Crew Snapshots

// 3.1
// struct CrewSnapshot { }
struct CrewSnapshot {
    var name: String
    var deck: Deck
    var oxygen: Int
 
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
// let crewRoster: [CrewSnapshot] = ...
var builtRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        builtRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
}
let crewRoster: [CrewSnapshot] = builtRoster

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
var original = crewRoster[0]
var copy = original
copy.oxygen = 1
print("copy:  original=\(original.oxygen) copy=\(copy.oxygen)")        // 62 and 1
 
func dropByValue(_ s: CrewSnapshot) {
    var local = s
    local.oxygen -= 10
}
func dropInout(_ s: inout CrewSnapshot) {
    s.oxygen -= 10           // changes the caller's variable
}
dropByValue(original)
print("plain parameter: \(original.oxygen)")                           // still 62
dropInout(&original)
print("inout: \(original.oxygen)")                                     // 52

// MARK: Level 4 · The Teleport Pod

// 4.1
// final class TeleportPod { }
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var shotsFired = 0
 
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
    }
 
    func load() {
        chargeLevel += 10
    }
 
    // returns false when the pod is empty
    func fire() -> Bool {
        if chargeLevel >= 10 {
            chargeLevel -= 10
            shotsFired += 1
            return true
        }
        return false
    }
 
    // Bonus: deinit runs when the last reference goes away
    deinit {
        print("pod \(id) deallocated")
    }
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
// let C = ...
let ledgerPod = TeleportPod(id: "L", chargeLevel: 0)
for _ in 1...3 {
    ledgerPod.load()
    _ = ledgerPod.fire()
}
let emptyShot = ledgerPod.fire()          // false, pod is empty
print("empty fire succeeded? \(emptyShot)")
let C = ledgerPod.shotsFired              // 3
print("C (shots fired) = \(C)")


// 4.3 · Reference-semantics demonstration
let podOne = TeleportPod(id: "R1", chargeLevel: 100)
let podTwo = podOne                        // same object, not a copy
podTwo.chargeLevel = 0
print("podOne.chargeLevel = \(podOne.chargeLevel)")   // 0

// MARK: Level 5 · Station Systems

// 5.1
// final class Station { }
final class Station {
    var oxygen: Int {
        didSet {
            if oxygen > 100 {
                oxygen = 100
            } else if oxygen < 0 {
                oxygen = 0
            }
        }
    }
 
    
    lazy var statusText: String = "Oxygen at \(oxygen)"
 
    init(oxygen: Int) {
        self.oxygen = oxygen
    }
}
 
let station = Station(oxygen: 50)

// let B = ...


// 5.2 · The clamp trap: 130, then -40, then 55
station.oxygen = 130
print("after 130: \(station.oxygen)")   // 100
station.oxygen = -40
print("after -40: \(station.oxygen)")   // 0
station.oxygen = 55
print("after 55:  \(station.oxygen)")   // 55
let B = station.oxygen                   // 55
print("B = \(B)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen
 //   Expected: crew lose 10 oxygen.   Actual: roster unchanged.
 //   Rule: structs are copied. `for var member` is a copy of each element.
 //   Fix: loop by index:  for i in 0..<roster.count { roster[i].oxygen -= 10 }

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100
 //   Expected: 100.   Actual: 0.
 //   Rule: classes are reference types; `let podB = podA` is the same object.
 //   Fix: make a second object: TeleportPod(id: "B", chargeLevel: podA.chargeLevel)
 

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}
 //   Error: cannot mutate `entries` in a non-mutating method.
 //   Rule: struct methods can't change self unless marked `mutating`.
 //   Fix: `mutating func add(...)`, and call it on a `var` Logbook.

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/
//   `let snapshot` is a struct, so ALL its properties are frozen.
//   Fix: `var snapshot = ...`.
//   The pod lines are fine: `let pod` freezes only the reference,
//   the object's var properties can still change.

// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

// final class FlightRecorder { }

// A free function elsewhere in the file that uses your fileprivate helper:
// func auditTranscript(of recorder: FlightRecorder) -> String { }

final class FlightRecorder {
    // private(set): anyone can read entries, only this class can write them
    private(set) var entries: [String] = []
 
    // private: only inside this class body (and its extensions in this file)
    private var isSealed = false
 
    // internal (default): visible everywhere in the module
    func log(_ text: String) {
        if isSealed == false {
            entries.append(text)
        }
    }
 
    func seal() {
        isSealed = true
    }
 
    // fileprivate: usable by other code in THIS FILE only
    fileprivate func rawTranscript() -> String {
        var result = ""
        for entry in entries {
            result += entry + "\n"
        }
        return result
    }
}
 
// Free function in the same file: it may use the fileprivate helper
func auditTranscript(of recorder: FlightRecorder) -> String {
    return "AUDIT:\n" + recorder.rawTranscript()
}
 
let recorder = FlightRecorder()
recorder.log("pod loaded")
recorder.log("pod fired")
recorder.log("teleport failed")
recorder.seal()
recorder.log("this is ignored")        // sealed
print(auditTranscript(of: recorder))
// recorder.entries.append("x")        // would NOT compile: setter is private
// recorder.isSealed = false           // would NOT compile: private


// MARK: Finale · Integrity Code

// let D = ...
// let integrityCode = "\(A)-\(B)-\(C)-\(D)"
// print("INTEGRITY CODE: \(integrityCode)")
let D = recorder.entries.count          // 3
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")   // 1244-55-3-3

// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity
do {
    let temp = TeleportPod(id: "TEMP", chargeLevel: 5)
    print("inside do-block: \(temp.id)")
}   // <- "pod TEMP deallocated" prints here
print("after do-block")
 
// === is identity (same object?). Only works on classes.
let same = (podOne === podTwo)                                          // true
let different = (podOne === TeleportPod(id: "X", chargeLevel: 0))       // false
print("podOne === podTwo: \(same), podOne === other: \(different)")

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 Structs automatically get a memberwise initializer, so CrewSnapshot(name:deck:oxygen:) works without writing anything. Classes don't get one. A class has to define its own init so every stored property is set before use, and inheritance makes an automatic one unsafe.
 
 2. What does `mutating` do to self, and why do classes never need it?
 In a struct, self is an immutable value inside methods by default. mutating makes self writable, so the method can change properties or replace the whole value. Classes are reference types: self is just a pointer, and changing the object's properties never changes the pointer. So they don't need the keyword.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 Struct: the whole value. Every property is frozen, so snapshot.oxygen = 40 fails to compile.
 Class: only the reference, meaning the constant can't point to a different object. The object's var properties can still change, so pod.chargeLevel = 10 works.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 A lazy property has no value at init and gets one the first time it is read. That is a change after initialization, so it must be var. It changes behaviour when its initial value depends on other properties. It reads them at first access, not at init, so it can capture a different value. For example, statusText in Station shows whatever the oxygen is when you first read it.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 rawTranscript() is fileprivate because the free function auditTranscript(of:) sits outside the class, in the same file, and calls it. With private, that call wouldn't compile, since private only allows access inside the class body.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 deinit: it fires at the closing } of the do block. The TEMP pod's last reference ends there, so "pod TEMP deallocated" prints right before "after do-block".
 ===: it checks object identity, meaning whether two references point to the same object in memory. Structs are values with no identity. Every copy is independent, so === only works on classes.

*/
