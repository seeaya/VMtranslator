//
//  main.swift
//
//
//  Created by Connor Barnes on 3/15/21.
//

import Foundation

// Parse arguments
let argumentCount = CommandLine.arguments.count - 1
guard argumentCount == 1 else {
	print("Expected 1 argument, but received \(argumentCount)")
	exit(1)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])

// Parse
let parsed: [([CommentedCommand], String)]
do {
	parsed = try Parser().parse(fileAt: inputURL)
} catch {
	print("Error parsing file: \(error)")
	exit(1)
}

// Translate
let translated = Translator().translate(components: parsed)

// Write to file
do {
	try FileWriter().write(instructions: translated, to: inputURL)
} catch {
	print("Error writing file: \(error)")
	exit(10)
}
