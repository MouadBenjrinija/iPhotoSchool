//
//  LessonListScreen.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import SwiftUI
import Combine

struct LessonListScreen: View {
  @ObservedObject var model: AppModel

  var body: some View {
    VStack {
      LoadableView(loadable: model.lessons) { lessons in
        List(lessons) { lesson in
          Text(lesson.name ?? "--")
        }
      }.task {
        await model.loadLessons()
      }
    }
  }

}

struct LessonListScreen_Previews: PreviewProvider {
  static var previews: some View {
    LessonListScreen(model: Composer.appModel())
  }
}
