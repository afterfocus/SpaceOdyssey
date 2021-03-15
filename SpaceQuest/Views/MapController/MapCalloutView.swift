//
//  MapCallout.swift
//  SpaceQuest
//
//  Created by Максим Голов on 08.02.2021.
//

import UIKit

final class MapCalloutView: UIView {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 3.5
        layer.borderColor = .lightAccent
    }
    
    func configure(for location: Location, isComplete: Bool, isLocked: Bool, isVisited: Bool) {
        addressLabel.text = location.address
        locationNameLabel.text = location.name
        photoImageView.image = UIImage(named: location.photoFilename)!
        
        if isComplete {
            configureButton(color: .lightAccent, alpha: 1, title: "К вопросу")
        } else if isLocked {
            configureButton(color: .systemYellow, alpha: 0.5, title: "Заблокировано")
        } else {
            configureButton(color: .systemYellow,
                            alpha: isVisited ? 1 : 0.5,
                            title: isVisited ? "К вопросу" : "Не посещено")
        }
    }
    
    private func configureButton(color: UIColor, alpha: CGFloat, title: String) {
        button.backgroundColor = color
        button.alpha = alpha
        button.setTitle(title, for: .normal)
    }
}
