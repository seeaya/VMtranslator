//
//  MemoryAccessCommand.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

extension VM{
	/// A memory access command.
	enum MemoryAccessCommand {
		/// Pushes the top of the stack to the given address.
		case push (segment: MemorySegment, offset: Int)
		/// Pops to the stack the value at the given address.
		case pop (segment: MemorySegment, offset: Int)
	}
}

// MARK:- VM.MemorySegment
extension VM {
	/// A memory segment.
	enum MemorySegment {
		/// The argument segment.
		case argument
		/// The local segment.
		case local
		/// The static segment.
		case `static`
		/// The constant pseudo-segment.
		case constant
		/// The this segment.
		case this
		/// The that segment.
		case that
		/// The pointer segment.
		case pointer
		/// The temp segment.
		case temp
	}
}

// MARK:- VM.MemoryAccessCommand conversion
extension VM.MemoryAccessCommand {
	/// Returns the instructions that will execute the command.
	/// - Parameter filename: The name of the file that the instructions are in.
	/// - Returns: The generated instructions.
	func instructions(forFilename filename: String) -> [CommentedInstruction] {
		switch self {
		case .push(segment: let segment, offset: let offset):
			return instructionsForPushCommand(offset: offset
																				, segment: segment,
																				filename: filename)
		case .pop(segment: let segment, offset: let offset):
			return instructionsForPopCommand(offset: offset,
																			 segment: segment,
																			 filename: filename)
		}
	}
}

// MARK:- Helper functions
/// Returns the instructions for the pop command.
/// - Parameters:
///   - offset: The offset from the segment's base.
///   - segment: The segment to pop to.
///   - filename: The name of the file that the instructions are in.
/// - Returns: The generated instructions.
private func instructionsForPopCommand(
	offset: Int,
	segment: VM.MemorySegment,
	filename: String
) -> [CommentedInstruction] {
	let isPointer = segment == .pointer || segment == .temp || segment == .static
	let base = baseFor(segment: segment, offset: offset, filename: filename)
	let actualOffset = segment == .static ? 0 : offset
	
	return [
		(Instruction.aInstruction(base), nil),
		(Instruction.cInstruction(destination: .d,
															computation: isPointer ? .a : .m,
															jump: []), nil),
		(Instruction.aInstruction(.integer(actualOffset)), nil),
		(Instruction.cInstruction(destination: .d,
															computation: .sumDA,
															jump: []), nil),
		(Instruction.aInstruction(.integer(13)), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil)
	]
	+ instructionsForLocalPop()
	+ [
		(Instruction.cInstruction(destination: .d,
															computation: .m,
															jump: []), nil),
		(Instruction.aInstruction(.integer(13)), nil),
		(Instruction.cInstruction(destination: .a,
															computation: .m,
															jump: []), nil),
		(Instruction.cInstruction(destination: .m,
															computation: .d,
															jump: []), nil)
	]
}

/// Returns the instructions for the push command.
/// - Parameters:
///   - offset: The offset from the segment's base.
///   - segment: The segment to push from.
///   - filename: The name of the file that the instructions are in.
/// - Returns: The generated instructions.
private func instructionsForPushCommand(
	offset: Int,
	segment: VM.MemorySegment,
	filename: String
) -> [CommentedInstruction] {
	if (segment == .constant) {
		return [
			(Instruction.aInstruction(.integer(offset)), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .a,
																jump: []), nil)
		]
		+ instructionsForLocalPush()
	}
	
	let isPointer = segment == .pointer || segment == .temp || segment == .static
	let base = baseFor(segment: segment, offset: offset, filename: filename)
	let actualOffset = segment == .static ? 0 : offset
	
	return [ (Instruction.aInstruction(base), nil)]
		+ (isPointer ? [] : [(Instruction.cInstruction(destination: .a,
																									 computation: .m,
																									 jump: []), nil)])
		+ [
			(Instruction.cInstruction(destination: .d,
																computation: .a,
																jump: []), nil),
			(Instruction.aInstruction(.integer(actualOffset)), nil),
			(Instruction.cInstruction(destination: .a,
																computation: .sumDA,
																jump: []), nil),
			(Instruction.cInstruction(destination: .d,
																computation: .m,
																jump: []), nil)
		]
		+ instructionsForLocalPush()
}

/// Returns the identifier to reference the given segment's base.
/// - Parameters:
///   - segment: The segment.
///   - offset: The offset from the segment's base.
///   - filename: The name of the file that the instructions are in.
/// - Returns: The segment's base identifier.
private func baseFor(segment: VM.MemorySegment,
										 offset: Int,
										 filename: String
) -> Literal {
	switch segment {
	case .argument:
		return .identifier("ARG")
	case .local:
		return .identifier("LCL")
	case .static:
		return .identifier("\(filename).\(offset)")
	case .constant:
		fatalError("Internal error")
	case .this:
		return .identifier("THIS")
	case .that:
		return .identifier("THAT")
	case .pointer:
		return .integer(3)
	case .temp:
		return .integer(5)
	}
}
