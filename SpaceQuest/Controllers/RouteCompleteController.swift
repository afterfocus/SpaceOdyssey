//
//  RouteCompleteController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 04.01.2021.
//

import UIKit

// MARK: RouteCompleteControllerDelegate

protocol RouteCompleteControllerDelegate: class {
    func routeCompleteControllerDidTapVideoAnswerButton(_ controller: RouteCompleteController)
    func routeCompleteControllerDidTapExitButton(_ controller: RouteCompleteController)
}


// MARK: - RouteCompleteController

class RouteCompleteController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var scoredStarsLabel: UILabel!
    @IBOutlet var totalStarsLabel: UILabel!
    @IBOutlet var videoAnswerButton: UIButton!
    
    // MARK: - Segue Properties
    
    weak var delegate: RouteCompleteControllerDelegate?
    var route: Route!
    var lastQuestion: Question!
    
    // MARK: - Private Properties
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.dropShadow(color: UIColor.systemYellow.cgColor, opacity: 0.3, radius: 25)
        starImageView.layer.dropShadow(opacity: 0.25, offset: CGSize(width: 0, height: 5), radius: 7)
        scoredStarsLabel.layer.dropShadow(opacity: 0.25, radius: 7)
        totalStarsLabel.layer.dropShadow(opacity: 0.25, radius: 7)
        
        videoAnswerButton.isEnabled = lastQuestion.answerVideoUrl != nil
        videoAnswerButton.alpha = lastQuestion.answerVideoUrl != nil ? 1 : 0.6
        totalStarsLabel.text = "\(route.maxScore)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 1 ... route.score {
            DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(i))) {
                [weak self] in
                self?.scoredStarsLabel.text = "\(i)"
                self?.feedbackGenerator.impactOccurred()
            }
        }
        
        UIView.animate(withDuration: 0.2 + (0.05 * Double(route.score)), delay: 0.05, options: [.curveEaseOut]) {
            [weak self] in self?.scoredStarsLabel.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        } completion: {
            [weak self] _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut]) {
                self?.scoredStarsLabel.transform = .identity
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func videoAnswerButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.routeCompleteControllerDidTapVideoAnswerButton(self)
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        delegate?.routeCompleteControllerDidTapExitButton(self)
        dismiss(animated: true)
    }
}

