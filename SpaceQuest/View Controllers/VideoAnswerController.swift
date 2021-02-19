//
//  VideoAnswerController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 07.01.2021.
//

import UIKit

// MARK: VideoAnswerControllerDelegate

protocol VideoAnswerControllerDelegate: class {
    func videoAnswerControllerDidTapNextQuestionButton(_ controller: VideoAnswerController)
    func videoAnswerControllerDidTapEndRouteButton(_ controller: VideoAnswerController)
    func videoAnswerControllerDidTapCloseButton(_ controller: VideoAnswerController)
}

extension VideoAnswerControllerDelegate {
    func videoAnswerControllerDidTapCloseButton(_ controller: VideoAnswerController) { }
}

// MARK: - VideoAnswerControllerDelegate

class VideoAnswerController: UIViewController {
    
    enum ExitMode {
        case introVideo, endRoute, nextQuestion, noAction
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webVideoView: WebVideoView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var introMainLabel: UILabel!
    @IBOutlet weak var introSecondaryLabel: UILabel!
    @IBOutlet weak var buttonCenterYConstraint: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var videoURL: URL!
    var exitMode: ExitMode!
    weak var delegate: VideoAnswerControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = (exitMode == .introVideo) ? "Вступление" : "Видео-ответ"
        
        if exitMode == .introVideo {
            titleLabel.text = "Вступление"
            introMainLabel.isHidden = false
            introSecondaryLabel.isHidden = false
            buttonCenterYConstraint.constant = 25
            closeButton.isEnabled = false
            closeButton.alpha = 0.6
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
                self.closeButton.isEnabled = true
                self.closeButton.alpha = 1
            }
        }
        
        switch exitMode {
            case .endRoute: closeButton.setTitle("Завершить маршрут", for: .normal)
            case .nextQuestion: closeButton.setTitle("Следующий вопрос", for: .normal)
            default: closeButton.setTitle("Закрыть", for: .normal)
        }
        
        webVideoView.layer.dropShadow(color: .cellShadow, opacity: 0.35, radius: 40)
        webVideoView.loadVideo(url: videoURL)
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) { [self] in
            switch exitMode {
                case .endRoute:
                    delegate?.videoAnswerControllerDidTapEndRouteButton(self)
                case .nextQuestion:
                    delegate?.videoAnswerControllerDidTapNextQuestionButton(self)
                default:
                    delegate?.videoAnswerControllerDidTapCloseButton(self)
            }
        }
    }
}
