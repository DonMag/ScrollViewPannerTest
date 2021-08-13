//
//  VelocityTestViewController.swift
//  ScrollViewPanner
//
//  Created by Don Mag on 8/6/21.
//

import UIKit

class VelocityTestViewController: UIViewController {

	let infoLabel: UILabel = {
		let v = UILabel()
		v.numberOfLines = 0
		v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		v.font = .monospacedSystemFont(ofSize: 14, weight: .light)
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	let v1: PanPlusVelocityView = {
		let v = PanPlusVelocityView()
		v.backgroundColor = .red
		v.label.text = "Pan+"
		return v
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemTeal
		
		// add an "info label"
		view.addSubview(infoLabel)
		let g = view.safeAreaLayoutGuide
		NSLayoutConstraint.activate([
			infoLabel.topAnchor.constraint(equalTo: g.topAnchor, constant: 8.0),
			infoLabel.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 8.0),
			infoLabel.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -8.0),
		])
		
		// add the PanPlus view
		view.addSubview(v1)

		v1.frame = CGRect(x: 20, y: 100, width: 100, height: 100)

		// let's "highlight" instead of "wiggle"
		v1.shouldWiggle = false
		v1.shouldHighlight = true

		// we can test and compare by changing
		//	the number of time/distance samples
		// set to 1 to get only the last move interval
		//	default == 2
		//v1.numSamples = 3
		
		// closure
		v1.endedCallback = { [weak self] view in
			guard let self = self,
				  let theView = view as? PanPlusVelocityView
			else {
				return
			}
			self.infoLabel.text = String(format: "My Velocity\n  vX: %0.3f vY: %0.3f\nGesture Velocity\n  vX: %0.3f vY: %0.3f",
										 theView.myVelocity.x, theView.myVelocity.y,
										 theView.panVelocity.x, theView.panVelocity.y)
		}

	}
	
}
