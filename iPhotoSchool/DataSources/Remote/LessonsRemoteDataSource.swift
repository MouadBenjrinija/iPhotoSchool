//
//  RemoteDataSource.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

protocol LessonsRemoteDataSource: RemoteDataSource {
  func fetchLessons() -> AnyPublisher<[Lesson], Error>
}

struct LessonsRemoteDataSourceMain: LessonsRemoteDataSource {

  let session: URLSession

  func fetchLessons() -> AnyPublisher<[Lesson], Error> {
      fetch(call: Call.getLessons)
      .map { (response: LessonsListApiModel) -> [Lesson] in
        response.lessons?.map { lesson in
          Lesson(id: lesson.id,
                 name: lesson.name,
                 description: lesson.description,
                 thumbnail: lesson.thumbnail,
                 videoURL: lesson.videoURL)
        } ?? []
      }
      .eraseToAnyPublisher()

  }

}

extension LessonsRemoteDataSourceMain {
  enum Call {
    case getLessons
  }
}

extension LessonsRemoteDataSourceMain.Call: RemoteCall {
  var auth: AuthStrategy { NoAuth() }
  var path: String {
    switch self {
    case .getLessons:
      return "/lessons"
    }
  }
  var method: String {
    switch self {
    case .getLessons:
      return "GET"
    }
  }
  var headers: [String: String]? {
    nil
  }

  var params: [String: String]? {
    nil
  }

  func body() throws -> Data? {
    nil
  }

}
