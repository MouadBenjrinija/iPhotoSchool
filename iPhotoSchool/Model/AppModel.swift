//
//  AppModel.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

@MainActor
class AppModel: ObservableObject {

  var lessonRepository: LessonsRepository
  @Published var lessons: Loadable<[Lesson]> = .notLoaded

  init(lessonRepository: LessonsRepository) {
    self.lessonRepository = lessonRepository
  }

  func loadLessons() async {
    self.lessons = .loading(latest: lessons.value)
    self.lessons = await lessonRepository.fetchLessons()
  }

}
