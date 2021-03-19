//
//  Parser.swift
//  
//
//  Created by Connor Barnes on 3/15/21.
//

import Foundation

/// A type that can parse a VM file.
struct Parser {
	/// Parses the VM file or directory of VM files at the given url.
	/// - Parameter url: The url of the vm file to parse or the url of a directory which includes the vm files to parse.
	/// - Throws: If the file(s) couldn't be parsed.
	/// - Returns: The commented commands in the VM file(s).
	func parse(
		fileAt url: URL
	) throws -> [([CommentedCommand], String)] {
		let sourceURLs: [URL]

		if url.pathExtension == "vm" {
			// Single file
			sourceURLs = [inputURL]
		} else if inputURL.pathExtension == "" {
			// Folder
			do {
				sourceURLs = try FileManager
					.default
					.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)
					.filter { $0.pathExtension == "vm" }
			} catch {
				print("Error opening directory \(inputURL.path)")
				exit(1)
			}
			
		} else {
			// Invalid file
			print("Invalid file type \".\(inputURL.pathExtension)\"")
			exit(1)
		}
		
		return try sourceURLs.map { (try parse(vmFileAt: $0), $0.lastPathComponent) }
	}
}
	
// MARK:- Helper functions
private extension Parser {
	/// Parses an individual VM file.
	/// - Parameter url: The url of the VM file.
	/// - Throws: If the VM file could not be parsed.
	/// - Returns: The commented commands in the VM file.
	private func parse(
		vmFileAt url: URL
	) throws -> [CommentedCommand] {
		return try String(contentsOf: url)
			.split(whereSeparator: \.isNewline)
			.enumerated()
			// TODO: Fix the line numbers skipping empty lines
			.map { ($0.1, $0.0 + 1) }
			.filter { !$0.0.isEmpty }
			.map { (line: Substring, lineNumber: Int) -> (String, String, Int) in
				let components = line.components(separatedBy: "//")
				
				return (components.first!,
								components.dropFirst().joined(separator: " "),
								lineNumber)
			}
			.map { ($0.0.split(whereSeparator: \.isWhitespace), $0.1, $0.2) }
			.map { components, string, lineNumber in
				try parse(lineComponents: components,
									comment: string == "" ? nil : string,
									lineNumber: lineNumber)
			}
	}
	
	/// Parses a single line.
	/// - Parameters:
	///   - components: The components of the line split on whitespace.
	///   - comment: The line's comment.
	///   - lineNumber: The line number.
	/// - Throws: If the line could not be parsed.
	/// - Returns: The command and or comment that this line represents.
	func parse(
		lineComponents components: [Substring],
		comment: String?,
		lineNumber: Int
	) throws -> CommentedCommand {
		if components.isEmpty {
			return (command: nil,
							rawValue: "",
							comment: comment)
		} else {
			return (command: try parse(commandComponents: components,
																 lineNumber: lineNumber),
							rawValue: components.joined(separator: " "),
							comment: comment)
		}
	}
	
	/// Returns the arithmetic command for the given name if there is one.
	/// - Parameter string: The name of the command.
	/// - Returns: The arithmetic command with the given name if there is one, otherwise `nil`.
	func arithmeticCommand(
		fromString string: Substring
	) -> VM.ArithmeticCommand? {
		switch string {
		case ("add"):
			return .add
		case ("sub"):
			return .sub
		case ("neg"):
			return .neg
		case ("eq"):
			return .eq
		case ("gt"):
			return .gt
		case ("lt"):
			return .lt
		case ("and"):
			return .and
		case ("or"):
			return .or
		case ("not"):
			return .not
		default:
			return nil
		}
	}
	
	/// Parses a memory access command.
	/// - Parameters:
	///   - name: The name of the command.
	///   - segmentString: The value provided for the segment argument.
	///   - offsetString: The value provided for the segment argument.
	///   - lineNumber: The line number.
	/// - Throws: If the command was invalid.
	/// - Returns: The parsed memory access command.
	func parseMemoryAccessCommand(
		named name: Substring,
		segment segmentString: Substring,
		offset offsetString: Substring,
		lineNumber: Int
	) throws -> VM.Command {
		let segment = try parse(segment: segmentString, lineNumber: lineNumber)
		
		guard let offset = Int(offsetString) else {
			throw Error.invalidOffset(lineNumber: lineNumber, offset: offsetString)
		}
		
		if name == "pop" {
			if segment == .constant {
				throw Error.invalidSegment(lineNumber: lineNumber, segment: "constant")
			}
			
			return .memoryAccess(.pop(segment: segment, offset: offset))
		} else {
			return .memoryAccess(.push(segment: segment, offset: offset))
		}
	}
	
	/// Returns the program flow command with the given name and symbol if there is one.
	/// - Parameters:
	///   - name: The name of the command.
	///   - symbol: The symbol given for the command's argument.
	/// - Returns: The program flow command with the given name and symbol if there is one, otherwise `nil`.
	func programFlowCommand(
		named name: Substring,
		symbol: String
	) -> VM.Command? {
		switch name {
		case "label":
			return .programFlow(.label(symbol))
		case "goto":
			return .programFlow(.goto(symbol))
		case "if-goto":
			return .programFlow(.ifGoto(symbol))
		default:
			return nil
		}
	}
	
	/// Parses a function call command.
	/// - Parameters:
	///   - name: The name of the command.
	///   - arguments: The arguments that were given to the command.
	///   - lineNumber: The line number.
	/// - Throws: If the command could not be parsed.
	/// - Returns: The pared function call command.
	func parseFunctionCallCommand(
		named name: Substring,
		arguments: [Substring],
		lineNumber: Int
	) throws -> VM.Command {
		if name == "return" {
			if arguments.count == 0 {
				return .functionCall(.return)
			} else {
				throw Error.invalidNumberOfArguments(lineNumber: lineNumber,
																						 count: arguments.count,
																						 expected: 0)
			}
		}
		
		// Not return, both other cases take 2 args
		guard arguments.count == 2 else {
			throw Error.invalidNumberOfArguments(lineNumber: lineNumber,
																					 count: arguments.count,
																					 expected: 0)
		}
		
		switch name {
		case ("function"):
			guard let numberOfLocals = Int(arguments[2]) else {
				throw Error.invalidNumberOfLocals(lineNumber: lineNumber,
																					numberOfLocals: arguments[2])
			}
			return .functionCall(.function(name: String(arguments[1]),
																		 argumentCount: numberOfLocals))
		case ("call"):
			guard let argumentCount = Int(arguments[2]) else {
				throw Error.invalidArgumentCount(lineNumber: lineNumber,
																				 argumentCount: arguments[2])
			}
			return .functionCall(.call(name: String(arguments[1]),
																 argumentCount: argumentCount))
		default:
			fatalError("Internal Error")
		}
	}
	
	/// Parses a command with the given components.
	/// - Parameters:
	///   - components: The components of the command (including the command name).
	///   - lineNumber: The line number.
	/// - Throws: If the command could not be parsed.
	/// - Returns: The parsed command.
	func parse(
		commandComponents components: [Substring],
		lineNumber: Int
	) throws -> VM.Command {
		switch (components.first!, components.dropFirst().count) {
		// Arithmetic commands
		case (let name, 0)
					where arithmeticCommand(fromString: name) != nil:
			return .arithmetic(arithmeticCommand(fromString: name)!)
			
		case (let name, let count)
					where arithmeticCommand(fromString: name) != nil:
			throw Error.invalidNumberOfArguments(lineNumber: lineNumber,
																					 count: count,
																					 expected: 0)
			
		// Push pop commands
		case (let name, 2) where name == "push" || name == "pop":
			return try parseMemoryAccessCommand(named: name,
																					segment: components[1],
																					offset: components[2],
																					lineNumber: lineNumber)
			
		case ("push", let count),
				 ("pop", let count):
			throw Error.invalidNumberOfArguments(lineNumber: lineNumber,
																					 count: count,
																					 expected: 2)
		// Program flow commands
		case (let name, 1)
					where programFlowCommand(named: name,
																	 symbol: String(components[1])) != nil:
			
			return programFlowCommand(named: name, symbol: String(components[1]))!
		
		case (let name, let count)
					where programFlowCommand(named: name,
																	 symbol: String(components[1])) != nil:
			
			throw Error.invalidNumberOfArguments(lineNumber: lineNumber,
																					 count: count,
																					 expected: 1)
		// Function calling commands
		case (let name, _) where ["function", "call", "return"].contains(name):
			return try parseFunctionCallCommand(named: name,
																					arguments: Array(components.dropFirst()),
																					lineNumber: lineNumber)
			
		// Invalid commands
		case (let commandName, _):
			throw Error.invalidCommandName(lineNumber: lineNumber,
																		 name: commandName)
		}
	}
	
	/// Parses a segment argument.
	/// - Parameters:
	///   - segment: The name of the segment.
	///   - lineNumber: The line number.
	/// - Throws: If the segment could not be parsed.
	/// - Returns: The parsed segment argument.
	func parse(
		segment: Substring,
		lineNumber: Int
	) throws -> VM.MemorySegment {
		switch segment {
		case "argument":
			return .argument
		case "local":
			return .local
		case "static":
			return .static
		case "constant":
			return .constant
		case "this":
			return .this
		case "that":
			return .that
		case "pointer":
			return .pointer
		case "temp":
			return .temp
		default:
			throw Error.invalidSegment(lineNumber: lineNumber, segment: segment)
		}
	}
}

// MARK:- Error
extension Parser {
	/// An error that can be encountered while parsing.
	enum Error: Swift.Error {
		/// The given segment argument was not a valid segment.
		///
		/// - Parameters:
		///   - lineNumber: The line that the error occurred on.
		///   - segment: The value that was provided for the segment argument.
		case invalidSegment (lineNumber: Int, segment: Substring)
		/// The given offset was invalid.
		///
		/// - Parameters:
		///   - lineNumber: The line number that the error occurred on.
		///   - offset: The value that was provided for the offset argument.
		case invalidOffset (lineNumber: Int, offset: Substring)
		/// The given number of locals argument was not valid.
		///
		/// - Parameters:
		///   - lineNumber: The line number that the error occurred on.
		///   - offset: The value that was provided for the number of locals argument.
		case invalidNumberOfLocals (lineNumber: Int, numberOfLocals: Substring)
		/// The given argument count argument was invalid.
		///
		/// - Parameters:
		///   - lineNumber: The line number that the error occurred on.
		///   - offset: The value that was provided for the argument count argument.
		case invalidArgumentCount (lineNumber: Int, argumentCount: Substring)
		/// The number of provided arguments was invalid.
		///
		/// - Parameters:
		///   - lineNumber: The line number that the error occurred on.
		///   - count: The number of arguments that were provided.
		///   - expected: The number of arguments that was expected.
		case invalidNumberOfArguments (lineNumber: Int, count: Int, expected: Int)
		/// The given command name was invalid.
		///
		/// - Parameters:
		///   - lineNumber: The line number that the error occurred on.
		///   - offset: The value that was provided for the name of the command was not valid.
		case invalidCommandName (lineNumber: Int, name: Substring)
		
		var localizedDescription: String {
			switch self {
			case .invalidSegment(let lineNumber, let segment):
				return "Invalid segment \"\(segment)\" on line \(lineNumber)"
			case .invalidOffset(let lineNumber, let offset):
				return "Invalid offset \"\(offset)\" on line \(lineNumber)"
			case .invalidNumberOfLocals(let lineNumber, let numberOfLocals):
				return "Invalid number of function local variables \"\(numberOfLocals)\" on line \(lineNumber)"
			case .invalidArgumentCount(let lineNumber, let argumentCount):
				return "Invalid function argument count \"\(argumentCount)\" on line \(lineNumber)"
			case .invalidNumberOfArguments(let lineNumber, let count, let expected):
				return "Expected \(expected) arguments but received \(count) on line \(lineNumber)"
			case .invalidCommandName(let lineNumber, let name):
				return "Invalid command \"\(name)\" on \(lineNumber)"
			}
		}
	}
}
