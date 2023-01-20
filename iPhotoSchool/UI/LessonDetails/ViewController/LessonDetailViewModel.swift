//
//  LessonDetailViewModel.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 20/1/2023.
//

import Foundation
import Combine

class LessonDetailViewModel {
  enum PlayerState {
    case notReady
    case ready
    case playing
  }

  @Published var lesson: Lesson?
  @Published var downloadState: DownloadButton.State = .normal
  @Published var error: Error?
  @Published var videoURL: Loadable<URL> = .notLoaded
  @Published var playerState: PlayerState = .notReady
  @Published var onNext: (() -> Void)?
  
  private let videoRepository: VideoRepository
  var downloadCancellable: AnyCancellable?
  var bag = Set<AnyCancellable>()

  init(videoRepository: VideoRepository = Composer.videoRepository()) {
    self.videoRepository = videoRepository
    setup()
  }

  func setup() {
    //let url = "https://file-examples.com/storage/fe2879c03363c669a9ef954/2017/04/file_example_MP4_480_1_5MG.mp4"
    $videoURL
      .sink(receiveValue: { [weak self] videoURL in
        if case .loaded(value: _, source: let source) = videoURL {
          self?.downloadState = source == .local ? .downloaded : .normal
        }
      }).store(in: &bag)
    $lesson
      .compactMap { $0 }
      .removeDuplicates()
      .sink(receiveValue: { [weak self] lesson in
        guard let self else { return }
        // on new lesson displayed
        self.cancelDownload()
        self.playerState = .notReady
        self.videoURL = self.videoRepository.video(for: lesson.videoURL)
      }).store(in: &bag)
  }

  func startPlaying() {
    playerState = .playing
  }

  func playerReady() {
    playerState = .ready
  }

  func downloadVideo() {
    downloadState = .downloading(progress: 0)
    downloadCancellable = videoRepository.downloadVideo(from: videoURL.value)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          guard let self = self else { return }
          if case .failure(let error) = completion {
            self.error = error
            self.downloadState = .normal
          } else {
            self.downloadState = .downloaded
          }
        }, receiveValue: { [weak self] value in
          guard let self = self else { return }
          if case .downloading(let progress) = value {
            self.downloadState = .downloading(progress: progress)
          }
        })
  }

  func cancelDownload() {
    videoRepository.cancelDownload()
  }
}
