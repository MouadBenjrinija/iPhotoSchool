//
//  Composer.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation 

protocol Composing {
  @MainActor
  func appModel() -> AppModel
  func imageRepository() -> ImageRepository
  func videoRepository() -> VideoRepository
}

class Composer: Composing {
  static var shared: Composing = Composer()
  private init() {}

  func appModel() -> AppModel {
    let lessonsRemoteDataSource = LessonsRemoteDataSourceMain(session: .default)
    let lessonsLocalDataSource = LessonsLocalDataSourceMain(localDataSource: CoreDataStack())
    let lessonsRepository = LessonsRepositoryMain(
      lessonsRemoteDataSource: lessonsRemoteDataSource,
      lessonsLocalDataSource: lessonsLocalDataSource)
    return AppModel(lessonRepository: lessonsRepository)
  }

  func imageRepository() -> ImageRepository {
    let localImageSourceDisk = LocaLImageSourceDisk()
    let localImageSourceCache = LocalImageSourceMemory()
    let localImageRepository = LocalImageRepository(diskSource: localImageSourceDisk,
                                                cacheSource: localImageSourceCache)
    let remoteImageSource = RemoteImageSourceMain(session: .default)
    let imageRepository = ImageRepositoryMain(localImageSource: localImageRepository,
                                              remoteImageSource: remoteImageSource)
    return imageRepository
  }

  func videoRepository() -> VideoRepository {
    let remoteVideoSource = RemoteVideoSourceMain()
    let localVideoSource = LocalVideoSourceMain()
    let videoRepository = VideoRepositoryMain(remoteSource: remoteVideoSource,
                                              localSource: localVideoSource)
    return videoRepository
  }

}
