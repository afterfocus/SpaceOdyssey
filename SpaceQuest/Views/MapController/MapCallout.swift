//
//  MapCallout.swift
//  SpaceQuest
//
//  Created by Максим Голов on 08.02.2021.
//

import UIKit

class MapCalloutView: UIView {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    
    func configure(for location: Location) {
        layer.borderWidth = 4
        layer.borderColor = UIColor.systemYellow.cgColor
        layer.dropShadow(color: UIColor.black.cgColor, opacity: 0.3, radius: 25)
        
        addressLabel.text = location.address
        locationNameLabel.text = location.name
        
        let image = UIImage(named: location.photoFilename)!
        photoImageView.image = image
        let ratio = image.size.width / image.size.height
        photoHeightConstraint.constant = photoImageView.frame.width / ratio
    }
}
