//
//  LocationCompleteController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 27.12.2020.
//

import AVKit
import UIKit

// MARK: - LocationCompleteController

final class LocationCompleteController: LocationFinishedController {
    
    // MARK: IBOutlets
    
    @IBOutlet var starImageViews: [UIImageView]!
    
    // MARK: - Private Properties
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let locationFinishedAudioPlayer = try? AVAudioPlayer(data: NSDataAsset(name: "location_finished")!.data)
    private let starAudioPlayers = [
        try? AVAudioPlayer(data: NSDataAsset(name: "star")!.data),
        try? AVAudioPlayer(data: NSDataAsset(name: "star")!.data),
        try? AVAudioPlayer(data: NSDataAsset(name: "star")!.data)
    ]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starImageViews.forEach {
            $0.layer.dropShadow(opacity: 0.25, offset: CGSize(width: 0, height: 5), radius: 7)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationFinishedAudioPlayer?.play()
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
                self?.starAudioPlayers[i]?.play()
                UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
                    self?.starImageViews[i].transform = .identity
                }
            }
            startTime += 0.4
        }
    }
}
