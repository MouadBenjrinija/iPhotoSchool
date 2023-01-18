//
//  Lesson.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation

struct Lesson: Equatable, Identifiable {
  let id: Int?
  let name: String?
  let description: String?
  let thumbnail: String?
  let videoURL: String?
}

extension Lesson: Comparable {
  static func < (lhs: Lesson, rhs: Lesson) -> Bool {
    lhs.id ?? 0 < rhs.id ?? 0
  }


}
