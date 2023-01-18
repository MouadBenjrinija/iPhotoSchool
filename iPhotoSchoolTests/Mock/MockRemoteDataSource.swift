//
//  MockRemoteDataSource.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import XCTest
import Combine
@testable import iPhotoSchool

struct MockResponse {
  var url: String
  var result: Result<Data, Error>
  var delay: TimeInterval = 0.1
  var headers: [String: String] = ["Content-Type": "application/json"]
  var code: Int = 200
  var response: URLResponse?
}

class MockUrlProtocol: URLProtocol {
  private static var mockResponses: [MockResponse] = []

  static func mockResponse(for url: String) -> MockResponse? {
    Self.mockResponses.first(where: { $0.url == url })
  }

  static func register(mock: MockResponse) {
    mockResponses.append(mock)
  }

  static func reset() {
    mockResponses.removeAll()
  }

  // MARK: - URLProtocol methods

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canInit(with task: URLSessionTask) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    if let url = request.url,
       let mockResponse = MockUrlProtocol.mockResponse(for: url.absoluteString),
       let response = mockResponse.response ??
                      HTTPURLResponse(url: url,
                        statusCode: mockResponse.code,
                        httpVersion: "HTTP/1.1",
                        headerFields: mockResponse.headers) {
        DispatchQueue.main
          .asyncAfter(deadline: .now() + mockResponse.delay) { [weak self] in
        guard let self = self else { return }
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        switch mockResponse.result {
        case .success(let data):
          self.client?.urlProtocol(self, didLoad: data)
          self.client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
          self.client?.urlProtocol(self, didFailWithError: error)
        }
      }
    } else {
      fatalError(request.url == nil ? "nil url \(#file) / \(#function)" :
                  "mock not registered for url: \(request.url!.absoluteString)")
    }
  }

  override func stopLoading() {}
}

extension URLSession {
  static var mocked: URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockUrlProtocol.self]
    configuration.timeoutIntervalForRequest = 1
    configuration.timeoutIntervalForResource = 1
    return URLSession(configuration: configuration)
  }
}
