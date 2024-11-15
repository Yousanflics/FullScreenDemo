//
//  PlayerFullScreenViewController.swift
//  FullScreenDemo
//
//  Created by yousanflics on 2020/9/21.
//  Copyright © 2020 yousanflics. All rights reserved.
//

import UIKit

public class PlayerFullScreenViewController: UIViewController {
    public var isAutorotateEnabled: Bool = true
    public var prefersInterfaceOrientation: UIInterfaceOrientation = .portrait
    public var prefersInterfaceOrientationMask: UIInterfaceOrientationMask = .portrait {
        didSet {
            if let superWindow = self.view?.window as? PlayerWindow {
                superWindow.supportedInterfaceOrientations = prefersInterfaceOrientationMask
            }
        }
    }
    
    private var originalIsAutorotateEnabled: Bool?
    private var originalPrefersInterfaceOrientation: UIInterfaceOrientation?
    private var originalPrefersInterfaceOrientationMask: UIInterfaceOrientationMask?
    
    public var contentView: UIView? {
        didSet {
            if contentView != oldValue {
                oldValue?.removeFromSuperview()
                if let contentView = self.contentView, let view = self.view {
                    contentView.frame = view.bounds
                    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    view.addSubview(contentView)
                }
            }
        }
    }
    
    
    public func attemptToRotate(to orientation: UIInterfaceOrientation) {
        self.originalIsAutorotateEnabled = isAutorotateEnabled
        self.originalPrefersInterfaceOrientation = prefersInterfaceOrientation
        self.originalPrefersInterfaceOrientationMask = prefersInterfaceOrientationMask
        
        self.isAutorotateEnabled = true
        self.prefersInterfaceOrientationMask = .all
        setDeviceOrientation(with: orientation)
    }
    
    func setDeviceOrientation(with orientation: UIInterfaceOrientation) {
        let deviceOrientation: UIDeviceOrientation
        switch orientation {
        case .landscapeLeft:
            deviceOrientation = .landscapeRight
        case .landscapeRight:
            deviceOrientation = .landscapeLeft
        case .portrait:
            deviceOrientation = .portrait
        case .portraitUpsideDown:
            deviceOrientation = .portraitUpsideDown
        default:
            deviceOrientation = .faceUp
        }
        UIDevice.current.setValue(deviceOrientation.rawValue, forKey: "orientation")
    }

    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (context) in
            if let isAutorotateEnabled = self.originalIsAutorotateEnabled {
                self.originalIsAutorotateEnabled = nil
                self.isAutorotateEnabled = isAutorotateEnabled
            }
            
            if let prefersInterfaceOrientationMask = self.originalPrefersInterfaceOrientationMask {
                self.originalPrefersInterfaceOrientationMask = nil
                self.prefersInterfaceOrientationMask = prefersInterfaceOrientationMask
            }
        }
    }
    
    public override var shouldAutorotate: Bool {
        return isAutorotateEnabled
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return prefersInterfaceOrientation
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return prefersInterfaceOrientationMask
    }
}
