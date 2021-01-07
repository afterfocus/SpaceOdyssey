//
//  QuestionControlsView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 07.01.2021.
//

import UIKit

protocol QuestionControlsViewDelegate: class {
    func questionControlsViewDidTapHintButton(_ questionControlsView: QuestionControlsView)
    func questionControlsViewDidTapClearButton(_ questionControlsView: QuestionControlsView)
    func questionControlsViewDidTapVideoAnswerButton(_ questionControlsView: QuestionControlsView)
}

class QuestionControlsView: UIStackView {
    
    enum QuestionControlsMode {
        case answerVideo, basic
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var rocketImageViews: [UIImageView]!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var answerVideoView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var answerVideoButton: UIButton!
    
    // MARK: - Internal Properties
    
    weak var delegate: QuestionControlsViewDelegate?
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rocketImageViews.forEach { $0.layer.dropShadow(opacity: 0.2, radius: 2) }
        hintLabel.layer.dropShadow(opacity: 0.4, radius: 2)
        hintButton.layer.dropShadow(opacity: 0.25, radius: 2)
        clearButton.layer.dropShadow(opacity: 0.25, radius: 2)
        answerVideoButton.layer.dropShadow(opacity: 0.25, radius: 2)
    }
    
    // MARK: - IBActions
    
    @IBAction func hintButtonPressed(_ sender: UIButton) {
        delegate?.questionControlsViewDidTapHintButton(self)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        delegate?.questionControlsViewDidTapClearButton(self)
    }
    
    @IBAction func videoAnswerButtonPressed(_ sender: UIButton) {
        delegate?.questionControlsViewDidTapVideoAnswerButton(self)
    }
    
    // MARK: - Internal Functions
    
    func configure(mode: QuestionControlsMode,
                   isAnswerVideoButtonEnabled: Bool,
                   remainingHints: Int,
                   score: Int,
                   delegate: QuestionControlsViewDelegate?) {
        hintView.isHidden = mode == .answerVideo
        clearView.isHidden = mode == .answerVideo
        answerVideoView.isHidden = mode == .basic
        
        answerVideoButton.isEnabled = isAnswerVideoButtonEnabled
        setRemainingHints(remainingHints)
        self.delegate = delegate
        
        for i in score ..< 3 {
            rocketImageViews[i].tintColor = .unhighlightedStar
        }
    }
    
    func setRemainingHints(_ remainingHints: Int) {
        hintLabel.text = "\(remainingHints)"
        hintButton.isEnabled = remainingHints > 0
    }
    
    func reduceScore(newValue: Int) {
        UIView.animate(withDuration: 0.75) {
            self.rocketImageViews[newValue].tintColor = .unhighlightedStar
        }
    }
    
    func animateHintButton() {
        UIView.animate(withDuration: 0.3) {
            self.hintButton.tintColor = .unhighlightedStar
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.hintButton.tintColor = .systemYellow
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    self.hintButton.tintColor = .unhighlightedStar
                } completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.hintButton.tintColor = .systemYellow
                    }
                }
            }
        }
    }
}
