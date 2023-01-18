//
//  ApiRepository.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine

protocol RemoteDataSource {
  var session: URLSession { get }
}

extension RemoteDataSource {
  func fetch<Value>(call: RemoteCall) -> AnyPublisher<Value, Error> where Value: Decodable {
    do {
      let request = try call.request()
      return session
        .dataTaskPublisher(for: request)
        .decodeData()
    } catch let error {
      return Fail<Value, Error>(error: error).eraseToAnyPublisher()
    }
  }

  func loadData(endpoint: RemoteCall) -> AnyPublisher<Data, Error> {
    do {
      let request = try endpoint.request()
      return session
        .dataTaskPublisher(for: request)
        .mapData()
    } catch let error {
      return Fail<Data, Error>(error: error).eraseToAnyPublisher()
    }
  }
}

extension Publisher where Output == URLSession.DataTaskPublisher.Output {
  func mapData(successCodes: HTTPCodes = .success) -> AnyPublisher<Data, Error> {
    tryMap { data, response in
      // extract status code
      guard let code = (response as? HTTPURLResponse)?.statusCode else {
        throw APIError.unexpectedResponse
      }
      // throw if status code is out of success range
      guard successCodes.contains(code) else {
        let json = String(data: data, encoding: .utf8)
        throw APIError.httpCode(code, json ?? "No data in body")
      }
      // return data object
      return data
    }.eraseToAnyPublisher()
  }

  func decodeData<T>(successCodes: HTTPCodes = .success)
  -> AnyPublisher<T, Error> where T: Decodable {
    mapData(successCodes: successCodes)
      .decode(type: T.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension URLSession {
  static var `default`: URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 60
    configuration.timeoutIntervalForResource = 120
    configuration.waitsForConnectivity = true
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    configuration.urlCache = .shared
    return URLSession(configuration: configuration)
  }
}
