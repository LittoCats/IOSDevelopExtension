//
//  ScriptLibrary.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//
//  该文件保存其它文件需要的大段脚本

import Foundation

struct ScriptLibrary {
    private static let root = NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("ScriptsLibrary")
    static var coffee_script_js: String{
        get{
            return NSString(contentsOfFile: root.stringByAppendingPathComponent("coffeescript.js"), encoding: NSUTF8StringEncoding, error: nil)!
        }
    }
    static var super_calendar_js: String{
        get{
            var script = NSString(contentsOfFile: root.stringByAppendingPathComponent("SuperCalendar.coffee"), encoding: NSUTF8StringEncoding, error: nil)!
            return CoffeeScript.compile(script: script)
        }
    }
}
