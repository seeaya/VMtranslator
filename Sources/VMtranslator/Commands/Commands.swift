//
// Commands.swift
//  
//
//  Created by Connor Barnes on 3/15/21.
//

/// A namespace for holding VM commands.
enum VM { }

// MARK: VM.Command
extension VM {
	/// A VM command.
	enum Command {
		/// An arithmetic or logic command.
		case arithmetic (ArithmeticCommand)
		/// A memory access command.
		case memoryAccess (MemoryAccessCommand)
		/// A program flow command.
		case programFlow (ProgramFlowCommand)
		/// A function call command.
		case functionCall (FunctionCallCommand)
	}
}

// MARK:- CommentedCommand
typealias CommentedCommand = (command: VM.Command?, rawValue: String, comment: String?)

// MARK: Instruction conversion
extension VM.Command {
	/// The instructions for performing the command.
	/// - Parameter filename: The name of the file the instructions are in.
	/// - Returns: The generated instructions.
	func instructions(forFilename filename: String) -> [CommentedInstruction] {
		switch self {
		case .arithmetic(let command):
			return command.instructions
		case .functionCall(let command):
			return command.instructions
		case .memoryAccess(let command):
			return command.instructions(forFilename: filename)
		case .programFlow(let command):
			return command.instructions
		}
	}
}

// MARK: Universal helper functions
/// Returns the instructions for decrementing the stack pointer and setting A to the top of the stack
/// - Returns: The generated instructions.
func instructionsForLocalPop() -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.identifier("SP")), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .decM,
															jump: []), nil),
		(Instruction.cInstruction(destination: .a,
															computation: .m,
															jump: []), nil)
	]
}

/// Returns the instructions for incrementing the stack pointer and setting the top of the stack to D.
/// - Returns: The generated instructions.
func instructionsForLocalPush() -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.identifier("SP")), nil),
		(Instruction.cInstruction(destination: .a,
															computation: .m,
															jump: []), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil)
	]
	+ instructionsForIncrementStack()
}

/// Returns the instructions for incrementing the stack pointer.
/// - Returns: The generated instructions.
func instructionsForIncrementStack() -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.identifier("SP")), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .incM,
															jump: []), nil)
	]
}
