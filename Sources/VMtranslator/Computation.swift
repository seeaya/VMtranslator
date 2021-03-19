//
//  Computation.swift
//  
//
//  Created by Connor Barnes on 3/1/21.
//

/// A computation to perform.
enum Computation: Int {
	/// `0`
	case zero = 0b0101010
	/// `1`
	case one = 0b0111111
	/// `-1`
	case negativeOne = 0b0111010
	/// `D`
	case d = 0b0001100
	/// `A`
	case a = 0b0110000
	/// `M`
	case m = 0b1110000
	/// `!D`
	case notD = 0b0001101
	/// `!A`
	case notA = 0b0110001
	/// `!M`
	case notM = 0b1110001
	/// `-D`
	case negD = 0b0001111
	/// `-A`
	case negA = 0b0110011
	/// `-M`
	case negM = 0b1110011
	/// `D+1`
	case incD = 0b0011111
	/// `A+1`
	case incA = 0b0110111
	/// `M+1`
	case incM = 0b1110111
	/// `D-1`
	case decD = 0b0001110
	/// `A-1`
	case decA = 0b0110010
	/// `M-1`
	case decM = 0b1110010
	/// `D+A`
	case sumDA = 0b0000010
	/// `D+M`
	case sumDM = 0b1000010
	/// `D-A`
	case subDA = 0b0010011
	/// `D-M`
	case subDM = 0b1010011
	/// `A-D`
	case subAD = 0b0000111
	/// `M-D`
	case subMD = 0b1000111
	/// `A&D`
	case andAD = 0b0000000
	/// `M&D`
	case andMD = 0b1000000
	/// `D|A`
	case orDA = 0b0010101
	/// `D|M`
	case orDM = 0b1010101
}

// MARK:- Custom string convertible
extension Computation: CustomStringConvertible {
	var description: String {
		switch self {
		case .zero:
			return "0"
		case .one:
			return "1"
		case .negativeOne:
			return "-1"
		case .d:
			return "D"
		case .a:
			return "A"
		case .m:
			return "M"
		case .notD:
			return "!D"
		case .notA:
			return "!A"
		case .notM:
			return "!M"
		case .negD:
			return "-D"
		case .negA:
			return "-A"
		case .negM:
			return "-M"
		case .incD:
			return "D+1"
		case .incA:
			return "A+1"
		case .incM:
			return "M+1"
		case .decD:
			return "D-1"
		case .decA:
			return "A-1"
		case .decM:
			return "M-1"
		case .sumDA:
			return "D+A"
		case .sumDM:
			return "D+M"
		case .subDA:
			return "D-A"
		case .subDM:
			return "D-M"
		case .subAD:
			return "A-D"
		case .subMD:
			return "M-D"
		case .andAD:
			return "D&A"
		case .andMD:
			return "D&M"
		case .orDA:
			return "D|A"
		case .orDM:
			return "D|M"
		}
	}
}
