//
//  QuestionCollectionViewHeader.swift
//  SpaceQuest
//
//  Created by Максим Голов on 19.04.2021.
//

import UIKit

final class QuestionCollectionViewHeader: UICollectionReusableView {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraint: NSLayoutConstraint!
    
    private let titles = [
        "Устал? Включи режим\n«‎На диване‎» в профиле‎.",
        "Пройди марушрут и получи\nуникальный приз!",
        "Пройди все маршруты и собери\nполную коллекцию призов!"]
    private var titleIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] timer in
            self?.updateTitle()
        }
    }
    
    func setSpacing(_ spacing: CGFloat) {
        leadingConstraint.constant = spacing
        trailingConstraint.constant = spacing
    }
    
    func updateTitle() {
        titleIndex += 1
        if titleIndex > 2 {
            titleIndex = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: self.frame.width / 3, y: 0)
            self.alpha = 0
        } completion: { _ in
            self.transform = CGAffineTransform(translationX: -self.frame.width / 3, y: 0)
            self.titleLabel.text = self.titles[self.titleIndex]
            
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
                self.alpha = 1
            }
        }
    }
}
