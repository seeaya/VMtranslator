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

// MARK: Command conversion
extension VM.ProgramFlowCommand {
	/// The assembly instructions that will execute this command.
	var instructions: [CommentedInstruction] {
		#warning("Not implemented")
		fatalError("Program flow commands are not implemented")
	}
}
