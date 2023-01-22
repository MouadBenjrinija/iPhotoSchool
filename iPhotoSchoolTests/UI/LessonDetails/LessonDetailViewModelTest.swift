//
//  LessonDetailViewModelTest.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 20/1/2023.
//

import XCTest
import Combine
@testable import iPhotoSchool

final class TestLessonDetailViewModel: XCTestCase {

  var sut: LessonDetailViewModel!
  var videoRepository: MockVideoRepository!
  let lessons = Stub.lessons
  var bag = Set<AnyCancellable>()

  override func setUpWithError() throws {
    videoRepository = MockVideoRepository()
    sut = LessonDetailViewModel(videoRepository: videoRepository)
  }

  override func tearDownWithError() throws {
    videoRepository = nil
  }

  func test_initialPreLoadingState() throws {
    // Given: No setup
    // Then
    XCTAssertEqual(sut.downloadState, .normal)
    XCTAssertEqual(sut.videoURL, .notLoaded)
    XCTAssertEqual(sut.playerState, .notReady)
  }

  func test_initialPostLoadingState() throws {
    // Given: a lesson
    let lesson = lessons[0]
    let videoURL = URL(string: lesson.videoURL!)!
    let expectation = expectation(description: #function)
    videoRepository.videoForUrlReponse = .loaded(value: videoURL, source: .remote)
    var name, description: String? // results
    // When: we pass a lesson to the viewModel
    sut.lesson = lesson
    sut.$videoURL
      .sinkToResult { result in
        result.assertSuccess()
        expectation.fulfill()
      }.store(in: &bag)
    sut.name.sink { name = $0 }.store(in: &bag)
    sut.description.sink { description = $0 }.store(in: &bag)
    // Then
    wait(for: [expectation], timeout: 0.1)
    XCTAssertEqual(sut.downloadState, .normal)
    XCTAssertEqual(sut.videoURL, .loaded(value: videoURL, source: .remote))
    XCTAssertEqual(lesson.name, name)
    XCTAssertEqual(lesson.description, description)
    // player will not be ready as it's controlled by the view
    XCTAssertEqual(sut.playerState, .notReady)
  }

  func test_nextButton_displayed() throws {
    // Given: a lesson
    let lesson = lessons[0]
    let expectation = expectation(description: #function)
    var result: Bool?
    // When: we pass a lesson to the viewModel
    sut.lesson = lesson
    sut.onNext = { }
    sut.isNextButtonHidden.sink{
      result = $0
      expectation.fulfill()
    }.store(in: &bag)
    // Then
    wait(for: [expectation], timeout: 0.1)
    XCTAssertFalse(try XCTUnwrap(result))
  }

  func test_nextButton_hidden() throws {
    // Given: a lesson
    let lesson = lessons[0]
    let expectation = expectation(description: #function)
    var result: Bool?
    // When: we pass a lesson to the viewModel
    sut.lesson = lesson
    sut.isNextButtonHidden.sink{
      result = $0
      expectation.fulfill()
    }.store(in: &bag)
    // Then
    wait(for: [expectation], timeout: 0.1)
    XCTAssertTrue(try XCTUnwrap(result))
  }

  func test_playerControls() throws {
    // Given: any view model state
    // When
    sut.playerReady()
    // Then: state should reflect the action
    XCTAssertEqual(sut.playerState, .ready)
    // When
    sut.startPlaying()
    // Then: state should reflect the action
    XCTAssertEqual(sut.playerState, .playing)
  }

  func test_DownloadVideo() {
    // Given: a lesson
    let lesson = lessons[0]
    let videoURL = URL(string: lesson.videoURL!)!
    let downloadingExpectation = expectation(description: "state should be downloading")
    downloadingExpectation.assertForOverFulfill = false
    let downloadedExpectation = expectation(description: "state should be finished downloading")
    sut.lesson = lesson
    // configure mock and spy
    videoRepository.downloadVideoResponse = [.downloading(progress: 50), .finished(localURL: videoURL)]
    videoRepository.recorder = MockActionRecorder(expected: [.downloadVideo])
    // When: we start download
    sut.downloadVideo()
    sut.$downloadState.sink { value in
      // Then: state should reflect
      if case .downloading = value {
        downloadingExpectation.fulfill()
      }
      if case .downloaded = value {
        downloadedExpectation.fulfill()
      }
    }.store(in: &bag)

    wait(for: [downloadingExpectation, downloadedExpectation], timeout: 5)
    // Then: repository should receive download request
    videoRepository.verify()
  }

  func testCancelDownload() {
    // Given: a lesson
    let lesson = lessons[0]
    let videoURL = URL(string: lesson.videoURL!)!
    let expectation = XCTestExpectation(description: "download state should be normal")
    sut.lesson = lesson
    // configure mock and spy
    videoRepository.downloadVideoResponse = [.downloading(progress: 50), .finished(localURL: videoURL)]
    videoRepository.recorder = MockActionRecorder(expected: [.downloadVideo, .cancelDownload])
    // When: we start then cancel the download
    sut.downloadVideo()
    sut.cancelDownload()
    sut.$downloadState.sink { value in
      // Then: download state should go back to .normal
      if case .normal = value {
        expectation.fulfill()
      }
    }.store(in: &bag)
    wait(for: [expectation], timeout: 1.0)
    // Then: should interract correctly with the video repository
    videoRepository.recorder.verify()
  }

}

