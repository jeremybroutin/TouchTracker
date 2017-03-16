//
//  ViewController.swift
//  TouchTracker
//
//  Created by Jeremy Broutin on 7/25/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var helpTextLabel: UILabel!
	@IBOutlet var helpViewBottomConstraint: NSLayoutConstraint!

	override func viewDidLoad() {
		super.viewDidLoad()
		setHelpText()
		closeHelpView(UIButton())
	}

	func setHelpText() {
		helpTextLabel.text = "Drag your fingers to draw lines.\nTap once to select a line.\nLong press to drag and drop a line.\nDouble tap to delete alll ines."
	}

	@IBAction func openHelpView(_ sender: UIButton) {
		helpViewBottomConstraint.constant = 0
	}
	@IBAction func closeHelpView(_ sender: UIButton) {
		helpViewBottomConstraint.constant = 2000
	}
	
}

