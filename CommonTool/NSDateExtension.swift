
import UIKit
import JavaScriptCore

extension NSDate {
    class func date(#script: String, format: String = "yyyy-MM-dd HH:mm:ss") -> NSDate?{
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(script)
    }
    
    class func initEasyCalendar(#context: JSContext?){
        dispatch_once(&LunarDate.Lib.onceToken, { () -> Void in
            if context != nil{
                LunarDate.Lib.context = context!
            }else{
                LunarDate.Lib.context = JSContext()
            }
            var libJSData = NSData(base64EncodedString: LunarDate.Lib.libCalendar, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            if libJSData == nil { println("SuperCalendar lib error"); return}
            var libJS = NSString(data: libJSData!, encoding: NSUTF8StringEncoding)
            if libJS == nil { println("SuperCalendar lib error"); return}
            
            LunarDate.Lib.context.evaluateScript(libJS)
        })
    }
    
    var lunar: LunarDate{
        get{
            var ld = objc_getAssociatedObject(self, &LunarDate.Lib.LunarDateKey) as? LunarDate
            if ld == nil {
                ld = LunarDate(date: self)
                self.lunar = ld!
            }
            return ld!
        }set{
            objc_setAssociatedObject(self, &LunarDate.Lib.LunarDateKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    /**
    *   根据农历 年 月 日 初始化
    *   如果 年 月 日 不合法，则初始化为当前日期
    */
    convenience init(lunarYear year: Int, month: Int, day: Int){
        var ld = LunarDate(lunarYear: year, month: month, day: day)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString("\(ld.solarYear)-\(ld.solarMonth)-\(ld.solarDay)")
        self.init(timeIntervalSinceReferenceDate: date!.timeIntervalSinceReferenceDate)
        self.lunar = ld
    }
    /**
    *   根据公历 年 月 日 初始化
    *   如果 年 月 日 不合法，则初始化为当前日期
    */
    convenience init(solarYear year: Int, month: Int, day: Int){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(String(format:"%.4i-%.2i-%.2i",year, month,day))
        self.init(timeIntervalSinceReferenceDate: date!.timeIntervalSinceReferenceDate)
    }
    
    class LunarDate {
        var info: NSDictionary = LunarDate.Lib.DefaultLunarInfo
        
        private init(date: NSDate){
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.stringFromDate(date)
            dateFormatter.dateFormat = "MM"
            let month = dateFormatter.stringFromDate(date)
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.stringFromDate(date)
            var info = LunarDate.Lib.context.evaluateScript("calendar.solar2lunar(\(year),\(month),\(day))")
            if info.isObject() {
                self.info = info.toDictionary()
            }
        }
        
        private init(lunarYear year: Int, month: Int, day: Int){
            var info = LunarDate.Lib.context.evaluateScript("calendar.lunar2solar(\(year),\(month),\(day))")
            if info.isObject() {
                self.info = info.toDictionary()
            }
        }
        
        // 农历 年
        var lunarYear: Int{return info.objectForKey("lYear") as Int}
        // 农历 月
        var lunarMonth: Int{return info.objectForKey("lMonth") as Int}
        //  农历 天
        var lunarDay: Int{return info.objectForKey("lDay") as Int}
        var lunarMonthCN: String{return info.objectForKey("IMonthCn") as String}
        var lunarDayCN: String{return info.objectForKey("IDayCn") as String}
        //  干支 记年
        var gzYear: String{return info.objectForKey("gzYear") as String}
        //  干支 记月
        var gzMonth: String{return info.objectForKey("gzMonth") as String}
        //  干支 记天
        var gzDay: String{return info.objectForKey("gzDay") as String}
        //  属相
        var animal: String{return info.objectForKey("Animal") as String}
        var week: Int{return info.objectForKey("nWeek") as Int}
        var weekCN: String{return info.objectForKey("ncWeek") as String}
        //  是否是节气
        var isTerm: Bool{return info.objectForKey("isTerm") as Bool}
        //  是否是今天
        var isToday: Bool{return info.objectForKey("isToday") as Bool}
        //  节气名
        var term: String?{return info.objectForKey("Term")? as? String}
        //  公历
        var solarYear: Int{return info.objectForKey("cYear") as Int}
        var solarMonth: Int{return info.objectForKey("cMonth") as Int}
        var solarDay: Int{return info.objectForKey("cDay") as Int}
    }
}

extension NSDate.LunarDate {
    class func daysOf(leapYear year: Int) ->Int{
        return Int(NSDate.LunarDate.Lib.context.evaluateScript("lYearDays(\(year))").toInt32())
    }
    class func dayOf(#month: Int, learYear year: Int) ->Int {
        return Int(NSDate.LunarDate.Lib.context.evaluateScript("lYearDays(\(year), \(month))").toInt32())
    }
}

extension NSDate.LunarDate {
    private struct Lib {
        static var context: JSContext!
        static var onceToken: dispatch_once_t = 0
        static var LunarDateKey = "LunarInfoKey"
        static var DefaultLunarInfo: NSDictionary = [
            "Animal": "羊",
            "IDayCn": "廿七",
            "IMonthCn": "正月",
            "Term": "",
            "cDay": 17,
            "cMonth": 3,
            "cYear": 2015,
            "gzDay": "壬辰",
            "gzMonth": "己卯",
            "gzYear": "乙未",
            "isLeap": false,
            "isTerm": false,
            "isToday": true,
            "lDay": 27,
            "lMonth": 1,
            "lYear": 2015,
            "nWeek": 2,
            "ncWeek": "星期二"
        ]
        static let libCalendar = "dmFyIGNhbGVuZGFyPXtsdW5hckluZm86WzE5NDE2LDE5MTY4LDQyMzUyLDIxNzE3LDUzODU2LDU1NjMyLDkxNDc2LDIyMTc2LDM5NjMyLDIxOTcwLDE5MTY4LDQyNDIyLDQyMTkyLDUzODQwLDExOTM4MSw0NjQwMCw1NDk0NCw0NDQ1MCwzODMyMCw4NDM0MywxODgwMCw0MjE2MCw0NjI2MSwyNzIxNiwyNzk2OCwxMDkzOTYsMTExMDQsMzgyNTYsMjEyMzQsMTg4MDAsMjU5NTgsNTQ0MzIsNTk5ODQsMjgzMDksMjMyNDgsMTExMDQsMTAwMDY3LDM3NjAwLDExNjk1MSw1MTUzNiw1NDQzMiwxMjA5OTgsNDY0MTYsMjIxNzYsMTA3OTU2LDk2ODAsMzc1ODQsNTM5MzgsNDMzNDQsNDY0MjMsMjc4MDgsNDY0MTYsODY4NjksMTk4NzIsNDI0MTYsODMzMTUsMjExNjgsNDM0MzIsNTk3MjgsMjcyOTYsNDQ3MTAsNDM4NTYsMTkyOTYsNDM3NDgsNDIzNTIsMjEwODgsNjIwNTEsNTU2MzIsMjMzODMsMjIxNzYsMzg2MDgsMTk5MjUsMTkxNTIsNDIxOTIsNTQ0ODQsNTM4NDAsNTQ2MTYsNDY0MDAsNDY3NTIsMTAzODQ2LDM4MzIwLDE4ODY0LDQzMzgwLDQyMTYwLDQ1NjkwLDI3MjE2LDI3OTY4LDQ0ODcwLDQzODcyLDM4MjU2LDE5MTg5LDE4ODAwLDI1Nzc2LDI5ODU5LDU5OTg0LDI3NDgwLDIxOTUyLDQzODcyLDM4NjEzLDM3NjAwLDUxNTUyLDU1NjM2LDU0NDMyLDU1ODg4LDMwMDM0LDIyMTc2LDQzOTU5LDk2ODAsMzc1ODQsNTE4OTMsNDMzNDQsNDYyNDAsNDc3ODAsNDQzNjgsMjE5NzcsMTkzNjAsNDI0MTYsODYzOTAsMjExNjgsNDMzMTIsMzEwNjAsMjcyOTYsNDQzNjgsMjMzNzgsMTkyOTYsNDI3MjYsNDIyMDgsNTM4NTYsNjAwMDUsNTQ1NzYsMjMyMDAsMzAzNzEsMzg2MDgsMTk0MTUsMTkxNTIsNDIxOTIsMTE4OTY2LDUzODQwLDU0NTYwLDU2NjQ1LDQ2NDk2LDIyMjI0LDIxOTM4LDE4ODY0LDQyMzU5LDQyMTYwLDQzNjAwLDExMTE4OSwyNzkzNiw0NDQ0OCw4NDgzNSwzNzc0NCwxODkzNiwxODgwMCwyNTc3Niw5MjMyNiw1OTk4NCwyNzQyNCwxMDgyMjgsNDM3NDQsNDE2OTYsNTM5ODcsNTE1NTIsNTQ2MTUsNTQ0MzIsNTU4ODgsMjM4OTMsMjIxNzYsNDI3MDQsMjE5NzIsMjEyMDAsNDM0NDgsNDMzNDQsNDYyNDAsNDY3NTgsNDQzNjgsMjE5MjAsNDM5NDAsNDI0MTYsMjExNjgsNDU2ODMsMjY5MjgsMjk0OTUsMjcyOTYsNDQzNjgsODQ4MjEsMTkyOTYsNDIzNTIsMjE3MzIsNTM2MDAsNTk3NTIsNTQ1NjAsNTU5NjgsOTI4MzgsMjIyMjQsMTkxNjgsNDM0NzYsNDE2ODAsNTM1ODQsNjIwMzQsNTQ1NjBdLHNvbGFyTW9udGg6WzMxLDI4LDMxLDMwLDMxLDMwLDMxLDMxLDMwLDMxLDMwLDMxXSxHYW46WyJcdTc1MzIiLCJcdTRlNTkiLCJcdTRlMTkiLCJcdTRlMDEiLCJcdTYyMGEiLCJcdTVkZjEiLCJcdTVlOWEiLCJcdThmOWIiLCJcdTU4ZWMiLCJcdTc2NzgiXSxaaGk6WyJcdTViNTAiLCJcdTRlMTEiLCJcdTViYzUiLCJcdTUzNmYiLCJcdThmYjAiLCJcdTVkZjMiLCJcdTUzNDgiLCJcdTY3MmEiLCJcdTc1MzMiLCJcdTkxNDkiLCJcdTYyMGMiLCJcdTRlYTUiXSxBbmltYWxzOlsiXHU5ZjIwIiwiXHU3MjViIiwiXHU4NjRlIiwiXHU1MTU0IiwiXHU5Zjk5IiwiXHU4NmM3IiwiXHU5YTZjIiwiXHU3ZjhhIiwiXHU3MzM0IiwiXHU5ZTIxIiwiXHU3MmQ3IiwiXHU3MzJhIl0sc29sYXJUZXJtOlsiXHU1YzBmXHU1YmQyIiwiXHU1OTI3XHU1YmQyIiwiXHU3YWNiXHU2NjI1IiwiXHU5NmU4XHU2YzM0IiwiXHU2MGNhXHU4NmYwIiwiXHU2NjI1XHU1MjA2IiwiXHU2ZTA1XHU2NjBlIiwiXHU4YzM3XHU5NmU4IiwiXHU3YWNiXHU1OTBmIiwiXHU1YzBmXHU2ZWUxIiwiXHU4MjkyXHU3OWNkIiwiXHU1OTBmXHU4MWYzIiwiXHU1YzBmXHU2NjkxIiwiXHU1OTI3XHU2NjkxIiwiXHU3YWNiXHU3OWNiIiwiXHU1OTA0XHU2NjkxIiwiXHU3NjdkXHU5NzMyIiwiXHU3OWNiXHU1MjA2IiwiXHU1YmQyXHU5NzMyIiwiXHU5NzFjXHU5NjRkIiwiXHU3YWNiXHU1MWFjIiwiXHU1YzBmXHU5NmVhIiwiXHU1OTI3XHU5NmVhIiwiXHU1MWFjXHU4MWYzIl0sc1Rlcm1JbmZvOlsiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDBiMDZiZGIwNzIyYzk2NWNlMWNmY2M5MjBmIiwiYjAyNzA5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTc3ODM5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5ODAxZDk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMTk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBlIiwiOTdiZDA5ODAxZDk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhlMWNmY2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDgyYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y5N2MzNTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA5N2JkMDdmNTk1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMTk4MDFlYzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI5N2JkMTk4MDFlYzk1ZjhjOTY1Y2M5MjBmIiwiOTdiZDA3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiZDA3ZjE0ODdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTY1Y2M5MjBlIiwiOTdiY2Y3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI5N2JkMTk4MDFlYzkyMTBjOTI3NGM5MjBlIiwiOTdiY2Y3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM5MWFhIiwiOTdiNmI5N2JkMTk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiY2Y3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YzkyMTBjOTI3NGM5MjBlIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNzBjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTI3NGM5MWFhIiwiOTdiNmI3ZjBlNDdmNTMxYjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM5MWFhIiwiOTdiNmI3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM5N2JkMDk3YzM2YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjUzMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIxMGM4ZGMyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDk3YzM1YjBiNmZjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlMzdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM5N2JkMDdmNTk1YjBiMGJjOTIwZmIwNzIyIiwiOTc3ODM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjE0ODdmNTk1YjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlNDdmMTQ5YjA3MjNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDcyM2IwNmJkIiwiN2YwN2U3ZjBlMzdmMTQ5OTgwODNiMDc4N2IwNzIxIiwiN2YwZTI3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM3ZjBlMzY2YWE4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2YwN2U3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM2NjY1YjY2YWE4OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNzIxIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIyIiwiN2YwZTM2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyM2IwMmQ1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTM2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwODJiMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI2NjY1YjY2YTQ0OTgwMWU5ODA4Mjk3YzM1IiwiNjY1ZjY3ZjBlMzdmMTQ4OTgwMWViMDcyMjk3YzM1IiwiN2VjOTY3ZjBlMzdmMTQ5OTgwODJiMDc4N2IwNmJkIiwiN2YwN2U3ZjBlNDdmNTMxYjA3MjNiMGI2ZmIwNzIxIiwiN2YwZTI3ZjE0ODdmNTMxYjBiMGJiMGI2ZmIwNzIyIl0sblN0cjE6WyJcdTY1ZTUiLCJcdTRlMDAiLCJcdTRlOGMiLCJcdTRlMDkiLCJcdTU2ZGIiLCJcdTRlOTQiLCJcdTUxNmQiLCJcdTRlMDMiLCJcdTUxNmIiLCJcdTRlNWQiLCJcdTUzNDEiXSxuU3RyMjpbIlx1NTIxZCIsIlx1NTM0MSIsIlx1NWVmZiIsIlx1NTM0NSJdLG5TdHIzOlsiXHU2YjYzIiwiXHU0ZThjIiwiXHU0ZTA5IiwiXHU1NmRiIiwiXHU0ZTk0IiwiXHU1MTZkIiwiXHU0ZTAzIiwiXHU1MTZiIiwiXHU0ZTVkIiwiXHU1MzQxIiwiXHU1MWFjIiwiXHU4MTRhIl0sbFllYXJEYXlzOmZ1bmN0aW9uKGMpe3ZhciBhLGI9MzQ4Owpmb3IoYT0zMjc2ODthPjg7YT4+PTEpe2IrPShjYWxlbmRhci5sdW5hckluZm9bYy0xOTAwXSZhKT8xOjB9cmV0dXJuKGIrY2FsZW5kYXIubGVhcERheXMoYykpfSxsZWFwTW9udGg6ZnVuY3Rpb24oYSl7cmV0dXJuKGNhbGVuZGFyLmx1bmFySW5mb1thLTE5MDBdJjE1KX0sbGVhcERheXM6ZnVuY3Rpb24oYSl7aWYoY2FsZW5kYXIubGVhcE1vbnRoKGEpKXtyZXR1cm4oKGNhbGVuZGFyLmx1bmFySW5mb1thLTE5MDBdJjY1NTM2KT8zMDoyOSl9cmV0dXJuKDApfSxtb250aERheXM6ZnVuY3Rpb24oYixhKXtpZihhPjEyfHxhPDEpe3JldHVybiAtMX1yZXR1cm4oKGNhbGVuZGFyLmx1bmFySW5mb1tiLTE5MDBdJig2NTUzNj4+YSkpPzMwOjI5KX0sc29sYXJEYXlzOmZ1bmN0aW9uKGMsYSl7aWYoYT4xMnx8YTwxKXtyZXR1cm4gLTF9dmFyIGI9YS0xO2lmKGI9PTEpe3JldHVybigoKGMlND09MCkmJihjJTEwMCE9MCl8fChjJTQwMD09MCkpPzI5OjI4KX1lbHNle3JldHVybihjYWxlbmRhci5zb2xhck1vbnRoW2JdKX19LHRvR2FuWmhpOmZ1bmN0aW9uKGEpe3JldHVybihjYWxlbmRhci5HYW5bYSUxMF0rY2FsZW5kYXIuWmhpW2ElMTJdKX0sZ2V0VGVybTpmdW5jdGlvbihlLGQpe2lmKGU8MTkwMHx8ZT4yMTAwKXtyZXR1cm4gLTF9aWYoZDwxfHxkPjI0KXtyZXR1cm4gLTF9dmFyIGE9Y2FsZW5kYXIuc1Rlcm1JbmZvW2UtMTkwMF07dmFyIGM9W3BhcnNlSW50KCIweCIrYS5zdWJzdHIoMCw1KSkudG9TdHJpbmcoKSxwYXJzZUludCgiMHgiK2Euc3Vic3RyKDUsNSkpLnRvU3RyaW5nKCkscGFyc2VJbnQoIjB4IithLnN1YnN0cigxMCw1KSkudG9TdHJpbmcoKSxwYXJzZUludCgiMHgiK2Euc3Vic3RyKDE1LDUpKS50b1N0cmluZygpLHBhcnNlSW50KCIweCIrYS5zdWJzdHIoMjAsNSkpLnRvU3RyaW5nKCkscGFyc2VJbnQoIjB4IithLnN1YnN0cigyNSw1KSkudG9TdHJpbmcoKV07dmFyIGI9W2NbMF0uc3Vic3RyKDAsMSksY1swXS5zdWJzdHIoMSwyKSxjWzBdLnN1YnN0cigzLDEpLGNbMF0uc3Vic3RyKDQsMiksY1sxXS5zdWJzdHIoMCwxKSxjWzFdLnN1YnN0cigxLDIpLGNbMV0uc3Vic3RyKDMsMSksY1sxXS5zdWJzdHIoNCwyKSxjWzJdLnN1YnN0cigwLDEpLGNbMl0uc3Vic3RyKDEsMiksY1syXS5zdWJzdHIoMywxKSxjWzJdLnN1YnN0cig0LDIpLGNbM10uc3Vic3RyKDAsMSksY1szXS5zdWJzdHIoMSwyKSxjWzNdLnN1YnN0cigzLDEpLGNbM10uc3Vic3RyKDQsMiksY1s0XS5zdWJzdHIoMCwxKSxjWzRdLnN1YnN0cigxLDIpLGNbNF0uc3Vic3RyKDMsMSksY1s0XS5zdWJzdHIoNCwyKSxjWzVdLnN1YnN0cigwLDEpLGNbNV0uc3Vic3RyKDEsMiksY1s1XS5zdWJzdHIoMywxKSxjWzVdLnN1YnN0cig0LDIpLF07cmV0dXJuIHBhcnNlSW50KGJbZC0xXSl9LHRvQ2hpbmFNb250aDpmdW5jdGlvbihhKXtpZihhPjEyfHxhPDEpe3JldHVybiAtMX12YXIgYj1jYWxlbmRhci5uU3RyM1thLTFdO2IrPSJcdTY3MDgiO3JldHVybiBifSx0b0NoaW5hRGF5OmZ1bmN0aW9uKGIpe3ZhciBhO3N3aXRjaChiKXtjYXNlIDEwOmE9Ilx1NTIxZFx1NTM0MSI7YnJlYWs7Y2FzZSAyMDphPSJcdTRlOGNcdTUzNDEiO2JyZWFrO2JyZWFrO2Nhc2UgMzA6YT0iXHU0ZTA5XHU1MzQxIjticmVhazticmVhaztkZWZhdWx0OmE9Y2FsZW5kYXIublN0cjJbTWF0aC5mbG9vcihiLzEwKV07YSs9Y2FsZW5kYXIublN0cjFbYiUxMF19cmV0dXJuKGEpfSxnZXRBbmltYWw6ZnVuY3Rpb24oYSl7cmV0dXJuIGNhbGVuZGFyLkFuaW1hbHNbKGEtNCklMTJdfSxzb2xhcjJsdW5hcjpmdW5jdGlvbihmLHEsQil7aWYoZjwxOTAwfHxmPjIxMDApe3JldHVybiAtMX1pZihmPT0xOTAwJiZxPT0xJiZCPDMxKXtyZXR1cm4gLTF9aWYoIWYpe3ZhciBlPW5ldyBEYXRlKCl9ZWxzZXt2YXIgZT1uZXcgRGF0ZShmLHBhcnNlSW50KHEpLTEsQil9dmFyIHUsaz0wLEE9MDt2YXIgZj1lLmdldEZ1bGxZZWFyKCkscT1lLmdldE1vbnRoKCkrMSxCPWUuZ2V0RGF0ZSgpO3ZhciBjPShEYXRlLlVUQyhlLmdldEZ1bGxZZWFyKCksZS5nZXRNb250aCgpLGUuZ2V0RGF0ZSgpKS1EYXRlLlVUQygxOTAwLDAsMzEpKS84NjQwMDAwMDtmb3IodT0xOTAwO3U8MjEwMSYmYz4wO3UrKyl7QT1jYWxlbmRhci5sWWVhckRheXModSk7Yy09QX1pZihjPDApe2MrPUE7dS0tfXZhciBnPW5ldyBEYXRlKCksRD1mYWxzZTtpZihnLmdldEZ1bGxZZWFyKCk9PWYmJmcuZ2V0TW9udGgoKSsxPT1xJiZnLmdldERhdGUoKT09Qil7RD10cnVlfXZhciB2PWUuZ2V0RGF5KCksYT1jYWxlbmRhci5uU3RyMVt2XTtpZih2PT0wKXt2PTd9dmFyIGo9dTt2YXIgaz1jYWxlbmRhci5sZWFwTW9udGgodSk7dmFyIG49ZmFsc2U7Zm9yKHU9MTt1PDEzJiZjPjA7dSsrKXtpZihrPjAmJnU9PShrKzEpJiZuPT1mYWxzZSl7LS11O249dHJ1ZTtBPWNhbGVuZGFyLmxlYXBEYXlzKGopfWVsc2V7QT1jYWxlbmRhci5tb250aERheXMoaix1KX1pZihuPT10cnVlJiZ1PT0oaysxKSl7bj1mYWxzZX1jLT1BfWlmKGM9PTAmJms+MCYmdT09aysxKXtpZihuKXtuPWZhbHNlfWVsc2V7bj10cnVlOy0tdX19aWYoYzwwKXtjKz1BOy0tdX12YXIgQz11O3ZhciB0PWMrMTt2YXIgdz1xLTE7dmFyIHI9Y2FsZW5kYXIuZ2V0VGVybShqLDMpO3ZhciBsPWNhbGVuZGFyLnRvR2FuWmhpKGotNCk7aWYodzwyJiZCPHIpe2w9Y2FsZW5kYXIudG9HYW5aaGkoai01KX1lbHNle2w9Y2FsZW5kYXIudG9HYW5aaGkoai00KX12YXIgcz1jYWxlbmRhci5nZXRUZXJtKGYsKHEqMi0xKSk7dmFyIGg9Y2FsZW5kYXIuZ2V0VGVybShmLChxKjIpKTt2YXIgej1jYWxlbmRhci50b0dhblpoaSgoZi0xOTAwKSoxMitxKzExKTtpZihCPj1zKXt6PWNhbGVuZGFyLnRvR2FuWmhpKChmLTE5MDApKjEyK3ErMTIpfXZhciBwPWZhbHNlO3ZhciB4PW51bGw7aWYocz09Qil7cD10cnVlO3g9Y2FsZW5kYXIuc29sYXJUZXJtW3EqMi0yXX1pZihoPT1CKXtwPXRydWU7eD1jYWxlbmRhci5zb2xhclRlcm1bcSoyLTFdfXZhciBvPURhdGUuVVRDKGYsdywxLDAsMCwwLDApLzg2NDAwMDAwKzI1NTY3KzEwO3ZhciBiPWNhbGVuZGFyLnRvR2FuWmhpKG8rQi0xKTtyZXR1cm57ImxZZWFyIjpqLCJsTW9udGgiOkMsImxEYXkiOnQsIkFuaW1hbCI6Y2FsZW5kYXIuZ2V0QW5pbWFsKGopLCJJTW9udGhDbiI6KG4/Ilx1OTVmMCI6IiIpK2NhbGVuZGFyLnRvQ2hpbmFNb250aChDKSwiSURheUNuIjpjYWxlbmRhci50b0NoaW5hRGF5KHQpLCJjWWVhciI6ZiwiY01vbnRoIjpxLCJjRGF5IjpCLCJnelllYXIiOmwsImd6TW9udGgiOnosImd6RGF5IjpiLCJpc1RvZGF5IjpELCJpc0xlYXAiOm4sIm5XZWVrIjp2LCJuY1dlZWsiOiJcdTY2MWZcdTY3MWYiK2EsImlzVGVybSI6cCwiVGVybSI6eH19LGx1bmFyMnNvbGFyOmZ1bmN0aW9uKG4sZixrLHQpe3ZhciBhPTA7dmFyIHM9Y2FsZW5kYXIubGVhcE1vbnRoKG4pO3ZhciBxPWNhbGVuZGFyLmxlYXBEYXlzKG4pO2lmKHQmJihzIT1mKSl7cmV0dXJuIC0xfWlmKG49PTIxMDAmJmY9PTEyJiZrPjF8fG49PTE5MDAmJmY9PTEmJms8MzEpe3JldHVybiAtMX12YXIgbz1jYWxlbmRhci5tb250aERheXMobixmKTtpZihuPDE5MDB8fG4+MjEwMHx8az5vKXtyZXR1cm4gLTF9dmFyIGc9MDtmb3IodmFyIGg9MTkwMDtoPG47aCsrKXtnKz1jYWxlbmRhci5sWWVhckRheXMoaCl9dmFyIGI9MCxyPWZhbHNlO2Zvcih2YXIgaD0xO2g8ZjtoKyspe2I9Y2FsZW5kYXIubGVhcE1vbnRoKG4pO2lmKCFyKXtpZihiPD1oJiZiPjApe2crPWNhbGVuZGFyLmxlYXBEYXlzKG4pO3I9dHJ1ZX19Zys9Y2FsZW5kYXIubW9udGhEYXlzKG4saCl9aWYodCl7Zys9b312YXIgcD1EYXRlLlVUQygxOTAwLDEsMzAsMCwwLDApO3ZhciBlPW5ldyBEYXRlKChnK2stMzEpKjg2NDAwMDAwK3ApO3ZhciBsPWUuZ2V0VVRDRnVsbFllYXIoKTt2YXIgYz1lLmdldFVUQ01vbnRoKCkrMTt2YXIgaj1lLmdldFVUQ0RhdGUoKTtyZXR1cm4gY2FsZW5kYXIuc29sYXIybHVuYXIobCxjLGopfX07"
    }
}
