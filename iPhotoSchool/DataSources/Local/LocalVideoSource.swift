//
//  LocalVideoSource.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import Combine

protocol LocalVideoSource {
  func urlFor(file: String?) -> URL?
  func saveFile(url: URL, for sourceUrl: URL) throws -> URL
}

class LocalVideoSourceMain: LocalVideoSource {

  func urlFor(file: String?) -> URL? {
    guard let file,
          let url = URL(string: file),
          let fileURL = try? folderURL()
              .appendingPathComponent(url.lastPathComponent),
          FileManager.default.fileExists(atPath: fileURL.path)
    else { return nil }
    return fileURL
  }

  func saveFile(url: URL, for sourceUrl: URL) throws -> URL {
    let savedURL = try folderURL().appendingPathComponent(sourceUrl.lastPathComponent)
    try FileManager.default.moveItem(at: url, to: savedURL)
    return savedURL
  }

  func folderURL() throws -> URL {
    try FileManager.default.url(for: .cachesDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: true)
  }

}

enum LocalVideoError: Error {
  case unableToSaveFile
}
