//
//  DonMagViewController.swift
//  ScrollViewPanner
//
//  Created by Don Mag on 8/5/21.
//

import UIKit

class DonMagViewController: UIViewController {

	let scrollView: UIScrollView = {
		let v = UIScrollView()
		v.backgroundColor = .lightGray
		return v
	}()

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(scrollView)
		
		let g = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0.0),
			scrollView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0.0),
			scrollView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0.0),
			scrollView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: 0.0),
		])
		
		// let's add 12 100x100 SpecialDraggableViews to the scrollView
		//	spaced 20-pts apart
		let colors: [UIColor] = [
			.red, .green, .blue,
			.cyan, .yellow, .magenta,
			.systemRed, .systemGreen, .systemBlue,
			.systemYellow, .systemOrange, .systemPink,
		]
		var x: CGFloat = 20.0
		for i in 0..<colors.count {
			//let v = SpecialDraggableView()
			let v = LongPressPlusVelocityView()
			v.backgroundColor = colors[i]
			v.label.text = "\(i + 1)"
			v.frame = CGRect(x: x, y: 200.0, width: 100.0, height: 100.0)
			
			v.shouldWiggle = false
			v.shouldHighlight = true
			v.longPressDuration = 0.3
			
			// closures
			v.startCallback = { [weak self] view in
				guard let self = self,
					  let theView = view as? LongPressPlusVelocityView,
					  let vID = theView.label.text
				else {
					return
				}
				print("Started dragging view ID:", vID)
			}
			v.movedCallback = { [weak self] view in
				guard let self = self,
					  let theView = view as? LongPressPlusVelocityView,
					  let vID = theView.label.text
				else {
					return
				}
				print("Dragging view ID:", vID, "to:", theView.center)
			}
			v.endedCallback = { [weak self] view in
				guard let self = self,
					  let theView = view as? LongPressPlusVelocityView,
					  let vID = theView.label.text
				else {
					return
				}
				print("Stopped dragging view ID:", vID, "at:", theView.center, "velocity:", theView.myVelocity)
				self.updateContentSize()
				self.title = String(format: "vX: %0.3f vY: %0.3f", theView.myVelocity.x, theView.myVelocity.y)
			}
			scrollView.addSubview(v)
			x += 120.0
		}
		
		// because we are not using auto-layout constraints for the draggable views,
		//	we need to calculate the scrollView's contentSize
		updateContentSize()

	}
 
	func updateContentSize() -> Void {
		guard let w = scrollView.subviews.lazy.map({ $0.frame.maxX }).max(),
			  let h = scrollView.subviews.lazy.map({ $0.frame.maxY }).max()
		else {
			fatalError("Bad setup!")
		}
		scrollView.contentSize = CGSize(width: w + 20.0, height: h + 20.0)
	}

}
