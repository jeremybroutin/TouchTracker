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
	var currentLine: Line?
	// Array of lines that have been drawn
	var finishedLines = [Line]()
	
	// Create and stroke a path
	func strokeLine(line: Line) {
		let path = UIBezierPath()
		path.lineWidth = 10
		path.lineCapStyle = CGLineCap.Round
		
		path.moveToPoint(line.begin)
		path.addLineToPoint(line.end)
		path.stroke()
	}
	
	// Draw the lines in the array
	override func drawRect(rect: CGRect) {
		// Draw finished lines in black
		UIColor.blackColor().setStroke()
		for line in finishedLines {
			strokeLine(line)
		}
		
		if let line = currentLine {
			// If there is a line currently being drawn, do it in red
			UIColor.redColor().setStroke()
			strokeLine(line)
		}
	}
	
	// Concept:
	// Touch begins: create a Line and set both properties to where teh touch began
	// Touch moves: update the Line's end
	// Touch ends: Line is complete
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = touches.first!
		
		// Get location of the touch in view's coordinate system
		let location = touch.locationInView(self)
		
		currentLine = Line(begin: location, end: location)
		
		// Flag the view to be redrawn at the end of the run loop
		setNeedsDisplay()
		// NB: the view is not actually redrawn until the next drawing cycle
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touch = touches.first!
		let location = touch.locationInView(self)
		
		currentLine?.end = location
		
		setNeedsDisplay()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if var line = currentLine {
			let touch = touches.first!
			let location = touch.locationInView(self)
			line.end = location
			
			finishedLines.append(line)
		}
		currentLine = nil
		
		setNeedsDisplay()
	}
	
}
