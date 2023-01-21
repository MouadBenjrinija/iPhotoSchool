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
  case loaded(value: T, source: DataSource? = nil)

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

extension Loadable: Equatable where T: Equatable {
  static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
      switch (lhs, rhs) {
      case (.notLoaded, .notLoaded):
          return true
      case let (.loading(lLatest), .loading(rLatest)):
          return lLatest == rLatest
      case let (.failed(lError), .failed(rError)):
          return lError.localizedDescription == rError.localizedDescription
      case let (.loaded(lValue, lSource), .loaded(rValue, rSource)):
          return lValue == rValue && lSource == rSource
      default:
          return false
      }
    }
}

enum DataSource {
  case remote
  case local
}
