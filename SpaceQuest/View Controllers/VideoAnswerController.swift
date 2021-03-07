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

final class VideoAnswerController: UIViewController {
    
    enum Mode {
        case introVideo, bonusVideo, endRoute, nextQuestion, noAction
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webVideoView: WebVideoView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var secondaryLabel: UILabel!
    @IBOutlet weak var tertiaryLabel: UILabel!
    @IBOutlet weak var buttonCenterYConstraint: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var videoURL: URL!
    var mode: Mode!
    weak var delegate: VideoAnswerControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .introVideo || mode == .bonusVideo {
            secondaryLabel.isHidden = false
            tertiaryLabel.isHidden = false
            buttonCenterYConstraint.constant = 30
            
            if mode == .introVideo {
                titleLabel.text = "Вступление"
                closeButton.isEnabled = false
                closeButton.alpha = 0.6
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
                    self.closeButton.isEnabled = true
                    self.closeButton.alpha = 1
                }
            } else if mode == .bonusVideo {
                titleLabel.text = "Видео с МКС\n9 апреля 2018 г."
                secondaryLabel.text = "Артемьев Олег Германович\nГерой РФ, лётчик-космонавт РФ"
                tertiaryLabel.text = "Автор стихов - Сергей Иванович Ткаченко\nПрофессор кафедры космического машиностроения Самарского университета,\nд.т.н., заместитель Генерального конструктора\nпо научной работе АО «РКЦ «Прогресс»,\nглавный конструктор серии малых космических аппаратов\n«АИСТ»."
            }
        }
        
        switch mode {
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
            switch mode {
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
