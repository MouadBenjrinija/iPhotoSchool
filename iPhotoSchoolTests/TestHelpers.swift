//
//  TestHelpers.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine
import XCTest

extension Publisher {
  func sinkToResult(_ result: @escaping
                    (Result<Self.Output, Self.Failure>) -> Void)
                      -> AnyCancellable {
    self.sink { completion in
      if case .failure(let error) = completion {
        result(.failure(error))
      }
    } receiveValue: { value in
      result(.success(value))
    }
  }
}

extension Result where Success: Equatable {
  func assertSuccess(to expectedValue: Success,
                     file: StaticString = #file, line: UInt = #line) {
    switch self {
    case .success(let result):
      XCTAssertEqual(result, expectedValue, file: file, line: line)
    case .failure(let error):
      XCTFail(error.localizedDescription)
    }
  }

  func assertSuccess(file: StaticString = #file, line: UInt = #line) {
    if case .failure(let failure) = self {
      XCTFail("Failed with error \(failure)")
    }
  }

  func assertFailure(_ failure: Error? = nil) {
    switch self {
    case .success:
      XCTFail("Expected Failure didn't occure")
    case .failure(let error):
      if let failure = failure {
        XCTAssertEqual(failure.localizedDescription, error.localizedDescription)
      }
    }
  }
}
