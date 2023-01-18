//
//  LessonsLocalDataSource.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

protocol LessonsLocalDataSource {
  func loadLessons() -> AnyPublisher<[Lesson], Error>
  func save(lessons: [Lesson]) -> AnyPublisher<[Lesson], Error>
  func deleteAll() -> AnyPublisher<[Lesson], Error>
}

struct LessonsLocalDataSourceMain: LessonsLocalDataSource {

  let localDataSource: LocalDataSource

  func loadLessons() -> AnyPublisher<[Lesson], Error> {
    return localDataSource
      .fetch(LessonPersistable.self) { LessonPersistable.fetchRequest }
      .unwrapped()
  }

  func save(lessons: [Lesson]) -> AnyPublisher<[Lesson], Error> {
    let persistable = lessons.map { LessonPersistable(lesson: $0) }
    return localDataSource
      .insert(persistable)
      .unwrapped()
  }

  func deleteAll() -> AnyPublisher<[Lesson], Error> {
    return localDataSource.update { context in
      let fetched = try context.fetch(LessonPersistable.fetchRequest)
      fetched.forEach { context.delete($0) }
      return fetched.map(LessonPersistable.init(managedObject:))
    }.unwrapped()
  }

}
