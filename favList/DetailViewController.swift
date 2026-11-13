//
//  DetailViewController.swift
//  favList
//
//  Created by Сая Смакова on 12.11.2026.
//

import UIKit

class DetailViewController: UIViewController {

    var item: FavoriteItem?

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starViews: [UIImageView]!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let item = item else { return }
        
        print("Movie: \(item.title)")
        print("Rating: \(item.rating)")
        print("Stars connected: \(starViews.count)")

        title = item.title

        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        for (index, star) in starViews.enumerated() {
            if index < item.rating {
                star.image = UIImage(systemName: "star.fill")
                star.tintColor = .systemYellow
            } else {
                star.image = UIImage(systemName: "star")
                star.tintColor = .systemGray4
            }
        }
    }
}

