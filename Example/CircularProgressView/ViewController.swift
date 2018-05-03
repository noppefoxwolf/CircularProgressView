//
//  ViewController.swift
//  CircularProgressView
//
//  Created by Tomoya Hirano on 05/03/2018.
//  Copyright (c) 2018 Tomoya Hirano. All rights reserved.
//

import UIKit
import CircularProgressView

final class ViewController: UIViewController {
  private let progressView = CircularProgressView(frame: .init(x: 40, y: 40, width: 80, height: 80))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    progressView.center = view.center
    view.addSubview(progressView)
    progressView.startSpinProgressBackgroundLayer()
    progressTest()
  }
  
  private func progressTest() {
    progressView.circularState = .stopSpinning
    var delayInSeconds: TimeInterval = 2.5
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delayInSeconds) {
      self.progressView.circularState = .stopProgress
      var i: Int = 0
      while i < 101 {
        i += 1
        DispatchQueue.main.async {
          self.progressView.progress = Double(i) / 100.0
          if i == 100 {
            self.progressView.circularState = .complated
          }
        }
        usleep(10000)
      }
      
      delayInSeconds = 2.0
      DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delayInSeconds) {
        DispatchQueue.main.async {
          self.progressView.progress = 0
        }
      }
      
      delayInSeconds = 3.0
      DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delayInSeconds) {
        DispatchQueue.main.async {
          self.progressView.circularState = .stop
          self.progressView.stopSpinProgressBackgroundLayer()
        }
      }
    }
  }
}


