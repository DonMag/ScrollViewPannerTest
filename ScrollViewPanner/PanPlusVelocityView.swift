//
//  PanPlusVelocityView.swift
//  ScrollViewPanner
//
//  Created by Don Mag on 8/11/21.
//

import UIKit

class PanPlusVelocityView: UIView {

	public var startCallback: ((UIView) -> ())?
	public var movedCallback: ((UIView) -> ())?
	public var endedCallback: ((UIView) -> ())?
	
	public var myVelocity: CGPoint = .zero
	public var panVelocity: CGPoint = .zero
	
	public var shouldWiggle: Bool = false
	public var shouldHighlight: Bool = false
	
	public var numSamples: Int = 2

	private var panGesture: UIPanGestureRecognizer!
	
	private var highlighted: Bool? {
		willSet {
			layer.borderWidth = newValue == true ? 3 : 0
		}
	}
	
	public let label: UILabel = {
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
	private func commonInit() -> Void {
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
		
		// used if highlight enabled
		layer.borderColor = UIColor.white.cgColor
		
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
		addGestureRecognizer(panGesture)
	}
	
	private struct VelocityStruct {
		var time: UInt64 = 0
		var dist: CGPoint = .zero
	}
	
	private var startTime = DispatchTime.now()
	private var aVelocities: [VelocityStruct] = []
	
	@objc func handlePan(_ g: UIPanGestureRecognizer) -> Void {
		
		switch g.state {
		
		case .began:
			
			// make sure we have a superview
			guard let sv = superview else {
				return
			}
			// if our superview is a UIScrollView, we need to grab
			//	view references and move self from the scrollView
			//	to its superview
			if sv is UIScrollView {
				guard let svsv = sv.superview else { return }
				theScrollView = (sv as! UIScrollView)
				theRootView = svsv
			} else {
				theScrollView = nil
				theRootView = sv
			}
			
			// if we're in a scrollView
			if theScrollView != nil {
				// convert center coords
				let cvtCenter = theScrollView.convert(self.center, to: theRootView)
				self.center = cvtCenter
				curCenter = self.center
				
				// add self to theRootView (removes self from scrollView)
				theRootView.addSubview(self)
			} else {
				curCenter = self.center
			}
			
			if shouldWiggle {
				// start wiggling anim
				startAnim()
			}
			if shouldHighlight {
				highlighted = true
			}
			
			aVelocities = []
			
			startTime = DispatchTime.now()
			
			// inform the controller
			startCallback?(self)
			
		case .changed:
			
			guard let thisView = g.view else {
				return
			}
			
			// get the gesture point
			let point = g.location(in: thisView.superview)
			
			let t = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds
			startTime = DispatchTime.now()
			
			if aVelocities.count < numSamples {
				aVelocities.append(VelocityStruct(time: t, dist: CGPoint(x: point.x - curCenter.x, y: point.y - curCenter.y)))
			} else {
				aVelocities = Array(aVelocities.dropFirst()) + [VelocityStruct(time: t, dist: CGPoint(x: point.x - curCenter.x, y: point.y - curCenter.y))]
			}
			
			startTime = DispatchTime.now()
			
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
			
			// un-highlight
			highlighted = false
			
			// convert center to scroll view (original superview) coords
			let cvtCenter = theRootView.convert(curCenter, to: theScrollView)
			
			// update center
			self.center = cvtCenter
			
			// if we started in a scrollView
			//	add self back to scroll view
			if theScrollView != nil {
				theScrollView.addSubview(self)
			}
			
			// should not be possible to get here if aVelocities is empty,
			//	but we need to do a sanity check to make sure we don't end up with
			//	a divide-by-zero error
			if aVelocities.count > 0 {
				
				var xDist: CGFloat = 0
				var yDist: CGFloat = 0
				
				// we only want to check consecutive time/distance values
				//	if they are the same sign - for example,
				//	if the user zig-zags the drag, with x-deltas of
				//		-12, +12, + 24
				//	or
				//		+20, -16, -30
				//	we only want to average the same-sign values
				
				var i = aVelocities.count
				
				let bPositiveX: Bool = aVelocities[i - 1].dist.x > 0
				let bPositiveY: Bool = aVelocities[i - 1].dist.y > 0
				
				var numX: Int = 0
				var numY: Int = 0
				
				while i > 0 {
					i -= 1
					if (aVelocities[i].dist.x > 0) == bPositiveX {
						xDist += aVelocities[i].dist.x / CGFloat(Double(aVelocities[i].time) / Double(NSEC_PER_SEC))
						numX += 1
					} else {
						break
					}
				}
				
				i = aVelocities.count
				
				while i > 0 {
					i -= 1
					if (aVelocities[i].dist.y > 0) == bPositiveY {
						yDist += aVelocities[i].dist.y / CGFloat(Double(aVelocities[i].time) / Double(NSEC_PER_SEC))
						numY += 1
					} else {
						break
					}
				}
				
				myVelocity = CGPoint(x: xDist / CGFloat(numX), y: yDist / CGFloat(numY))
				panVelocity = g.velocity(in: theRootView)

			}
			
			// inform the controller
			endedCallback?(self)
			
		}
		
	}
	
	private weak var theRootView: UIView!
	private weak var theScrollView: UIScrollView!
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
