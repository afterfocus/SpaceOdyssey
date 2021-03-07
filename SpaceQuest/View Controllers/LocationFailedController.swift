//
//  File.swift
//  SpaceQuest
//
//  Created by Максим Голов on 11.01.2021.
//

import UIKit

// MARK: - LocationFailedController

final class LocationFailedController: LocationFinishedController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightAnswerField: AnswerFieldView!
    @IBOutlet weak var rightAnswerFieldHeight: NSLayoutConstraint!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.layer.dropShadow(opacity: 0.3, radius: 8)
        rightAnswerField.configureFor(rightAnswer: question.answer,
                                      alternativeAnswer: nil,
                                      isComplete: true,
                                      maxWidth: 280)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rightAnswerFieldHeight.constant = rightAnswerField.contentSize.height
    }
}
