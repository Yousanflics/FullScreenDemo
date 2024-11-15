//
//  PlayerWindow.swift
//  FullScreenDemo
//
//  Created by yousanflics on 2020/9/21.
//  Copyright © 2020 yousanflics. All rights reserved.
//

import UIKit

public protocol WindowRotatable: UIWindow {
    var supportedInterfaceOrientations: UIInterfaceOrientationMask { get }
}

public class PlayerWindow: UIWindow, WindowRotatable {
    public var originInterfaceOrientation: UIInterfaceOrientation = .portrait
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask = .portrait
}

public class PlayerWindowManager: NSObject {
    private static var currentWindow: PlayerWindow?
}

public extension PlayerWindowManager {
    class func rotate(to orientation: UIInterfaceOrientation) {
        guard let currentWindow = self.currentWindow,
            let containerVC = currentWindow.rootViewController as? PlayerFullScreenViewController else {
            return
        }
        
        containerVC.attemptToRotate(to: orientation)
    }
    
    class func show(_ playerView: UIView, origin: UIInterfaceOrientation, expected: UIInterfaceOrientation, animated: Bool = true) {
        guard self.currentWindow == nil, let originWindow = playerView.window else { return }
        
        let playerWindow: PlayerWindow
        if #available(iOS 13.0, *), let windowScene = originWindow.windowScene {
            playerWindow = PlayerWindow(windowScene: windowScene)
        } else {
            playerWindow = PlayerWindow(frame: UIScreen.main.bounds)
        }
        let containerVC = PlayerFullScreenViewController()
        containerVC.isAutorotateEnabled = true
        containerVC.prefersInterfaceOrientation = expected
        containerVC.prefersInterfaceOrientationMask = expected.orientationMask
        playerWindow.supportedInterfaceOrientations = containerVC.prefersInterfaceOrientationMask
        playerWindow.originInterfaceOrientation = origin
        
        self.currentWindow = playerWindow
        playerWindow.rootViewController = containerVC
        playerWindow.isHidden = false
        
        containerVC.contentView = playerView
    }
    
    class func dismiss(_ playerView: UIView, animated: Bool = true, completion: @escaping () -> Void) {
        guard let currentWindow = self.currentWindow else { return }
        self.currentWindow = nil
        let origin = currentWindow.originInterfaceOrientation
        let playerWindow: PlayerWindow
        if #available(iOS 13.0, *), let windowScene = currentWindow.windowScene {
           playerWindow = PlayerWindow(windowScene: windowScene)
        } else {
           playerWindow = PlayerWindow(frame: UIScreen.main.bounds)
        }
        let containerVC = PlayerFullScreenViewController()
        containerVC.isAutorotateEnabled = true
        containerVC.prefersInterfaceOrientation = origin
        containerVC.prefersInterfaceOrientationMask = origin.orientationMask
        playerWindow.rootViewController = containerVC
        playerWindow.isHidden = false
        DispatchQueue.main.async {
            playerWindow.isHidden = true
            completion()
        }
    }
}


extension UIInterfaceOrientation {
    var orientationMask: UIInterfaceOrientationMask {
        switch self {
        case .landscapeLeft, .landscapeRight:
            return .landscape
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .all
        }
    }
}
