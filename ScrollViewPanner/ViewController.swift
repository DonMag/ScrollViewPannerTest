//
//  ViewController.swift
//  ScrollViewPanner
//
//  Created by Jeff Campbell on 8/5/21.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet private var scrollView1:UIScrollView!

	@IBOutlet private var panView:UIView!

	private var panViewGestureRecognizer:UIPanGestureRecognizer!
	
	@objc func didPanView(_ gestureRecognizer:UIPanGestureRecognizer) {
		guard let view = gestureRecognizer.view else { return }

		switch gestureRecognizer.state {
		case .began:
			print("Began - \(String(describing: view))")
			self.scrollView1.panGestureRecognizer.reset()
		case .cancelled:
			print("Cancelled - \(String(describing: view))")
		case .changed:
			print("Changed - \(String(describing: view))")

			// This is where the view is being panned...

			let translation = gestureRecognizer.translation(in: view.superview)
			gestureRecognizer.setTranslation(.zero, in: view.superview)
			view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)

		case .failed:
			print("Failed - \(String(describing: view))")
		case .possible:
			print("Possible - \(String(describing: view))")
		case .recognized:
			print("Recognized - \(String(describing: view))")
		case .ended:
			print("Ended - \(String(describing: view))")
		@unknown default:
			fatalError()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.panView.backgroundColor							= UIColor.darkGray
		self.panView.layer.borderColor							= UIColor.white.cgColor
		self.panView.layer.borderWidth							= 1.0
		
		self.panViewGestureRecognizer							= UIPanGestureRecognizer(target: self, action: #selector(didPanView(_:)))

		self.panViewGestureRecognizer.delegate					= self
		
		self.panView.addGestureRecognizer(self.panViewGestureRecognizer)
	}
}

extension ViewController: UIGestureRecognizerDelegate {
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//		return true
//	}
}
