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
  var didLoadLessons: Bool { model.lessons.value != nil }
  internal let inspection = Inspection<Self>() // for test

  var body: some View {
    NavigationStack(path: $lessonDetailPath) {
      LoadableView(loadable: model.lessons, retry: fetchLessons) { lessons in
        List(lessons) { lesson in
          NavigationLink(value: lesson) {
            LessonItemView(lesson: lesson)
          }.foregroundColor(.accentColor)
        }.listStyle(.plain)
        .refreshable { fetchLessons() }
      }
      .navigationTitle("Lessons")
      .navigationDestination(for: Lesson.self) { lesson in
        LessonDetailScreen(lesson: lesson, onNext: onNext(lesson: lesson))
          .navigationBarTitleDisplayMode(.inline)
      }
      .onAppear { if !didLoadLessons { fetchLessons() } }
    }.onReceive(inspection.notice) { self.inspection.visit(self, $0) } // for test
  }

  func fetchLessons() {
    Task { await model.loadLessons() }
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
    return { [nextLesson] in
      lessonDetailPath = [nextLesson]
    }
  }

}

struct LessonListScreen_Previews: PreviewProvider {
  static var previews: some View {
    LessonListScreen(model: Composer.shared.appModel())
  }
}
