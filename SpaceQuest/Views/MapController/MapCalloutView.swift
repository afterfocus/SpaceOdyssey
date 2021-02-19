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
    
    override func awakeFromNib() {
        layer.borderWidth = 3.5
        layer.borderColor = .lightAccent
    }
    
    func configure(for location: Location) {
        addressLabel.text = location.address
        locationNameLabel.text = location.name
        photoImageView.image = UIImage(named: location.photoFilename)!
    }
}
