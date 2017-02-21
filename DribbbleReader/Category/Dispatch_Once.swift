//
//  Dispatch_Once.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/21.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform. or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    //使用UUID作为token
    public class func once(block:()->Void) {
        let token = NSUUID().uuidString
        DispatchQueue.once(token: token, block: block)
    }
}
