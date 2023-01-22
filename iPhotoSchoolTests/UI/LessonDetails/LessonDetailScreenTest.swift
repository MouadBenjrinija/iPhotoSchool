//
//  LessonDetailScreenTest.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 22/1/2023.
//

import Foundation

import XCTest
import ViewInspector
import SwiftUI
import Combine
import AVKit

@testable import iPhotoSchool

final class LessonDetailScreenTest: XCTestCase {
  let lessons = Stub.lessons
  var view: LessonDetailScreen!
  var sut: LessonDetailViewController!
  var viewModel: LessonDetailViewModel!

  override func setUpWithError() throws {
    view = LessonDetailScreen(lesson: lessons[0], onNext: {})
    ViewHosting.host(view: view)
    sut = try view.inspect().view(LessonDetailScreen.self).actualView().viewController()
    viewModel = sut.viewModel
  }

  func test_LessonDetails_DisplayedCorrectly() throws {
    // Given: a lesson
    let lesson = lessons[1]
    // When: we pass it to the viewModel
    viewModel.lesson = lesson
    // Then: views should be correctly updated
    XCTAssertEqual(sut.nameLabel.text, lesson.name!)
    XCTAssertEqual(sut.descriptionLabel.text, lesson.description!)
    let videoURL = (sut.playerViewController.player?.currentItem?.asset as? AVURLAsset)?.url
    XCTAssertEqual(videoURL, URL(string: lesson.videoURL!))
  }

  func test_NextButton_HiddenState() throws {
    // Given: any lesson passed
    viewModel.lesson = lessons[0]
    // When: we pass a nil onNext closure
    viewModel.onNext = nil
    // Then: next button should be hidden
    XCTAssertTrue(sut.nextButton.isHidden)
    // When: we pass a valid onNext closure
    viewModel.onNext = { }
    // Then: next button should be displayed
    XCTAssertFalse(sut.nextButton.isHidden)
  }

  func test_DownloadButton_State() throws {
    // Given: any lesson passed
    viewModel.lesson = lessons[0]

    // When: the video is not downloaded
    viewModel.downloadState = .normal
    // Then: nav bar button should show a download button
    XCTAssertFalse(sut.downloadButton.downloadButton.isHidden)

    // When: the video is downloading
    viewModel.downloadState = .downloading(progress: 25)
    // Then: nav bar button should show the download progress
    XCTAssertFalse(sut.downloadButton.downloadingButton.isHidden)
    XCTAssertEqual(sut.downloadButton.downloadingButton.currentProgress, 0.25)

    // When: the video is not downloaded
    viewModel.downloadState = .downloaded
    // Then: nav bar button should show a download button
    XCTAssertFalse(sut.downloadButton.downloadedButton.isHidden)
  }

  func test_Player_StartPlaying() throws {
    // Given: any lesson passed
    viewModel.lesson = lessons[0]

    // When: we view is loaded
    // Then: start button should be displayed
    XCTAssertFalse(sut.startButton.isHidden)
    XCTAssertEqual(viewModel.playerState, .ready)

    // When: we click on the start button
    sut.startButton.sendActions(for: .touchUpInside)
    // Then: next button should be hidden and player state updated
    XCTAssertTrue(sut.startButton.isHidden)
    XCTAssertEqual(viewModel.playerState, .playing)
  }

}

struct LessonDetailScreenInspector {
  let inspector: InspectableView<ViewType.ClassifiedView>

  var loadable: InspectableView<ViewType.View<LoadableView<[Lesson], some View>>> {
    get throws {
      try inspector
        .navigationStack()
        .find(LoadableView<[Lesson], AnyView>.self)
    }
  }

  var list: InspectableView<ViewType.List> {
    get throws {
      try loadable
        .list(0)
    }
  }

  var listItems: [InspectableView<ViewType.View<NavigationLink<LessonItemView, Never>>>] {
    get throws {
      try list.findAll(NavigationLink<LessonItemView, Never>.self)
    }
  }

  var retryButton: InspectableView<ViewType.Button>  {
    get throws {
      try inspector.find(button: "Retry")
    }
  }
}
