//
//  AnswerButtonsCollectionView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 23.12.2020.
//

import UIKit


// MARK: AnswerButtonsViewDelegate

protocol AnswerButtonsViewDelegate: class {
    func answerButtonsView(_ answerButtonsView: AnswerButtonsView, didSelect character: Character, at indexPath: IndexPath)
}


// MARK: - AnswerButtonsView

final class AnswerButtonsView: UICollectionView {
    
    @IBOutlet weak var width: NSLayoutConstraint!
    
    // MARK: Internal Properties
    
    var answerCharacters = [Character]() {
        didSet {
            reloadData()
        }
    }
    weak var answerButtonsViewDelegate: AnswerButtonsViewDelegate?
    
    // MARK: - Private Properties
    
    private var buttonCellSize: CGSize!
    private var buttonCellSpacing: CGFloat!
    
    // MARK: - Internal Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        
        if UIScreen.main.bounds.width > 320 {
            buttonCellSize = CGSize(width: 37, height: 37)
            buttonCellSpacing = 7
            width.constant = 301
        } else {
            buttonCellSize = CGSize(width: 35, height: 35)
            buttonCellSpacing = 6
            width.constant = 281
        }
    }
    
    func removeCharacter(at indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) else { return }
        animateDissapearance(of: cell)
    }
    
    func removeCharacter(_ character: Character) {
        guard let index = answerCharacters.firstIndex(of: character),
              let cell = cellForItem(at: IndexPath(item: index, section: 0)) else { return }
        animateDissapearance(of: cell)
    }
    
    func returnCharacter(_ character: Character) {
        for index in cellIndexesFor(character: character) {
            guard let cell = cellForItem(at: IndexPath(item: index, section: 0)) as? AnswerButtonCollectionViewCell
                else { continue }
            if cell.alpha == 0, cell.character == character {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
                    cell.alpha = 1
                }
                return
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func cellIndexesFor(character: Character) -> [Int] {
        var result = [Int]()
        for (index, char) in answerCharacters.enumerated() where character == char {
            result.append(index)
        }
        return result
    }
    
    private func animateDissapearance(of cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
            cell.transform = cell.transform.translatedBy(x: 0, y: -50)
            cell.alpha = 0
        } completion: { _ in
            cell.transform = CGAffineTransform.identity
        }
    }
}


// MARK: - UICollectionViewDelegate

extension AnswerButtonsView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = cellForItem(at: indexPath) as? AnswerButtonCollectionViewCell else { return }
        answerButtonsViewDelegate?.answerButtonsView(self, didSelect: cell.letterLabel.text!.first!, at: indexPath)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension AnswerButtonsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return buttonCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return buttonCellSpacing
    }
}


// MARK: - UICollectionViewDataSource

extension AnswerButtonsView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return answerCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AnswerButtonCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.character = answerCharacters[indexPath.row]
        return cell
    }
}
