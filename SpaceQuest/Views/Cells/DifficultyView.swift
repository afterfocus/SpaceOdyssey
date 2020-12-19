//
//  DifficultyView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 16.11.2020.
//

import UIKit

class DifficultyView: UIView {
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    func configure(with routeVariation: RouteVariation, route: Route) {
        lengthLabel.text = "\(routeVariation.length)"
        durationLabel.text = "\(routeVariation.duration)"
        progressLabel.text = "\(route.progress(for: routeVariation))"
    }
}
