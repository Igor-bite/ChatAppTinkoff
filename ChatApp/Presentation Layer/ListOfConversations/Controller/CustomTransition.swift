//
//  CustomTransition.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 29.04.2021.
//

import UIKit

class MyCustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to)
        else { return }
        
        containerView.addSubview(toView)
        showCells(into: containerView)
        
        CATransaction.begin()
        let ba = CABasicAnimation(keyPath: "emitterPosition")
        CATransaction.setCompletionBlock {
            self.crestLayer?.emitterPosition = CGPoint(x: toView.bounds.width / 2.0, y: toView.bounds.height * 2.0)
        }
        ba.fromValue = CGPoint(x: toView.bounds.width / 2.0, y: -2.0 * toView.bounds.height)
        ba.toValue = CGPoint(x: toView.bounds.width / 2.0, y: toView.bounds.height * 2.0)
        ba.duration = 3.0
        ba.repeatCount = 1
        self.crestLayer?.add(ba, forKey: "anim")
        CATransaction.commit()
        
        toView.alpha = 0.0
        UIView.animate(withDuration: 1.5,
                        animations: {
                            toView.alpha = 1.0
                        },
                        completion: { _ in
                            transitionContext.completeTransition(true)
                        })
    
    }
    
    private var crestLayer: CAEmitterLayer?
    
    func showCells(into view: UIView) {
        let crestLayer = CAEmitterLayer()
        crestLayer.emitterPosition = CGPoint(x: view.bounds.width / 2.0, y: 0)
        crestLayer.emitterSize = CGSize(width: view.bounds.width, height: 1.0)
        crestLayer.emitterShape = .line
        crestLayer.renderMode = .backToFront
        crestLayer.beginTime = CACurrentMediaTime()
        crestLayer.timeOffset = CFTimeInterval(arc4random_uniform(6) + 5)
        crestLayer.emitterCells = [crestCell]
        self.crestLayer = crestLayer
        view.layer.addSublayer(crestLayer)
    }
    
    lazy var crestCell: CAEmitterCell = {
        var crest = CAEmitterCell()
        crest.contents = UIImage(named: "Crest")?.cgImage
        
        crest.birthRate = 300.0
        crest.lifetime = 10.0
        crest.velocity = CGFloat(crest.birthRate * crest.lifetime) / 2.0
        crest.velocityRange = crest.velocity / 2
        crest.emissionLongitude = .pi
        crest.emissionRange = .pi / 4
        crest.spinRange = -0.5
        crest.scaleRange = 0.2
        crest.scale = 0.5

        return crest
    }()
}
