//
//  DrawView.swift
//  TouchTracker
//
//  Created by Jeremy Broutin on 7/25/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
	
	// MARK: - Properties

	// Dict of Line / Circle points instances to handle multiple touches (aka multiple lines)
	// The key to store a line will be deruved from the UITouch object that the line corresponds to
	var currentLines = [NSValue:Line]()
	var finishedLines = [Line]()
	var selectedLineIndex: Int? {
		didSet{
			// Make sure the menu is not visible if selectedIndex is nil (eg: on doubleTap)
			if selectedLineIndex == nil {
				let menu = UIMenuController.sharedMenuController()
				menu.setMenuVisible(false, animated: true)
			}
		}
	}
	var moveRecognizer: UIPanGestureRecognizer! // so that we have access to it in all methods
	var longPressRecognizer: UILongPressGestureRecognizer! // same as above for silver challenge

	
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
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:)))
		tapRecognizer.delaysTouchesBegan = true
		tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer) // dependency: wait before claiming the single tap
		addGestureRecognizer(tapRecognizer)
		
		longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawView.longPress(_:)))
		addGestureRecognizer(longPressRecognizer)
		
		moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawView.moveLine(_:)))
		moveRecognizer.delegate = self
		moveRecognizer.cancelsTouchesInView = false // let the view also handle the touch via UIResponder methods (touchesBegan)
		addGestureRecognizer(moveRecognizer)
	}
	
	// MARK: - Gesture recognizer targets
	
	func doubleTap(gestureRecognizer: UIGestureRecognizer){
		print("Recognized a double tap")
		
		selectedLineIndex = nil // avoid trap if line is selected when double tapping
		currentLines.removeAll(keepCapacity: false)
		finishedLines.removeAll(keepCapacity: false)
		setNeedsDisplay()
	}
	
	func tap(gestureRecognizer: UIGestureRecognizer){
		print("Recognized a tap")
		
		let point = gestureRecognizer.locationInView(self)
		selectedLineIndex = indexOfLineAtPoint(point)
		
		// Grab the menu controller
		let menu = UIMenuController.sharedMenuController()
		if selectedLineIndex != nil {
			//Make DrawView the target of menu item action messages
			becomeFirstResponder()
			
			// Create a new Delete UIMenuItem
			let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawView.deleteLine(_:)))
			menu.menuItems = [deleteItem]
			
			// Tell the menu where it should come from and show it
			menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 2, height: 2), inView: self)
			menu.setMenuVisible(true, animated: true)
		}
		else {
			// Hide the menu if no line is selected
			menu.setMenuVisible(false, animated: true)
		}
		
		setNeedsDisplay()
	}
	
	func deleteLine(sender: AnyObject){
		// Remove the selected line from the list of finishedLines
		if let index = selectedLineIndex {
			finishedLines.removeAtIndex(index)
			selectedLineIndex = nil
			
			// Redraw everything
			setNeedsDisplay()
		}
	}
	
	func longPress(gestureRecognizer: UIGestureRecognizer){
		print("Recognized long press")
		
		// Select closest line from gesture
		if gestureRecognizer.state == .Began {
			let point = gestureRecognizer.locationInView(self)
			selectedLineIndex = indexOfLineAtPoint(point)
			
			if selectedLineIndex != nil {
				currentLines.removeAll(keepCapacity: false)
			}
		}
		// Or release the selected line
		else if gestureRecognizer.state == .Ended {
			selectedLineIndex = nil
		}
		setNeedsDisplay()
	}
	
	func moveLine(gestureRecognizer: UIPanGestureRecognizer){
		// Because we will send the gesture Recog. a method from UIPanGestureRec. class, the parameter of this ,ethod
		// must be a ref to an instance of UIPanGestureRec.
		
		print("Recognized a pan")
		
		// Silver challenge, avoid moving line if no long press
		if longPressRecognizer.state != .Changed {
			return
		}
		
		// I f a line is selected
		if let index = selectedLineIndex {
			// When the pan recognizer changes its position
			if gestureRecognizer.state == .Changed {
				// How far has it moved
				let translation = gestureRecognizer.translationInView(self)
				
				// Add the translation to the current beginning and end points of the line
				finishedLines[index].begin.x += translation.x
				finishedLines[index].begin.y += translation.y
				finishedLines[index].end.x += translation.x
				finishedLines[index].end.y += translation.y
				
				// Make sure we reset the translation to zero before the next state changed iteration
				// Otherwise the translation is getting bigger incrementaly and doesn't reflect
				// the user's pan.
				gestureRecognizer.setTranslation(CGPoint.zero, inView: self)
				
				// Re draw the screen
				setNeedsDisplay()
			}
		} else {
			// If no line selected, do nothing
			return
		}
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
	
	// Set line color based on its angle
	func colorFromAngle(angle: Double) -> UIColor {
		let hue = CGFloat(angle/180) // to get a value between 0 and 1
		return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
		
	}
	
	// Return the index of the Line closest to a specific point
	func indexOfLineAtPoint(point: CGPoint) -> Int? {
		
		// Find a line close to point
		for (index, line) in finishedLines.enumerate(){
			let begin = line.begin
			let end = line.end
			
			// Check a few points on the line
			for t in CGFloat(0).stride(to: 1.0, by: 0.05){
				let x = begin.x + ((end.x - begin.x) * t)
				let y = begin.y + ((end.y - begin.y) * t)
				
				// If the tapped point is within 20 points, let's return this line
				if hypot(x - point.x, y - point.y) < 20.0 {
					return index
				}
			}
		}
		// If nothing is close enough to the tapped pointm then we did not select the line
		return nil
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
		
		if let index = selectedLineIndex {
			UIColor.greenColor().setStroke()
			let selectedLine = finishedLines[index]
			strokeLine(selectedLine)
		}
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
	
	// Allow this custom view class to become the first responder for the menu controller to appear
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	// MARK: - UIGestureRecognizer delegate methods
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
		// only the moveRecognizer has a delegate so we can simply return true
	}
	
}
