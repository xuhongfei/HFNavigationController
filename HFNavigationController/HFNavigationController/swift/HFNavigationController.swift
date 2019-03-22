//
//  HFNavigationController.swift
//  DcoinWallet
//
//  Created by hongfei xu on 2018/11/6.
//  Copyright © 2018 dcoin. All rights reserved.
//

import UIKit

class HFNavigationController: UINavigationController {

    // MARK: - public
    
    public enum PopAnimationType {
        /// 线性动画，default
        case liner
        /// 幕布式动画
        case curtain
        /// 缩放式动画
        case scale
    }
    
    /// 是否支持手势返回
    public var canIneractive: Bool = true
    
    /// pop动画类型
    public var popAnimationType: PopAnimationType = .liner
    
    // MARK: - private
    fileprivate var screenShots: [UIImage] = []
    fileprivate var isMoving: Bool = false
    fileprivate var startTouch: CGPoint = CGPoint.zero
    
    fileprivate var backgroundView: UIView?
    fileprivate var blackMask: UIView?
    fileprivate var lastScreenShotView: UIImageView?
    
    fileprivate var keyWindow: UIWindow {
        get {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                return delegate.window!
            }
            return UIApplication.shared.keyWindow!
        }
    }
    
    fileprivate var topView: UIView? {
        get {
            return keyWindow.rootViewController?.view
//            return UIApplication.shared.keyWindow?.rootViewController?.view
        }
    }
    
    fileprivate var screenWidth: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.screenShots.count == 0 {
            if let capturedImage = capture() {
                screenShots.append(capturedImage)
            }
        }
    }
    
    deinit {
        screenShots = []
    }

    // MARK: -
    fileprivate func setup() {
        
        navigationBar.isTranslucent = false
        
        let screenEdgePanGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        screenEdgePanGR.edges = .left
        screenEdgePanGR.delegate = self
        view.addGestureRecognizer(screenEdgePanGR)
        
    }
    
    // MARK: -
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let capturedImage = capture() {
            screenShots.append(capturedImage)
        }
        
        if viewControllers.count > 0 {
    
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(back))
        }
        
        if viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        screenShots.removeLast()
        
        return super.popViewController(animated: animated)
    }
    
    // MARK: -
    @objc
    fileprivate func panGestureRecognizer(_ panGR: UIScreenEdgePanGestureRecognizer) {
        
        guard viewControllers.count > 1 && canIneractive else {
            return
        }
        
        let touchPoint = panGR.location(in: keyWindow)
        
        switch panGR.state {
        case .began:
            
            isMoving = true
            startTouch = touchPoint
            
            if backgroundView == nil {
                let frame = topView!.frame
                backgroundView = UIView()
                let bgvFrame = CGRect(origin: CGPoint.zero, size: frame.size)
                backgroundView!.frame = bgvFrame
                backgroundView!.backgroundColor = UIColor.white
                topView!.superview?.insertSubview(backgroundView!, belowSubview: topView!)
                
                blackMask = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
                blackMask?.backgroundColor = UIColor.black
                backgroundView?.addSubview(blackMask!)
            }
            
            backgroundView?.isHidden = false
            lastScreenShotView?.removeFromSuperview()
            if let lastScreenShot = screenShots.last {
                lastScreenShotView = UIImageView(image: lastScreenShot)
                backgroundView?.insertSubview(lastScreenShotView!, belowSubview: blackMask!)
            }
            
        case .ended:
            
            if touchPoint.x - startTouch.x > screenWidth * 0.3 {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.moveView(with: self!.screenWidth)
                }) { [weak self] (finished) in
                    _ = self?.popViewController(animated: false)
                    var frame = self!.topView!.frame
                    frame.origin.x = 0
                    UIApplication.shared.keyWindow!.rootViewController!.view.frame = frame
                    
                    self?.isMoving = false
                    self?.backgroundView?.isHidden = true
                }
            } else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.moveView(with: 0)
                }) { [weak self] (finished) in
                    self?.isMoving = false
                    self?.backgroundView?.isHidden = true
                }
            }
 
            return
            
        case .cancelled:
            
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.moveView(with: 0)
            }) { [weak self] (finished) in
                self?.isMoving = false
                self?.backgroundView?.isHidden = true
            }
            
            return
            
        default:
            break
        }
        
        if isMoving {
            moveView(with: touchPoint.x - startTouch.x)
        }
        
    }
    
    @objc
    fileprivate func back() {
        _ = popViewController(animated: true)
    }
    
    // MARK: -
    fileprivate func capture() -> UIImage? {
        
        if let topView = topView {
            UIGraphicsBeginImageContextWithOptions(topView.bounds.size, topView.isOpaque, UIScreen.main.scale)
            topView.drawHierarchy(in: topView.bounds, afterScreenUpdates: true)
            topView.layer.contents = nil
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return img
        }
        
        return nil
    }
    
    fileprivate func barButtonItem(with image: UIImage, higlightedImage: UIImage, target: Any, action: Selector) -> UIBarButtonItem {
        let btn = UIButton(type: .custom)
        
        let normal = image
        let higlighted = higlightedImage
        btn.setImage(normal, for: .normal)
        btn.setImage(higlighted, for: .highlighted)
        btn.bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }
    
    fileprivate func moveView(with x: CGFloat) {
        let x = max(0, x > screenWidth ? screenWidth : x)
        
        var frame = topView!.frame
        frame.origin.x = x
        UIApplication.shared.keyWindow!.rootViewController!.view.frame = frame
        
        let alpha = 0.3 - (x / screenWidth * 0.3)
        let scale = (x / screenWidth * 0.05) + 0.95
        
        switch popAnimationType {
        case .liner:
            if let last = lastScreenShotView {
                last.transform = CGAffineTransform(translationX: x * 0.5 - last.center.x, y: 0)
            }
            break
        case .scale:
            if let last = lastScreenShotView {
                last.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            break
        default:
            break
        }
        
        blackMask?.alpha = alpha
    }
}

extension HFNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1 && canIneractive ? true : false
    }
}
