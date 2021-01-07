//
//  UIColorExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 05.12.2020.
//

import UIKit

extension UIColor {
    static let topViewGradient = UIColor(red: 40/255, green: 94/255, blue: 168/255, alpha: 0.85)
    static let unhighlightedStar = UIColor(red: 0, green: 0, blue: 54/255, alpha: 0.5)
    
    static let answerCellDefault = UIColor(red: 100/255, green: 180/255, blue: 240/255, alpha: 0.92)
    static let answerCellRed = UIColor.systemRed.withAlphaComponent(0.92)
    static let answerCellGreen = UIColor.systemGreen.withAlphaComponent(0.92)
    
}

extension CGColor {
    static let cellGradientStart = UIColor(red: 115/255, green: 172/255, blue: 236/255, alpha: 1).cgColor
    static let cellGradientEnd = UIColor(red: 5/255, green: 30/255, blue: 81/255, alpha: 1).cgColor
    static let cellShadow = UIColor(red: 105/255, green: 192/255, blue: 240/255, alpha: 1).cgColor
}

