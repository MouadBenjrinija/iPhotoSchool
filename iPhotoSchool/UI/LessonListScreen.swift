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
  @State var lessonDetailPath: [Lesson] = []

  var body: some View {
    NavigationStack(path: $lessonDetailPath) {
      LoadableView(loadable: model.lessons) { lessons in
        List(lessons) { lesson in
          NavigationLink(value: lesson) {
            LessonItemView(lesson: lesson)
          }.foregroundColor(.accentColor)
        }.listStyle(.plain)
      }
      .navigationTitle("Lessons")
      .navigationDestination(for: Lesson.self) { lesson in
        LessonDetailScreen()
      }
      .task {
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
