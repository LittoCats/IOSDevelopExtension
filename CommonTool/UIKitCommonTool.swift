//
//  UIKitCommonTool.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/14/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import UIKit

struct ToastPosition: RawOptionSetType{
    typealias RawValue = UInt
    private var value: RawValue = 0x0000
    init(_ value: RawValue) { self.value = value }
    init(rawValue value: RawValue) { self.value = value }
    init(nilLiteral: ()) { self.value = 0x0000 }
    static var allZeros: ToastPosition { return self(0) }
    static func fromMask(raw: RawValue) -> ToastPosition { return self(raw) }
    var rawValue: RawValue { return self.value }
    
    static var top:     ToastPosition {return ToastPosition(0xF000)}
    static var bottom:  ToastPosition {return ToastPosition(0x0F00)}
    static var left:    ToastPosition {return ToastPosition(0x00F0)}
    static var right:   ToastPosition {return ToastPosition(0x000F)}
    
    static var center:    ToastPosition {return .bottom | .left | .right | .top}
    static var bottomCenter:    ToastPosition {return .bottom | .left | .right}
    
    var top:    Bool {return (value & ToastPosition.top.rawValue) == ToastPosition.top.rawValue}
    var bottom: Bool {return (value & ToastPosition.bottom.rawValue) == ToastPosition.bottom.rawValue}
    var left:   Bool {return (value & ToastPosition.left.rawValue) == ToastPosition.left.rawValue}
    var right:  Bool {return (value & ToastPosition.right.rawValue) == ToastPosition.right.rawValue}
}

enum IndicatorStyle {
    case Default
    case Small
    case SizeToFit
}

func |(left: ToastPosition, right: ToastPosition) -> ToastPosition{
    return ToastPosition(rawValue: left.rawValue | right.rawValue)
}

extension UIView {
    
    private struct AssociatedObjectKey {
        static var ToastViewKey = "ToastViewKey"
        static var IndicatorViewKey =  "IndicatorViewKey"
    }
    
    /**
    *  makeToast
    *  如果上一条 toast 尚未消失，则覆盖上一条 toast 的 message / interval，即 toast 的内容及消失时间以最后一次调用为准,如果一条 message 中的一行太长，可能会超出 toast 的显示范围，请在适当的位置换行
    *  @discussion 建议 message 单行长度不超过 32 个英文字符，不超过 4 行
    */
    func makeToast(message: String, position: ToastPosition, interval: NSTimeInterval){
        var toast: ToastView? = objc_getAssociatedObject(self, &AssociatedObjectKey.ToastViewKey) as? UIView.ToastView
        if toast == nil {
            toast = ToastView(frame: CGRectZero)
            objc_setAssociatedObject(self, &AssociatedObjectKey.ToastViewKey, toast, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
            self.addObserver(toast!, forKeyPath: "frame", options: NSKeyValueObservingOptions.Old, context: UnsafeMutablePointer<Void>())
            self.addSubview(toast!)
        }
        toast?.text = message
        toast?.interval = interval
        toast?.position = position
    }
    /**
    *  在 view 上显示一个 activityIndicator
    *  @message    如果存在，将显示在 indicator 下面。多次调用时，显示最后一次的值，隐藏时，设置为 nil
    *  @style      indicator 的大小，多次调用时，以第一次为准
    *  @interval   持续时间，如果 <= 0.0 ，将不直显示，直到调用 hide 方法
    
    *  @discussion 当多次调用时，需调用 hide 方法的次应与  interval <= 0.0 的调用次数相同； interval > 0.0 的多次调用，hide 时间以最晚的结束时间为准，不一定是 inteval 中的最大值。连续调用，位置保持不变
    */
    func showIndicator(message: String?, style: IndicatorStyle = IndicatorStyle.Default, interval: NSTimeInterval = -1){
        var indicator: IndicatorView? = objc_getAssociatedObject(self, &AssociatedObjectKey.IndicatorViewKey) as? UIView.IndicatorView
        if indicator == nil {
            indicator = IndicatorView(frame: self.bounds)
            objc_setAssociatedObject(self, &AssociatedObjectKey.IndicatorViewKey, indicator, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
            self.addObserver(indicator!, forKeyPath: "frame", options: NSKeyValueObservingOptions.Old, context: UnsafeMutablePointer<Void>())
            self.addSubview(indicator!)
        }
        indicator?.message = message
        indicator?.interval = interval
        indicator?.style = style
    }
    /**
    *  隐藏 indicator
    *  @isAll 是否强制隐藏所有的 indicator
    */
    func hideIndicator(anyHow: Bool = false){
        var indicator: IndicatorView? = objc_getAssociatedObject(self, &AssociatedObjectKey.IndicatorViewKey) as? UIView.IndicatorView
        if indicator == nil {return}
        if anyHow {indicator?.serialNum = 0}
        else {indicator?.serialNum = indicator!.serialNum - 1}
    }
    
    /**
    *   扩展 set 方法
    *   返回值均为 self ，实现连续设置属性的 连点 语法
    */
    func set(#alpha: CGFloat)               ->Self{self.alpha = alpha; return self}
    func set(#backgroundColor: UIColor)     ->Self{self.backgroundColor = backgroundColor;return self}
    func set(#bounds: CGRect)               ->Self{self.bounds = bounds ; return self}
    func set(#center: CGPoint)              ->Self{self.center = center; return self}
    func set(#frame: CGRect)                ->Self{self.frame = frame;return self}
    func set(#tag: Int)                     ->Self{self.tag = tag; return self}
    func set(#transform: CGAffineTransform) ->Self{self.transform = transform ; return self}
    func set(#multipleTouchEnabled: Bool)   ->Self{self.multipleTouchEnabled = multipleTouchEnabled ; return self}
    func set(#exclusiveTouch: Bool)         ->Self{self.exclusiveTouch = exclusiveTouch ; return self}
    func set(#userInteractionEnabled: Bool) ->Self{self.userInteractionEnabled = userInteractionEnabled ; return self}
    func set(#contentScaleFactor: CGFloat)  ->Self{self.contentScaleFactor = contentScaleFactor ; return self}
    func set(#clipsToBounds: Bool)          ->Self{self.clipsToBounds = clipsToBounds;return self}
    func set(#opaque: Bool)                 ->Self{self.opaque = opaque; return self}
    func set(#hidden: Bool)                 ->Self{self.hidden = hidden; return self}
    func set(#contentMode:UIViewContentMode)->Self{self.contentMode = contentMode; return self}
    func set(#tintColor: UIColor!)          ->Self{self.tintColor = tintColor; return self}
    func set(#cornerRadius: CGFloat)        ->Self{self.layer.cornerRadius = cornerRadius; return self}
    func set(#borderWidth: CGFloat)         ->Self{self.layer.borderWidth = borderWidth; return self}
    func set(#borderColor: UIColor)         ->Self{self.layer.borderColor = borderColor.CGColor; return self}
    func set(#shadowColor: UIColor)         ->Self{self.layer.shadowColor = shadowColor.CGColor; return self}
    func set(#shadowOpacity: Float)         ->Self{self.layer.shadowOpacity = shadowOpacity; return self}
    func set(#shadowOffset: CGSize)         ->Self{self.layer.shadowOffset = shadowOffset; return self}
    func set(#shadowRadius: CGFloat)        ->Self{self.layer.shadowRadius = shadowRadius; return self}
}

extension UIView {
    final class IndicatorView: UIView {
        var message: String?{
            set{
                messageLabel.text = newValue
            }
            get{
                return messageLabel.text
            }
        }
        var serialNum: Int = 0{
            didSet{
                if serialNum == 0 && self.superview != nil{
                    self.superview!.removeObserver(self, forKeyPath: "frame")
                    objc_setAssociatedObject(self.superview!, &AssociatedObjectKey.IndicatorViewKey, nil, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
                    self.removeFromSuperview()
                }
                if serialNum < oldValue {
                    messageLabel.text = nil
                }
            }
        }
        var interval: NSTimeInterval!{
            didSet{
                serialNum += 1
                if interval <= 0 {return}
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000000000 * interval)), dispatch_get_main_queue()) {
                    [weak self]() -> Void in
                    if self == nil {return}
                    self!.serialNum = self!.serialNum - 1
                }
            }
        }
        var style: IndicatorStyle = .Default{
            didSet{
                if style == oldValue {return}
                if style == .Small{
                    contentTransform = CGAffineTransformMakeScale(0.6, 0.6)
                }else{
                    contentTransform = CGAffineTransformMakeScale(1, 1)
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            defaultInit()
        }

        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            defaultInit()
        }
        
        override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            self.frame = self.superview!.bounds
        }
        
        private var contentView: UIView = UIView(frame: CGRectZero)
        private var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        private var messageLabel: UILabel = UILabel(frame: CGRectZero)
        private var contentTransform: CGAffineTransform = CGAffineTransformMakeScale(1, 1)
        
        private func defaultInit(){
            self.backgroundColor = UIColor.clearColor().colorWithAlphaComponent(0.2)
            contentView.backgroundColor = UIColor.blackColor()
            contentView.opaque = false
            contentView.layer.cornerRadius = 3.5
            contentView.frame = CGRectMake(0, 0, 66, 66)
            messageLabel.backgroundColor = UIColor.blackColor()
            messageLabel.numberOfLines = 1
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.opaque = false
            messageLabel.textColor = UIColor.whiteColor()
            messageLabel.font = UIFont.systemFontOfSize(13)
            
            contentView.addSubview(indicator)
            contentView.addSubview(messageLabel)
            
            self.addSubview(contentView)
            
            indicator.startAnimating()
        }
        
        override func layoutSubviews() {
            contentView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
            if style == .SizeToFit {
                var size: CGFloat = min(self.frame.size.width, self.frame.size.height)
                var scale: CGFloat = size/6/66
                scale = min(1.0, scale)
                contentTransform = CGAffineTransformMakeScale(scale, scale)
            }
            contentView.transform = contentTransform
            messageLabel.sizeToFit()
            indicator.center = CGPointMake(contentView.frame.size.width / contentView.transform.a / 2, contentView.frame.size.height / contentView.transform.d / 2 - 10)
            messageLabel.center = CGPointMake(contentView.frame.size.width / contentView.transform.a / 2, contentView.frame.size.height / contentView.transform.d/2 + indicator.frame.size.height / 2)
        }
    }
}

extension UIView {
    final class ToastView: UILabel {
        var serialNum: Int64 = 0
        var interval: NSTimeInterval = 2.5{
            didSet{
                var num: Int64 = ++self.serialNum
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1000 * 1000 * 1000 * interval)), dispatch_get_main_queue()) {
                    [weak self]() -> Void in
                    if self == nil || num != self!.serialNum {return}
                    objc_setAssociatedObject(self!.superview!, &AssociatedObjectKey.ToastViewKey, nil, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
                    self!.superview!.removeObserver(self!, forKeyPath: "frame")
                    self!.removeFromSuperview()
                }
            }
        }
        var position: ToastPosition!{
            didSet{
                updatePosition()
                if self.superview != nil {
                }
            }
        }
        override var text: String?{
            didSet{
                self.sizeToFit()
            }
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            defaultInit()
        }

        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            defaultInit()
        }
        
        override func sizeThatFits(size: CGSize) -> CGSize {
            var size: CGSize = super.sizeThatFits(size)
            size.width += 7.0
            size.height += 7.0
            return size
        }
        
        override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            updatePosition()
        }
        
        private func defaultInit(){
            self.opaque = false
            self.font = UIFont.systemFontOfSize(13)
            self.textColor = UIColor.whiteColor()
            self.textAlignment = NSTextAlignment.Center
            self.numberOfLines = 0
            self.layer.cornerRadius = 3.5
            self.clipsToBounds = true
            self.backgroundColor = UIColor.blackColor()
        }
        
        // layout
        func updatePosition(){
            if self.superview == nil {return}
            var center: CGPoint = CGPointMake(self.superview!.bounds.size.width / 2, self.superview!.bounds.size.height / 2)
            var dy: CGFloat = center.y - (self.superview!.bounds.size.height / 10 + self.frame.size.height / 2)
            var dx: CGFloat = center.x - (10 + self.frame.size.width / 2)
            if position.top     {center.y = center.y - dy}
            if position.bottom  {center.y = center.y + dy}
            if position.left    {center.x = center.x - dx}
            if position.right   {center.x = center.x + dx}
            self.center = center
        }
    }
}
/****************************************************** UIAlertView ***************************************************************/
extension UIAlertView {
    typealias UIAlertViewDismissHandler = @objc_block(view: UIAlertView, atIndex: Int) -> Void
    convenience init(title: String?, message: String?, cancelButtonTitle: String?, cancelHandler: UIAlertViewDismissHandler? = nil){
        self.init(title: title, message: message, delegate: BlockHandleSharedTarget.self, cancelButtonTitle:cancelButtonTitle)
        if cancelHandler == nil || cancelButtonTitle == nil{return}
        self.blockTable.setObject(unsafeBitCast(cancelHandler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
    }
    
    func add(button buttonTitle: String, handler: UIAlertViewDismissHandler? = nil) ->Self{
        self.addButtonWithTitle(buttonTitle)
        if handler != nil {
            self.blockTable.setObject(unsafeBitCast(handler!, AnyObject.self), forKey: String(self.numberOfButtons - 1))
        }
        return self
    }
    
    @objc private class BlockHandleSharedTarget: NSObject, UIAlertViewDelegate {
        @objc class func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int){
            var blockObject: AnyObject? = alertView.blockTable.objectForKey(String(buttonIndex))
            if blockObject == nil {return}
            var block = unsafeBitCast(blockObject, UIAlertViewDismissHandler.self)
            block(view: alertView, atIndex: buttonIndex)
        }
    }
    private var blockTable: NSMapTable{
        get{
            var table = objc_getAssociatedObject(self, &BlockHandle.BlockTableKey) as? NSMapTable
            if table == nil {
                table = NSMapTable.strongToStrongObjectsMapTable()
                objc_setAssociatedObject(self, &BlockHandle.BlockTableKey, table, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
            return table!
        }
    }
    private struct BlockHandle {
        static var BlockTableKey = "BlockTableKey"
    }
}

/****************************************************** UIControl ***************************************************************/
extension UIControl {
    typealias UIControlBlockHandler = @objc_block (sender: UIControl/* UIControl or subClass*/, event: UIControlEvents) ->Void
    /**
    *  为 events 添加 block 事件
    *  @discussion if block is nil , events handler will be removed if exist
    */
    func handle(#events: UIControlEvents, withBlock block: UIControlBlockHandler?) ->Self {
        var nameArr = BlockHandleSharedTarget.names(events: events)
        var table = blockTable
        for name in nameArr{
            table.removeObjectForKey(name)
            self.removeTarget(BlockHandleSharedTarget.self, action: Selector(name+":"), forControlEvents: BlockHandle.eventsTable[name]!)
            if block != nil {
                table.setObject(unsafeBitCast(block, AnyObject.self), forKey: name)
                self.addTarget(BlockHandleSharedTarget.self, action: Selector(name+":"), forControlEvents: BlockHandle.eventsTable[name]!)
            }
        }
        return self
    }
    
    private var blockTable: NSMapTable {
        get{
            var table = objc_getAssociatedObject(self, &BlockHandle.BlockTableKey) as? NSMapTable
            if table == nil {
                table = NSMapTable.strongToStrongObjectsMapTable()
                objc_setAssociatedObject(self, &BlockHandle.BlockTableKey, table, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            }
            return table!
        }
    }
    
    private struct BlockHandle {
        static var onceToken: dispatch_once_t = 0
        static var BlockTableKey = "BlockTableKey"
        static let eventsTable = [
            "TouchDown"         :UIControlEvents.TouchDown,
            "TouchDownRepeat"   :UIControlEvents.TouchDownRepeat,
            "TouchDragInside"   :UIControlEvents.TouchDragInside,
            "TouchDragOutside"  :UIControlEvents.TouchDragOutside,
            "TouchDragEnter"    :UIControlEvents.TouchDragEnter,
            "TouchDragExit"     :UIControlEvents.TouchDragExit,
            "TouchUpInside"     :UIControlEvents.TouchUpInside,
            "TouchUpOutside"    :UIControlEvents.TouchUpOutside,
            "TouchCancel"       :UIControlEvents.TouchCancel,
            "ValueChanged"      :UIControlEvents.ValueChanged,
            "EditingDidBegin"   :UIControlEvents.EditingDidBegin,
            "EditingChanged"    :UIControlEvents.EditingChanged,
            "EditingDidEnd"     :UIControlEvents.EditingDidEnd,
            "EditingDidEndOnExit":UIControlEvents.EditingDidEndOnExit
        ]
        static var handler: BlockHandleSharedTarget!
    }
    @objc private final class  BlockHandleSharedTarget: NSObject {
        class func names(#events: UIControlEvents) ->[String]{
            var nameArr = [String]()
            for item in BlockHandle.eventsTable {
                if events & item.1 == item.1 {
                    nameArr.append(item.0)
                }
            }
            return nameArr
        }
        class func handle(#event: String, sender: UIControl)->Void{
            var blockObject: AnyObject? = sender.blockTable.objectForKey(event)
            if blockObject == nil {return}
            var block = unsafeBitCast(blockObject, UIControlBlockHandler.self)
            block(sender: sender, event: BlockHandle.eventsTable[event]!)
        }
        
        @objc class func TouchDown              (sender: UIControl)->Void{handle(event: "TouchDown", sender: sender)}
        @objc class func TouchDownRepeat        (sender: UIControl)->Void{handle(event: "TouchDownRepeat", sender: sender)}
        @objc class func TouchDragInside        (sender: UIControl)->Void{handle(event: "TouchDragInside", sender: sender)}
        @objc class func TouchDragOutside       (sender: UIControl)->Void{handle(event: "TouchDragOutside", sender: sender)}
        @objc class func TouchDragEnter         (sender: UIControl)->Void{handle(event: "TouchDragEnter", sender: sender)}
        @objc class func TouchDragExit          (sender: UIControl)->Void{handle(event: "TouchDragExit", sender: sender)}
        @objc class func TouchUpInside          (sender: UIControl)->Void{handle(event: "TouchUpInside", sender: sender)}
        @objc class func TouchUpOutside         (sender: UIControl)->Void{handle(event: "TouchUpOutside", sender: sender)}
        @objc class func TouchCancel            (sender: UIControl)->Void{handle(event: "TouchCancel", sender: sender)}
        @objc class func ValueChanged           (sender: UIControl)->Void{handle(event: "ValueChanged", sender: sender)}
        @objc class func EditingDidBegin        (sender: UIControl)->Void{handle(event: "EditingDidBegin", sender: sender)}
        @objc class func EditingChanged         (sender: UIControl)->Void{handle(event: "EditingChanged", sender: sender)}
        @objc class func EditingDidEnd          (sender: UIControl)->Void{handle(event: "EditingDidEnd", sender: sender)}
        @objc class func EditingDidEndOnExit    (sender: UIControl)->Void{handle(event: "EditingDidEndOnExit", sender: sender)}
    }
}
/****************************************************** UIButton ***************************************************************/
extension UIButton {
    func set(#title: String?, forState state: UIControlState)
        ->Self{self.setTitle(title, forState: state);return self}
    func set(#titleColor: UIColor?, forState state: UIControlState)
        ->Self{self.setTitleColor(titleColor, forState: state) ;return self}
    func set(#titleShadowColor: UIColor?, forState state: UIControlState)
        ->Self{self.setTitleShadowColor(titleShadowColor, forState: state);return self}
    func set(#image: UIImage?, forState state: UIControlState)
        ->Self{self.setImage(image, forState: state) ;return self}
    func set(#backgroundImage: UIImage?, forState state: UIControlState)
        ->Self{self.setBackgroundImage(backgroundImage, forState: state) ;return self}
    func set(#attributedTitle: NSAttributedString!, forState state: UIControlState)
        ->Self{self.setAttributedTitle(attributedTitle, forState: state) ;return self}
}
/****************************************************** UILabel ***************************************************************/
extension UILabel {
    func set(#text: String?)                    ->Self{self.text = text; return self}
    func set(#font: UIFont!)                    ->Self{self.font = font; return self}
    func set(#textColor: UIColor!)              ->Self{self.textColor = textColor; return self}
    func set(#textAlignment: NSTextAlignment)   ->Self{self.textAlignment = textAlignment; return self}
    func set(#lineBreakMode: NSLineBreakMode)   ->Self{self.lineBreakMode = lineBreakMode; return self}
    func set(#attributedText:NSAttributedString)->Self{self.attributedText = attributedText; return self}
    func set(#numberOfLines: Int)               ->Self{self.numberOfLines = numberOfLines; return self}
    override func set(#shadowColor: UIColor?)   ->Self{self.shadowColor = shadowColor; return self}
    override func set(#shadowOffset: CGSize)    ->Self{self.shadowOffset = shadowOffset; return self}
    
}
/****************************************************** UITableView ***************************************************************/
extension UITableView {
    func set(#dataSource: UITableViewDataSource?)   ->Self{self.dataSource = dataSource; return self}
    func set(#delegate: UITableViewDelegate?)       ->Self{self.delegate = delegate; return self}
    func set(#backgroundView: UIView?)              ->Self{self.backgroundView = backgroundView; return self}
    func set(#separatorStyle: UITableViewCellSeparatorStyle)    ->Self{self.separatorStyle = separatorStyle; return self}
    func set(#separatorColor: UIColor!)             ->Self{self.separatorColor = separatorColor; return self}
}

/****************************************************** UIScrollView ***************************************************************/
@objc protocol UIScrollViewPreOrSuffixViewProtocol: NSObjectProtocol {
    optional func prefix(#view: UIView, didMove offset: CGFloat)
    optional func suffix(#view: UIView, didMove offset: CGFloat)
}
extension UIScrollView {
    private struct PSFixDefine {
        static var PrefixViewKey    = "PrefixViewKey"
        static var SuffixViewKey    = "SuffixViewKey"
        static var PreSufTargetKey  = "PreSufTargetKey"
    }
    // prefixView 需实现 UIScrollViewPreOrSuffixViewProtocol
    var prefixView: UIView?{
        get{
            return objc_getAssociatedObject(self, &PSFixDefine.PrefixViewKey) as? UIView
        }
        set{
            if prefixView == newValue {return}
            self.prefixView?.removeFromSuperview()
            objc_setAssociatedObject(self, &PSFixDefine.PrefixViewKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            if newValue != nil {self.PreSufTarget}
        }
    }
    var suffixView: UIView?{
        get{
            return objc_getAssociatedObject(self, &PSFixDefine.SuffixViewKey) as? UIView
        }
        set{
            if suffixView == newValue {return}
            self.suffixView?.removeFromSuperview()
            objc_setAssociatedObject(self, &PSFixDefine.SuffixViewKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            if newValue != nil {self.PreSufTarget}
        }
    }
    
    private var PreSufTarget: UIScrollViewPreSufTarget{
        get{
            var instance: UIScrollViewPreSufTarget? = objc_getAssociatedObject(self, &PSFixDefine.PreSufTargetKey) as? UIScrollViewPreSufTarget
            if instance == nil {
                instance = UIScrollViewPreSufTarget(scrollView: self)
                objc_setAssociatedObject(self, &PSFixDefine.PreSufTargetKey, instance, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
            return instance!
        }
    }
    
    final private class UIScrollViewPreSufTarget: NSObject {
        weak var scrollView: UIScrollView? {
            didSet{
                oldValue?.removeObserver(self, forKeyPath: "contentOffset")
                scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.Old, context: UnsafeMutablePointer<Void>())
            }
        }
        init(scrollView: UIScrollView){
            super.init()
            self.scrollView = scrollView
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.Old, context: UnsafeMutablePointer<Void>())
        }
        private override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            if scrollView!.contentOffset.y < 0 && scrollView!.prefixView != nil{
                if scrollView!.prefixView!.superview == nil {
                    var frame: CGRect = scrollView!.prefixView!.bounds
                    frame.origin.y = 0 - frame.size.height
                    scrollView!.prefixView!.frame = frame
                    scrollView!.addSubview(scrollView!.prefixView!)
                }
                (scrollView?.prefixView as? UIScrollViewPreOrSuffixViewProtocol)?.prefix?(view: scrollView!.prefixView!, didMove: 0 - scrollView!.contentOffset.y)
            }else{
                scrollView!.prefixView?.removeFromSuperview()
            }
            
            if scrollView!.contentOffset.y > scrollView!.contentSize.height && scrollView!.suffixView != nil{
                if scrollView!.prefixView!.superview == nil {
                    var frame: CGRect = scrollView!.suffixView!.bounds
                    frame.origin.y = scrollView!.contentSize.height
                    scrollView!.suffixView!.frame = frame
                    scrollView!.addSubview(scrollView!.suffixView!)
                }
                (scrollView?.suffixView as? UIScrollViewPreOrSuffixViewProtocol)?.prefix?(view: scrollView!.suffixView!, didMove: scrollView!.contentOffset.y - scrollView!.contentSize.height)
            }else{
                scrollView!.suffixView?.removeFromSuperview()
            }
        }
    }
    
    // setter
    func set(#prefixView: UIView?)      ->Self{self.prefixView = prefixView; return self}
    func set(#suffixView: UIView?)      ->Self{self.prefixView = suffixView; return self}
}

extension UIScrollView {
    func set(#contentSize: CGSize)                      ->Self{self.contentSize = contentSize; return self}
    func set(#contentOffset: CGPoint)                   ->Self{self.contentOffset = contentOffset; return self}
    func set(#pagingEnabled: Bool)                      ->Self{self.pagingEnabled = pagingEnabled; return self}
    func set(#scrollEnabled: Bool)                      ->Self{self.scrollEnabled = scrollEnabled; return self}
    func set(#showsHorizontalScrollIndicator: Bool)     ->Self{self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator; return self}
    func set(#showsVerticalScrollIndicator: Bool)       ->Self{self.showsVerticalScrollIndicator = showsVerticalScrollIndicator; return self}
    func set(#indicatorStyle:UIScrollViewIndicatorStyle)->Self{self.indicatorStyle = indicatorStyle; return self}
    func set(#decelerationRate: CGFloat)                ->Self{self.decelerationRate = decelerationRate; return self}
}

/****************************************************** UIColor ***************************************************************/

extension UIColor {
    convenience init(script: String){
        if script.hasPrefix("#"){
            self.init(hex: script)
        }else{
            self.init(name: script)
        }
    }
    convenience init(hex: String){
        var hexStr: NSString = hex.substringFromIndex(advance(hex.startIndex, 1))
        if hexStr.rangeOfString("[^0-9A-Fa-f]", options: NSStringCompareOptions.RegularExpressionSearch).location != NSNotFound {
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            return
        }
        var valueArr = ["F","F","F","F","F","F","F","F",]
        if hexStr.length <= 4{
            for (var i = 0; i < hexStr.length && i < 4; i++){
                valueArr[i * 2] = hexStr.substringWithRange(NSMakeRange(i, 1))
                valueArr[i * 2 + 1] = hexStr.substringWithRange(NSMakeRange(i, 1))
            }
        }else{
            for (var i = 0; i < hexStr.length && i < 4; i++){
                valueArr[i] = hexStr.substringWithRange(NSMakeRange(i, 1))
            }
        }
        let red     = CGFloat(SS.HEXTable[valueArr[0]]! << 4 | SS.HEXTable[valueArr[1]]!)
        let green   = CGFloat(SS.HEXTable[valueArr[2]]! << 4 | SS.HEXTable[valueArr[3]]!)
        let blue    = CGFloat(SS.HEXTable[valueArr[4]]! << 4 | SS.HEXTable[valueArr[5]]!)
        let alpha   = CGFloat(SS.HEXTable[valueArr[6]]! << 4 | SS.HEXTable[valueArr[7]]!)
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: alpha/255)
    }
    convenience init(name: String){
        var range: NSRange = SS.libColor.rangeOfString("@\(name.uppercaseString)#[0-9A-F]{6}", options: NSStringCompareOptions.RegularExpressionSearch)
        if range.location == NSNotFound {
            self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else{
            var hex: NSString = SS.libColor.substringWithRange(range)
            hex = hex.substringWithRange(NSMakeRange(hex.length - 7, 7))
            self.init(hex: hex)
        }
    }
    
    class func Random(){
        self.init(red: CGFloat(arc4random() % 256 / 255), green: CGFloat(arc4random() % 256 / 255), blue: CGFloat(arc4random() % 256 / 255), alpha: CGFloat(arc4random() % 256 / 255))
    }
    
    class func color(#script: String) ->UIColor {
        var color: UIColor? = SS.Cache.objectForKey(script) as? UIColor
        if color == nil {
            color = UIColor(script: script)
            SS.Cache.setObject(color!, forKey: script)
        }
        return color!
    }
    
    // static source
    private struct SS {
        private static let HEXTable: [String: UInt32] = ["0":0,"1":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,"A":10,"a":10,"B":11,"b":11,"C":12,"c":12,"D":13,"d":13,"E":14,"e":14,"F":15,"f":15]
        private static let libColor: NSString = "@LIGHTPINK#FFB6C1(浅粉色)-@PINK#FFC0CB(粉红)-@CRIMSON#DC143C(猩红)-@LAVENDERBLUSH#FFF0F5(脸红的淡紫色)-@PALEVIOLETRED#DB7093(苍白的紫罗兰红色)-@HOTPINK#FF69B4(热情的粉红)-@DEEPPINK#FF1493(深粉色)-@MEDIUMVIOLETRED#C71585(适中的紫罗兰红色)-@ORCHID#DA70D6(兰花的紫色)-@THISTLE#D8BFD8(蓟)-@PLUM#DDA0DD(李子)-@VIOLET#EE82EE(紫罗兰)-@MAGENTA#FF00FF(洋红)-@FUCHSIA#FF00FF(灯笼海棠（紫红色）)-@DARKMAGENTA#8B008B(深洋红色)-@PURPLE#800080(紫色)-@MEDIUMORCHID#BA55D3(适中的兰花紫)-@DARKVOILET#9400D3(深紫罗兰色)-@DARKORCHID#9932CC(深兰花紫)-@INDIGO#4B0082(靛青)-@BLUEVIOLET#8A2BE2(深紫罗兰的蓝色)-@MEDIUMPURPLE#9370DB(适中的紫色)-@MEDIUMSLATEBLUE#7B68EE(适中的板岩暗蓝灰色)-@SLATEBLUE#6A5ACD(板岩暗蓝灰色)-@DARKSLATEBLUE#483D8B(深岩暗蓝灰色)-@LAVENDER#E6E6FA(薰衣草花的淡紫色)-@GHOSTWHITE#F8F8FF(幽灵的白色)-@MEDIUMBLUE#0000CD(适中的蓝色)-@MIDNIGHTBLUE#191970(午夜的蓝色)-@DARKBLUE#00008B(深蓝色)-@NAVY#000080(海军蓝)-@ROYALBLUE#4169E1(皇军蓝)-@CORNFLOWERBLUE#6495ED(矢车菊的蓝色)-@LIGHTSTEELBLUE#B0C4DE(淡钢蓝)-@LIGHTSLATEGRAY#778899(浅石板灰)-@SLATEGRAY#708090(石板灰)-@DODERBLUE#1E90FF(道奇蓝)-@ALICEBLUE#F0F8FF(爱丽丝蓝)-@STEELBLUE#4682B4(钢蓝)-@LIGHTSKYBLUE#87CEFA(淡蓝色)-@SKYBLUE#87CEEB(天蓝色)-@DEEPSKYBLUE#00BFFF(深天蓝)-@LIGHTBLUE#ADD8E6(淡蓝)-@POWDERBLUE#B0E0E6(火药蓝)-@CADETBLUE#5F9EA0(军校蓝)-@AZURE#F0FFFF(蔚蓝色)-@LIGHTCYAN#E1FFFF(淡青色)-@PALETURQUOISE#AFEEEE(苍白的绿宝石)-@CYAN#00FFFF(青色)-@AQUA#00FFFF(水绿色)-@DARKTURQUOISE#00CED1(深绿宝石)-@DARKSLATEGRAY#2F4F4F(深石板灰)-@DARKCYAN#008B8B(深青色)-@TEAL#008080(水鸭色)-@MEDIUMTURQUOISE#48D1CC(适中的绿宝石)-@LIGHTSEAGREEN#20B2AA(浅海洋绿)-@TURQUOISE#40E0D0(绿宝石)-@AUQAMARIN#7FFFAA(绿玉/碧绿色)-@MEDIUMAQUAMARINE#00FA9A(适中的碧绿色)-@MEDIUMSPRINGGREEN#F5FFFA(适中的春天的绿色)-@MINTCREAM#00FF7F(薄荷奶油)-@SPRINGGREEN#3CB371(春天的绿色)-@SEAGREEN#2E8B57(海洋绿)-@HONEYDEW#F0FFF0(蜂蜜)-@LIGHTGREEN#90EE90(淡绿色)-@PALEGREEN#98FB98(苍白的绿色)-@DARKSEAGREEN#8FBC8F(深海洋绿)-@LIMEGREEN#32CD32(酸橙绿)-@LIME#00FF00(酸橙色)-@FORESTGREEN#228B22(森林绿)-@DARKGREEN#006400(深绿色)-@CHARTREUSE#7FFF00(查特酒绿)-@LAWNGREEN#7CFC00(草坪绿)-@GREENYELLOW#ADFF2F(绿黄色)-@OLIVEDRAB#556B2F(橄榄土褐色)-@BEIGE#6B8E23(米色（浅褐色）)-@LIGHTGOLDENRODYELLOW#FAFAD2(浅秋麒麟黄)-@IVORY#FFFFF0(象牙色)-@LIGHTYELLOW#FFFFE0(浅黄色)-@OLIVE#808000(橄榄)-@DARKKHAKI#BDB76B(深卡其布)-@LEMONCHIFFON#FFFACD(柠檬薄纱)-@PALEGODENROD#EEE8AA(灰秋麒麟)-@KHAKI#F0E68C(卡其布)-@GOLD#FFD700(金)-@CORNISLK#FFF8DC(玉米色)-@GOLDENROD#DAA520(秋麒麟)-@FLORALWHITE#FFFAF0(花的白色)-@OLDLACE#FDF5E6(老饰带)-@WHEAT#F5DEB3(小麦色)-@MOCCASIN#FFE4B5(鹿皮鞋)-@ORANGE#FFA500(橙色)-@PAPAYAWHIP#FFEFD5(番木瓜)-@BLANCHEDALMOND#FFEBCD(漂白的杏仁)-@NAVAJOWHITE#FFDEAD(NAVAJO白)-@ANTIQUEWHITE#FAEBD7(古代的白色)-@TAN#D2B48C(晒黑)-@BRULYWOOD#DEB887(结实的树)-@BISQUE#FFE4C4(（浓汤）乳脂，番茄等)-@DARKORANGE#FF8C00(深橙色)-@LINEN#FAF0E6(亚麻布)-@PERU#CD853F(秘鲁)-@PEACHPUFF#FFDAB9(桃色)-@SANDYBROWN#F4A460(沙棕色)-@CHOCOLATE#D2691E(巧克力)-@SADDLEBROWN#8B4513(马鞍棕色)-@SEASHELL#FFF5EE(海贝壳)-@SIENNA#A0522D(黄土赭色)-@LIGHTSALMON#FFA07A(浅鲜肉（鲑鱼）色)-@CORAL#FF7F50(珊瑚)-@ORANGERED#FF4500(橙红色)-@DARKSALMON#E9967A(深鲜肉（鲑鱼）色)-@TOMATO#FF6347(番茄)-@MISTYROSE#FFE4E1(薄雾玫瑰)-@SALMON#FA8072(鲜肉（鲑鱼）色)-@SNOW#FFFAFA(雪)-@LIGHTCORAL#F08080(淡珊瑚色)-@ROSYBROWN#BC8F8F(玫瑰棕色)-@INDIANRED#CD5C5C(印度红)-@BROWN#A52A2A(棕色)-@FIREBRICK#B22222(耐火砖)-@DARKRED#8B0000(深红色)-@MAROON#800000(栗色)-@WHITESMOKE#F5F5F5(白烟)-@GAINSBORO#DCDCDC(GAINSBORO)-@SILVER#C0C0C0(银白色)-@DIMGRAY#696969(暗淡的灰色)"
        private static let Cache: NSCache = NSCache()
    }
}