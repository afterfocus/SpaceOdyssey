//
//  AnswerButtonCollectionViewCell.swift
//  SpaceQuest
//
//  Created by Максим Голов on 05.12.2020.
//

import UIKit

class AnswerButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var letterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4
    }
}
