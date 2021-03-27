//
//  FileWriter.swift
//  
//
//  Created by Connor Barnes on 3/18/21.
//

import Foundation

/// A type for writing assembly instructions to a file.
struct FileWriter {
	/// Write the given instructions from the given input url.
	/// - Parameters:
	///   - instructions: The instructions to write.
	///   - url: The url that was used as input. The output will have the same name but with the `.asm` extension.
	/// - Throws: If the file could not be written to.
	func write(instructions: [CommentedInstruction], to url: URL) throws {
		let outputPath: String
		
		if url.pathExtension == "vm" {
			// Single file
			// Remove the extension and add on the extension .asm to name the output file
			outputPath = url
				.deletingPathExtension()
				.lastPathComponent
				.appending(".asm")
		} else if url.pathExtension == "" {
			// Folder
			let name = url
				.lastPathComponent
			
			outputPath = name
				.appending("/\(name).asm")
		} else {
			fatalError("Invalid path extension \"\(url.pathExtension)\"")
		}
		
		
		let outputFile = url
			.deletingLastPathComponent()
			.appendingPathComponent(outputPath)
		
		try instructions
			.map { instruction, comment -> String in
				// The comment portion of the instruction
				let commentString: String = {
					if let comment = comment {
						return "// \(comment)"
					} else {
						return ""
					}
				}()
				
				if let instruction = instruction {
					return instruction.description
					+ (commentString.isEmpty ? "" : " \(commentString)")
				} else {
					return commentString
				}
			}
			.joined(separator: "\n")
			.data(using: .utf8)!
			.write(to: outputFile)
	}
}
