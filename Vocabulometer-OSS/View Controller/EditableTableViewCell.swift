//
//  EditableTableViewCell.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/29.
//

import UIKit

class EditableTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var translationTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.sizeToFit()
        translationTextField.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
