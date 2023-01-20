//
//  DownloadButton.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 19/1/2023.
//

import UIKit

class DownloadButton: UIView {

  enum State {
    case normal
    case downloading(progress: Int)
    case downloaded
  }

  var onDownload: (() -> Void)?
  var onCancel: (() -> Void)?

  func configure(state: State) {
    downloadButton.isHidden = true
    downloadingButton.isHidden = true
    downloadedButton.isHidden = true
    switch state {
    case .normal: downloadButton.isHidden = false
    case .downloaded: downloadedButton.isHidden = false
    case .downloading(progress: let progress):
      downloadingButton.isHidden = false
      downloadingButton.animate(progress: progress)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  private func setupView() {
    let holder = UIStackView(arrangedSubviews: [
      downloadButton, downloadingButton, downloadedButton
    ])
    holder.axis = .horizontal
    addSubview(holder)

    holder.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: holder.topAnchor),
      leadingAnchor.constraint(equalTo: holder.leadingAnchor),
      trailingAnchor.constraint(equalTo: holder.trailingAnchor),
      bottomAnchor.constraint(equalTo: holder.bottomAnchor)
    ])
  }

  lazy var downloadButton: UIButton = {
    let button = UIButton(type: .system)
    let image = UIImage(systemName: "icloud.and.arrow.down",
                        withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
    button.setImage(image, for: .normal)
    button.setTitle(" Download", for: .normal)
    button.addTarget(self,
                     action: #selector(downloadTapped),
                     for: .touchUpInside)
    button.sizeToFit()
    return button
  }()

  lazy var downloadingButton: LoadingButton = {
    let button = LoadingButton()
    button.onCancel = self.cancelTapped
    return button
  }()

  let downloadedButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Downloaded", for: .normal)
    button.isEnabled = false
    button.sizeToFit()
    return button
  }()

  @objc func downloadTapped() {
    onDownload?()
  }

  func cancelTapped() {
    onCancel?()
  }

}

