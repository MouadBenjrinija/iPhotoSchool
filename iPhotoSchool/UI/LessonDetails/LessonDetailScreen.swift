//
//  LessonDetailScreen.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import SwiftUI

struct LessonDetailScreen: UIViewControllerRepresentable {
  typealias UIViewControllerType = LessonDetailViewController

  let lesson: Lesson
  let onNext: (() -> Void)?
  
  func makeUIViewController(context: Context) -> LessonDetailViewController {
    let vc = LessonDetailViewController()
    vc.viewModel = LessonDetailViewModel()
    return vc
  }

  func updateUIViewController(_ uiViewController: LessonDetailViewController, context: Context) {
    uiViewController.configure(lesson: lesson, onNext: onNext)
  }

}

struct LessonDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
      LessonDetailScreen(lesson: Stub.lessons[0], onNext: nil)
    }
}
