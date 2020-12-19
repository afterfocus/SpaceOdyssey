//
//  QuestionViewController.swift
//  SpaceQuest
//
//  Created by Максим Голов on 29.11.2020.
//

import WebKit

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorLabelBackground: UIView!
    @IBOutlet weak var webVideoView: WebVideoView!
    @IBOutlet weak var questionLabelBackgroundView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var answerCollectionView: UICollectionView!
    @IBOutlet weak var answerButtonsBackgroundView: UIView!
    @IBOutlet weak var answerButtonsCollectionView: UICollectionView!
    
    @IBOutlet weak var answerCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var answerButtonsCollectionViewHeight: NSLayoutConstraint!
    
    var route: Route!
    var question: Question!
    
    private let buttonCellSize = CGSize(width: 37, height: 37)
    private var answerCellSize: CGSize!
    private var answerCellSpacing: CGFloat!
    private var promtCellSize: CGSize!
    
    private var userAnswer = [[Character]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = question.title
        backgroundImageView.image = UIImage(named: route.imageFileName)
        
        authorLabel.text = question.authorInitials
        authorLabelBackground.layer.cornerRadius = 11
        authorLabelBackground.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        questionLabel.text = question.questionText
        questionLabelBackgroundView.layer.dropShadow(opacity: 0.3, radius: 7)
        
        starImageViews.forEach { $0.layer.dropShadow(opacity: 0.25, radius: 2) }
        hintButton.layer.dropShadow(opacity: 0.25, radius: 2)
        
        answerButtonsBackgroundView.layer.cornerRadius = 20
        answerButtonsBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        answerCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeLastLetterFromAnswer)))
        
        if let url = question.questionVideoUrl {
            webVideoView.loadVideo(url: url)
        } else {
            webVideoView.showNoVideoLabel()
        }
        
        for (rowIndex, row) in question.answer.enumerated() {
            userAnswer.append([])
            for char in row {
                userAnswer[rowIndex].append(char.isLetter || char.isNumber ? " " : char)
            }
        }
        let cellSpace = min((UIScreen.main.bounds.width - 20) / CGFloat(question.answer.max()!.count), 38)
        answerCellSize = CGSize(width: cellSpace * 0.88, height: cellSpace * 0.88)
        answerCellSpacing = cellSpace * 0.12
        promtCellSize = CGSize(width: cellSpace * 0.4, height: cellSpace * 0.88)
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
        answerCollectionViewHeight.constant = answerCollectionView.contentSize.height
        answerButtonsCollectionViewHeight.constant = answerButtonsCollectionView.contentSize.height
    }
}

extension QuestionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === answerButtonsCollectionView {
            guard let targetIndexPath = findFirstEmptyIndex() else { return }
            userAnswer[targetIndexPath.section][targetIndexPath.row] = question.answerButtons[indexPath.row]
            answerCollectionView.reloadData()
        }
    }
    
    @objc private func removeLastLetterFromAnswer() {
        
    }
    
    private func findFirstEmptyIndex() -> IndexPath? {
        for section in 0..<userAnswer.count {
            for item in 0..<userAnswer[section].count {
                if userAnswer[section][item] == " " {
                    return IndexPath(item: item, section: section)
                }
            }
        }
        return nil
    }
    
    private func findFirstNonEmptyIndex() -> IndexPath? {
        for section in 0..<userAnswer.count {
            for item in 0..<userAnswer[section].count {
                if userAnswer[section][item] != " " {
                    return IndexPath(item: item, section: section)
                }
            }
        }
        return nil
    }
}

extension QuestionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === answerButtonsCollectionView {
            return buttonCellSize
        } else {
            let char = question.answer[indexPath.section][indexPath.row]
            return (char.isLetter || char.isNumber) ? answerCellSize : promtCellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return answerCellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView === answerCollectionView {
            let totalCellWidth = Array(question.answer[section]).reduce(into: CGFloat.zero) {
                $0 += (($1.isLetter || $1.isNumber) ? answerCellSize.width : promtCellSize.width)
            }
            let totalCellSpacing = answerCellSpacing * CGFloat(question.answer[section].count - 1)
            let inset = (collectionView.frame.width - 2 - totalCellWidth - totalCellSpacing) / 2
            return UIEdgeInsets(top: 0, left: inset, bottom: 15, right: inset)
        } else {
            return .zero
        }
    }
}

extension QuestionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView === answerButtonsCollectionView ? 1 : question.answer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView === answerButtonsCollectionView ? question.answerButtons.count : question.answer[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (section, row) = (indexPath.section, indexPath.row)
        if collectionView === answerButtonsCollectionView {
            let cell: AnswerButtonCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.letterLabel.text = "\(question.answerButtons[row])"
            return cell
        } else {
            let char = question.answer[section][row]
            if char.isLetter || char.isNumber {
                let cell: AnswerCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.letterLabel.text = "\(userAnswer[section][row])"
                return cell
            } else {
                let cell: AnswerStubCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.stubLabel.text = "\(char)"
                return cell
            }
        }
    }
}
