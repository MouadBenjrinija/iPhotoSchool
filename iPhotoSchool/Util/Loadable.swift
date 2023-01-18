//
//  Loadable.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

enum Loadable<T> {
  case notLoaded
  case loading(latest: T?)
  case failed(error: Error)
  case loaded(value: T, source: DataSource)

  var value: T? {
    switch self {
    case .loading(let latest): return latest
    case .loaded(let value, _): return value
    default: return nil
    }
  }

  var error: Error? {
    switch self {
    case .failed(let error): return error
    default: return nil
    }
  }
}

enum DataSource {
  case remote
  case local
}
