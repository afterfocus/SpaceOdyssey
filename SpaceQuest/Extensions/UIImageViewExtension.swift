//
//  UIImageViewExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

extension UIImageView {
    convenience init(withImageNamed imageFileName: String,
                     alpha: CGFloat,
                     contentMode: ContentMode = .scaleAspectFill) {
        self.init(image: UIImage(named: imageFileName))
        self.alpha = alpha
        self.contentMode = contentMode
    }
}
