//
//  QuestionCollectionViewCell.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

// MARK: QuestionCollectionViewCell

class QuestionCollectionViewCell: UICollectionViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var patronymicLabel: UILabel!
    @IBOutlet weak var aboutAuthorLabel: UILabel!
    
    @IBOutlet weak var lockView: UIVisualEffectView!
    
    // MARK: - Cell Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.dropShadow(opacity: 0.4, radius: 7)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.frame
        gradientLayer.locations = [0.05, 0.95]
        gradientLayer.colors = [CGColor.lightBlue, CGColor.darkBlue]
        frontView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        frontView.isHidden = false
        backView.isHidden = true
        layer.shadowColor = UIColor.black.cgColor
    }
    
    // MARK: - Internal Functions
    
    func configure(with question: Question, index: Int, isLocked: Bool) {
        numberLabel.text = "\(index)"
        titleLabel.text = question.title
        locationNameLabel.text = question.location.name
        
        surnameLabel.text = question.author.surname
        nameLabel.text = question.author.name
        patronymicLabel.text = question.author.patronymic
        aboutAuthorLabel.text = question.author.aboutAuthor
        checkmarkImageView.isHidden = !question.isComplete
        
        for (index, star) in starImageViews.enumerated() {
            star.tintColor = question.score > index ? .systemYellow : .unhighlightedStar
        }
        lockView.isHidden = !isLocked
    }
    
    func flip() {
        let flipDirection: UIView.AnimationOptions = frontView.isHidden ? .transitionFlipFromRight : .transitionFlipFromLeft
        let shouldHideFront = !frontView.isHidden
        
        layer.shadowOpacity = 0
        UIView.transition(with: contentView, duration: 0.4, options: flipDirection) {
            [weak self] in
            self?.frontView.isHidden = shouldHideFront
            self?.backView.isHidden = !shouldHideFront
            self?.layer.shadowColor = shouldHideFront ? .cellShadow : UIColor.black.cgColor
        }
        UIView.animate(withDuration: 0.2, delay: 0.2, options: []) {
            [weak self] in
            self?.layer.shadowOpacity = 0.4
        }
    }
}
