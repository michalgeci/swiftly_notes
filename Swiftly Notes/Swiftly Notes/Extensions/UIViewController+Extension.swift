//
//  UIViewController+Extension.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 15/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

extension UIViewController {
    
    static let loaderTag = 12345
    static let activityIndicatorTag = 74956
    static let containerTag = 8456
    
    private var loaderView: UIView? {
        return view.viewWithTag(UIViewController.loaderTag)
    }
    
    func showLoader(withMessage: String = "", withBlur: Bool = true) {
        if let _ = self.loaderView {
            return
        }
        self.view.isUserInteractionEnabled = false
        
        let background = UIView()
        background.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = background.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background.addSubview(blurEffectView)
        self.view.addSubview(background)
        
        background.tag = UIViewController.loaderTag
        background.translatesAutoresizingMaskIntoConstraints = false
        
        background.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        background.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        background.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        background.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let container = UIView()
        container.tag = UIViewController.containerTag
        container.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        container.layer.cornerRadius = 16
        background.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: 120).isActive = true
        container.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.tag = UIViewController.activityIndicatorTag
        container.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    
    func hideLoader(completition: (()->())? = nil) {
        view.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, animations: {
            self.loaderView?.alpha = 0
        }) { _ in
            self.loaderView?.removeFromSuperview()
        }
        if let complete = completition {
            complete()
        }
    }
    
    
    func showAlert(actionHandler: @escaping ()->Void) {
        let alert = UIAlertController(title: "", message: "Can not connect to server.\nTry again later please.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            actionHandler()
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
