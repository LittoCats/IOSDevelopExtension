# IOS Develop Common Tool

重新使用 swift 整理的 IOS 开发过程中常用的工具，主要是对 UIKit 及 Foundation 中类的扩展。

### 主要内容

* 主要属性的设置实现级连
* UIControl/UIAlertView 的事件使用 closures
* UIScroll 添加 prefixview/suffixView
* UIColor 添加 script 方法

#### 属性设置

```
var button: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
button.set(backgroundColor: UIColor.lightGrayColor())
	.set(cornerRadius: 3.5)
	.set(center: CGPointMake(100, 300))
	.set(clipsToBounds: true)
	.set(title: "Block Control", forState: UIControlState.Normal)
	.sizeToFit()
```

#### closures 用于事件回调

对于一些简单的场境中，使 closures 更方便

```
UIAlertView(title: nil, message: "Alert with colusure", cancelButtonTitle: "Cancel")
	.add(button: "Confirm", handler: { (view, atIndex) -> Void in
                    println("Message from alertview with colusure control")
                })
	.add(button: "Yes", handler: { (view, atIndex) -> Void in
                    println("\(atIndex)")
                })
	.show()
```


*** 代码使用比较简单，其它的暂不做使用说明 ***