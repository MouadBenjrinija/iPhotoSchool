//
//  LessonDetailViewController.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import UIKit
import AVKit
import Combine

class LessonDetailViewController: UIViewController {

  @IBOutlet weak var videoLayer: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var startButton: UIButton!

  var downloadButton = DownloadButton()

  var viewModel: LessonDetailViewModel!

  let videoRepository = Composer.videoRepository()
  var bag = Set<AnyCancellable>()

  private var playerViewController = AVPlayerViewController()

  func configure(lesson: Lesson, onNext: (() -> Void)?) {
    viewModel.lesson = lesson
    viewModel.onNext = onNext
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    createPlayer()
    bindViewModel()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    playerViewController.player?.pause()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavBar(button: downloadButton)
  }

  func setNavBar(button: UIView) {
    self.navigationController?.navigationBar
        .topItem?.rightBarButtonItem = UIBarButtonItem(customView: button)
  }

  func bindViewModel() {
    viewModel.$lesson
      .compactMap{ $0 }
      .map(\.name)
      .assign(to: \.text, on: nameLabel)
      .store(in: &bag)
    viewModel.$lesson
      .compactMap{ $0 }
      .map(\.description)
      .assign(to: \.text, on: descriptionLabel)
      .store(in: &bag)
    viewModel.$videoURL
      .map(\.value)
      .removeDuplicates()
      .sink(receiveValue: configurePlayer(with:))
      .store(in: &bag)
    viewModel.$downloadState
      .sink(receiveValue: { state in
        self.downloadButton.configure(state: state)
      }).store(in: &bag)
    viewModel.$onNext
      .sink(receiveValue: { onNext in
        self.nextButton.isHidden = onNext == nil
      }).store(in: &bag)
    viewModel.$playerState
      .removeDuplicates()
      .sink(receiveValue: {[weak self] state in
        switch state {
        case .notReady:
          self?.resetPlayer()
        case .playing:
          self?.startPlaying()
        case .ready:
          self?.startButton.isHidden = false
        }
      }).store(in: &bag)

    downloadButton.onDownload = viewModel.downloadVideo
    downloadButton.onCancel = viewModel.cancelDownload
  }

  func createPlayer() {
    self.addChild(playerViewController)
    playerViewController.view.frame = self.videoLayer.bounds
    playerViewController.player = AVPlayer()
    self.videoLayer.addSubview(playerViewController.view)
    playerViewController.didMove(toParent: self)
  }

  func startPlaying() {
    startButton.isHidden = true
    playerViewController.player?.play()
  }

  func resetPlayer() {
    playerViewController.player?.pause()
    playerViewController.player?.replaceCurrentItem(with: nil)
    startButton.isHidden = true
  }

  func configurePlayer(with url: URL?) {
    guard let url else { return }
    let asset = AVAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    playerViewController.player?.replaceCurrentItem(with: playerItem)
    self.viewModel.playerReady()
  }

  @IBAction func nextTapped(_ sender: Any) {
    viewModel.onNext?()
  }

  @IBAction func startTapped(_ sender: Any) {
    viewModel.startPlaying()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    if UIDevice.current.orientation.isLandscape {
      viewModel.startPlaying()
      playerViewController.enterFullScreen(animated: true)
    }
  }

}

extension AVPlayerViewController {
  func enterFullScreen(animated: Bool) {
    perform(NSSelectorFromString("enterFullScreenAnimated:completionHandler:"), with: animated, with: nil)
  }

}
