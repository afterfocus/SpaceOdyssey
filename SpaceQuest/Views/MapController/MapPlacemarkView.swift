//
//  MapPlacemark.swift
//  SpaceQuest
//
//  Created by Максим Голов on 23.01.2021.
//

import UIKit

final class MapPlacemarkView: UIView {
    
    convenience init(index: Int, isComplete: Bool, isLocked: Bool, isVisited: Bool) {
        self.init(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        isOpaque = false
        alpha = isLocked ? 0.5 : 1
        
        let backCircle = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        backCircle.backgroundColor = isComplete ? .darkBlue : .systemYellow
        backCircle.layer.cornerRadius = 17.5
        addSubview(backCircle)
        
        let frontCircle = UIView(frame: CGRect(x: 3, y: 3, width: 29, height: 29))
        frontCircle.backgroundColor = isComplete ? .systemYellow : .darkBlue
        frontCircle.layer.cornerRadius = 14.5
        addSubview(frontCircle)
        
        let numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        numberLabel.textAlignment = .center
        numberLabel.textColor = isComplete ? .darkBlue : .systemYellow
        numberLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        numberLabel.text = "\(index + 1)"
        addSubview(numberLabel)
        
        if isVisited {
            let isVisitedIndicator = UIView(frame: CGRect(x: 25, y: 22, width: 11, height: 11))
            isVisitedIndicator.layer.cornerRadius = 5.5
            isVisitedIndicator.backgroundColor = .systemGreen
            isVisitedIndicator.layer.borderWidth = 3
            isVisitedIndicator.layer.borderColor = .darkBlue
            insertSubview(isVisitedIndicator, at: subviews.count)
        }
    }
}
