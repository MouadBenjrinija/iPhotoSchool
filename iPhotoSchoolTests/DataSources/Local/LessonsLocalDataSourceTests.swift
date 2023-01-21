//
//  LessonsLocalDataSourceTests.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

@testable import iPhotoSchool
import XCTest
import Combine

final class TestLessonsLocalDataSource: XCTestCase {

  var sut: LessonsLocalDataSource!
  var mockDataStack: CoreDataStackMock!
  var subs = Set<AnyCancellable>()

  override func setUpWithError() throws {
    mockDataStack = CoreDataStackMock()
    sut = LessonsLocalDataSourceMain(localDataSource: mockDataStack)
  }

  override func tearDownWithError() throws {
    sut = nil
    mockDataStack = nil
  }

  func test_saveLesson_success() throws {
    // Given
    let stub = Stub.lessons
    var results: [Lesson]?
    mockDataStack.recorder = .init(expected: [
      .update("\(Lesson.self)", .init(inserted: stub.count, updated: 0, deleted: 0))
    ])
    let expectation = expectation(description: #function)

    // When
    sut.save(lessons: stub)
      .sinkToResult { result in
        result.assertSuccess()
        results = try? result.get()
        expectation.fulfill()
      }.store(in: &subs)
    wait(for: [expectation], timeout: 0.1)

    // Then
    mockDataStack.verify()
    XCTAssertEqual(results!.count, stub.count, "Result count doesn't match")
  }

  func test_fetchLesson_success() throws {
    // Given
    let stub = Stub.lessons
    let persistable = stub.map { LessonPersistable(lesson: $0) }
    var results: [Lesson]?
    try mockDataStack.preload(persistable)
    mockDataStack.recorder = .init(expected: [
      .fetch("\(Lesson.self)", .init(inserted: 0, updated: 0, deleted: 0))
    ])
    let expectations = expectation(description: #function)

    // When
    sut.loadLessons()
      .sinkToResult { result in
        result.assertSuccess()
        results = try? result.get()
        expectations.fulfill()
      }.store(in: &subs)
    wait(for: [expectations], timeout: 0.1)

    // Then
    mockDataStack.verify()
    XCTAssertEqual(results!.count, stub.count, "Result count doesn't match")
  }

  func test_deleteLessons_success() throws {
    // Given
    let stub = Stub.lessons
    let persistable = stub.map { LessonPersistable(lesson: $0) }
    var results: [Lesson]?
    try mockDataStack.preload(persistable)
    mockDataStack.recorder = .init(expected: [
      .update("\(Lesson.self)",
        .init(inserted: 0, updated: 0, deleted: stub.count)),
      .fetch("\(Lesson.self)",
        .init(inserted: 0, updated: 0, deleted: 0))
    ])
    let expectations = expectation(description: #function)

    // When
    sut.deleteAll()
      .sinkToResult { deleteResult in
        deleteResult.assertSuccess()
        self.sut.loadLessons()
          .sinkToResult { result in
            result.assertSuccess()
            results = try? result.get()
            expectations.fulfill()
          }.store(in: &self.subs)
      }.store(in: &subs)

    wait(for: [expectations], timeout: 0.1)

    // Then
    mockDataStack.verify()
    XCTAssertEqual(results!.count, 0, "Result count doesn't match")
  }
}
