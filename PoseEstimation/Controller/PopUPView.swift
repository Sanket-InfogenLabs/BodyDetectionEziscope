//
//  PopUPView.swift
//  PoseEstimation
//
//  Created by Sanket Lothe on 08/02/24.
//  Copyright © 2024 tensorflow. All rights reserved.
//

import UIKit

class PopUPView: UIView {
    
    
    @IBOutlet weak var showMebtn: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var ContentView: UIView!
    
    @IBOutlet var container: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commitInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commitInit()
    }

    private func commitInit() {
        Bundle.main.loadNibNamed("PopUpView", owner: self, options: nil)
        addSubview(container)
        container.frame = bounds
        container.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        ContentView.layer.applyCornerRadiusShadow(color: .black,
                                                alpha: 0.25,
                                                x: 0, y: 1,
                                                blur: 4,
                                                spread: 0,
                                                cornerRadiusValue: 20)


        let backgraoundViewTap = UITapGestureRecognizer(target: self, action: #selector(handleTapForBackground(_:)))
        backgroundView.addGestureRecognizer(backgraoundViewTap)
    }

    @objc func handleTapForBackground(_ sender: UITapGestureRecognizer) {
        HomeScreenViewController.sharedInstance?.removeARHelp()
    }
    
    @IBAction func showMEBthAction(_ sender: UIButton) {
        
        HomeScreenViewController.sharedInstance?.goToShowMe()
        
    }
    
    
}

extension CALayer {
    func applyCornerRadiusShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0,
        cornerRadiusValue: CGFloat = 0
    ) {
        cornerRadius = cornerRadiusValue
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        }
        else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
