//
//  AnswerCollectionViewCell.swift
//  SpaceQuest
//
//  Created by Максим Голов on 15.12.2020.
//

import UIKit

class AnswerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var letterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
    }
}
