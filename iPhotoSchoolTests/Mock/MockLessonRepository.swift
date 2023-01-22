//
//  MockLessonRepository.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 21/1/2023.
//

import Foundation
@testable import iPhotoSchool

class MockLessonsRepository: LessonsRepository {

  var response: Loadable<[Lesson]> = .notLoaded

  func fetchLessons() async -> Loadable<[Lesson]> {
    return response
  }
}
