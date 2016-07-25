//
//  DrawView.swift
//  TouchTracker
//
//  Created by Jeremy Broutin on 7/25/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class DrawView: UIView {
	
	// Optional line to keep track of a line possibly being drawn
	// var currentLine: Line?
	// Replacing currentLine by a dict of Line instances to handle multiple touches (aka multiple lines)
	var currentLines = [NSValue:Line]()
	// The key to store a line will be deruved from the UITouch object that the line corresponds to
	
	// Array of lines that have been drawn
	var finishedLines = [Line]()
	
	//Allow properties to be known and modified by Interface Builder
	@IBInspectable var finishedLineColor: UIColor = UIColor.blackColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	@IBInspectable var currentLineColor: UIColor = UIColor.redColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	@IBInspectable var lineThickness: CGFloat = 10 {
		didSet{
			setNeedsDisplay()
		}
	}
	
	
	// Create and stroke a path
	func strokeLine(line: Line) {
		let path = UIBezierPath()
		//path.lineWidth = 10 // Use IBInspectable properties instead
		path.lineWidth = lineThickness
		path.lineCapStyle = CGLineCap.Round
		
		path.moveToPoint(line.begin)
		path.addLineToPoint(line.end)
		path.stroke()
	}
	
	// Draw the lines in the array
	override func drawRect(rect: CGRect) {
		// Draw finished lines in black
		// UIColor.blackColor().setStroke() // Use IBInspectable properties instead
		finishedLineColor.setStroke()
		for line in finishedLines {
			strokeLine(line)
		}
		
// Commented out to handle multiples touches
//		if let line = currentLine {
//			// If there is a line currently being drawn, do it in red
//			UIColor.redColor().setStroke()
//			strokeLine(line)
//		}
		
		// Draw current lines in red (multiple touches)
		// UIColor.redColor().setStroke() // Use IBInspectable properties instead
		currentLineColor.setStroke()
		for (_, line) in currentLines {
			strokeLine(line)
		}
	}
	
	// Concept:
	// Touch begins: create a Line and set both properties to where teh touch began
	// Touch moves: update the Line's end
	// Touch ends: Line is complete
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
// Commented out to handle multiples touches
//		let touch = touches.first!
		
		// Get location of the touch in view's coordinate system
//		let location = touch.locationInView(self)
//		currentLine = Line(begin: location, end: location)
		
		print(#function)
		
		// Use a loop in case touches began at the exact same time (not highly probable but just in case)
		for touch in touches {
			let location = touch.locationInView(self)
			let newLine = Line(begin: location, end: location)
			
			// Create a NSValue instance that holds on to the address of the UITouch obj
			// Because we should not retain to UITouch obj directly
			// Wrapping it in an NSValue avoids creating a strong reference to the obj
			let key = NSValue(nonretainedObject: touch)
			
			currentLines[key] = newLine
		}
		
		// Flag the view to be redrawn at the end of the run loop
		setNeedsDisplay()
		// NB: the view is not actually redrawn until the next drawing cycle
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
// Commented out to handle multiples touches
//		let touch = touches.first!
//		let location = touch.locationInView(self)
//		
//		currentLine?.end = location
		
		print(#function)

		for touch in touches {
			let key  = NSValue(nonretainedObject: touch)
			currentLines[key]?.end = touch.locationInView(self)
		}
		
		setNeedsDisplay()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
// Commented out to handle multiples touches
//		if var line = currentLine {
//			let touch = touches.first!
//			let location = touch.locationInView(self)
//			line.end = location
//			
//			finishedLines.append(line)
//		}
//		currentLine = nil
		
		print(#function)
		
		for touch in touches {
			let key = NSValue(nonretainedObject: touch)
			if var line = currentLines[key] {
				line.end = touch.locationInView(self)
				
				finishedLines.append(line)
				currentLines.removeValueForKey(key)
			}
		}
		
		setNeedsDisplay()
	}
	
	// Finally, handle the case when the app is interrupted by the OS: touch gets canceled
	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		print(#function)
		
		currentLines.removeAll()
		
		setNeedsDisplay()
	}
	
}
