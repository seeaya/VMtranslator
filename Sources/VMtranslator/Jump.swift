//
//  Jump.swift
//  
//
//  Created by Connor Barnes on 3/1/21.
//

/// An C-instruction's jump value.
// We make Jump conform to OptionSet so that we get SetAlgebra for free, which
// is useful as a Jump can compose of any combination of the three jump operations
struct Jump: OptionSet {
	let rawValue: Int
	
	/// Jump if greater-than.
	static let greaterThan = Jump(rawValue: 1 << 0)
	/// Jump if equal-to.
	static let equalTo = Jump(rawValue: 1 << 1)
	/// Jump is less-than.
	static let lessThan = Jump(rawValue: 1 << 2)
}

// MARK:- Custom string convertible
extension Jump: CustomStringConvertible {
	var description: String {
		switch self {
		case []:
			return ""
		case [.greaterThan]:
			return "JGT"
		case [.equalTo]:
			return "JEQ"
		case [.lessThan]:
			return "JLT"
		case [.greaterThan, .equalTo]:
			return "JGE"
		case [.lessThan, .equalTo]:
			return "JLE"
		case [.lessThan, .greaterThan]:
			return "JNE"
		case [.lessThan, .equalTo, .greaterThan]:
			return "JMP"
		default:
			return ""
		}
	}
}
