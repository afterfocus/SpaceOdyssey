//
//  QuestionViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 29.11.2020.
//

import WebKit
import AudioToolbox

// MARK: QuestionViewController

class QuestionViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var rootScrollView: UIScrollView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorLabelBackground: UIView!
    @IBOutlet weak var webVideoView: WebVideoView!
    @IBOutlet weak var questionLabelBackgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionControlsView: QuestionControlsView!
    @IBOutlet weak var answerFieldView: AnswerFieldView!
    @IBOutlet weak var answerButtonsBackgroundView: UIView!
    @IBOutlet weak var answerButtonsView: AnswerButtonsView!
    
    @IBOutlet weak var answerFieldViewHeight: NSLayoutConstraint!
    @IBOutlet weak var answerFieldViewContainterHeight: NSLayoutConstraint!
    @IBOutlet weak var answerButtonsViewHeight: NSLayoutConstraint!
    
    // MARK: - Segue Properties
    
    var route: Route!
    var variation: RouteVariation!
    var questionIndex: Int!
    
    // MARK: - Private Properties
    
    private var currentQuestion: Question!
    private var score = 3
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage(named: route.imageFileName)
        
        authorLabelBackground.layer.cornerRadius = 11
        authorLabelBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        questionLabelBackgroundView.layer.dropShadow(opacity: 0.3, radius: 7)
        
        answerButtonsBackgroundView.layer.cornerRadius = 20
        answerButtonsBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        answerFieldView.answerFieldViewDelegate = self
        answerButtonsView.answerButtonsViewDelegate = self
        
        // Configure Question Data
        currentQuestion = route[variation[questionIndex]]
        title = currentQuestion.title
        authorLabel.text = currentQuestion.author.initials
        questionLabel.text = currentQuestion.questionText
        
        answerFieldView.configureFor(rightAnswer: currentQuestion.answer,
                                     alternativeAnswer: currentQuestion.alternativeAnswer,
                                     isComplete: currentQuestion.isComplete,
                                     maxWidth: UIScreen.main.bounds.width - 20)
        answerButtonsView.answerCharacters = currentQuestion.answerCharacters
        score = currentQuestion.isComplete ? currentQuestion.score : 3
        
        questionControlsView.configure(mode: currentQuestion.isComplete ? .answerVideo : .basic,
                                       isAnswerVideoButtonEnabled: currentQuestion.answerVideoUrl != nil,
                                       remainingHints: answerFieldView.remainingHints,
                                       score: score,
                                       delegate: self)
        
        if let url = currentQuestion.questionVideoUrl {
            webVideoView.loadVideo(url: url)
        } else {
            webVideoView.showNoVideoLabel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3, delay: 0.2, options: []) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            [weak self] in self?.tabBarController?.tabBar.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        answerFieldViewHeight.constant = answerFieldView.contentSize.height
        answerButtonsViewHeight.constant = answerButtonsView.contentSize.height
        
        let rootScrollViewHeight = rootScrollView.contentSize.height
        let layoutFrameHeight = view.safeAreaLayoutGuide.layoutFrame.size.height + 40
        let minAnswerFieldHeight = layoutFrameHeight - rootScrollViewHeight + answerFieldViewContainterHeight.constant
        answerFieldViewContainterHeight.constant = max(answerFieldViewHeight.constant, minAnswerFieldHeight)
    }
    
    // MARK: - IBOutlets
    
    @IBAction func locationInfoButtonPressed(_ sender: UIButton) {
        guard let controller = storyboard!.instantiateViewController(withIdentifier: "LocationInfoContainerController") as? LocationInfoContainerController else { return }
        controller.questionIndex = questionIndex
        controller.question = currentQuestion
        present(controller, animated: true)
    }
    
    // MARK: - Private Functions
    
    private func useHint() {
        guard answerFieldView.remainingHints > 0 else { return }
        
        answerFieldView.useHint().forEach {
            answerButtonsView.removeCharacter($0)
        }
        questionControlsView.setRemainingHints(answerFieldView.remainingHints)
    }
    
    private func delay(delayTime: Double = 0.75, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            closure()
        }
    }
    
    // MARK: Navigation
    
    private func showNextQuestion() {
        guard let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else { return }
        questionVC.route = route
        questionVC.variation = variation
        questionVC.questionIndex = route.firstIncompleteIndex(for: variation)
        navigationController?.popViewController(animated: true)
        navigationController?.pushViewController(questionVC, animated: true)
    }
    
    private func showVideoAnswer(mode: VideoAnswerController.Mode) {
        guard let videoAnswerVC = storyboard!.instantiateViewController(withIdentifier: "VideoAnswerController") as? VideoAnswerController else { return }
        videoAnswerVC.videoURL = currentQuestion.answerVideoUrl
        videoAnswerVC.mode = mode
        videoAnswerVC.delegate = self
        present(videoAnswerVC, animated: true)
    }
    
    private func showLocationFinishedController(isLocationFailed: Bool = false, isRouteCompleted: Bool) {
        let identifier = isLocationFailed ? "LocationFailedController" : "LocationCompleteController"
        guard let controller = storyboard!.instantiateViewController(withIdentifier: identifier) as? LocationFinishedController else { return }
        controller.question = currentQuestion
        controller.isRouteCompleted = isRouteCompleted
        controller.delegate = self
        present(controller, animated: true)
    }
    
    private func showRouteCompletedController() {
        guard let controller = storyboard!.instantiateViewController(withIdentifier: "RouteCompleteController") as? RouteCompleteController else { return }
        controller.route = route
        controller.lastQuestion = currentQuestion
        controller.delegate = self
        present(controller, animated: true)
    }
}


// MARK: - QuestionControlsViewDelegate

extension QuestionViewController: QuestionControlsViewDelegate {
    
    func questionControlsViewDidTapHintButton(_ questionControlsView: QuestionControlsView) {
        let controller = UIAlertController(title: "Использовать подсказку",
                                           message: "\nИспользовать одну из оставшихся подсказок, чтобы открыть первую и последнюю буквы?\n\nОставшихся подсказок: \(answerFieldView.remainingHints)",
                                           preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        let useAction = UIAlertAction(title: "Использовать", style: .default) { _ in
            self.useHint()
            self.score -= 1
            self.questionControlsView.reduceScore(newValue: self.score)
            self.questionControlsView.animateHintButton()
        }
        controller.addAction(cancelAction)
        controller.addAction(useAction)
        present(controller, animated: true)
    }
    
    func questionControlsViewDidTapClearButton(_ questionControlsView: QuestionControlsView) {
        answerFieldView.clear()
    }
    
    func questionControlsViewDidTapVideoAnswerButton(_ questionControlsView: QuestionControlsView) {
        showVideoAnswer(mode: .noAction)
    }
}


// MARK: - AnswerButtonsViewDelegate

extension QuestionViewController: AnswerButtonsViewDelegate {
    
    func answerButtonsView(_ answerButtonsView: AnswerButtonsView, didSelect character: Character, at indexPath: IndexPath) {
        if answerFieldView.appendCharacter(character) {
            impactGenerator.impactOccurred()
            AudioServicesPlaySystemSound(0x450)
            answerButtonsView.removeCharacter(at: indexPath)
        }
    }
}


// MARK: - AnswerFieldViewDelegate

extension QuestionViewController: AnswerFieldViewDelegate {
    
    func answerFieldView(_ answerFieldView: AnswerFieldView, didRemove character: Character) {
        answerButtonsView.returnCharacter(character)
    }
    
    func answerFieldView(_ answerFieldView: AnswerFieldView, didReceiveAnswer isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            currentQuestion.score = score
            currentQuestion.isComplete = true
            delay {
                self.showLocationFinishedController(isRouteCompleted: self.route.isVariationComplete(self.variation))
                self.webVideoView.stopVideoPlaying()
            }
        } else {
            score -= 1
            delay { self.questionControlsView.reduceScore(newValue: self.score) }
            
            if score == 0 {
                currentQuestion.isComplete = true
                delay {
                    self.showLocationFinishedController(isLocationFailed: true,
                                                        isRouteCompleted: self.route.isVariationComplete(self.variation))
                    self.webVideoView.stopVideoPlaying()
                }
            } else {
                guard answerFieldView.remainingHints > 0 else { return }
                questionControlsView.animateHintButton()
                delay { self.useHint() }
                delay(delayTime: 1.5) { self.answerFieldView.clear() }
            }
        }
    }
}


// MARK: - LocationCompleteControllerDelegate

extension QuestionViewController: LocationFinishedControllerDelegate {
    
    func locationFinishedControllerDidTapVideoAnswerButton(_ controller: LocationFinishedController) {
        showVideoAnswer(mode: route.isVariationComplete(variation) ? .endRoute : .nextQuestion)
    }
    
    func locationFinishedControllerDidTapNextQuestionButton(_ controller: LocationFinishedController) {
        showNextQuestion()
    }
    
    func locationFinishedControllerDidTapEndRouteButton(_ controller: LocationFinishedController) {
        showRouteCompletedController()
    }
}


// MARK: - RouteCompleteControllerDelegate

extension QuestionViewController: RouteCompleteControllerDelegate {
    
    func routeCompleteControllerDidTapExitButton(_ controller: RouteCompleteController) {
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - VideoAnswerControllerDelegate

extension QuestionViewController: VideoAnswerControllerDelegate {
    
    func videoAnswerControllerDidTapNextQuestionButton(_ controller: VideoAnswerController) {
        showNextQuestion()
    }
    
    func videoAnswerControllerDidTapEndRouteButton(_ controller: VideoAnswerController) {
        showRouteCompletedController()
    }
}
