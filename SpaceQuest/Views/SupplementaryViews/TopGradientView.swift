//
//  topGradientView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

/// Представление с градиентом для верхней части экрана
class TopGradientView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if layer.sublayers == nil {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.locations = [0.15, 1]
            gradientLayer.colors = [UIColor.topViewGradient.cgColor, UIColor.topViewGradient.withAlphaComponent(0).cgColor]
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
