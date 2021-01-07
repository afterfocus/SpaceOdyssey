//
//  RouteCell.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import UIKit

// MARK: RouteTableViewCellDelegate

protocol RouteTableViewCellDelegate: class {
    /// Выбрана вариация маршрута с индексом `index`
    func routeTableViewCell(_ cell: RouteTableViewCell, didSelectRouteVariationAt index: Int)
}


// MARK: - RouteTableViewCell

class RouteTableViewCell: UITableViewCell {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var foregroundView: UIView!
    
    @IBOutlet var difficultyViews: [DifficultyView]!
    @IBOutlet weak var difficultyViewHeight: NSLayoutConstraint!
    
    // MARK: - Internal Properties
    
    weak var delegate: RouteTableViewCellDelegate?
    
    // MARK: - Cell Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.layer.borderColor = UIColor.systemYellow.cgColor
        layer.dropShadow(opacity: 0.3, radius: 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        UIView.animate(withDuration: 0.25) { [self] in
            foregroundView.alpha = isSelected ? 0 : 1
            backgroundImageView.layer.borderWidth = isSelected ? 4 : 0
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        delegate?.routeTableViewCell(self, didSelectRouteVariationAt: sender.tag)
    }

    // MARK: - Internal Functions
    
    func configure(with route: Route) {
        backgroundImageView.image = UIImage(named: route.imageFileName)
        titleLabel.text = route.title
        subtitleLabel.text = route.subtitle
        scoreLabel.text = "\(route.score)"
        
        for (index, difficultyView) in difficultyViews.enumerated() {
            if index < route.variations.count {
                difficultyView.isHidden = false
                difficultyView.configure(with: route.variations[index], route: route)
            } else {
                difficultyView.isHidden = true
            }
        }
        difficultyViewHeight.constant = CGFloat(15 + 61 * route.variations.count)
    }
}
