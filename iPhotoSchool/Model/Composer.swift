//
//  Composer.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation

struct Composer {
  @MainActor
  static func appModel() -> AppModel {
    let lessonsRemoteDataSource = LessonsRemoteDataSourceMain(session: .default)
    let lessonsLocalDataSource = LessonsLocalDataSourceMain(localDataSource: CoreDataStack())
    let lessonsRepository = LessonsRepositoryMain(
      lessonsRemoteDataSource: lessonsRemoteDataSource,
      lessonsLocalDataSource: lessonsLocalDataSource)
    return AppModel(lessonRepository: lessonsRepository)
  }
}
