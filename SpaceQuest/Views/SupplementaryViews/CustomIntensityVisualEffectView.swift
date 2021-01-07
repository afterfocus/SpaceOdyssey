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
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            [unowned self] in
            self.effect = UIBlurEffect(style: .dark)
        }
        animator.fractionComplete = 0.15
    }
}
