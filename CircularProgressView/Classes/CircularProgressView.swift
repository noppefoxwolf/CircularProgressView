//
//  CircularProgressView.swift
//  CircularProgressView
//
//  Created by Tomoya Hirano on 2018/05/03.
//

import UIKit

open class CircularProgressView: UIControl {
  public enum CircularState: Int {
    case stop
    case stopSpinning
    case stopProgress
    case complated
    case icon
  }
  private var _progress: Double = 0.0
  public var progress: Double {
    get { return _progress }
    set {
      let newValue = min(newValue, 1.0)
      guard _progress != newValue else { return }
      _progress = newValue
      print(progress, progress == 1.0)
      if progress == 1.0 {
        animateProgressBackgroundLayerFillColor()
      }
      if progress == 0.0 {
        progressBackgroundLayer.fillColor = backgroundColor?.cgColor
      }
      setNeedsDisplay()
    }
  }
  private var _lineWidth: CGFloat = 1.0
  public var lineWidth: CGFloat {
    get { return _lineWidth }
    set {
      _lineWidth = max(newValue, 1.0)
      progressBackgroundLayer.lineWidth = lineWidth
      progressLayer.lineWidth = lineWidth * 2.0
      iconLayer.lineWidth = lineWidth
    }
  }
  public var progressColor: UIColor = .init(red: 0, green: 122.0/255.0, blue: 1.0, alpha: 1.0) {
    didSet {
      progressBackgroundLayer.strokeColor = progressColor.cgColor
      progressLayer.strokeColor = progressColor.cgColor
      iconLayer.strokeColor = progressColor.cgColor
      if progress == 1.0 {
        progressBackgroundLayer.fillColor = progressColor.cgColor
      }
    }
  }
  public var tickColor: UIColor = .white
  public var iconView: UIView? = nil {
    willSet {
      guard iconView != nil else { return }
      iconView?.removeFromSuperview()
    }
    didSet {
      guard let iconView = iconView else { return }
      addSubview(iconView)
    }
  }
  public var iconPath: UIBezierPath? = nil
  public var isSpinning: Bool = false
  public var circularState: CircularState = .stop {
    didSet {
      guard oldValue != circularState else { return }
      switch circularState {
      case .stop:
        progress = 0.0
        if isSpinning { stopSpinProgressBackgroundLayer() }
        if isAnimatingProgressBackgroundLayerFillColor {
          stopAnimatingProgressBackgroundLayerFillColor()
        }
      case .stopSpinning:
        progress = 0.0
        if !isSpinning { startSpinProgressBackgroundLayer() }
        if isAnimatingProgressBackgroundLayerFillColor {
          stopAnimatingProgressBackgroundLayerFillColor()
        }
      case .stopProgress:
        if isSpinning { stopSpinProgressBackgroundLayer() }
        if isAnimatingProgressBackgroundLayerFillColor {
          stopAnimatingProgressBackgroundLayerFillColor()
        }
      case .complated:
        progress = 1.0
        if isSpinning { stopSpinProgressBackgroundLayer() }
      case .icon:
        progress = 0.0
        if isSpinning { stopSpinProgressBackgroundLayer() }
        if isAnimatingProgressBackgroundLayerFillColor {
          stopAnimatingProgressBackgroundLayerFillColor()
        }
      }
      setNeedsDisplay()
    }
  }
  override open var tintColor: UIColor! {
    didSet {
      if let tintColor = tintColor {
        progressColor = tintColor
      } else {
        progressColor = UIColor(red: 0.0, green: 122.0 / 255.0, blue: 1.0, alpha: 1.0)
      }
    }
  }
  override open var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        alpha = 0.5
      } else {
        alpha = 1.0
      }
    }
  }
  
  public func downArrowPath() -> UIBezierPath {
    let radius = bounds.width / 2.0
    let ratio = kArrowSizeRatio
    let segmentSize = bounds.width * ratio
    
    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: .init(x: segmentSize * 2.0, y: 0.0))
    path.addLine(to: .init(x: segmentSize * 2.0, y: segmentSize))
    path.addLine(to: .init(x: segmentSize * 3.0, y: segmentSize))
    path.addLine(to: .init(x: segmentSize, y: segmentSize * 3.0))
    path.addLine(to: .init(x: -segmentSize, y: segmentSize))
    path.addLine(to: .init(x: 0.0, y: segmentSize))
    path.addLine(to: .zero)
    path.close()
    
    path.apply(.init(translationX: -(segmentSize / 2.0), y: -segmentSize / 1.2))
    path.apply(.init(translationX: radius * (1.0 - ratio), y: radius * (1.0 - ratio)))
    
    return path
  }
  
  public func upArrowPath() -> UIBezierPath {
    let radius = bounds.width / 2.0
    let ratio = kArrowSizeRatio
    let segmentSize = bounds.width * ratio
    
    let path = UIBezierPath()
    path.move(to: .zero)
    path.addLine(to: .init(x: segmentSize * 2.0, y: 0.0))
    path.addLine(to: .init(x: segmentSize * 2.0, y: segmentSize))
    path.addLine(to: .init(x: segmentSize * 3.0, y: segmentSize))
    path.addLine(to: .init(x: segmentSize, y: segmentSize * 3.3))
    path.addLine(to: .init(x: -segmentSize, y: segmentSize))
    path.addLine(to: .init(x: 0.0, y: segmentSize))
    path.addLine(to: .zero)
    path.close()
    
    path.apply(.init(rotationAngle: .pi))
    path.apply(.init(translationX: radius * 1.0, y: 1.0 * radius))
    path.apply(.init(translationX: segmentSize, y: segmentSize * 1.3))
    
    return path
  }
  public func startSpinProgressBackgroundLayer() {
    isSpinning = true
    drawBackgroundCircle(true)
    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
    rotationAnimation.toValue = CGFloat.pi * 2.0
    rotationAnimation.duration = 1.0
    rotationAnimation.isRemovedOnCompletion = true
    rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
    progressBackgroundLayer.add(rotationAnimation, forKey: "rotationAnimation")
  }
  public func stopSpinProgressBackgroundLayer() {
    drawBackgroundCircle(false)
    progressBackgroundLayer.removeAllAnimations()
    isSpinning = false
  }
  private lazy var progressBackgroundLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.contentsScale = UIScreen.main.scale
    layer.strokeColor = progressColor.cgColor
    layer.fillColor = backgroundColor?.cgColor
    layer.lineCap = kCALineCapRound
    layer.lineWidth = lineWidth
    return layer
  }()
  private lazy var progressLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.contentsScale = UIScreen.main.scale
    layer.strokeColor = progressColor.cgColor
    layer.fillColor = nil
    layer.lineCap = kCALineCapSquare
    layer.lineWidth = lineWidth * 2.0
    return layer
  }()
  private lazy var iconLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.contentsScale = UIScreen.main.scale
    layer.strokeColor = progressColor.cgColor
    layer.fillColor = nil
    layer.lineCap = kCALineCapButt
    layer.lineWidth = lineWidth
    layer.fillRule = kCAFillRuleNonZero
    return layer
  }()
  private var isAnimatingProgressBackgroundLayerFillColor: Bool = true
  let kArrowSizeRatio: CGFloat = 0.12
  let kStopSizeRatio: CGFloat = 0.3
  let kTickWidthRatio: CGFloat = 0.3
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private func setup() {
    backgroundColor = .clear
    lineWidth = max(frame.size.width * 0.025, 1.0)
    
    layer.addSublayer(progressBackgroundLayer)
    layer.addSublayer(progressLayer)
    layer.addSublayer(iconLayer)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(CircularProgressView.applicationWillEnterForeground(_:)),
                                           name: .UIApplicationWillEnterForeground,
                                           object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override open func draw(_ rect: CGRect) {
    progressBackgroundLayer.frame = bounds
    progressLayer.frame = bounds
    iconLayer.frame = bounds
    let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
    var radius = (bounds.size.width - lineWidth) / 2.0
    
    drawBackgroundCircle(isSpinning)
    
    let startAngle = -(CGFloat.pi / 2.0)
    let endAngle = (CGFloat(progress) * 2.0 * CGFloat.pi) + startAngle
    let processPath = UIBezierPath()
    processPath.lineCapStyle = .butt
    processPath.lineWidth = lineWidth
    
    radius = (bounds.width - lineWidth * 3.0) / 2.0
    processPath.addArc(withCenter: center,
                       radius: radius,
                       startAngle: startAngle,
                       endAngle: endAngle,
                       clockwise: true)
    progressLayer.path = processPath.cgPath
    
    switch circularState {
    case .stop:
      drawStop()
    case .stopSpinning:
      drawStop()
    case .stopProgress:
      drawStop()
    case .complated:
      drawTick()
    case .icon:
      if iconView != nil && iconPath != nil {
        drawArrow()
      } else if iconPath != nil {
        iconLayer.path = iconPath?.cgPath
        iconLayer.fillColor = nil
      }
    }
  }
  
  private func drawBackgroundCircle(_ partial: Bool) {
    let startAngle = -(CGFloat.pi / 2.0)
    var endAngle = (2.0 * CGFloat.pi) + startAngle
    let center = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
    let radius = (bounds.width - lineWidth) / 2.0
    
    let processBackgroundPath = UIBezierPath()
    processBackgroundPath.lineWidth = lineWidth
    processBackgroundPath.lineCapStyle = .round
    
    if partial {
      endAngle = (1.8 * CGFloat.pi) + startAngle
    }
    
    processBackgroundPath.addArc(withCenter: center,
                                 radius: radius,
                                 startAngle: startAngle,
                                 endAngle: endAngle,
                                 clockwise: true)
    progressBackgroundLayer.path = processBackgroundPath.cgPath
  }
  
  private func drawTick() {
    let radius = min(frame.width, frame.height) / 2.0
    let tickPath = UIBezierPath()
    let tickWidth = radius * kTickWidthRatio
    tickPath.move(to: .zero)
    tickPath.addLine(to: .init(x: 0, y: tickWidth * 2.0))
    tickPath.addLine(to: .init(x: tickWidth * 3, y: tickWidth * 2.0))
    tickPath.addLine(to: .init(x: tickWidth * 3, y: tickWidth))
    tickPath.addLine(to: .init(x: tickWidth, y: tickWidth))
    tickPath.addLine(to: .init(x: tickWidth, y: 0.0))
    tickPath.close()
    
    tickPath.apply(.init(rotationAngle: -(.pi / 4.0)))
    
    tickPath.apply(.init(translationX: radius * 0.46, y: 1.02 * radius))
    
    iconLayer.path = tickPath.cgPath
    iconLayer.fillColor = tickColor.cgColor
    progressBackgroundLayer.fillColor = progressLayer.strokeColor
  }
  
  private func drawStop() {
    let radius = bounds.width / 2.0
    let ratio = kStopSizeRatio
    let sideSize = bounds.width * ratio
    
    let stopPath = UIBezierPath()
    stopPath.move(to: .zero)
    stopPath.addLine(to: .init(x: sideSize, y: 0.0))
    stopPath.addLine(to: .init(x: sideSize, y: sideSize))
    stopPath.addLine(to: .init(x: 0.0, y: sideSize))
    stopPath.close()
    
    stopPath.apply(.init(translationX: radius * (1.0 - ratio), y: radius * (1.0 - ratio)))
    
    iconLayer.path = stopPath.cgPath
    iconLayer.strokeColor = progressLayer.strokeColor
    iconLayer.fillColor = progressColor.cgColor
  }
  
  private func drawArrow() {
    iconLayer.path = downArrowPath().cgPath
    iconLayer.fillColor = nil
  }
  
  private func animateProgressBackgroundLayerFillColor() {
    let colorAnimation = CABasicAnimation(keyPath: "fillColor")
    colorAnimation.duration = 0.5
    colorAnimation.repeatCount = 1.0
    colorAnimation.isRemovedOnCompletion = false
    colorAnimation.fromValue = progressBackgroundLayer.backgroundColor
    colorAnimation.toValue = progressBackgroundLayer.strokeColor
    colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    progressBackgroundLayer.add(colorAnimation, forKey: "colorAnimation")
    isAnimatingProgressBackgroundLayerFillColor = true
  }
  
  private func stopAnimatingProgressBackgroundLayerFillColor() {
    progressBackgroundLayer.removeAnimation(forKey: "colorAnimation")
    progressBackgroundLayer.fillColor = backgroundColor?.cgColor
    isAnimatingProgressBackgroundLayerFillColor = false
  }
  
  private func restartAnimation() {
    let shouldStart = isSpinning
    isSpinning = true
    stopSpinProgressBackgroundLayer()
    if shouldStart {
      startSpinProgressBackgroundLayer()
    }
  }
  
  override open func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
    restartAnimation()
  }
  
  override open func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    restartAnimation()
  }
  
  @objc private func applicationWillEnterForeground(_ notification: Notification) {
    restartAnimation()
  }
}
