//
//  DrawView.swift
//  TouchTracker
//
//  Created by Jeremy Broutin on 7/25/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class DrawView: UIView {
	
	// MARK: - Properties

	// Dict of Line / Circle points instances to handle multiple touches (aka multiple lines)
	// The key to store a line will be deruved from the UITouch object that the line corresponds to
	var currentLines = [NSValue:Line]()
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
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:)))
		doubleTapRecognizer.numberOfTapsRequired = 2
		doubleTapRecognizer.delaysTouchesBegan = true
		addGestureRecognizer(doubleTapRecognizer)
	}
	
	// MARK: - Drawing helper functions
	
	// Create the line
	func strokeLine(line: Line) {
		let path = UIBezierPath()
		path.lineWidth = lineThickness
		path.lineCapStyle = CGLineCap.Round
		
		path.moveToPoint(line.begin)
		path.addLineToPoint(line.end)
		path.stroke()
	}
	
	// MARK: - Gesture recognizer targets
	
	func doubleTap(gestureRecognizer: UIGestureRecognizer){
		print("Recognized a double tap")
		
		currentLines.removeAll(keepCapacity: false)
		finishedLines.removeAll(keepCapacity: false)
		setNeedsDisplay()
	}
	
	// MARK: - Drawing on the view
	
	// Draw the lines in the array
	override func drawRect(rect: CGRect) {
		
		// Line
		finishedLineColor.setStroke()
		for line in finishedLines {
			strokeLine(line)
		}
		
		for (_, line) in currentLines {
			colorFromAngle(line.angle).setStroke()
			strokeLine(line)
		}
	}
	
	func colorFromAngle(angle: Double) -> UIColor {
		let hue = CGFloat(angle/180) // to get a value between 0 and 1
		return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
		
	}
	
	// MARK: - UITouch tracking methods
	
	// Concept:
	// Touch begins: create a Line and set both properties to where teh touch began
	// Touch moves: update the Line's end
	// Touch ends: Line is complete
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		print(#function)
		
		// Use a loop in case touches began at the exact same time (not highly probable but just in case)
		for touch in touches {
			let location = touch.locationInView(self)
			// Create a NSValue instance that holds on to the address of the UITouch obj, because we should not retain to UITouch obj directly
			// Wrapping it in an NSValue avoids creating a strong reference to the obj
			let key = NSValue(nonretainedObject: touch)
			let newLine = Line(begin: location, end: location)
			currentLines[key] = newLine
		}
		// Flag the view to be redrawn at the end of the run loop
		setNeedsDisplay()
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

		for touch in touches {
			let key  = NSValue(nonretainedObject: touch)
			// Update line's end
			currentLines[key]?.end = touch.locationInView(self)
		}
		setNeedsDisplay()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		
		print(#function)
		
		for touch in touches {
			let key = NSValue(nonretainedObject: touch)
			// Line
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
