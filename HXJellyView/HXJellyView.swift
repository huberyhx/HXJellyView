//
//  HXJellyView.swift
//  HXJellyView
//
//  Created by hubery on 2017/6/5.
//  Copyright © 2017年 hubery. All rights reserved.
//

import UIKit

let Main_Height = UIScreen.main.bounds.height
let Main_Width = UIScreen.main.bounds.width
let Min_Height : CGFloat = 100.0

class HXJellyView: UIView {
    //属性
    dynamic var curveX : CGFloat = 0.0
    dynamic var curveY : CGFloat = 0.0
    var mHeight : CGFloat = 100.0
    var isAnimating = false
    
    //懒加载
    lazy var curveView: UIView = {
        self.curveX = Main_Width / 2.0 - 3
        self.curveY = self.mHeight
        let view = UIView.init(frame: CGRect.init(x: self.curveX, y:self.curveY , width: 6, height: 6))
        view.backgroundColor = UIColor.purple
        return view
    }()
    lazy var shapeLayer : CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.fillColor = UIColor.red.cgColor
        return layer
    }()
    lazy var displayLink : CADisplayLink = {
        let link = CADisplayLink.init(target: self, selector: #selector(HXJellyView.calculatePath))
        link.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        return link
    }()
    lazy var pan : UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(HXJellyView.handlePanAction))
        return pan
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //KVO
        addObserver(self, forKeyPath: "curveX", options: NSKeyValueObservingOptions.new, context: nil)
        addObserver(self, forKeyPath: "curveY", options: NSKeyValueObservingOptions.new, context: nil)
        //添加layer
        layer.addSublayer(shapeLayer)
        //暂停计时器
        displayLink.isPaused = true
        //添加手势
        addGestureRecognizer(pan)
        //添加控制点(紫色view)
        addSubview(curveView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: "curveX")
        removeObserver(self, forKeyPath: "curveY")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "curveX" || keyPath == "curveY" {
            updateShapeLayerPath()
        }
    }
    //改变path
    func updateShapeLayerPath(){
        let path = UIBezierPath.init()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: Main_Width, y: 0))
        path.addLine(to: CGPoint(x: Main_Width, y: Min_Height))
        path.addQuadCurve(to: CGPoint(x: 0, y: Min_Height), controlPoint: CGPoint(x: curveX, y: curveY))
        path.close()
        shapeLayer.path = path.cgPath
    }
    
    //计算路径
    func calculatePath(){
        let layer = curveView.layer.presentation()
        curveX = (layer?.position.x)!
        curveY = (layer?.position.y)!
    }
    
    func handlePanAction(){
        if isAnimating {
            return
        }
        if pan.state == UIGestureRecognizerState.changed {
            //相对于初始触点位置
            let point = pan.translation(in: self)
            //相对于self
//            let point = pan.location(in: self)
            //让红点跟着手势走
            mHeight = point.y + Min_Height
            curveX = point.x + Main_Width * 0.5
            curveY = mHeight > Min_Height ? mHeight : Min_Height
            curveView.frame = CGRect(x: curveX, y: curveY, width: 6, height: 6 )
            
        }else if pan.state == UIGestureRecognizerState.ended || pan.state == UIGestureRecognizerState.cancelled||pan.state == UIGestureRecognizerState.failed{
            isAnimating = true
            displayLink.isPaused = false
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: {
                            //让紫色点产生弹簧效果,路径跟着黄点走
                            self.curveView.frame = CGRect(x: Main_Width * 0.5 - 3.0, y: Min_Height, width: 6, height: 6)
            }, completion: { (finished) in
                print(finished)
                if finished{
                    self.displayLink.isPaused = true
                    self.isAnimating = false
                }
            })
        }
        
        
    }
    
    
}
