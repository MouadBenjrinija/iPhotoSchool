//
//  LessonStubs.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation

struct Stub {
  static func loadJson<T: Decodable>(of type: T.Type,
                                     for file: StubFile) throws -> T {
    let data = try loadData(for: file)
    let jsonData = try JSONDecoder().decode(T.self, from: data)
    return jsonData
  }

  static func loadData(for file: StubFile) throws -> Data {
    let url = try Bundle.main.url(forResource: file.rawValue, withExtension: "json") ??
              { throw StubError.fileNotFound }()
    return try Data(contentsOf: url)
  }

}

enum StubFile: String {
  case lessons
}

enum StubError: Error {
  case fileNotFound
}


extension Stub {
  static var lessons: [Lesson] {
    let result = try! Stub.loadJson(of: LessonsListApiModel.self , for: .lessons)
    return result.lessons?.map { lesson in
      Lesson(id: lesson.id,
             name: lesson.name,
             description: lesson.description,
             thumbnail: lesson.thumbnail,
             videoURL: lesson.videoURL)
    } ?? []
  }
}
