//
//  VideoAnswerController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 07.01.2021.
//

import UIKit

protocol VideoAnswerControllerDelegate: class {
    func videoAnswerControllerDidTapNextQuestionButton(_ controller: VideoAnswerController)
    func videoAnswerControllerDidTapExitToRouteListButton(_ controller: VideoAnswerController)
    func videoAnswerControllerDidTapExitButton(_ controller: VideoAnswerController)
}

extension VideoAnswerControllerDelegate {
    func videoAnswerControllerDidTapExitButton(_ controller: VideoAnswerController) { }
}

class VideoAnswerController: UIViewController {
    
    enum ExitMode {
        case routeList, nextQuestion, noAction
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var webVideoView: WebVideoView!
    @IBOutlet var exitButton: UIButton!
    
    // MARK: - Segue Properties
    
    var videoURL: URL!
    var exitMode: ExitMode!
    weak var delegate: VideoAnswerControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webVideoView.layer.dropShadow(color: .cellShadow, opacity: 0.35, radius: 40)
        
        switch exitMode {
            case .routeList: exitButton.setTitle("На главный экран", for: .normal)
            case .nextQuestion: exitButton.setTitle("Следующий вопрос", for: .normal)
            default: exitButton.setTitle("Закрыть", for: .normal)
        }
        webVideoView.loadVideo(url: videoURL)
    }
    
    // MARK: - IBActions
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        switch exitMode {
            case .routeList: delegate?.videoAnswerControllerDidTapExitToRouteListButton(self)
            case .nextQuestion: delegate?.videoAnswerControllerDidTapNextQuestionButton(self)
            default: delegate?.videoAnswerControllerDidTapExitButton(self)
        }
        dismiss(animated: true)
    }
}
