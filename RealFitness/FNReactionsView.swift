//
//  FNReactionsView.swift
//  FNLiveReactions
//
//  Created by Fabio Nisci on 24/03/17.
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Fabio Nisci
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

class FNReactionsView: UIView{
    
    func showReaction(image: UIImage){
        let reactionImageView = UIImageView(image: image)
        reactionImageView.contentMode = .scaleAspectFit
        let dimension = 20 + drand48() * 10 //reaction emoji size (20-30)
        reactionImageView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.delegate = self
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3 //animation duration (2-3)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.setValue(reactionImageView, forKey: "imageView")
        
        reactionImageView.layer.add(animation, forKey: nil)
        addSubview(reactionImageView)
    }
    
    func showReaction(textReaction: String){
        let reactionTextView = UITextView();
        reactionTextView.text = textReaction;
        reactionTextView.textColor = .orange;
        
        let dimension = 120 + drand48() * 10 //reaction emoji size (20-30)
        reactionTextView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        reactionTextView.backgroundColor = .clear;
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.delegate = self
        animation.path = customPath().cgPath
        animation.duration = 2 + drand48() * 3 //animation duration (2-3)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.setValue(reactionTextView, forKey: "textView")
        
        reactionTextView.layer.add(animation, forKey: nil)
        addSubview(reactionTextView)
    }
    
    
    fileprivate func customPath() -> UIBezierPath{
        //     /-\
        // ---/   \----\   /------
        //              \_/
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: self.frame.size.height / 2))
        let endPoint = CGPoint(x: self.frame.size.width, y: self.frame.size.height / 2)
        let minimumheight = self.frame.size.height * (10/100) // 10%
        let maximumheight = self.frame.size.height * (90/100) // 90%
        let minimumX = self.frame.size.width * (40/100) // 40%
        let maximumX = self.frame.size.width * (60/100) // 60%
        let randomYShift = CGFloat(Double(minimumheight) + drand48() * Double(maximumheight))
        let cp1 = CGPoint(x: minimumX, y: minimumheight - randomYShift)
        let cp2 = CGPoint(x: maximumX, y: maximumheight + randomYShift)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }
}

extension FNReactionsView: CAAnimationDelegate{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let imageView = anim.value(forKey: "imageView") as? UIImageView{
            imageView.removeFromSuperview()
        }
        
        if let textView = anim.value(forKey: "textView") as? UITextView{
            textView.removeFromSuperview()
        }
        
    }
}
