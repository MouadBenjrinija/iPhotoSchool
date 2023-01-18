//
//  iPhotoSchoolApp.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import SwiftUI

@main
struct iPhotoSchoolApp: App {
  @StateObject var model = Composer.appModel()

  var body: some Scene {
    WindowGroup {
      LessonListScreen(model: model)
    }
  }
}
