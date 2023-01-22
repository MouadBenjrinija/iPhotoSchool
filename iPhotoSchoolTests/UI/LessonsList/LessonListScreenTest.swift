//
//  LessonListScreenTest.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 21/1/2023.
//

import XCTest
import ViewInspector
import SwiftUI
import Combine
@testable import iPhotoSchool

final class LessonListScreenTest: XCTestCase {
  let lessons = Stub.lessons
  let repository = MockLessonsRepository()
  var view: LessonListScreen!
  var sut: LessonListScreenInspector!

  @MainActor
  override func setUpWithError() throws {
    view = LessonListScreen(model: AppModel(lessonRepository: repository))
    sut = LessonListScreenInspector(inspector: try view.inspect())

  }

  @MainActor
  func test_LessonLoading_success() throws {
    // Given: a list of lessons loaded
    repository.response = .loaded(value: lessons)
    // When: view finish loading
    let loadingExpectation = view.inspection.inspect(after: 0.3) { _ in
      let items = try self.sut.listItems
      // Then: list items show be the same count as the loaded model list
      XCTAssertEqual(items.count, self.lessons.count)
      // verify each row text
      for (index, lesson) in self.lessons.enumerated() {
        _ = try items[index].find(text: lesson.name!)
      }
    }
    ViewHosting.host(view: view)
    wait(for: [loadingExpectation], timeout: 1)
  }

  func test_LessonLoading_failure() throws {
    // Given: a lesson loading failure response
    repository.response = .failed(error: APIError.unexpectedResponse)
    // When: view finish loading
    let loadingExpectation = view.inspection.inspect(after: 0.3) { view in
      let loadableView = try self.sut.loadable
      // Then: should display an error view with a retry button
      _ = try self.sut.retryButton
    }
    ViewHosting.host(view: view)
    wait(for: [loadingExpectation], timeout: 1)
  }

  func test_LessonLoading_retryAfterFailure() throws {
    // Given: a lesson loading failure response
    repository.response = .failed(error: APIError.unexpectedResponse)
    let retryingExpectation = expectation(description: "Is retrying after failure")
    let loadingExpectation = view.inspection.inspect(after: 0.3) { view in
      // When: we tap on retry while simulating a successful response
      self.repository.response = .loaded(value: self.lessons)
      let retryButton = try self.sut.retryButton
      try retryButton.tap()
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
        // should successfully retry and load the correct list items
        XCTAssertEqual(try! self.sut.listItems.count, self.lessons.count)
        retryingExpectation.fulfill()
      }
    }
    ViewHosting.host(view: view)
    wait(for: [loadingExpectation, retryingExpectation], timeout: 1)
  }

}

struct LessonListScreenInspector {
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
extension Inspection: InspectionEmissary { }
