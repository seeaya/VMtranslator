//
//  Translator.swift
//  
//
//  Created by Connor Barnes on 3/15/21.
//

/// A type that can translate VM comments and commands into instructions.
struct Translator {
	/// Translates the given VM comments and commands into instructions.
	/// - Parameter components: An array of tuples where the first element in the tuple is an array of VM comments and commands and the second element in the tuple is the name of the file.
	/// - Returns: The translated assembly instructions.
	func translate(
		components: [(commands: [CommentedCommand], fileName: String)]
	) -> [CommentedInstruction] {
		return components
			.flatMap { translateFile(withCommands: $0.commands, fileName: $0.fileName) }
	}
}

// MARK: Helper functions
private extension Translator {
	/// Translates a single parsed VM file into instructions.
	/// - Parameters:
	///   - commands: The parsed VM comments and commands in the file.
	///   - fileName: The name of the file.
	/// - Returns: The translated assembly instructions.
	func translateFile(
		withCommands commands: [CommentedCommand],
		fileName: String
	) -> [CommentedInstruction] {
		// Add filename and marker at top for easier debugging
		return [(nil, "\(fileName) " + String(repeating: "-", count: 60))]
			+ commands.flatMap { translate(command: $0) }
	}
	
	/// Translates a single VM command into instructions.
	/// - Parameter command: The VM command to translate.
	/// - Returns: The translated assembly instructions.
	func translate(
		command: CommentedCommand
	) -> [CommentedInstruction] {
		// Add the user comments above the instructions
		let commentInstructions: [CommentedInstruction]
		if let comment = command.comment {
			commentInstructions = [(nil, comment)]
		} else {
			commentInstructions = []
		}
		
		// Add the VM command as a comment above the instructions for easier debugging
		let rawCommandInstructions: [CommentedInstruction] = command.rawValue.isEmpty ? [] : [(nil, command.rawValue)]
		
		return commentInstructions
			+ rawCommandInstructions
			+ (command.command?.instructions ?? [])
	}
}
