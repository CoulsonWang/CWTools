//
//  EmoticonManager.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/9.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit

class EmoticonManager {
    var packages : [EmoticonPackage] = [EmoticonPackage]()
    
    init() {
        packages.append(EmoticonPackage(id: ""))
        packages.append(EmoticonPackage(id: "com.sina.default"))
        packages.append(EmoticonPackage(id: "com.apple.emoji"))
        packages.append(EmoticonPackage(id: "com.sina.lxh"))
    }
}
