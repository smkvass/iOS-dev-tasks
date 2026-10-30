import Cocoa

//Easy tasks
//1
let fruits = ["Apple", "Banana", "Orange", "Watermelon", "Pear"]
print(fruits[2])

//2
var numbers: Set<Int> = [1, 2, 3, 4, 5]
numbers.insert(6)
print(numbers)

//3
let languages = ["C++": 1985, "Python": 1991, "Swift": 2014]
print(languages["Swift"])

//4
var colors = ["Black", "Purple", "Pink", "White"]
colors[1] = "Blue"
print(colors)

//Medium
//1
let set1 = Set([1, 2, 3, 4])
let set2 = Set([3, 4, 5, 6])
let result = set1.intersection(set2)
print(result)


//2
var students = ["Saya" : 90, "Nazerke" : 91, "Qalamqas": 95]
students["Saya"] = 93
print(students)

//3
let array1 = ["apple", "banana"]
let array2 = ["cherry", "date"]
let merged = array1 + array2
print(merged)

//Hard tasks
//1
var countries = ["Kazakhstan" : 20694819, "China" : 1412226668, "India" : 1470000000]
countries["Korea"] = 51600000
print(countries)

//2
let set_1 = Set(["cat", "dog"])
let set_2 = Set(["dog", "mouse"])

let result_1 = set_1.union(set_2)
let result_2 = result_1.subtracting(set_2)
print(result_2)

//3
var grades = [
    "Sarah": [90, 91, 88],
    "Sophia" : [85, 87, 82],
    "Toreali": [88, 92, 90]
]
print(grades["Sarah"]![1])

