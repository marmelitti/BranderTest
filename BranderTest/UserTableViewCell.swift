//
//  UserTableViewCell.swift
//  BranderTest
//
//  Created by Alexandra Brovko on 01/08/2023.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    static let reuseId = String(describing: UserTableViewCell.self)
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usersImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
