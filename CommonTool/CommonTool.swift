//
//  CommonTool.swift
//  CommonTool
//
//  Created by 程巍巍 on 3/20/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation
import JavaScriptCore

class CommonTool: NSObject {
    private struct StaticContext {
        static var jsContext: JSContext = JSContext()
    }
    
    override class func load(){
        CoffeeScript.externalInit(StaticContext.jsContext)  // 初始化 CoffeeScript 编译器，必须为第一个
    }
}

struct CoffeeScript {
    private static var compiler: JSValue!
    private static var runner: JSValue!
    private static var evaler: JSValue!
    private static func externalInit(context: JSContext){
        var coffeescript = ScriptLibrary.coffee_script_js
        context.evaluateScript(coffeescript)
        CoffeeScript.compiler = context.evaluateScript("CoffeeScript.compile")
        CoffeeScript.runner = context.evaluateScript("CoffeeScript.run")
        CoffeeScript.evaler = context.evaluateScript("CoffeeScript.eval")
    }
    
    static func compile(#script: String, bare: Bool = false) ->String{
        return CoffeeScript.compiler.callWithArguments([script, ["bare": bare]]).toString()
    }
    
    static func run(#script: String) ->AnyObject{
        return CoffeeScript.runner.callWithArguments([script]).toObject()
    }
    
    static func eval(#script: String) ->AnyObject{
        return CoffeeScript.evaler.callWithArguments([script]).toObject()
    }
}
