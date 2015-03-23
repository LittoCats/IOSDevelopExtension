//
//  FoundationExtension.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/16/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import JavaScriptCore

/****************************************************** NSDate ***************************************************************/
/**
*  NSDate 与字符串的格式化转换
e.g.   2014-10-19 23:58:59:345
yyyy    : 2014			//年
YYYY    ; 2014			//年
MM      : 10			//年中的月份  1〜12
dd      : 19			//当月中的第几天 1〜31
DD      : 292			//当年中的第几天	1〜366
hh      : 11			//当天中的小时 12 进制 1〜12
HH      : 23			//当天中的小时 24 进制 0 〜 23
mm      : 58			//当前小时中的分钟 0 〜 59
ss      : 59			//当前分钟中的秒数 0 〜 59
SSS     : 345			//当前秒中的耗秒数 0 〜 999
a       : PM			//表示上下午 AM 上午 PM 下午
A       : 86339345		//当天中已经过的耗秒数
t       : 				//普通字符无意义，通常用作日期与时间的分隔
T       : 				//普通字符无意义，通常用作日期与时间的分隔
v       : China Time	//时间名
V       : cnsha		//时间名缩写
w       : 43			//当年中的第几周	星期天为周的开始
W       : 4 			//当月中的第几周 星期天为周的开始
F       : 3 			//当月中的第几周 星期一为周的开始
x		: +08			//表示当前时区
x 		: +08			//表示当前时区
*/
extension NSDate {
    convenience init?(script: NSString, format: NSString = "yyyy-MM-dd HH:mm:ss", lunar: Bool = false){
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        var temp = dateFormatter.dateFromString(script)
        if temp == nil {self.init();return nil}
        if lunar {
            var lunarComponent = LunarComponent(solarYear: temp!.string(format: "yyyy").toInt()!, month: temp!.string(format: "MM").toInt()!, day: temp!.string(format: "dd").toInt()!)
            if lunarComponent.info == nil {self.init();return nil}
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            temp = dateFormatter.dateFromString(NSString(format: "%.4i-%.2i-%.2i", lunarComponent.solarYear, lunarComponent.solarMonth, lunarComponent.solarDay))
        }
        self.init(timeIntervalSinceReferenceDate: temp!.timeIntervalSinceReferenceDate)
        objc_setAssociatedObject(temp!, &LunarComponent.Lib.LunarComponentKey, lunarComponent, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    
    func string(#format: String) ->String{
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    /**
    *   第一次使用 LunarComponent 之前必须先调用 LunarComponent.externalInit
    **/
    var lunarComponent: LunarComponent {
        get{
            var component: LunarComponent? = objc_getAssociatedObject(self, &LunarComponent.Lib.LunarComponentKey) as? LunarComponent
            if component == nil{
                component = LunarComponent(solarYear: self.string(format: "yyyy").toInt()!, month: self.string(format: "MM").toInt()!, day: self.string(format: "dd").toInt()!)
                objc_setAssociatedObject(self, &LunarComponent.Lib.LunarComponentKey, component, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
            return component!
        }
    }
}
extension NSDate {
    class LunarComponent {
        private var info: NSDictionary!
        // 农历年、月、日初始化
        private init(lunarYear year: Int, month: Int, day: Int){
            var info = Lib.context.evaluateScript("SuperCalendar.lunar2solar(\(year),\(month),\(day))")
            if info.isObject() {
                self.info = info.toDictionary()
            }
        }
        // 农历年、月、日初始化
        private init(solarYear year: Int, month: Int, day: Int){
            var info = Lib.context.evaluateScript("SuperCalendar.solar2lunar(\(year),\(month),\(day))")
            if info.isObject() {self.info = info.toDictionary()}
        }
        
        //  公历
        var solarYear: Int{return info.objectForKey("SolarYear") as Int}
        var solarMonth: Int{return info.objectForKey("SolarMonth") as Int}
        var solarDay: Int{return info.objectForKey("SolarDay") as Int}
        // 农历 年
        var lunarYear: Int{return info.objectForKey("LunarYear") as Int}
        var lunarMonth: Int{return info.objectForKey("LunarMonth") as Int}
        var lunarDay: Int{return info.objectForKey("LunarDay") as Int}
        var lunarMonthCN: String{return info.objectForKey("LunarMonthCN") as String}
        var lunarDayCN: String{return info.objectForKey("LunarDayCN") as String}
        // 是否为闰月
        var isLeapMonth: Bool{return info.objectForKey("isLeapMonth") as Bool}
        //  干支
        var gzYear: String{return info.objectForKey("GZYear") as String}
        var gzMonth: String{return info.objectForKey("GZMonth") as String}
        var gzDay: String{return info.objectForKey("GZDay") as String}
        //  属相
        var animal: String{return info.objectForKey("AnimalCN") as String}
        var week: Int{return info.objectForKey("Week") as Int}
        var weekCN: String{return info.objectForKey("WeekNameCN") as String}
        //  是否是节气
        var isSolarTerm: Bool{return info.objectForKey("isSolarTerm") as Bool}
        //  节气名
        var solarTerm: String{return info.objectForKey("SolarTermCN") as String}
        //  是否是今天
        var isToday: Bool{return info.objectForKey("isToday") as Bool}
        // 星座
        var astronomy: String{return info.objectForKey("AstronomyCN") as String}
        
        var description: String{
            var error: NSError?
            return NSString(data: NSJSONSerialization.dataWithJSONObject(self.info, options: NSJSONWritingOptions.PrettyPrinted, error: &error)!, encoding: NSUTF8StringEncoding)!
        }
        /**
        *   第一次使用 LunarComponent 之前必须先调用该方法
        *   如果该 extension 单独使用，需修改这个方法的实现，将 javascript 库载入
        */
        class func externalInit(#context: JSContext?){
            dispatch_once(&self.Lib.onceToken, { () -> Void in
                if context != nil {self.Lib.context = context}
                else{self.Lib.context = JSContext()}
                var libJS = ScriptLibrary.super_calendar_js
                self.Lib.context.evaluateScript(libJS)
            })
        }
    }
}
extension NSDate.LunarComponent{
    private struct Lib {
        static var context: JSContext!
        static var onceToken: dispatch_once_t = 0
        static var LunarComponentKey = "LunarComponentKey"
        static let DefaultLunarComponentInfo = ["SolarYear":0,"SolarMonth":0,"SolarDay":0,"Week":0,"LunarYear":0,"LunarMonth":0,"LunarDay":0,"LunarMonthCN":"","LunarDayCN":"","AnimalCN":"","AstronomyCN":"","SolarTermCN":"","GZYear":"","GZMonth":"","GZDay":"","WeekNameCN":"","isSolarTerm":false,"isToday":false,"isLeapMonth":false,]
    }
}
/****************************************************** NSTimer ***************************************************************/

@objc protocol EasyTimer{
    optional var userInfo: AnyObject? { get }
    optional func invalidate()
    optional func fire()
}
extension NSTimer: EasyTimer {
    typealias NSTimerScheduledTask = (timer: EasyTimer)->Bool
    
    // strict == false 时 task 永远在后台线程中执行
    class func scheduled(#task:NSTimerScheduledTask, interval: NSTimeInterval, repeat: Bool = true, userInfo: AnyObject? = nil, strict: Bool = false) ->EasyTimer{
        var timer: EasyTimer?
        if strict {
            timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: NSScheduledTaskTimerTarget.self, selector: "reciveTimer:", userInfo: userInfo, repeats: repeat)
        }else{
            timer = EasyTimerTask(ti: interval, target: NSScheduledTaskTimerTarget.self, selector: "reciveTimer:", userInfo: userInfo, repeats: repeat)
        }
        objc_setAssociatedObject(timer, &NSScheduledTask.TaskKey, unsafeBitCast(task, AnyObject.self), objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        return timer!
    }
    
    private struct NSScheduledTask {
        static var TaskKey = "TaskKey"
    }
    
    @objc private class EasyTimerTask: EasyTimer {
        var timeInterval: NSTimeInterval!
        var userInfo: AnyObject?
        var repeat: Bool
        var valid: Bool = true
        weak var target: AnyObject!
        var selector: Selector!
        
        init(ti: NSTimeInterval, target aTarget: AnyObject, selector aSelector: Selector, userInfo: AnyObject?, repeats yesOrNo: Bool){
            self.timeInterval = ti
            self.userInfo = userInfo
            self.repeat = yesOrNo
            self.target = aTarget
            self.selector = aSelector
            self.schedule()
        }
        
        func schedule(){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.timeInterval * 1000000000)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if self.valid == false {return}
                NSThread.detachNewThreadSelector(self.selector, toTarget: self, withObject: self)
                if self.repeat {
                    self.schedule()
                }
            })
        }
        
        func invalidate(){
            self.valid = false
        }
        func fire(){
            NSThread.detachNewThreadSelector(self.selector, toTarget: self, withObject: self)
        }
    }
    
    @objc private class NSScheduledTaskTimerTarget: NSObject{
        @objc func reciveTimer(timer: NSTimer){
            var taskObj: AnyObject? = objc_getAssociatedObject(timer, &NSScheduledTask.TaskKey)
            if taskObj == nil { timer.invalidate(); return}
            var task = unsafeBitCast(taskObj, NSTimerScheduledTask.self)
            
            if task(timer: timer){
                timer.invalidate()
            }
        }
    }
}
