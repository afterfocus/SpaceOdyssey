//
//  LocationCompleteController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 27.12.2020.
//

import UIKit

// MARK: LocationCompleteControllerDelegate

protocol LocationCompleteControllerDelegate: class {
    func locationCompleteControllerDidTapVideoAnswerButton(_ controller: LocationCompleteController)
    func locationCompleteControllerDidTapNextQuestionButton(_ controller: LocationCompleteController)
}


// MARK: - LocationCompleteController

class LocationCompleteController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet var videoAnswerButton: UIButton!
    
    // MARK: - Segue Properties
    
    var question: Question!
    weak var delegate: LocationCompleteControllerDelegate?
    
    // MARK: - Private Properties
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        starImageViews.forEach {
            $0.layer.dropShadow(opacity: 0.25, offset: CGSize(width: 0, height: 5), radius: 7)
        }
        containerView.layer.dropShadow(color: UIColor.systemYellow.cgColor, opacity: 0.3, radius: 25)
        videoAnswerButton.isEnabled = question.answerVideoUrl != nil
        videoAnswerButton.alpha = question.answerVideoUrl != nil ? 1 : 0.6
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
    
    // MARK: - IBActions
    
    @IBAction func videoAnswerButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.locationCompleteControllerDidTapVideoAnswerButton(self)
        }
    }
    
    @IBAction func nextQuestionButtonPressed(_ sender: UIButton) {
        delegate?.locationCompleteControllerDidTapNextQuestionButton(self)
        dismiss(animated: true)
    }
}
