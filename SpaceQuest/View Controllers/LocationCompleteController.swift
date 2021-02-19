//
//  LocationCompleteController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 27.12.2020.
//

import UIKit


// MARK: - LocationCompleteController

class LocationCompleteController: LocationFinishedController {
    
    // MARK: IBOutlets
    
    @IBOutlet var starImageViews: [UIImageView]!
    
    // MARK: - Private Properties
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starImageViews.forEach {
            $0.layer.dropShadow(opacity: 0.25, offset: CGSize(width: 0, height: 5), radius: 7)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var startTime: Double = 0
        
        for i in 0 ..< question.score {
            UIView.animate(withDuration: 0.3, delay: startTime, options: [.curveEaseIn]) {
                [weak self] in
                self?.starImageViews[i].tintColor = .systemYellow
            }
            
            UIView.animate(withDuration: 0.15, delay: startTime + 0.2, options: [.curveEaseIn]) {
                [weak self] in
                self?.feedbackGenerator.prepare()
                self?.starImageViews[i].transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            } completion: {
                [weak self] _ in
                self?.feedbackGenerator.impactOccurred()
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
                    self?.starImageViews[i].transform = .identity
                }
            }
            startTime += 0.4
        }
    }
}
