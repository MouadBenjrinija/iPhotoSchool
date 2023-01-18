//
//  LocalImageSourceMemory.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 18/1/2023.
//

import Foundation
import UIKit.UIImage

class LocalImageSourceMemory: LocalImageSource {
  typealias Cache = NSCache<AnyObject, AnyObject>
  let memoryLimit = 1024 * 1024 * 100 // 100MB
  let lock = NSLock()
  private lazy var rawImageCache: Cache = {
    let cache = Cache()
    cache.totalCostLimit = self.memoryLimit
    return cache
  }()
  private lazy var decodedImageCache: Cache = {
    let cache = Cache()
    cache.totalCostLimit = self.memoryLimit
    return cache
  }()

  // MARK: - implementation

  func saveImage(image: UIImage, url: URL) async {
    cache(image: image, in: rawImageCache, for: url)
    cache(image: image.decodedImage(), in: decodedImageCache, for: url)
  }

  func loadImage(for url: URL) async -> UIImage? {
    if let image = from(cache: decodedImageCache, for: url) {
      return image
    }
    if let image = from(cache: rawImageCache, for: url) {
      let decoded = image.decodedImage()
      cache(image: decoded, in: decodedImageCache, for: url)
      return decoded
    }
    return nil
  }

  func remove(for key: URL) async {
    rawImageCache.removeObject(forKey: key as AnyObject)
    decodedImageCache.removeObject(forKey: key as AnyObject)
  }

  func removeAll() {
    rawImageCache.removeAllObjects()
    decodedImageCache.removeAllObjects()
  }

  func cache(image: UIImage, in cache: Cache, for key: URL) {
    cache.setObject(image as AnyObject,
                    forKey: key as AnyObject,
                    cost: image.diskSize)
  }

  func from(cache: Cache, for key: URL) -> UIImage? {
    cache.object(forKey: key as AnyObject) as? UIImage
  }
}

extension UIImage {
  func decodedImage() -> UIImage {
    guard let cgImage = cgImage else { return self }
    let size = CGSize(width: cgImage.width, height: cgImage.height)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: 8,
                            bytesPerRow: cgImage.bytesPerRow,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
    context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
    guard let decodedImage = context?.makeImage() else { return self }
    return UIImage(cgImage: decodedImage)
  }

  // Rough estimation of how much memory image uses in bytes
  var diskSize: Int {
      guard let cgImage = cgImage else { return 0 }
      return cgImage.bytesPerRow * cgImage.height
  }
}
