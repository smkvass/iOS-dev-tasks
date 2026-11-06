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
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starViews: [UIImageView]!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        for (index, star) in starViews.enumerated() {
            let filled = index < item.rating

            star.image = UIImage(
                systemName: filled ? "star.fill" : "star"
            )

            star.tintColor = filled ? .systemYellow : .systemGray4
        }
    }
}
