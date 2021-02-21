//
//  MapPlacemark.swift
//  SpaceQuest
//
//  Created by Максим Голов on 23.01.2021.
//

import UIKit

class MapPlacemarkView: UIView {
    
    private var numberLabel = UILabel()
    
    convenience init(index: Int, isComplete: Bool, isLocked: Bool) {
        self.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        isOpaque = false
        clearsContextBeforeDrawing = false
        alpha = isLocked ? 0.5 : 1
        
        backgroundColor = isComplete ? .systemYellow : .darkBlue
        layer.cornerRadius = 17.5
        layer.borderWidth = 3
        layer.borderColor = isComplete ? .darkBlue : UIColor.systemYellow.cgColor
        
        numberLabel.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        numberLabel.textAlignment = .center
        numberLabel.textColor = isComplete ? .darkBlue : .systemYellow
        numberLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        numberLabel.text = "\(index + 1)"
        addSubview(numberLabel)
    }
}
