//
//  SpecialDraggableView.swift
//  ScrollViewPanner
//
//  Created by Don Mag on 8/5/21.
//

import UIKit

class SpecialDraggableView: UIView {

	var startCallback: ((UIView) -> ())?
	var movedCallback: ((UIView) -> ())?
	var endedCallback: ((UIView) -> ())?

	let label: UILabel = {
		let v = UILabel()
		v.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		v.textAlignment = .center
		return v
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		// add a label
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.centerYAnchor.constraint(equalTo: centerYAnchor),
			label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
			label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
		])
		
		// just for aesthetics
		layer.cornerRadius = 12
		
		let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
		addGestureRecognizer(lp)
	}
	
	@objc func handleLongPress(_ g: UILongPressGestureRecognizer) -> Void {
		
		switch g.state {
		
		case .began:
			
			// get our superview and its superview
			guard let sv = superview as? UIScrollView,
				  let ssv = sv.superview
			else {
				return
			}
			theScrollView = sv
			theRootView = ssv
			
			// convert center coords
			let cvtCenter = theScrollView.convert(self.center, to: theRootView)
			self.center = cvtCenter
			curCenter = self.center
			
			// add self to ssv (removes self from sv)
			ssv.addSubview(self)
			
			// start wiggling anim
			startAnim()
			
			// inform the controller
			startCallback?(self)
			
		case .changed:
			
			guard let thisView = g.view else {
				return
			}
			
			// get the gesture point
			let point = g.location(in: thisView.superview)
			
			// Calculate new center position
			var newCenter = thisView.center;
			newCenter.x += point.x - curCenter.x;
			newCenter.y += point.y - curCenter.y;
			
			// Update view center
			thisView.center = newCenter
			curCenter = newCenter
			
			// inform the controller
			movedCallback?(self)
			
		default:
			
			// stop wiggle anim
			stopAnim()
			
			// convert center to scroll view (original superview) coords
			let cvtCenter = theRootView.convert(curCenter, to: theScrollView)
			
			// update center
			self.center = cvtCenter
			
			// add self back to scroll view
			theScrollView.addSubview(self)
			
			// inform the controller
			endedCallback?(self)
			
		}
		
	}
	
	private var theRootView: UIView!
	private var theScrollView: UIScrollView!
	private var curCenter: CGPoint = .zero
	
	private func startAnim() {
		addAnimations()
	}
	private func stopAnim() {
		layer.removeAllAnimations()
	}
	private func addAnimations() {
		CATransaction.begin()
		CATransaction.setDisableActions(false)
		layer.add(rotAnim(), forKey: "rot")
		layer.add(bounceAnim(), forKey: "bounce")
		CATransaction.commit()
	}
	private func rotAnim() -> CAKeyframeAnimation {
		let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		let angle = CGFloat(0.04)
		animation.values = [angle, -angle]
		animation.autoreverses = true
		animation.duration = 0.1
		animation.repeatCount = Float.infinity
		return animation
	}
	private func bounceAnim() -> CAKeyframeAnimation {
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
		let bounce = CGFloat(3.0)
		animation.values = [bounce, -bounce]
		animation.autoreverses = true
		animation.duration = 0.12
		animation.repeatCount = Float.infinity
		return animation
	}

}
