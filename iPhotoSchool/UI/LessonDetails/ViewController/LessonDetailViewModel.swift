//
//  LessonDetailViewModel.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 20/1/2023.
//

import Foundation
import Combine

class LessonDetailViewModel {
  enum PlayerState: Equatable {
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

  var name: AnyPublisher<String?, Never> {
    $lesson
      .compactMap{ $0 }
      .map(\.name)
      .replaceError(with: nil)
      .eraseToAnyPublisher()
  }

  var description: AnyPublisher<String?, Never> {
    $lesson
      .compactMap{ $0 }
      .map(\.description)
      .replaceError(with: nil)
      .eraseToAnyPublisher()
  }

  var isNextButtonHidden: AnyPublisher<Bool, Never> {
    $onNext.map { $0 == nil }
      .eraseToAnyPublisher()
  }

  init(videoRepository: VideoRepository = Composer.videoRepository()) {
    self.videoRepository = videoRepository
    setup()
  }

  func setup() {
    // configuration when receiving a new lesson
    $lesson
      .compactMap { $0 }
      .removeDuplicates()
      .sink(receiveValue: { [weak self] lesson in
        guard let self else { return }
        // on new lesson received
        self.cancelDownload()
        self.playerState = .notReady
        self.videoURL = self.videoRepository.video(for: lesson.videoURL)
      }).store(in: &bag)

    // configuration when loading the videoUrl
    $videoURL
      .sink(receiveValue: { [weak self] videoURL in
        if case .loaded(value: _, source: let source) = videoURL {
          self?.downloadState = source == .local ? .downloaded : .normal
        }
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
      .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
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
