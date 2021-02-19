//
//  LocationFinishedControllerProtocol.swift
//  SpaceQuest
//
//  Created by Максим Голов on 11.01.2021.
//

import UIKit

// MARK: LocationCompleteControllerDelegate

protocol LocationFinishedControllerDelegate: class {
    func locationFinishedControllerDidTapVideoAnswerButton(_ controller: LocationFinishedController)
    func locationFinishedControllerDidTapNextQuestionButton(_ controller: LocationFinishedController)
    func locationFinishedControllerDidTapEndRouteButton(_ controller: LocationFinishedController)
}

// MARK: - LocationFinishedController

class LocationFinishedController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoAnswerButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Segue Properties
    
    var question: Question!
    var isRouteCompleted: Bool!
    weak var delegate: LocationFinishedControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.dropShadow(color: UIColor.systemYellow.cgColor, opacity: 0.3, radius: 25)
        videoAnswerButton.isEnabled = question.answerVideoUrl != nil
        videoAnswerButton.alpha = question.answerVideoUrl != nil ? 1 : 0.6
        closeButton.setTitle(isRouteCompleted ? "Завершить маршрут" : "Следующий вопрос", for: .normal)
    }
    
    // MARK: - IBActions
    
    @IBAction func videoAnswerButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.delegate?.locationFinishedControllerDidTapVideoAnswerButton(self)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { [self] in
            if self.isRouteCompleted {
                delegate?.locationFinishedControllerDidTapEndRouteButton(self)
            } else {
                delegate?.locationFinishedControllerDidTapNextQuestionButton(self)
            }
        }
    }
}
