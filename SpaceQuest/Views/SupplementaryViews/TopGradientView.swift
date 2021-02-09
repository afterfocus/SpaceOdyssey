//
//  topGradientView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

/// Представление с градиентом для верхней части экрана
class TopGradientView: UIView {
    
    var color: UIColor = .topViewGradient
    var startLocation: NSNumber = 0.15
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if layer.sublayers == nil {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = frame
            gradientLayer.locations = [startLocation, 1]
            gradientLayer.colors = [
                color.cgColor,
                color.withAlphaComponent(0).cgColor]
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
