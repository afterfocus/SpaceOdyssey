//
//  Answer.swift
//  SpaceQuest
//
//  Created by Максим Голов on 24.12.2020.
//

import Foundation

final class UserAnswer {
    
    private var answer: [[Character]]
    
    var count: Int {
        answer.count
    }
    
    init(rightAnswer: [String], isComplete: Bool) {
        answer = [[Character]]()
        for (rowIndex, row) in rightAnswer.enumerated() {
            answer.append([])
            row.forEach {
                if isComplete {
                    answer[rowIndex].append($0)
                } else {
                    answer[rowIndex].append($0.isLetter || $0.isNumber ? "_" : $0)
                }
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> Character {
        get {
            return answer[indexPath.section][indexPath.item]
        }
        set {
            answer[indexPath.section][indexPath.item] = newValue
        }
    }
    
    subscript(index: Int) -> String {
        return String(answer[index])
    }
    
    func appendCharacter(_ character: Character) -> Bool {
        guard let indexPath = firstEmptyIndexPath() else { return false }
        self[indexPath] = character
        return true
    }
    
    func firstEmptyIndexPath() -> IndexPath? {
        for section in 0..<answer.count {
            guard let item = answer[section].firstIndex(of: "_") else { continue }
            return IndexPath(item: item, section: section)
        }
        return nil
    }
    
    func isInputCompleted() -> Bool {
        for row in answer {
            for char in row where char == "_" {
                return false
            }
        }
        return true
    }
    
    func isEqual(to rightAnswer: [String], or alternativeAnswer: [String]) -> Bool {
        var isEqualToRightAnswer = true
        var isEqualToAlternativeAnswer = !alternativeAnswer.isEmpty
        for (rowIndex, row) in rightAnswer.enumerated() where row != self[rowIndex] {
            isEqualToRightAnswer = false
        }
        for (rowIndex, row) in alternativeAnswer.enumerated() where row != self[rowIndex] {
            isEqualToAlternativeAnswer = false
        }
        return isEqualToRightAnswer || isEqualToAlternativeAnswer
    }
}
