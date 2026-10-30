
import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let author: String
    let description: String
}

class ViewController: UIViewController {

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    let favorites: [Favorite] = [
        Favorite(imageName: "1.jpg", title: "And Then There Were None",author: "by Agatha Cristie",
                 description: "Ten strangers are invited to an isolated island, where mysterious events begin. One by one, they discover that someone is hiding a dark secret."),
        Favorite(imageName: "2.jpg", title: "Back to You", author: "by Sarah Jio",
                 description: "A story about relationships, memories and finding your way back. The characters must learn whether the past can help them build a better future."),
        Favorite(imageName: "3", title: "The Last Camellia", author: "by Sarah Jio",
                 description: "A woman uncovers a mystery connected to a rare camellia and an old estate. As she investigates, she discovers secrets hidden for decades."),
        Favorite(imageName: "4.jpg", title: "The Moon Trail",author: "by Sarah Jio",
                 description: "A woman follows a mysterious path that leads her to unexpected discoveries. Along the way, she uncovers secrets about love, the past, and the people around her."),
        Favorite(imageName: "5.jpg", title: "The Mystery of the Blue Train", author: "by Agatha Cristie",
                 description: "Detective Hercule Poirot investigates a mysterious murder aboard a train. A stolen jewel and several suspicious passengers make the case even more complicated."),
        Favorite(imageName: "6", title: "If Your Memory Disappears", author: "by Genki Cawamura",
                 description: "A moving story about memory, relationships and the fear of forgetting. It explores how memories shape our identity and connect us to the people we love."),
        Favorite(imageName: "7.jpg", title: "The Picture of Dorian Gray",author: "by Oscar Wilde",
                 description: "A portrait reveals the dark consequences of vanity and the search for beauty. While Dorian remains young, the painting reflects the changes in his soul."),
        Favorite(imageName: "8.jpg", title: "The Flowers for Algernon", author: "by Danalies Keyes",
                 description: "A man takes part in an experiment to increase his intelligence. As his mind changes, he discovers the true meaning of friendship, happiness, and being human."),
        Favorite(imageName: "9.jpg", title: "A Walk to Remember",author: "by Nicholas Sparks",
                 description: "Two teenagers discover love, kindness and the power of change. Their relationship teaches them to appreciate every moment they share."),
        Favorite(imageName: "10", title: "The Best of Me", author: "by Nicholas Sparks",
                 description: "Two former lovers meet again and remember the love that changed their lives. They must face their past and decide whether love deserves a second chance.")
    ]

    var lastFavoriteIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        showInitialFavorite()
    }

    func showInitialFavorite() {
        guard let firstFavorite = favorites.first else { return }

        lastFavoriteIndex = 0
        displayFavorite(firstFavorite)
    }

    @IBAction func randomBookButtonTapped(_ sender: UIButton) {
        guard favorites.count > 1 else { return }

        var randomIndex = Int.random(in: 0..<favorites.count)

        while randomIndex == lastFavoriteIndex {
            randomIndex = Int.random(in: 0..<favorites.count)
        }

        lastFavoriteIndex = randomIndex
        displayFavorite(favorites[randomIndex])
    }

    func displayFavorite(_ favorite: Favorite) {
        bookImageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        authorLabel.text = favorite.author
        descriptionLabel.text = favorite.description
    }
}
