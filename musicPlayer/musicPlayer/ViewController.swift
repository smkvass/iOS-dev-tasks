//
//  ViewController.swift
//  musicPlayer
//
//  Created by Сая Смакова on 30.10.2026.
//


import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!

    private var audioPlayer: AVAudioPlayer?
    private var currentTrackIndex = 0
    private var isPlaying = false

    private var tracks: [Track] {
        TrackLibrary.tracks
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard !tracks.isEmpty else {
            print("The track library is empty.")
            return
        }

        updateUI()
    }

    

    private func updateUI() {
        guard tracks.indices.contains(currentTrackIndex) else {
            return
        }

        let track = tracks[currentTrackIndex]

        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(
            named: track.coverImageName
        )

        updatePlayPauseIcon()
    }

    private func updatePlayPauseIcon() {
        let symbol = isPlaying ? "pause.fill" : "play.fill"

        playPauseButton.setImage(
            UIImage(systemName: symbol),
            for: .normal
        )
    }


    private func loadTrack(shouldPlay: Bool) {
        guard tracks.indices.contains(currentTrackIndex) else {
            return
        }

        let track = tracks[currentTrackIndex]


        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false

        
        guard let url = Bundle.main.url(
            forResource: track.fileName,
            withExtension: "mp3"
        ) else {
            print("Audio file not found: \(track.fileName).mp3")
            updatePlayPauseIcon()
            return
        }

        do {
            
            let player = try AVAudioPlayer(contentsOf: url)

            player.delegate = self
            audioPlayer = player
            player.prepareToPlay()

            
            if shouldPlay {
                isPlaying = player.play()
            }

        } catch {
            print("Could not load audio: \(error.localizedDescription)")
        }

        updatePlayPauseIcon()
    }
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
        } else {
            if audioPlayer == nil {
                loadTrack(shouldPlay: true)
                return
            }

            isPlaying = audioPlayer?.play() ?? false
        }

        updatePlayPauseIcon()
    }


    @IBAction func nextButtonTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    @IBAction func previousButtonTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    private func changeTrack(by offset: Int) {
        guard !tracks.isEmpty else {
            return
        }

        let wasPlaying = isPlaying

        currentTrackIndex =
            (currentTrackIndex + offset + tracks.count)
            % tracks.count

        updateUI()
        loadTrack(shouldPlay: wasPlaying)
    }


    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        currentTrackIndex =
            (currentTrackIndex + 1) % tracks.count

        updateUI()
        loadTrack(shouldPlay: true)
    }
}

