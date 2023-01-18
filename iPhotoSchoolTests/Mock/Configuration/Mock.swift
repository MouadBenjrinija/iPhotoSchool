//
//  Mock.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import XCTest

// MARK: - Mock protocol
protocol Mock {
  associatedtype Action: Equatable // an enum
  var recorder: MockActionRecorder<Action> { get }
}

extension Mock {
  func verify() { recorder.verify() }
  func record(action: Action) { recorder.record(action: action) }
}

// MARK: - Action recorder/verifier
class MockActionRecorder<Action: Equatable> {
  let expected: [Action]
  var recorded: [Action] = []

  init(expected: [Action]) {
    self.expected = expected
  }

  func record(action: Action) {
    recorded.append(action)
  }

  func verify() {
    guard expected != recorded else { return }
    XCTFail("Expected: \n\(expected)\n Recorded: \(recorded)")
  }

}
