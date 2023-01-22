//
//  Fake.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 22/1/2023.
//

import Foundation

class FakeLessonsRepository: LessonsRepository {
  func fetchLessons() async -> Loadable<[Lesson]> {
    return .loaded(value: Stub.lessons)
  }
}

class FakeComposer: Composing {

  let realComposer = Composer()

  func appModel() -> AppModel {
    AppModel(lessonRepository: FakeLessonsRepository())
  }

  func imageRepository() -> ImageRepository {
    realComposer.imageRepository()
  }

  func videoRepository() -> VideoRepository {
    realComposer.videoRepository()
  }

}
