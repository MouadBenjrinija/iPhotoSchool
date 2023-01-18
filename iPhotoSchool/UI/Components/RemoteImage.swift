//
//  RemoteImage.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import SwiftUI
import Combine

struct RemoteImage<Content: View, Placeholder: View>: View {
  let repository = Composer.imageRepository()
  var url: String?
  var placeholder: () -> Placeholder
  var content: (Image) -> Content

  @State var image: Loadable<UIImage> = .notLoaded

  init(url: String? = nil,
       content: @escaping (Image) -> Content = { $0 },
       placeholder: @escaping () -> Placeholder = { EmptyView() }
  ) {
    self.url = url
    self.content = content
    self.placeholder = placeholder
  }

  var body: some View {
    contentView
      .task {
        if let result = await repository.loadImage(from: url) {
          image = .loaded(value: result)
        }
      }
  }

  var contentView: some View {
    Group {
      if case .loaded(let image, _) = self.image {
        content(Image(uiImage: image))
      } else {
        placeholder()
      }
    }
  }
}

struct RemoteImage_Previews: PreviewProvider {
  static var previews: some View {
    RemoteImage()
  }
}
