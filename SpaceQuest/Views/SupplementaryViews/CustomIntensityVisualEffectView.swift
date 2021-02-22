//
//  CustomIntensityVisualEffectView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 27.12.2020.
//

import UIKit

class CustomIntensityVisualEffectView: UIVisualEffectView {
    
    private var animator: UIViewPropertyAnimator!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        effect = nil
        animator = UIViewPropertyAnimator(duration: 0, curve: .linear) {
            [weak self] in
            self?.effect = UIBlurEffect(style: .dark)
        }
        animator.fractionComplete = 0.1
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            [weak self] in
            self?.animator.stopAnimation(true)
            self?.animator.finishAnimation(at: .current)
        }
    }
}
