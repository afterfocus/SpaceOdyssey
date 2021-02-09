//
//  QuestionsViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

// MARK: QuestionListViewController

class QuestionListViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var questionsCollectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Segue Properties
    
    var route: Route!
    var routeVariation: RouteVariation!
    
    // MARK: - Private Properties
    
    private var firstIncompleteIndex: Int?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UILabel.titleLabel(with: route.title)
        questionsCollectionView.backgroundView = UIImageView(withImageNamed: route.imageFileName, alpha: 0.75)
        startButton.isHidden = route.isVariationComplete(routeVariation)
        startButton.layer.dropShadow(opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 7)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstIncompleteIndex = route!.firstIncompleteIndex(for: routeVariation)
        questionsCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "isFirstTimeLaunched") {
            guard let videoAnswerVC = storyboard!.instantiateViewController(withIdentifier: "VideoAnswerController") as? VideoAnswerController else { return }
            videoAnswerVC.videoURL = URL(string: "https://www.youtube.com/embed/yvkINNzNnlU?playsinline=1")
            videoAnswerVC.exitMode = .introVideo
            present(videoAnswerVC, animated: true)
            UserDefaults.standard.setValue(false, forKey: "isFirstTimeLaunched")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        showQuestionController(questionIndex: firstIncompleteIndex!)
    }
    
    @IBAction func mapButtonPressed(_ sender: UIBarButtonItem) {
        showMapController()
    }
    
    // MARK: - Private Functions
    
    private func showQuestionController(questionIndex: Int) {
        guard let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else { return }
        questionVC.route = route
        questionVC.variation = routeVariation
        questionVC.questionIndex = questionIndex
        navigationController?.pushViewController(questionVC, animated: true)
    }
    
    private func showMapController() {
        guard let questionVC = storyboard?.instantiateViewController(withIdentifier: "MapController") as? MapController else { return }
        questionVC.route = route
        questionVC.routeVariation = routeVariation
        navigationController?.pushViewController(questionVC, animated: true)
    }
}


// MARK: - UICollectionViewDelegate

extension QuestionListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QuestionCollectionViewCell,
              cell.lockView.isHidden else { return }
        
        if cell.backView.isHidden {
            cell.flip()
        } else {
            showQuestionController(questionIndex: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QuestionCollectionViewCell,
              cell.frontView.isHidden else { return }
        cell.flip()
    }
}


// MARK: - UICollectionViewDataSource

extension QuestionListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        routeVariation.questionIndexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: QuestionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: route[routeVariation[indexPath.row]],
                       index: indexPath.row + 1,
                       isLocked: indexPath.row > firstIncompleteIndex ?? 100)
        return cell
    }
}
