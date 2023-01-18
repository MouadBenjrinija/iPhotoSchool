//
//  Authentication.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation

// no auth neeed in this project
// this file is just for showcase

protocol AuthStrategy {
  func patch(params: [String: String]?) -> [String: String]?
  func patch(headers: [String: String]?) -> [String: String]?
}

struct NoAuth: AuthStrategy {

  func patch(params: [String: String]?) -> [String: String]? {
    return params
  }

  func patch(headers: [String: String]?) -> [String: String]? {
    return headers
  }
}
