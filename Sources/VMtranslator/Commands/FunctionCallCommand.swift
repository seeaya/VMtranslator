//
//  FunctionCallCommand.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

extension VM {
	/// A function call command.
	enum FunctionCallCommand {
		/// Declares a function with the given name and number of local variables.
		case function (name: String, localVariableCount: Int)
		/// Calls the function with the given name and argument count.
		case call (name: String, argumentCount: Int)
		/// Returns from the current function.
		case `return`
	}
}

// MARK:- Command conversion
extension VM.FunctionCallCommand {
	/// Returns the instructions that will execute the command.
	var instructions: [CommentedInstruction] {
		switch self {
		case .function(let name, let localVariableCount):
			return instructionsForFunction(named: name,
																		 localVariableCount: localVariableCount)
		case .call(let name, let argumentCount):
			return instructionsForCall(functionName: name,
																 argumentCount: argumentCount)
		case .return:
			return instructionsForReturn()
		}
	}
}

// MARK:- Helper functions
/// Returns the instructions for assigning to the given identifier from the value at the given pointer and offset.
/// - Parameters:
///   - identifier: The identifier to assign to.
///   - base: The pointer's base.
///   - offset: The offset from the pointer's base.
/// - Returns: The generated instructions.
private func instructionsForAssign(
	to identifier: String,
	fromPointerOffsetFrom base: Int,
	by offset: Int
) -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.integer(base)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .m,
															jump: []), nil),
		(Instruction.aInstruction(.integer(offset)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .subDA,
															jump: []), nil),
		(Instruction.cInstruction(destination: .a,
															computation: .d,
															jump: []), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .m,
															jump: []), nil),
		(Instruction.aInstruction(.identifier(identifier)), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil)
	]
}

/// Returns the instructions for performing a return command.
/// - Returns: The generated commands.
private func instructionsForReturn() -> [CommentedInstruction] {
	return [
		[
			// FRAME = LCL
			(Instruction.aInstruction(.identifier("LCL")), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.integer(13)), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil),
			// Put return-address in a temp var (RET = *(FRAME - 5))
			(Instruction.aInstruction(.integer(5)), nil),
			(Instruction.cInstruction(destination: .a,
																computation: .subDA,
																jump: []), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.integer(14)), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil)
		],
		instructionsForLocalPop(),
		[
			// Reposition return value for caller (*ARG = pop())
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.identifier("ARG")), nil),
			(Instruction.cInstruction(destination: .a,
																computation: .m,
																jump: []), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil),
			// SP = ARG + 1
			(Instruction.aInstruction(.identifier("ARG")), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .incM,
																jump: []), nil),
			(Instruction.aInstruction(.identifier("SP")), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil),
		],
		// THAT = *(FRAME - 1)
		instructionsForAssign(to: "THAT", fromPointerOffsetFrom: 13, by: 1),
		// THIS = *(FRAME - 2)
		instructionsForAssign(to: "THIS", fromPointerOffsetFrom: 13, by: 2),
		// ARG = *(FRAME - 3)
		instructionsForAssign(to: "ARG", fromPointerOffsetFrom: 13, by: 3),
		// LCL = *(FRAME - 4)
		instructionsForAssign(to: "LCL", fromPointerOffsetFrom: 13, by: 4),
		[
			// Goto return address (goto RET)
			(Instruction.aInstruction(.integer(14)), nil),
			(Instruction.cInstruction(destination: .a,
																computation: .m,
																jump: []), nil),
			(Instruction.cInstruction(destination: [],
																computation: .zero,
																jump: [.lessThan, .equalTo, .greaterThan]), nil)
		]
	].flatMap { $0 }
}

/// Returns the instructions for performing a local push and moving the pushed value into the given
/// identifier.
/// - Parameter identifier: The identifier to push into.
/// - Returns: The generated instructions.
private func instructionsForLocalPush(
	of identifier: String,
	isReference: Bool = false
) -> [CommentedInstruction] {
	return [
		(Instruction.aInstruction(.identifier(identifier)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: isReference ? .a : .m,
															jump: []), nil)
	]
		+ instructionsForLocalPush()
}

/// Returns the instructions for performing a function call to the given function name with the given
/// number of arguments.
/// - Parameters:
///   - functionName: The name of the function to call.
///   - argumentCount: The number of arguments that have been pushed onto the stack.
/// - Returns: The generated instructions.
private func instructionsForCall(
	functionName: String,
	argumentCount: Int
) -> [CommentedInstruction] {
	let returnAddressLabel = "$CallReturn\(Parser.nextCallIndex)"
	
	return [
		// Push <return-address>
		instructionsForLocalPush(of: returnAddressLabel, isReference: true),
		// Push LCL
		instructionsForLocalPush(of: "LCL"),
		// Push ARG
		instructionsForLocalPush(of: "ARG"),
		// Push THIS
		instructionsForLocalPush(of: "THIS"),
		// Push THAT
		instructionsForLocalPush(of: "THAT"),
		[
			// Reposition ARG (ARG = SP - n - 5)
			(Instruction.aInstruction(.identifier("SP")), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.integer(argumentCount)), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .subDA,
																jump: []), nil),
			(Instruction.aInstruction(.integer(5)), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .subDA,
																jump: []), nil),
			(Instruction.aInstruction(.identifier("ARG")), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil),
			// Reposition LCL (LCL = SP)
			(Instruction.aInstruction(.identifier("SP")), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil),
			(Instruction.aInstruction(.identifier("LCL")), nil),
			(Instruction.cInstruction(destination: .m,
																computation: .d,
																jump: []), nil),
			// Transfer control (goto f)
			(Instruction.aInstruction(.identifier(functionName)), nil),
			(Instruction.cInstruction(destination: [],
																computation: .zero,
																jump: [.lessThan, .equalTo, .greaterThan]), nil),
			// Define return
			(Instruction.declareLabel(returnAddressLabel), nil)
		]
	].flatMap { $0 }
}

/// Returns the instructions for declaring a function with the given name and number of local variables.
/// - Parameters:
///   - name: The name of the function to declare.
///   - localVariableCount: The number of local variables that the function defines.
/// - Returns: The generated instructions.
private func instructionsForFunction(
	named name: String,
	localVariableCount: Int
) -> [CommentedInstruction] {
	Parser.currentFunctionName = name
	
	let startLabel = name + "$$initStart"
	let endLabel = name + "$$initEnd"
	
	return [
		// Initialize counter
		(Instruction.declareLabel(name), nil),
		(Instruction.aInstruction(.integer(localVariableCount)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .a,
															jump: []), nil),
		(Instruction.aInstruction(.integer(13)), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil),
		// Loop condition
		(Instruction.declareLabel(startLabel), nil),
		(Instruction.aInstruction(.integer(13)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .m,
															jump: []), nil),
		(Instruction.aInstruction(.identifier(endLabel)), nil),
		(Instruction.cInstruction(destination: [],
															computation: .d,
															jump: [.equalTo]), nil),
		// Loop body
		// Decrement counter
		(Instruction.cInstruction(destination: .d,
															computation: .decD,
															jump: []), nil),
		(Instruction.aInstruction(.integer(13)), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil),
		// Push 0 to stack
		(Instruction.cInstruction(destination: .d,
															computation: .zero,
															jump: []), nil)
	]
	+ instructionsForLocalPush()
	+ [
		// Jump to loop condition
		(Instruction.aInstruction(.identifier(startLabel)), nil),
		(Instruction.cInstruction(destination: [],
															computation: .zero,
															jump: [.lessThan, .equalTo, .greaterThan]), nil),
		(Instruction.declareLabel(endLabel), nil)
	]
}
