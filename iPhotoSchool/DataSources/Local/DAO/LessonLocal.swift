//
//  Lesson.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import CoreData

struct LessonPersistable: Persistable {
  let lesson: Lesson

  init(managedObject: LessonManagedObject) {
    self.lesson = Lesson(
      id: Int(managedObject.id),
      name: managedObject.name,
      description: managedObject.desc,
      thumbnail: managedObject.thumbnail,
      videoURL: managedObject.videoURL
    )
  }

  init(lesson: Lesson) {
    self.lesson = lesson
  }

  func unwrap() -> Lesson {
    lesson
  }

  func populate(object: LessonManagedObject) -> LessonManagedObject {
    object.id = Int16(lesson.id ?? 0)
    object.name = lesson.name
    object.desc = lesson.description
    object.thumbnail = lesson.thumbnail
    object.videoURL = lesson.videoURL
    return object
  }

  static var fetchRequest: NSFetchRequest<LessonManagedObject> {
    LessonManagedObject.fetchRequest()
  }
  
}
