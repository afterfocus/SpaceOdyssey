//
//  AnswerFieldCollectionView.swift
//  SpaceQuest
//
//  Created by Максим Голов on 23.12.2020.
//

import UIKit

// MARK: AnswerButtonsViewDelegate

protocol AnswerFieldViewDelegate: class {
    func answerFieldView(_ answerFieldView: AnswerFieldView, didRemove character: Character)
    func answerFieldView(_ answerFieldView: AnswerFieldView, didReceiveAnswer isCorrectAnswer: Bool)
}


// MARK: - AnswerFieldCollectionView

class AnswerFieldView: UICollectionView {
    
    // MARK: Internal Properties
    
    weak var answerFieldViewDelegate: AnswerFieldViewDelegate?
    var remainingHints: Int {
        return availableHints.max() ?? 0
    }
    
    // MARK: - Private Properties
    
    private var answerCellSize: CGSize!
    private var answerCellSpacing: CGFloat!
    private var stubCellSize: CGSize!
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    private var rightAnswer = [String]()
    private var userAnswer: UserAnswer!
    private var availableHints: [Int]!
    private var usedHints = 0
    private var cellBackgroundColor = UIColor.answerCellDefault
    private var isFixed: [[Bool]]!

    // MARK: - Internal Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
    }
    
    func configureFor(rightAnswer: [String], isComplete: Bool) {
        self.rightAnswer = rightAnswer
        userAnswer = UserAnswer(rightAnswer: rightAnswer, isComplete: isComplete)
        availableHints = []
        isFixed = []
        usedHints = 0
        cellBackgroundColor = .answerCellDefault
    
        rightAnswer.forEach {
            switch $0.count {
            case 5...7: availableHints.append(1)
            case 8...: availableHints.append(2)
            default: availableHints.append(0)
            }
            isFixed.append([Bool](repeating: isComplete, count: $0.count))
        }
        computeCellSizes()
        reloadData()
    }
    
    func appendCharacter(_ character: Character) -> Bool {
        let isAppended = userAnswer.appendCharacter(character)
        if isAppended && userAnswer.isInputCompleted() {
            inputCompeleted(isCorrect: userAnswer.isEqual(to: rightAnswer))
        }
        reloadData()
        return isAppended
    }
    
    func useHint() -> [Character] {
        var openedCharacters = [Character]()
    
        for section in 0..<rightAnswer.count {
            guard availableHints[section] > 0 else { continue }
            availableHints[section] -= 1
            
            let firstIndexPath = IndexPath(item: usedHints, section: section)
            let lastIndexPath = IndexPath(item: rightAnswer[section].count - (1 + usedHints), section: section)
            openedCharacters.append(openCharacter(at: firstIndexPath))
            openedCharacters.append(openCharacter(at: lastIndexPath))
            reloadItems(at: [firstIndexPath, lastIndexPath])
        }
        usedHints += 1
        
        /*
        if userAnswer.isInputCompleted(),
           userAnswer.isEqual(to: rightAnswer) {
            inputCompeleted(isCorrect: true)
            reloadData()
        }*/
        return openedCharacters
    }
    
    func clear() {
        cellBackgroundColor = .answerCellDefault
        for section in 0..<rightAnswer.count {
            for item in 0..<rightAnswer[section].count where !isFixed[section][item] {
                removeCharacter(at: IndexPath(item: item, section: section))
            }
        }
        reloadData()
    }
    
    // MARK: - Private Functions
    
    private func computeCellSizes() {
        var maxSymbolsCount = 0
        rightAnswer.forEach {
            maxSymbolsCount = max(maxSymbolsCount, $0.count)
        }
        var cellSpace = (UIScreen.main.bounds.width - 20) / CGFloat(maxSymbolsCount)
        cellSpace = min(cellSpace, 38)
        answerCellSize = CGSize(width: cellSpace * 0.88, height: cellSpace * 0.88)
        answerCellSpacing = cellSpace * 0.12
        stubCellSize = CGSize(width: cellSpace * 0.4, height: cellSpace * 0.88)
    }
    
    private func openCharacter(at indexPath: IndexPath) -> Character {
        let (currentChar, item, section) = (userAnswer[indexPath], indexPath.item, indexPath.section)
        if currentChar != "_" {
            answerFieldViewDelegate?.answerFieldView(self, didRemove: currentChar)
        }
        let rightChar = rightAnswer[section][item]
        userAnswer[indexPath] = rightChar
        isFixed[section][item] = true
        return rightChar
    }
    
    private func removeCharacter(at indexPath: IndexPath) {
        let char = userAnswer[indexPath]
        guard char != "_" else { return }
        userAnswer[indexPath] = "_"
        cellBackgroundColor = .answerCellDefault
        answerFieldViewDelegate?.answerFieldView(self, didRemove: char)
    }
    
    private func inputCompeleted(isCorrect: Bool) {
        cellBackgroundColor = isCorrect ? .answerCellGreen : .answerCellRed
        animateAnswerReceiving(isCorrectAnswer: isCorrect)
        feedbackGenerator.notificationOccurred(isCorrect ? .success : .error)
        answerFieldViewDelegate?.answerFieldView(self, didReceiveAnswer: isCorrect)
    }
    
    private func animateAnswerReceiving(isCorrectAnswer: Bool) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.autoreverses = true
        animation.duration = isCorrectAnswer ? 0.12 : 0.07
        animation.repeatCount = isCorrectAnswer ? 2 : 3
        
        if isCorrectAnswer {
            animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y - 15))
        } else {
            animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 10, y: center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 10, y: center.y))
        }
        layer.add(animation, forKey: "position")
    }
}


// MARK: - UICollectionViewDelegate

extension AnswerFieldView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        removeCharacter(at: indexPath)
        reloadData()
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension AnswerFieldView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return answerCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let char = rightAnswer[indexPath.section][indexPath.row]
        return (char.isLetter || char.isNumber) ? answerCellSize : stubCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = Array(rightAnswer[section]).reduce(into: CGFloat.zero) {
            $0 += (($1.isLetter || $1.isNumber) ? answerCellSize.width : stubCellSize.width)
        }
        let totalCellSpacing = answerCellSpacing * CGFloat(rightAnswer[section].count - 1)
        var inset = (collectionView.frame.width - 2 - totalCellWidth - totalCellSpacing) / 2
        inset = max(inset, 0)
        return UIEdgeInsets(top: 0, left: inset, bottom: 15, right: inset)
    }
}


// MARK: - UICollectionViewDataSource

extension AnswerFieldView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return userAnswer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userAnswer[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (row, section) = (indexPath.row, indexPath.section)
        
        let char = rightAnswer[section][row]
        if char.isLetter || char.isNumber {
            let cell: AnswerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            let char = userAnswer[section][row]
            cell.letterLabel.text = "\(char == "_" ? " " : char)"
            cell.setBackgroundColor(isFixed[section][row] ? .answerCellGreen : cellBackgroundColor)
            return cell
        } else {
            let cell: AnswerStubCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.stubLabel.text = "\(char)"
            return cell
        }
    }
}
