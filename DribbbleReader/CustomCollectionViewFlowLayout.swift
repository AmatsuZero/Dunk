//
//  CustomCollectionViewLayout.swift
//  DribbbleReader
//
//  Created by 姜振华 on 2017/2/22.
//  Copyright © 2017年 naoyashiga. All rights reserved.
//

import UIKit

class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
   
    override init() {
        super.init()
        scrollDirection = .vertical
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
