//
//  FoundationCommonTool.swift
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
    class func date(#script: String, format: String = "yyyy-MM-dd HH:mm:ss") -> NSDate?{
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(script)
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
        private var info: NSDictionary = LunarComponent.Lib.DefaultLunarComponentInfo
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
        */
        class func externalInit(#context: JSContext?){
            dispatch_once(&self.Lib.onceToken, { () -> Void in
                if context != nil {self.Lib.context = context}
                else{self.Lib.context = JSContext()}
                var libJSData = NSData(base64EncodedString: self.Lib.libJS, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                if libJSData == nil { println("SuperCalendar lib error"); return}
                var libJS = NSString(data: libJSData!, encoding: NSUTF8StringEncoding)
                if libJS == nil { println("SuperCalendar lib error"); return}
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
        static let libJS: String = "KGZ1bmN0aW9uKCl7dmFyIHEsayx2LHAsZix0LHcsaCxvLGIsYSxzLGksbix4LGcsZSxkLGMscixtLGosdSxsO3A9WzE5NDE2LDE5MTY4LDQyMzUyLDIxNzE3LDUzODU2LDU1NjMyLDkxNDc2LDIyMTc2LDM5NjMyLDIxOTcwLDE5MTY4LDQyNDIyLDQyMTkyLDUzODQwLDExOTM4MSw0NjQwMCw1NDk0NCw0NDQ1MCwzODMyMCw4NDM0MywxODgwMCw0MjE2MCw0NjI2MSwyNzIxNiwyNzk2OCwxMDkzOTYsMTExMDQsMzgyNTYsMjEyMzQsMTg4MDAsMjU5NTgsNTQ0MzIsNTk5ODQsMjgzMDksMjMyNDgsMTExMDQsMTAwMDY3LDM3NjAwLDExNjk1MSw1MTUzNiw1NDQzMiwxMjA5OTgsNDY0MTYsMjIxNzYsMTA3OTU2LDk2ODAsMzc1ODQsNTM5MzgsNDMzNDQsNDY0MjMsMjc4MDgsNDY0MTYsODY4NjksMTk4NzIsNDI0MTYsODMzMTUsMjExNjgsNDM0MzIsNTk3MjgsMjcyOTYsNDQ3MTAsNDM4NTYsMTkyOTYsNDM3NDgsNDIzNTIsMjEwODgsNjIwNTEsNTU2MzIsMjMzODMsMjIxNzYsMzg2MDgsMTk5MjUsMTkxNTIsNDIxOTIsNTQ0ODQsNTM4NDAsNTQ2MTYsNDY0MDAsNDY3NTIsMTAzODQ2LDM4MzIwLDE4ODY0LDQzMzgwLDQyMTYwLDQ1NjkwLDI3MjE2LDI3OTY4LDQ0ODcwLDQzODcyLDM4MjU2LDE5MTg5LDE4ODAwLDI1Nzc2LDI5ODU5LDU5OTg0LDI3NDgwLDIxOTUyLDQzODcyLDM4NjEzLDM3NjAwLDUxNTUyLDU1NjM2LDU0NDMyLDU1ODg4LDMwMDM0LDIyMTc2LDQzOTU5LDk2ODAsMzc1ODQsNTE4OTMsNDMzNDQsNDYyNDAsNDc3ODAsNDQzNjgsMjE5NzcsMTkzNjAsNDI0MTYsODYzOTAsMjExNjgsNDMzMTIsMzEwNjAsMjcyOTYsNDQzNjgsMjMzNzgsMTkyOTYsNDI3MjYsNDIyMDgsNTM4NTYsNjAwMDUsNTQ1NzYsMjMyMDAsMzAzNzEsMzg2MDgsMTk0MTUsMTkxNTIsNDIxOTIsMTE4OTY2LDUzODQwLDU0NTYwLDU2NjQ1LDQ2NDk2LDIyMjI0LDIxOTM4LDE4ODY0LDQyMzU5LDQyMTYwLDQzNjAwLDExMTE4OSwyNzkzNiw0NDQ0OCw4NDgzNSwzNzc0NCwxODkzNiwxODgwMCwyNTc3Niw5MjMyNiw1OTk4NCwyNzQyNCwxMDgyMjgsNDM3NDQsNDE2OTYsNTM5ODcsNTE1NTIsNTQ2MTUsNTQ0MzIsNTU4ODgsMjM4OTMsMjIxNzYsNDI3MDQsMjE5NzIsMjEyMDAsNDM0NDgsNDMzNDQsNDYyNDAsNDY3NTgsNDQzNjgsMjE5MjAsNDM5NDAsNDI0MTYsMjExNjgsNDU2ODMsMjY5MjgsMjk0OTUsMjcyOTYsNDQzNjgsODQ4MjEsMTkyOTYsNDIzNTIsMjE3MzIsNTM2MDAsNTk3NTIsNTQ1NjAsNTU5NjgsOTI4MzgsMjIyMjQsMTkxNjgsNDM0NzYsNDE2ODAsNTM1ODQsNjIwMzQsNTQ1NjBdO2Y9WzMxLDI4LDMxLDMwLDMxLDMwLDMxLDMxLDMwLDMxLDMwLDMxXTt2PVsi55SyIiwi5LmZIiwi5LiZIiwi5LiBIiwi5oiKIiwi5bexIiwi5bqaIiwi6L6bIiwi5aOsIiwi55m4Il07dz1bIuWtkCIsIuS4kSIsIuWvhSIsIuWNryIsIui+sCIsIuW3syIsIuWNiCIsIuacqiIsIueUsyIsIumFiSIsIuaIjCIsIuS6pSJdO3E9WyLpvKAiLCLniZsiLCLomY4iLCLlhZQiLCLpvpkiLCLom4ciLCLpqawiLCLnvooiLCLnjLQiLCLpuKEiLCLni5ciLCLnjKoiXTt0PVsi5bCP5a+SIiwi5aSn5a+SIiwi56uL5pilIiwi6Zuo5rC0Iiwi5oOK6JuwIiwi5pil5YiGIiwi5riF5piOIiwi6LC36ZuoIiwi56uL5aSPIiwi5bCP5ruhIiwi6IqS56eNIiwi5aSP6IezIiwi5bCP5pqRIiwi5aSn5pqRIiwi56uL56eLIiwi5aSE5pqRIiwi55m96ZyyIiwi56eL5YiGIiwi5a+S6ZyyIiwi6Zyc6ZmNIiwi56uL5YasIiwi5bCP6ZuqIiwi5aSn6ZuqIiwi5Yas6IezIl07az1bezEyMjM6IuaRqee+r+W6pyJ9LHsxMjE6IuawtOeTtuW6pyJ9LHsyMjA6IuWPjOmxvOW6pyJ9LHszMjE6IueJoee+iuW6pyJ9LHs0MjE6IumHkeeJm+W6pyJ9LHs1MjI6IuWPjOWtkOW6pyJ9LHs2MjI6IuW3qOifueW6pyJ9LHs3MjQ6IueLruWtkOW6pyJ9LHs4MjQ6IuWkhOWls+W6pyJ9LHs5MjQ6IuWkqeenpOW6pyJ9LHsxMDI0OiLlpKnonY7luqcifSx7MTEyMzoi5bCE5omL5bqnIn0sezEyMjM6IuaRqee+r+W6pyJ9XTtjPVsiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTc3ODM5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5ODAxZDk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMTk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBlIiwiOTdiZDA5ODAxZDk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDdmNTk1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMTk4MDFlYzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiZDA3ZjE0ODdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTI3NGM5MjBlIiwiOTdiY2Y3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM5MWFhIiwiOTdiNmI5N2JkMTk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiY2Y3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNzBjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM5MWFhIiwiOTdiNmI3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlMzdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlMzdmMTQ5OTgwODNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2YwN2U3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM2NjY1YjY2YWE4OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIl07Zz1bIuaXpSIsIuS4gCIsIuS6jCIsIuS4iSIsIuWbmyIsIuS6lCIsIuWFrSIsIuS4gyIsIuWFqyIsIuS5nSIsIuWNgSJdO2U9WyLliJ0iLCLljYEiLCLlu78iLCLljYUiXTtkPVsi5q2jIiwi5LqMIiwi5LiJIiwi5ZubIiwi5LqUIiwi5YWtIiwi5LiDIiwi5YWrIiwi5LmdIiwi5Y2BIiwi5YasIiwi6IWKIl07YT1mdW5jdGlvbih6KXtyZXR1cm4gcFt6LTE5MDBdJjE1fTtzPWZ1bmN0aW9uKHope2lmKGEoeikpe2lmKHBbei0xOTAwXSY2NTUzNil7cmV0dXJuIDMwfWVsc2V7cmV0dXJuIDI5fX1yZXR1cm4gMH07eD1mdW5jdGlvbihCKXt2YXIgeixBO0E9MzQ4O3o9MzI3Njg7d2hpbGUoej44KXtpZihwW0ItMTkwMF0meil7QSs9MX16Pj49MX1yZXR1cm4gQStzKEIpfTtuPWZ1bmN0aW9uKEEseil7aWYoej4xMnx8ejwxKXtyZXR1cm4gLTF9aWYocFtBLTE5MDBdJig2NTUzNj4+eikpe3JldHVybiAzMH1lbHNle3JldHVybiAyOX19O209ZnVuY3Rpb24oQix6KXt2YXIgQTtpZih6PjEyfHx6PDEpe3JldHVybiAtMX1BPXotMTtpZihBIT09MSl7cmV0dXJuIGZbQV19aWYoKEIlND09PTApJiYoQiUxMDAhPT0wKXx8KEIlNDAwPT09MCkpe3JldHVybiAyOX1lbHNle3JldHVybiAyOH19O2w9ZnVuY3Rpb24oeSl7cmV0dXJuIHZbeSUxMF0rd1t5JTEyXX07Yj1mdW5jdGlvbihDLEIpe3ZhciBBLHo7aWYoQzwxOTAwfHxDPjIxMDB8fEI8MXx8Qj4yNCl7cmV0dXJuIC0xfUItPTE7ej1jW0MtMTkwMF07QT1wYXJzZUludCgiMHgiK3ouc3Vic3RyKHBhcnNlSW50KEIvNCkqNSw1KSkudG9TdHJpbmcoKTtyZXR1cm4gcGFyc2VJbnQoQS5zdWJzdHIoWzAsMSwzLDRdW0IlNF0sWzEsMl1bQiU0JTJdKSl9O3U9ZnVuY3Rpb24oeSl7aWYoeT4xMnx8eTwxKXtyZXR1cm4gLTF9ZWxzZXtyZXR1cm4gZFt5LTFdKyLmnIgifX07aj1mdW5jdGlvbih5KXtyZXR1cm4gZVtNYXRoLmZsb29yKHkvMTApXStnW3klMTBdfTtoPWZ1bmN0aW9uKHope3JldHVybiBxWyh6LTQpJTEyXX07bz1mdW5jdGlvbih6LEQpe3ZhciBBLEMsQix5O0I9a1t6XTtmb3IoQSBpbiBCKXtDPUJbQV07aWYoeioxMDArRD49QSl7cmV0dXJuIEN9fXk9a1t6LTFdO2ZvcihBIGluIHkpe0M9eVtBXTtyZXR1cm4gQ319O3I9ZnVuY3Rpb24oRyxPLFgpe3ZhciB6LFIsTixRLEEsWSxMLFMsTSxELGFhLEgsSyxaLFUsRixFLEosVixULFcsUCxJLEMsQjtpZihHPDE5MDB8fEc+MjEwMCl7cmV0dXJuIC0xfWlmKEc9PT0xOTAwJiZPPT09MSYmWDwzMSl7cmV0dXJuIC0xfUY9bmV3IERhdGUoRyxwYXJzZUludChPLTEpLFgpO0s9MDtXPTA7Rz1GLmdldEZ1bGxZZWFyKCk7Tz1GLmdldE1vbnRoKCkrMTtYPUYuZ2V0RGF0ZSgpO0U9KERhdGUuVVRDKEcsTy0xLFgpLURhdGUuVVRDKDE5MDAsMCwzMSkpLzg2NDAwMDAwO2ZvcihTPUM9MTkwMDtDPDIxMDA7Uz0rK0Mpe2lmKEU8PTApe2JyZWFrfVc9eChTKTtFLT1XfWlmKEU8MCl7RSs9VztTLS19SD1uZXcgRGF0ZSgpO2FhPUguZ2V0RnVsbFllYXIoKT09PUcmJkguZ2V0TW9udGgoKSsxPT09TyYmSC5nZXREYXRlKCk9PT1YO1U9Ri5nZXREYXkoKTt6PWdbVV07aWYoVT09PTApe1U9N31JPVM7Sz1hKFMpO009ZmFsc2U7Zm9yKFM9Qj0xO0I8MTI7Uz0rK0Ipe2lmKEU8PTApe2JyZWFrfWlmKEs+MCYmUz09PShLKzEpJiZNPT09ZmFsc2Upey0tUztNPXRydWU7Vz1zKEkpfWVsc2V7Vz1uKEksUyl9aWYoTT09PXRydWUmJlM9PT1LKzEpe009ZmFsc2V9RS09V31pZihFPT09MCYmSz4wJiZTPT09SysxKXtpZihNKXtNPWZhbHNlfWVsc2V7TT10cnVlOy0tU319aWYoRTwwKXtFKz1XOy0tU31aPVM7Uj1FKzE7Vj1PLTE7UD1iKEksMyk7TD1sKEktNCk7TD1WPDImJlg8UD9sKEktNSk6bChJLTQpO1E9YihHLE8qMi0xKTtKPWIoRyxPKjIpO1k9WDxRP2woKEctMTkwMCkqMTIrTysxMSk6bCgoRy0xOTAwKSoxMitPKzEyKTtEPWZhbHNlO1Q9IiI7aWYoUT09PVgpe0Q9dHJ1ZTtUPXRbTyoyLTJdfWlmKEo9PT1YKXtEPXRydWU7VD10W08qMi0xXX1OPURhdGUuVVRDKEcsViwxLDAsMCwwLDApLzg2NDAwMDAwKzI1NTY3KzEwO0E9bChOK1gtMSk7cmV0dXJueyJTb2xhclllYXIiOkcsIlNvbGFyTW9udGgiOk8sIlNvbGFyRGF5IjpYLCJXZWVrIjpVLCJMdW5hclllYXIiOkksIkx1bmFyTW9udGgiOlosIkx1bmFyRGF5IjpSLCJMdW5hck1vbnRoQ04iOihNPyLpl7AiOiIiKSt1KFopLCJMdW5hckRheUNOIjpqKFIpLCJBbmltYWxDTiI6aChJKSwiQXN0cm9ub215Q04iOm8oTyxYKSwiU29sYXJUZXJtQ04iOlQsIkdaWWVhciI6TCwiR1pNb250aCI6WSwiR1pEYXkiOkEsIldlZWtOYW1lQ04iOiLmmJ/mnJ8iK3osImlzU29sYXJUZXJtIjpELCJpc1RvZGF5IjphYSwiaXNMZWFwTW9udGgiOk19fTtpPWZ1bmN0aW9uKEosQyxJLE4pe3ZhciBELEssSCxNLEIseixBLEcsTCxGLEU7ej0wO0E9YShKKTtpZihOJiZBIT09Qyl7cmV0dXJuIC0xfWlmKChKPT09MjEwMCYmQz09PTEyJiZJPjEpfHwoSj09PTE5MDAmJkM9PT0xJiZJPDMxKSl7cmV0dXJuIC0xfUs9bihKLEMpO2lmKEo8MTkwMHx8Sj4yMTAwfHxJPkspe3JldHVybiAtMX1HPTA7Zm9yKEg9Rj0xOTAwOzE5MDA8PUo/RjxKOkY+SjtIPTE5MDA8PUo/KytGOi0tRil7Rys9eChIKX1CPTA7TT1mYWxzZTtmb3IoSD1FPTE7MTw9Qz9FPEM6RT5DO0g9MTw9Qz8rK0U6LS1FKXtCPWEoSik7aWYoIU0mJihCPD1IJiZCPjApKXtHKz1zKEopO009dHJ1ZX1HKz1uKEosSCl9aWYoTil7Rys9S31MPURhdGUuVVRDKDE5MDAsMSwzMCwwLDAsMCk7RD1uZXcgRGF0ZSgoRytJLTMxKSo4NjQwMDAwMCtMKTtyZXR1cm4gcihELmdldFVUQ0Z1bGxZZWFyKCksRC5nZXRVVENNb250aCgpKzEsRC5nZXRVVENEYXRlKCkpfTt0aGlzLlN1cGVyQ2FsZW5kYXI9e2x1bmFyMnNvbGFyOmksc29sYXIybHVuYXI6cixsZWFwTW9udGg6YSxsZWFwTW9udGhEYXlzOnMsbHVuYXJZZWFyRGF5czp4LGx1bmFyTW9udGhEYXlzOm4sc29sYXJEYXlzOm0sZ2V0U29sYXJUZXJtOmIsZ2V0QW5pbWFsOmgsZ2V0QXN0cm9ub215Om99fSkuY2FsbCh0aGlzKTs="
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
