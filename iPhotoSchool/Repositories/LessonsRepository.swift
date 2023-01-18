//
//  LessonsRepository.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

protocol LessonsRepository {
  func fetchLessons() async -> Loadable<[Lesson]>
}

struct LessonsRepositoryMain: LessonsRepository {
  private let lessonsRemoteDataSource: LessonsRemoteDataSource
  private let lessonsLocalDataSource: LessonsLocalDataSource

  init(lessonsRemoteDataSource: LessonsRemoteDataSource,
       lessonsLocalDataSource: LessonsLocalDataSource) {
    self.lessonsRemoteDataSource = lessonsRemoteDataSource
    self.lessonsLocalDataSource = lessonsLocalDataSource
  }

  func fetchLessons() async -> Loadable<[Lesson]> {
    do {
      // try to load from server
      let result = try await lessonsRemoteDataSource.fetchLessons().async()
      // delete old and save results to local cache
      _ = try? await lessonsLocalDataSource.deleteAll().async()
      _ = try? await lessonsLocalDataSource.save(lessons: result).async()
      // update data
      return .loaded(value: result, source: .remote)
    } catch {
      return await loadFromCache()
    }
  }

  private func loadFromCache() async -> Loadable<[Lesson]> {
    do {
      // try to load from local
      let result = try await lessonsLocalDataSource.loadLessons().async()
      // update data
      return .loaded(value: result, source: .local)
    } catch {
      // set error
      return .failed(error: error)
    }
  }

}
