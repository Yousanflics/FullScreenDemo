//
//  ViewController.swift
//  FullScreenDemo
//
//  Created by yousanflics on 2020/9/21.
//  Copyright © 2020 yousanflics. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var playerContainerView: UIView = UIView()
    
    lazy var playerView: PlayerView = PlayerView()
    
    var isEnterFullScreen: Bool = false
    
    var observer: Any? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        
        playerView.delegate = self
    }
    
    func setupUI() {
        playerContainerView.backgroundColor = UIColor.cyan
        self.view.addSubview(playerContainerView)
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerContainerView.heightAnchor.constraint(equalToConstant: 250),
            playerContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        playerView.frame = playerContainerView.bounds
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerContainerView.addSubview(playerView)
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .allButUpsideDown
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

extension ViewController: PlayerViewDelegate {
    func playerView(_ playerView: PlayerView, rotateTo orientation: UIInterfaceOrientation) {
        PlayerWindowManager.rotate(to: orientation)
    }
    
    func playerView(_ playerView: PlayerView, enterFullScreen: Bool) {
        self.isEnterFullScreen = enterFullScreen
        if enterFullScreen {
            PlayerWindowManager.show(playerView, origin: .portrait, expected: .landscapeRight)
        } else {
            PlayerWindowManager.dismiss(playerView) {
                playerView.removeFromSuperview()
                playerView.frame = self.playerContainerView.bounds
                playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.playerContainerView.addSubview(self.playerView)
            }
            
        }
    }
}

