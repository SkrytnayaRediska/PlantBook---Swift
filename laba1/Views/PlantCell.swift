//
//  PlantCell.swift
//  laba1
//
//  Created by Ольга Ерохина on 3/14/21.
//

import UIKit

class PlantCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: PlantCell.self)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var plantImage: UIImageView!
}
