//
//  LaunchViewController.swift
//  ScrollViewPanner
//
//  Created by Don Mag on 8/11/21.
//

import UIKit

class LaunchViewController: UIViewController {

	var isFirstTime: Bool = true
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if isFirstTime {
			isFirstTime = false
			let vc = UIAlertController(title: "Please Note!", message: "\nThis is EXAMPLE code!\n\nIt makes a lot of assumptions about the view hierarchy, and is intended to be a Starting Point Only and should not be considered\n\n\"Production Ready\"", preferredStyle: .alert)
			vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(vc, animated: true, completion: nil)
		}
	}

}
