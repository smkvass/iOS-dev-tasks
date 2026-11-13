//
//  ViewController.swift
//  favList
//
//  Created by Сая Смакова on 03.11.2026.
//


import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FavoriteData.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell

        cell.configure(with: FavoriteData.items[indexPath.row])

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destination = segue.destination as? DetailViewController,
               let indexPath = tableView.indexPathForSelectedRow {

                destination.item = FavoriteData.items[indexPath.row]
            }
        }
    }
}



