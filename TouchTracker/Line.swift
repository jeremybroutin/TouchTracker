//
//  Line.swift
//  TouchTracker
//
//  Created by Jeremy Broutin on 7/25/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import Foundation
import CoreGraphics

struct Line {
	
	// CGPoint properties for the beginning and ending of the line
	var begin = CGPoint.zero
	var end = CGPoint.zero
	
	// Silver challnge: calculate angle btw points and set stroke color differently
	var angle: Double {
		let angleRadiants = Double(atan2(end.y - begin.y, end.x - begin.x))
		// aten: arc tangent, computes the principal value of the arc tangent of
		// y/x, using the signs of both arguments to determine the quadrant of the return value.
		let angleDegrees = angleRadiants * 180 / M_PI
		return angleDegrees > 0 ? angleDegrees	: angleDegrees + 180 // return a value btw 0 and 180
	}
}
