//
//  ItemCell.swift
//  Todoey
//
//  Created by Lan Chu on 4/27/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var starButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = .white
        backGroundView.layer.cornerRadius = backGroundView.frame.height / 5
        backGroundView.layer.masksToBounds = true
        backGroundView.layer.cornerRadius = 15.0
        backGroundView.layer.borderWidth = 0.0
        backGroundView.layer.shadowColor = UIColor.black.cgColor
        backGroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backGroundView.layer.shadowRadius = 5.0
        backGroundView.layer.shadowOpacity = 0.23
        backGroundView.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
