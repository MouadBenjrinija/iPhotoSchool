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
        LessonDetailScreen(lesson: lesson, onNext: onNext(lesson: lesson))
          .navigationBarTitleDisplayMode(.inline)
      }
      .task {
        await model.loadLessons()
      }
    }
  }

  func next(lesson: Lesson) -> Lesson? {
    if let lessons = model.lessons.value,
       let lessonIndex = lessons.firstIndex(of: lesson),
       lessonIndex < (lessons.count - 1) {
      return lessons[lessonIndex + 1]
    } else { return nil }
  }

  func onNext(lesson: Lesson) -> (() -> Void)? {
    guard let nextLesson = next(lesson: lesson) else { return nil }
    return { lessonDetailPath = [nextLesson] }
  }

}

struct LessonListScreen_Previews: PreviewProvider {
  static var previews: some View {
    LessonListScreen(model: Composer.appModel())
  }
}
