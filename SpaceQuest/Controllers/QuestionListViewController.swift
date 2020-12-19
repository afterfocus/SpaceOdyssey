//
//  QuestionsViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 20.11.2020.
//

import UIKit

class QuestionListViewController: UIViewController {
    
    @IBOutlet weak var questionsCollectionView: UICollectionView!
    
    var route: Route!
    var routeVariation: RouteVariation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UILabel.titleLabel(with: route.title)
        questionsCollectionView.backgroundView = UIImageView(withImageNamed: route.imageFileName, alpha: 0.75)
    }
}

extension QuestionListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QuestionCollectionViewCell else { return }
        if cell.backView.isHidden {
            cell.flip()
        } else {
            guard let questionVC = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController else { return }
            questionVC.route = route
            questionVC.question = route[routeVariation[indexPath.row]]
            navigationController?.pushViewController(questionVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? QuestionCollectionViewCell,
              cell.frontView.isHidden else { return }
        cell.flip()
    }
}

extension QuestionListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        routeVariation.questionIndexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: QuestionCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: route[routeVariation[indexPath.row]], index: indexPath.row + 1)
        return cell
    }
}
