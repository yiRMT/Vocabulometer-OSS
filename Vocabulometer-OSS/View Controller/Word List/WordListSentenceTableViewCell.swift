//
//  WordListSentenceTableViewCell.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/29.
//

import UIKit

class WordListSentenceTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sentenceLabel.numberOfLines = 0
        sentenceLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
