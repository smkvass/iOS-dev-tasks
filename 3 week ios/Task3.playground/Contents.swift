// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
// func parseReading(_ raw: String) -> Reading? { }
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":" ),
          sensor.isEmpty == false,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else {
        return nil
    }
    return (sensor: sensor, value: value)
}

print(parseReading("RAD:3"))
print(parseReading("TEMP:-12"))
print(parseReading("RAD:abc"))
print(parseReading(":55"))
print(parseReading("hello"))

// 1.2
// func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) { }
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int){
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

// let A = ...
let parsed = parseLog(rawLog)
print("Valid: \(parsed.valid.count), invalid: \(parsed.invalidCount)")
let parsedSmall = parseLog(["O2:50", "bad", "TEMP:-5"])
print("Small log -> valid: \(parsedSmall.valid), invalid: \(parsedSmall.invalidCount)")

let A = parsed.invalidCount
print("Fragment A = \(A)")

// MARK: Level 2 · Analysis

// 2.1
// func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] { }
// func values(of readings: [Reading]) -> [Int] { }

func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading]{
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let validReadings = parsed.valid
let o2Readings = select(validReadings) { $0.sensor == "O2" }
print("O2 readings: \(o2Readings)")
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
print("TEMP readings: \(tempReadings)")
let bigReadings = select(validReadings) { $0.value > 90 }
print("Readings > 90: \(bigReadings)")
print("O2 values: \(values(of: o2Readings))")
print("TEMP values: \(values(of: tempReadings))")

// 2.2
// func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? { }
// func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? { }
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}
 
print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: [10, 20]) as Any)
print(stats(of: []) as Any)

// let B = ...
let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)
print("Fragment B = \(B)")


let ladder1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
 

let ladder2 = validReadings.sorted(by: { a, b in
    return a.value > b.value
})
 

let ladder3 = validReadings.sorted(by: { a, b in a.value > b.value })
 

let ladder4 = validReadings.sorted(by: { $0.value > $1.value })
 
// 5. Trailing closure
let ladder5 = validReadings.sorted { $0.value > $1.value }
 
func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}
 
let allLadderMatch = sameReadings(ladder1, ladder2)
    && sameReadings(ladder1, ladder3)
    && sameReadings(ladder1, ladder4)
    && sameReadings(ladder1, ladder5)
print("Sorted values: \(values(of: ladder5))")
print("All 5 closure sorts match: \(allLadderMatch)")


// MARK: Level 3 · Temperature Stabilization

// 3.1
// func heatUp(_ t: Int) -> Int { }
// func coolDown(_ t: Int) -> Int { }
// func hold(_ t: Int) -> Int { }
// func chooseProtocol(for temp: Int) -> (Int) -> Int { }

func heatUp(_ t: Int) -> Int { return t + 5 }
func coolDown(_ t: Int) -> Int { return t - 3 }
func hold(_ t: Int) -> Int { return t }
 

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}
 

print(chooseProtocol(for: 10)(10))   // heatUp   -> 15
print(chooseProtocol(for: 30)(30))   // coolDown -> 27
print(chooseProtocol(for: 20)(20))   // hold     -> 20

// 3.2
// func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) { }
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: temp >= 18 && temp <= 24)
}
 

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))
print(runUntilStable(from: 20))
// let C = ...
let lowestTemp = stats(of: values(of: tempReadings))?.min ?? 0
print("Lowest valid temperature: \(lowestTemp)")
let C = runUntilStable(from: lowestTemp).steps
print("Fragment C = \(C)")

// MARK: Level 4 · The Crew

// 4.1
// func oxygenLevel(of member: CrewMember) -> Int? { }
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}
 

print(oxygenLevel(of: crew[0]) as Any)
print(oxygenLevel(of: crew[1]) as Any)
print(oxygenLevel(of: crew[3]) as Any)

// 4.2
// func status(of member: CrewMember) -> String { }
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    }
    return "\(member.name): \(level)% OK"
}
 

print("--- Crew status BEFORE transfer ---")
for member in crew {
    print(status(of: member))
}
 

// 4.3
// @discardableResult
// func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int { }
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let moved = max(0, min(amount, source, 100 - target))
    source -= moved
    target += moved
    return moved
}
 
// let D = ...

var testSource = 50
var testTarget = 95
let movedTest = transferOxygen(from: &testSource, to: &testTarget, amount: 30)
print("Moved \(movedTest): source=\(testSource), target=\(testTarget)")
 
var poorSource = 10
var emptyTarget = 0
transferOxygen(from: &poorSource, to: &emptyTarget, amount: 30)
print("Poor source: source=\(poorSource), target=\(emptyTarget)")
 
var negSource = 20
var negTarget = 20
let movedNeg = transferOxygen(from: &negSource, to: &negTarget, amount: -5)
print("Negative amount moved \(movedNeg): \(negSource), \(negTarget)")

 
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred \(moved) from Lab to Hab")
} else {
    print("Transfer impossible: a tank is missing")
}
 
let D = hab.oxygenTank?.level ?? 0
print("Fragment D = \(D)")
 
print("--- Crew status AFTER transfer ---")
for member in crew {
    print(status(of: member))
}

// 4.4
// func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] { }
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let byPriority = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in byPriority {
        result.append(member.name)
    }
    return result
}
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Aigerim", roster: roster))
print(evacuationOrder(roster: roster))

// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.


/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let module = member.module,
          let tank = module.oxygenTank else {
        return "\(member.name): no data"
    }
    
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else {
            continue
        }
        
        if level < 20 {
            return member.name
        }
    }
    
    return nil
}

let testCrew = [
    CrewMember(
        name: "First",
        role: "Engineer",
        priority: 1,
        module: Module(name: "Test1", oxygenTank: Tank(level: 10))
    ),
    CrewMember(
        name: "Second",
        role: "UI/UI Designer",
        priority: 2,
        module: Module(name: "Test2", oxygenTank: Tank(level: 5))
    )
]

print(firstCritical(in: testCrew) ?? "No critical member")


// MARK: Finale · Launch Code

// let launchCode = "\(A)-\(B)-\(C)-\(D)"
// print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

// func makeAlarm(threshold: Int) -> (Int) -> Bool { }


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
 guard let checks a value and stops the function if the value is nil.
 After guard let, we can use the value in the rest of the function.
 if let puts the code inside an if block, so it can be more difficult to read.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 Int... means we give separate numbers, not an array.
 For example: stats(1, 2, 3) // correct stats([1, 2, 3]) // wrong

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
 Because x is the same variable for both inout parameters.
 Swift does not allow this because it can cause a conflict.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 oxygenLevel returns an Int?, but "no data" is a String. The types must be the same.
 For example: oxygenLevel(of: dana) ?? 0
 
 5. Full type of chooseProtocol and how to read it:
 (Int) -> (Int) -> Int It takes an Int and returns a function.
 The new function also takes an Int and returns an Int.
 
 Bonus. Where does the alarm counter live after makeAlarm returns?
 The closure keeps the counter in memory. So, even after makeAlarm finishes,
 the closure can still use the counter.
 

*/
