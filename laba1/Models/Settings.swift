//
//  Settings.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/2/21.
//

import Foundation
import UIKit

enum SettingsLanguages: String, CaseIterable {
    case ru = "ru"
    case en = "en"
}

struct Settings {
    
    var language: SettingsLanguages
    
    func copy() -> Settings {
        return self
    }
    
    func languages() -> [String] {
        return SettingsLanguages.allCases.map{ $0.rawValue
        }
    }
    
    func languagesFromValueToIndex(fromValue: SettingsLanguages) -> Int? {
        return SettingsLanguages.allCases.firstIndex(of: fromValue)
    }
    func languagesFromIndexToValue(fromIndex: Int) -> SettingsLanguages? {
        return SettingsLanguages.allCases[fromIndex]
    }
    func languagesFromRawValueToValue(fromValue: String) -> SettingsLanguages? {
        return SettingsLanguages(rawValue: fromValue)
    }
    
}
