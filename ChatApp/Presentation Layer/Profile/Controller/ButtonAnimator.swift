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
    var duration: Double {get set}
    func animate()
    func stop(completion: @escaping () -> Void)
}

class WigglingAnimator: Animator {
    var isAnimating: Bool = false
    var view: UIView
    var duration: Double
    private var degreeFrom = NSNumber(value: Double.pi / 10)
    private var degreeTo = NSNumber(value: -Double.pi / 10)
    private var offset: CGFloat = CGFloat(5)
    private var initialPosition: CGPoint
    
    init(view: UIView, duration: Double = 0.3) {
        self.view = view
        view.superview?.layoutSublayers(of: view.layer)
        self.initialPosition = view.layer.position
        self.duration = duration
    }
    
    func animate() {
        self.isAnimating = true
        CATransaction.begin()
        
        let positionAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        let x = initialPosition.x
        let y = initialPosition.y
        positionAnimation.values = [NSValue(cgPoint: CGPoint(x: x, y: y)),
                                     NSValue(cgPoint: CGPoint(x: x - offset, y: y - offset)),
                                     NSValue(cgPoint: CGPoint(x: x + offset, y: y + offset)),
                                     NSValue(cgPoint: CGPoint(x: x, y: y))]
        positionAnimation.calculationMode = .cubicPaced
        
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotationAnimation.values = [0, degreeFrom, degreeTo, 0]
        rotationAnimation.calculationMode = .cubicPaced
        
        let group = CAAnimationGroup()
        group.repeatCount = .infinity
        group.duration = duration
        group.animations = [positionAnimation, rotationAnimation]
        
        view.layer.add(group, forKey: "allAnimations")
        CATransaction.commit()
    }
    
    func stop(completion: @escaping () -> Void) {
        isAnimating = false
        
        guard let currentPos: CGPoint = view.layer.presentation()?.value(forKey: #keyPath(CALayer.position)) as? CGPoint
        else { return }
        
        guard let angle = view.layer.presentation()?.value(forKeyPath: "transform.rotation") as? CGFloat else { return }
        let radian = .pi / 180.0 * angle
        view.layer.position = currentPos
        view.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layer.position = self.initialPosition
            self.view.transform = CGAffineTransform(rotationAngle: radian)
        }, completion: { (_) in
            completion()
        })
    }
}
