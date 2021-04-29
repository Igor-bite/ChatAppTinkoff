//
//  ButtonAnimator.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 29.04.2021.
//

import UIKit

protocol Animator {
    var view: UIView {get set}
    var isAnimating: Bool {get}
    func animate()
    func stop(completion: @escaping () -> Void)
}

class WigglingAnimator: Animator {
    var isAnimating: Bool = false
    var view: UIView
    private var positionAnimation: CAKeyframeAnimation?
    private var rotationAnimation: CAKeyframeAnimation?
    private var group: CAAnimationGroup?
    private var degreeFrom = NSNumber(value: Double.pi / 10)
    private var degreeTo = NSNumber(value: -Double.pi / 10)
    private var offset: CGFloat = CGFloat(5)
    private var initialPosition: CGPoint
    
    init(view: UIView, duration: Double = 0.3) {
        self.view = view
        self.initialPosition = view.layer.position
        
        self.positionAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        let x = view.layer.position.x
        let y = view.layer.position.y
        positionAnimation?.values = [NSValue(cgPoint: CGPoint(x: x, y: y)),
                                     NSValue(cgPoint: CGPoint(x: x - offset, y: y - offset)),
                                     NSValue(cgPoint: CGPoint(x: x + offset, y: y + offset)),
                                     NSValue(cgPoint: CGPoint(x: x, y: y))]
        positionAnimation?.calculationMode = .cubicPaced
        
        self.rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation?.values = [0, degreeFrom, degreeTo, 0]
        rotationAnimation?.calculationMode = .cubicPaced
        
        self.group = CAAnimationGroup()
        group?.repeatCount = .infinity
        group?.duration = duration
        group?.fillMode = .forwards
        guard let positionAnimation = positionAnimation, let rotationAnimation = rotationAnimation else { return }
        group?.animations = [positionAnimation, rotationAnimation]
        group?.isRemovedOnCompletion = false
    }
    
    func animate() {
        self.isAnimating = true
        CATransaction.begin()
        guard let group = group else { return }
        view.layer.add(group, forKey: "allAnimations")
        CATransaction.commit()
    }
    
    func stop(completion: @escaping () -> Void) {
        isAnimating = false
        
        guard let currentPos: CGPoint = view.layer.presentation()?.value(forKey: #keyPath(CALayer.position)) as? CGPoint
        else { return }
        
        guard let angle = view.layer.presentation()?.value(forKeyPath: "transform.rotation") as? CGFloat else { return }
        let rad = .pi / 180.0 * angle
        
        view.layer.position = currentPos
        
        view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//                self.myButtonView?.transform = CGAffineTransform(translationX: 0, y: 0)
//                self.myButtonView?.transform = CGAffineTransform(rotationAngle: .zero)
            self.view.layer.position = self.initialPosition
            self.view.transform = CGAffineTransform(rotationAngle: rad)
//                print(self.myButtonView?.transform, CGAffineTransform.identity)
        }, completion: { (_) in
            completion()
        })
    }
}
