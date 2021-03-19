//
//  Literal.swift
//  
//
//  Created by Connor Barnes on 3/1/21.
//

/// A literal used in an A-instruction.
enum Literal {
	/// A literal that represents an identifier (either a label or variable).
	case identifier (String)
	/// A literal that represents a decimal integer.
	case integer (Int)
}

// MARK:- Custom string convertible
extension Literal: CustomStringConvertible {
	var description: String {
		switch self {
		case .identifier(let identifier):
			return identifier
		case .integer(let integer):
			return String(integer)
		}
	}
}
