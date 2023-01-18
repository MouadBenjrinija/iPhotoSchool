//
//  LessonItemView.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import SwiftUI

struct LessonItemView: View {

  let lesson: Lesson

  var body: some View {
    HStack {
      RemoteImage(url: lesson.thumbnail) { image in
        image.resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        Rectangle()
          .opacity(0.2)
      }
        .frame(width: 100,height: 56)
        .cornerRadius(4)

      Text(lesson.name ?? "--")
        .foregroundColor(.primary)
        .fontWeight(.medium)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

struct LessonItemView_Previews: PreviewProvider {
  static var previews: some View {
    LessonItemView(lesson: Stub.lessons[0])
  }
}
