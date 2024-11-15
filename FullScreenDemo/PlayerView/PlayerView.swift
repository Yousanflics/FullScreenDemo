//
//  PlayerView.swift
//  FullScreenDemo
//
//  Created by yousanflics on 2020/9/21.
//  Copyright © 2020 yousanflics. All rights reserved.
//

import UIKit

public protocol PlayerViewDelegate: AnyObject {
    func playerView(_ playerView: PlayerView, enterFullScreen: Bool)
    func playerView(_ playerView: PlayerView, rotateTo orientation: UIInterfaceOrientation)
}

public class PlayerView: UIView {
    public weak var delegate: PlayerViewDelegate?
    
    private lazy var controlView = UIView()
    private lazy var fullScreenButton = UIButton(type: .custom)
    
    
    private lazy var rotateButton = UIButton(type: .custom)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupUI()
        self.fullScreenButton.addTarget(self, action: #selector(didClickFullScreenButton(_:)), for: .touchUpInside)
        self.rotateButton.addTarget(self, action: #selector(didClickRotateScreenButton(_:)), for: .touchUpInside)
    }
    
    @objc
    private func didClickFullScreenButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        delegate?.playerView(self, enterFullScreen: button.isSelected)
    }
    
        @objc
    private func didClickRotateScreenButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            delegate?.playerView(self, rotateTo: .landscapeRight)
        } else {
            delegate?.playerView(self, rotateTo: .portrait)
        }
            
    }
}

private extension PlayerView {
    func setupUI() {
        self.backgroundColor = UIColor.orange
        controlView.backgroundColor = UIColor.yellow
        fullScreenButton.backgroundColor = UIColor.green
        rotateButton.backgroundColor = UIColor.blue
        
        self.addSubview(controlView)
        self.addSubview(fullScreenButton)
        self.addSubview(rotateButton)
        
        controlView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlView.heightAnchor.constraint(equalToConstant: 60),
            controlView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            controlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            controlView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            fullScreenButton.widthAnchor.constraint(equalToConstant: 60),
            fullScreenButton.heightAnchor.constraint(equalToConstant: 60),
            fullScreenButton.trailingAnchor.constraint(equalTo: controlView.trailingAnchor),
            fullScreenButton.bottomAnchor.constraint(equalTo: controlView.bottomAnchor),
            rotateButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            rotateButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}
