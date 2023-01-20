//
//  LoadingButton.swift
//  iPhotoSchool
//
//  Created by MOUAD BENJRINIJA on 20/1/2023.
//

import UIKit

class LoadingButton: UIView {

  private static let height: CGFloat = 20
  var currentProgress: Float = 0.0
  var onCancel: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  func setup() {
    let ringView = UIView()
    ringView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      ringView.heightAnchor.constraint(equalToConstant: Self.height),
      ringView.widthAnchor.constraint(equalToConstant: Self.height)
    ])
    ringView.layer.addSublayer(progressLayer)
    let holder = UIStackView(arrangedSubviews: [ringView,cancelButton])
    holder.axis = .horizontal
    holder.spacing = 6
    addSubview(holder)
    holder.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: holder.topAnchor),
      leadingAnchor.constraint(equalTo: holder.leadingAnchor),
      trailingAnchor.constraint(equalTo: holder.trailingAnchor),
      bottomAnchor.constraint(equalTo: holder.bottomAnchor)
    ])
  }


  lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Cancel", for: .normal)
    button.addTarget(self, action: #selector(cancelTapped),
                     for: .touchUpInside)
    button.sizeToFit()
    return button
  }()

  var progressLayer: CAShapeLayer = {
    let progressLayer = CAShapeLayer()
    let lineWidth = 2.0
    let center = CGPoint(x: height/2, y: height/2)
    let circularPath = UIBezierPath(arcCenter: center, radius: (height - lineWidth)/2,
                                    startAngle: -.pi / 2, endAngle: 2 * .pi,
                                    clockwise: true)
    progressLayer.path = circularPath.cgPath
    progressLayer.fillColor = UIColor.clear.cgColor
    progressLayer.strokeColor = UIColor.tintColor.cgColor
    progressLayer.lineCap = .round
    progressLayer.lineWidth = lineWidth
    progressLayer.strokeEnd = 0
    return progressLayer
  }()

  func animate(progress: Int) {
    let newProgress = Float(progress)/100.0
    let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    progressAnimation.fromValue = currentProgress
    progressAnimation.toValue = newProgress
    progressAnimation.fillMode = .forwards
    progressAnimation.isRemovedOnCompletion = false
    progressLayer.add(progressAnimation, forKey: "progressAnim")
    currentProgress = newProgress
  }

  @objc func cancelTapped() {
    onCancel?()
  }

}
