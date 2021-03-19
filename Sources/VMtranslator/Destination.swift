//
//  Destination.swift
//  
//
//  Created by Connor Barnes on 3/1/21.
//

/// An C-instruction's destination registers.
// We make Destination conform to OptionSet so that we get SetAlgebra for free,
// which is useful as a Destination can compose of any combination of the three
// registers.
struct Destination: OptionSet {
	let rawValue: Int
	
	/// The M register.
	static let m = Destination(rawValue: 1 << 0)
	/// The D register.
	static let d = Destination(rawValue: 1 << 1)
	/// The A register.
	static let a = Destination(rawValue: 1 << 2)
}

// MARK:- String value
extension Destination: CustomStringConvertible {
	var description: String {
		var string = ""
		
		if contains(.a) {
			string += "A"
		}
		
		if contains(.d) {
			string += "D"
		}
		
		if contains(.m) {
			string += "M"
		}
		
		return string
	}
}
