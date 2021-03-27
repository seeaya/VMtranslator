//
//  ProgramFlowCommand.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

extension VM {
	/// A program flow command.
	enum ProgramFlowCommand {
		/// Declares a label with the given symbol.
		case label (String)
		/// Goes to the given label.
		case goto (String)
		/// Goes to the given label if the top of the stack is true.
		case ifGoto (String)
	}
}

// MARK:- Command conversion
extension VM.ProgramFlowCommand {
	/// The assembly instructions that will execute this command.
	var instructions: [CommentedInstruction] {
		switch self {
		case .label(let name):
			return instructionsForLabel(named: name)
		case .goto(let name):
			return instructionsForGoto(label: name)
		case .ifGoto(let name):
			return instructionForIfGoto(label: name)
		}
	}
}

// MARK:- Helper functions
/// Returns the fully qualified name for a given label.
/// - Parameter name: The label to find the fully qualified name for.
/// - Returns: The label's fully qualified name.
private func fullLabelName(for name: String) -> String {
	return (Parser.currentFunctionName ?? "") + "$" + name
}

/// Returns the instructions for declaring a label.
/// - Parameter name: The name of the label to declare.
/// - Returns: The generated instructions.
private func instructionsForLabel(named name: String) -> [CommentedInstruction] {
	return [
		(Instruction.declareLabel(fullLabelName(for: name)), nil)
	]
}

/// Returns the instructions for a goto command.
/// - Parameter label: The name of the label to goto.
/// - Returns: The generated instructions.
private func instructionsForGoto(label: String) -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.identifier(fullLabelName(for: label))), nil),
		(Instruction.cInstruction(destination: [],
															computation: .zero,
															jump: [.lessThan, .equalTo, .greaterThan]), nil)
	]
}

/// Returns the instructions for an if-goto command.
/// - Parameter label: The name of the label to goto.
/// - Returns: The generated instructions.
private func instructionForIfGoto(label: String) -> [CommentedInstruction] {
	return instructionsForLocalPop()
		+ [
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.identifier(fullLabelName(for: label))), nil),
			(Instruction.cInstruction(destination: [],
																computation: .d,
																jump: [.lessThan, .greaterThan]), nil)
		]
}
