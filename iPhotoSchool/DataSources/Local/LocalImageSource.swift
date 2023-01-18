//
//  LocaLImageSourceDisk.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import UIKit.UIImage

protocol LocalImageSource {
  func loadImage(for url: URL) async -> UIImage?
  func saveImage(image: UIImage, url: URL) async
}

struct LocaLImageSourceDisk: LocalImageSource {

  private let fileManager = FileManager.default
  private let cacheDirectory = try! FileManager.default.url(for: .cachesDirectory,
                                                            in: .userDomainMask,
                                                            appropriateFor: nil,
                                                            create: true)

  func loadImage(for url: URL) async -> UIImage? {
    let fileUrl = cacheDirectory.appendingPathComponent(url.lastPathComponent)
    guard fileManager.fileExists(atPath: fileUrl.path),
          let image = UIImage(contentsOfFile: fileUrl.path) else {
      return nil
    }
    return image
  }

  func saveImage(image: UIImage, url: URL) {
    let fileUrl = cacheDirectory.appendingPathComponent(url.lastPathComponent)
    guard let data = image.jpegData(compressionQuality: 1) else { return }
    fileManager.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
  }

}
