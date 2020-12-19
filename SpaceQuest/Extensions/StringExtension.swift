//
//  StringExtension.swift
//  SpaceQuest
//
//  Created by Максим Голов on 15.12.2020.
//

import Foundation

extension String {
    subscript(i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}
