//
//  FunctionCallCommand.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

extension VM {
	/// A function call command.
	enum FunctionCallCommand {
		/// Declares a function with the given name and number of arguments.
		case function (name: String, argumentCount: Int)
		/// Calls the function with the given name and argument count.
		case call (name: String, argumentCount: Int)
		/// Returns from the current function.
		case `return`
	}
}

// MARK:- Command conversion
extension VM.FunctionCallCommand {
	var instructions: [CommentedInstruction] {
		#warning("Not implemented")
		fatalError("Function call commands are not implemented")
	}
}
