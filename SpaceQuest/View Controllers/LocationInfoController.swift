//
//  LocationInfoController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 10.02.2021.
//

import UIKit

// MARK: - LocationInfoContainerController

class LocationInfoContainerController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var height: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var location: Location!
    
    // MARK: - View Life Cycle
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InfoEmbedSegue" {
            let infoController = segue.destination as? LocationInfoController
            infoController?.height = height
            infoController?.location = location
        }
    }
}


// MARK: - LocationInfoController

class LocationInfoController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var photoImageViewHeight: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var location: Location!
    weak var height: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 3
        view.layer.borderColor = .lightAccent
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        addressLabel.text = location.address
        locationNameLabel.text = location.name
        photoImageView.image = UIImage(named: location.photoFilename)!
    }
    
    override func viewDidLayoutSubviews() {
        let ratio = photoImageView.image!.size.height / photoImageView.image!.size.width
        photoImageViewHeight.constant = photoImageView.bounds.width * ratio
        print(photoImageView.bounds.width)
        height.constant = 170 + photoImageViewHeight.constant + addressLabel.bounds.height + locationNameLabel.bounds.height
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

