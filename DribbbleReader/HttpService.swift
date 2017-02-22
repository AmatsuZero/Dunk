//
//  HttpService.swift
//  DribbbleReader
//
//  Created by naoyashiga on 2015/05/17.
//  Copyright (c) 2015年 naoyashiga. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class HttpService {
    class func getJSON(_ url: String, callback:@escaping ((NSArray) -> Void)) {
        let nsURL = URL(string: url)!
        let request = Alamofire.request(nsURL)
        request.responseJSON { response in
            if let JSON = response.result.value {
                callback(JSON as! NSArray)
            } else {
                request.cancel()
            }
        }
    }

}
