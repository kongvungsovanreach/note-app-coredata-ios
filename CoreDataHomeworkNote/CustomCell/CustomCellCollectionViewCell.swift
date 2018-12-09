//
//  CustomCellCollectionViewCell.swift
//  CoreDataHomeworkNote
//
//  Created by Kong Vungsovanreach on 12/8/18.
//  Copyright © 2018 Kong Vungsovanreach. All rights reserved.
//

import UIKit

class CustomCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.sizeToFit()
        viewContainer.layer.borderWidth = 1
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.borderColor = UIColor(rgb: 0xDFE1E5).cgColor
        // Initialization code
    }

}
