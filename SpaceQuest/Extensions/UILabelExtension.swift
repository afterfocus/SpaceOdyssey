//
//  UILabelExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 06.12.2020.
//

import UIKit

extension UILabel {
    class func titleLabel(with text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.font = .boldSystemFont(ofSize: 17)
        label.text = text
        return label
    }
}
