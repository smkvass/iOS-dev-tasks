//
//  FavoriteCell.swift
//  favList
//
//  Created by Сая Смакова on 04.11.2026.
//

import UIKit

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
    }
}

