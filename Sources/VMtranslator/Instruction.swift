//
//  Instruction.swift
//  
//
//  Created by Connor Barnes on 2/28/21.
//

/// A type representing an instruction or pseudo-instruction.
enum Instruction {
	/// An A-instruction with the given literal (either an integer or identifier)
	case aInstruction (Literal)
	/// A C-instruction with the given destination, computation, and jump components.
	case cInstruction (destination: Destination, computation: Computation, jump: Jump)
	/// A label declaration (a pseudo-instruction) declaring the given label.
	case declareLabel (String)
}

// MARK:- Custom string convertible
extension Instruction {
	var description: String {
		switch self {
		case .aInstruction(let literal):
			return "@\(literal)"
		case .cInstruction(let destination, let computation, let jump):
			var instructionString = ""
			
			if !destination.description.isEmpty {
				instructionString += destination.description + "="
			}
			
			instructionString += computation.description
			
			if !jump.description.isEmpty {
				instructionString += ";" + jump.description
			}
			
			return instructionString
		case .declareLabel(let label):
			return "(" + label + ")"
		}
	}
}

// MARK:- InstructionCommentPair
typealias CommentedInstruction = (instruction: Instruction?, comment: String?)
