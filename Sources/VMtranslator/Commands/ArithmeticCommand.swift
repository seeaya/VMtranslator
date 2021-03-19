//
//  ArithmeticCommand.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

extension VM {
	/// An arithmetic or logic command.
	enum ArithmeticCommand {
		/// Pops the top two elements from the stack, adds them, and pushes the sum to the stack.
		case add
		/// Pops the top two elements from the stack, subtracts them, and pushes the difference to the stack.
		case sub
		/// Pops the top element from the stack, negates it, and pushes the result to the stack.
		case neg
		/// Pops the top two elements from the stack, pushes `true` to the stack if they are equal, or otherwise pushes `false` to the stack.
		case eq
		/// Pops the top two elements from the stack, pushes `true` to the stack if the first is greater, or otherwise pushes `false` to the stack.
		case gt
		/// Pops the top two elements from the stack, pushes `true` to the stack if the first is less, or otherwise pushes `false` to the stack.
		case lt
		/// Pops the top two elements from the stack, logically ands them, and pushes the result to the stack.
		case and
		/// Pops the top two elements from the stack, logically ors them, and pushes the result to the stack.
		case or
		/// Pops the top element from the stack, logically inverts it, and pushes the result to the stack.
		case not
	}
}

// MARK: Command conversion
extension VM.ArithmeticCommand {
	/// The instructions that execute the command.
	var instructions: [CommentedInstruction] {
		switch self {
		case .add, .sub, .and, .or:
			return instructionsFor(binary: self)
		case .eq, .gt, .lt:
			return instructionFor(binaryCompare: self)
		case .not, .neg:
			return instructionsFor(unary: self)
		}
	}
}

// MARK:- Helper functions
/// Returns the instructions for performing the given unary arithmetic command.
/// - Parameter unary: The unary command to execute.
/// - Returns: The generated instructions.
private func instructionsFor(
	unary: VM.ArithmeticCommand
) -> [CommentedInstruction] {
	return instructionsForLocalPop()
		+ computeInstructionsFor(arithmeticCommand: unary)
		+ instructionsForIncrementStack()
}

/// Returns the instructions for performing the given binary arithmetic command.
/// - Parameter binary: The binary command to execute.
/// - Returns: The generated instructions.
private func instructionsFor(
	binary: VM.ArithmeticCommand
) -> [CommentedInstruction] {
	return instructionsForLocalPop()
		+ [(Instruction.cInstruction(destination: .d,
																 computation: .m,
																 jump: []), nil)]
		+ instructionsForLocalPop()
		+ computeInstructionsFor(arithmeticCommand: binary)
		+ instructionsForLocalPush()
}

/// Stores the value used for the last label index.
private var _lastLabelIndex = -1
/// Returns the index to use for the next label.
private var nextLabelIndex: Int {
	_lastLabelIndex += 1
	return _lastLabelIndex
}

/// Returns the instructions for performing the given binary comparison command.
/// - Parameter binaryCompare: The binary compare command to execute.
/// - Returns: The generated instructions.
private func instructionFor(
	binaryCompare: VM.ArithmeticCommand
) -> [CommentedInstruction] {
	let labelIndex = nextLabelIndex
	
	let trueLabel = "CompJump\(labelIndex)True"
	let falseLabel = "CompJump\(labelIndex)False"
	let endLabel = "CompJump\(labelIndex)End"
	
	return [
		instructionsForLocalPop(),
		[(Instruction.cInstruction(destination: .d,
															 computation: .m,
															 jump: []), nil)],
		instructionsForLocalPop(),
		[
			(Instruction.cInstruction(destination: .d,
																computation: .subMD,
																jump: []), nil),
			(Instruction.aInstruction(.identifier(trueLabel)), nil)
		],
		computeInstructionsFor(arithmeticCommand: binaryCompare),
		[
			(Instruction.aInstruction(.identifier(falseLabel)), nil),
			(Instruction.cInstruction(destination: [],
																computation: .zero,
																jump: [.equalTo, .greaterThan, .lessThan]), nil),
			(Instruction.declareLabel(falseLabel), nil),
			(Instruction.aInstruction(.integer(0)), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .a,
																jump: []), nil),
			(Instruction.aInstruction(.identifier(endLabel)), nil),
			(Instruction.cInstruction(destination: [],
																computation: .zero,
																jump: [.equalTo, .greaterThan, .lessThan]), nil),
			(Instruction.declareLabel(trueLabel), nil),
			(Instruction.aInstruction(.integer(0)), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .decA,
																jump: []), nil),
			(Instruction.declareLabel(endLabel), nil)
		],
		instructionsForLocalPush()
	].flatMap { $0 }
}

/// Returns the instructions for performing the given arithmetic command.
/// - Parameter arithmeticCommand: The command to execute.
/// - Returns: The generated instructions.
private func computeInstructionsFor(
	arithmeticCommand: VM.ArithmeticCommand
) -> [CommentedInstruction] {
	switch arithmeticCommand {
	case .add:
		return [(Instruction.cInstruction(destination: .d,
																			computation: .sumDM,
																			jump: []), nil)]
	case .sub:
		return [(Instruction.cInstruction(destination: .d,
																			computation: .subMD,
																			jump: []), nil)]
	case .neg:
		return [(Instruction.cInstruction(destination: .m,
																			computation: .negM,
																			jump: []), nil)]
	case .eq:
		return [(Instruction.cInstruction(destination: [],
																			computation: .d,
																			jump: [.equalTo]), nil)]
	case .gt:
		return [(Instruction.cInstruction(destination: [],
																			computation: .d,
																			jump: [.greaterThan]), nil)]
	case .lt:
		return [(Instruction.cInstruction(destination: [],
																			computation: .d,
																			jump: [.lessThan]), nil)]
	case .and:
		return [(Instruction.cInstruction(destination: .d,
																			computation: .andMD,
																			jump: []), nil)]
	case .or:
		return [(Instruction.cInstruction(destination: .d,
																			computation: .orDM,
																			jump: []), nil)]
	case .not:
		return [(Instruction.cInstruction(destination: .m,
																			computation: .notM,
																			jump: []), nil)]
	}
}
