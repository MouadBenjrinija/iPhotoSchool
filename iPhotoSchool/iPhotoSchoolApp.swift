//
//  iPhotoSchoolApp.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import SwiftUI

@main
struct iPhotoSchoolApp: App {

  @StateObject var model = Composer.shared.appModel()

  var body: some Scene {
    WindowGroup {
      if Env.isRunningTests {
        // to avoid inaccurate coverage
        Text("IS TESTING")
      } else {
        LessonListScreen(model: model)
      }
    }
  }
}

