在网上看到的UI效果
模仿写了Swift版本
[github地址](https://github.com/huberyhx/HXJellyView.git)
效果图:
![gif.gif](http://upload-images.jianshu.io/upload_images/2954364-d2c9074c2954be99.gif?imageMogr2/auto-orient/strip)
- View的使用:
```swift
        //创建
        let jellyView = HXJellyView()
        jellyView.frame = CGRect.init(x: 0, y: 0, width: Main_Width, height: Main_Height)
        //添加
        view.addSubview(jellyView)
```
- 实现方法:
 - 控件包括两个子控件
一个是红色Layer(CAShapeLayer)
一个是紫色view
 - CAShapeLayer使用UIBezierPath描述
紫色View作为UIBezierPath的控制点:
![示意图](http://upload-images.jianshu.io/upload_images/2954364-275da6aa61136448.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 - 为控件添加手势
紫色点根据手势的移动而移动
紫色点位置改变,控制点也就被改变了,UIBezierPath就变了,进而改变了CAShapeLayer
 - 松开手后,使用UIView动画做弹性动画
- 代码:
 - 监听属性,添加手势
```swift
    //创建属性(控制点的X和Y)
    dynamic var curveX : CGFloat = 0.0
    dynamic var curveY : CGFloat = 0.0
   //使用KVO监听这两个属性
    override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: "curveX", options: NSKeyValueObservingOptions.new, context: nil)
        addObserver(self, forKeyPath: "curveY", options: NSKeyValueObservingOptions.new, context: nil)
        //添加手势
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(HXJellyView.handlePanAction))
        addGestureRecognizer(pan)
}
```
 - 根据手势移动让紫色View执行动画,并改变监听属性
```swift
func handlePanAction(){
        if isAnimating {
            return
        }
        //手势在移动的时候
        if pan.state == UIGestureRecognizerState.changed {
            //相对于初始触点位置
            let point = pan.translation(in: self)
            //让紫色点跟着手势走
            mHeight = point.y + Min_Height
           //改变监听属性的值
            curveX = point.x + Main_Width * 0.5
            curveY = mHeight > Min_Height ? mHeight : Min_Height
            curveView.frame = CGRect(x: curveX, y: curveY, width: 6, height: 6 )
        }
        //手松开的时候 做回弹动画
        else if pan.state == UIGestureRecognizerState.ended || pan.state == UIGestureRecognizerState.cancelled||pan.state == UIGestureRecognizerState.failed{
            isAnimating = true
            //松开手了,打开计时器,做弹性动画
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
```
 - 手势移动的时候,监听属性被改变了,重新计算Path
```swift
    //改变path
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "curveX" || keyPath == "curveY" {
            let path = UIBezierPath.init()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: Main_Width, y: 0))
            path.addLine(to: CGPoint(x: Main_Width, y: Min_Height))
            path.addQuadCurve(to: CGPoint(x: 0, y: Min_Height), controlPoint: CGPoint(x: curveX, y: curveY))
            path.close()
            shapeLayer.path = path.cgPath
        }
}
```
 - 松开手的时候,计时器被打开,紫色额View在做弹性动画,同时也要更改监听属性,让Path也相应作出改变
```swift
    //计算路径
    func calculatePath(){
        //动画开始时 presentation layer开始移动，原始layer隐藏，动画结束时，presentation layer从屏幕上移除，原始layer显示
        //所以移动的是presentation layer
        let layer = curveView.layer.presentation()
        curveX = (layer?.position.x)!
        curveY = (layer?.position.y)!
    }
```

谢谢阅读
有不合适的地方请指教
喜欢请点个赞
抱拳了!
