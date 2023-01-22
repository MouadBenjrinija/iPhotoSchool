//
//  LoadableView.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import SwiftUI

struct LoadableView<T, Content: View>: View {
  let loadable: Loadable<T>
  let retry: (() -> Void)?
  @ViewBuilder let loadedView: (T) -> Content

  var body: some View {
    switch loadable {
    case .notLoaded:
      Text("Not Loaded!")
        .font(.caption)
        .foregroundColor(.gray)
    case .loading:
      VStack {
        ProgressView()
          .padding()
        Text("  Loading..")
          .font(.caption)
          .foregroundColor(.gray)
      }
    case .failed:
      VStack {
        Image(systemName: "exclamationmark.triangle")
          .font(.largeTitle)
          .foregroundColor(.gray)
        Text("Unable to load!")
          .font(.caption)
          .padding(1)
          .foregroundColor(.gray)
        Button(action: { retry?() }) {
          Text("Retry")
            .font(.caption)
            .padding(4)
        }
      }
    case .loaded(let loadedValue, _):
      loadedView(loadedValue)
    }
  }
}
