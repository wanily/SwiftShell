//
// PythonicTests.swift
// PythonicTests
//
// Created by Kåre Morstøl on 18/07/14.
// Copyright (c) 2014 practicalswift. All rights reserved.
//

import XCTest
import SwiftShell

class StreamIterationTests: XCTestCase {
	
	func stream(text: String) -> NSFileHandle {
		let pipe = NSPipe()
		let input = pipe.fileHandleForWriting
		input.writeData( text.dataUsingEncoding(streamencoding, allowLossyConversion:false)!)
		input.closeFile()
		return pipe.fileHandleForReading
	}
	
	func stream ( array: [String])  -> ReadableStreamType {
		class ArrayStream: ReadableStreamType {
			var generator: IndexingGenerator<[ String]>
			
			init(array: Array <String >) {
				generator = array.generate() 
			}
			
			func readSome() -> String? {
				return generator.next()
			}
			
			func read() -> String {
				XCTAssert(false,  "not implemented")
				return "" 
			}
			
			func lines() -> SequenceOf <String >{
				return split(delimiter: "\n")(stream: self)
			}
		}
		
		return ArrayStream (array: array)
	}
	
	
	func testIterateOverFileHandle() {
		var filehandletest = ""
		
		for line in stream("line 1\nline 2\n").lines() {
			filehandletest += line + "\n"
		}
		XCTAssert(filehandletest == "line 1\nline 2\n")
		
		XCTAssert(["line 1","line 2"] == Array(stream("line 1\nline 2").lines()))
		XCTAssert(["line 1"] == Array(stream("line 1\n").lines()))
		XCTAssert(["line 1"] == Array(stream("line 1").lines()))
		XCTAssert(["line 1","", "line 3"] == Array(stream("line 1\n\nline 3").lines()))
		XCTAssert(["","line 2", "line 3"] == Array(stream("\nline 2\nline 3").lines()))
		XCTAssert(["","", "line 3"] == Array(stream("\n\nline 3").lines()))
	}
	
	func testIterateOverStreamInPieces () {
		XCTAssert(["line 1","line 2"] == Array(stream(["line"," 1\nline 2"]).lines()))
		XCTAssert(["line 1"] == Array(stream(["line 1","\n"]).lines()))
		XCTAssert(["line 1"] == Array(stream(["li","ne"," 1"]).lines()))
		XCTAssert(["line 1","", "line 3"] == Array(stream(["line 1\n","\n","line 3"]).lines()))
		XCTAssert(["","line 2", "line 3"] == Array(stream(["\nline 2\n","line 3"]).lines()))
		XCTAssert(["","", "line 3"] == Array(stream(["\n","\nli","ne 3"]).lines()))		
	}

	// FIXME:  crashes with "incorrect checksum for freed object - object was probably modified after being freed."
	func notestReadingLinesFromShellCommand () {
		for line in  SwiftShell.run("ls -R  ~/Library").lines()  {
			println(line)
		}
	}

	// same input as above, works fine
	func notestReadingLinesFromLongFile () {
		var numberoflines = 0
		for line in SwiftShell.open("/Users/karemorstol/Data/Programmering/Shell.Swift/Shell.Swift/Shell.SwiftTests/Scripts/longtext.txt").lines()  {
			 numberoflines++
		}
		XCTAssertEqual(numberoflines, 641810)
	}

	//  same input as above, works fine
	func notestReadingFromShellCommand () {
		let file = SwiftShell.run("ls -R  ~/Library") as ReadableStreamType
		var some = file.readSome()
		var i = 1
		while (some != nil) {
			some = file.readSome()
			i++
		}
		println( "readSome was called \(i) times")// readSome was called 6559 times

	}
}