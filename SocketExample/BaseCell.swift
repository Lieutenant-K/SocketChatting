//
//  BaseCell.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
        
        // Set the selection style to None.
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
