//
//  main.swift
//  SuperCalendar
//
//  Created by 程巍巍 on 3/18/15.
//  Copyright (c) 2015 Littocats. All rights reserved.
//

import Foundation

println("Hello, World!")

NSDate.LunarComponent.externalInit(context: nil)

println(NSDate().lunarComponent.description)