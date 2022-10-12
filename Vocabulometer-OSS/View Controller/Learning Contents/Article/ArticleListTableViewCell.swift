//
//  ArticleListTableViewCell.swift
//  MultimediaVocabulometer
//
//  Created by iwashita on 2022/05/08.
//

import UIKit

class ArticleListTableViewCell: UITableViewCell {
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        articleTitleLabel.numberOfLines = 0
        articleTitleLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
