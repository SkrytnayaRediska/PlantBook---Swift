//
//  Theme.swift
//  laba1
//
//  Created by Ольга Ерохина on 5/4/21.
//

import UIKit

struct Theme {
    let textColor: UIColor
    let backgroundColor: UIColor
    let backgroundColorForNavigationBar: UIColor
    var backgroundColorForFields: UIColor
    
    static let light = Theme(textColor: .black, backgroundColor: .systemTeal, backgroundColorForNavigationBar: .white, backgroundColorForFields: .systemBackground)
    static let dark = Theme(textColor: .white, backgroundColor: .black, backgroundColorForNavigationBar: .black, backgroundColorForFields: .systemBackground)
}
