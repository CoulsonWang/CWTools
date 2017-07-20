//
//  Emoticon.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/9.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//  单个表情模型

import UIKit

class Emoticon: NSObject {
    var code : String? {
        didSet {
            guard let code = code else { return }
            let scanner = Scanner(string: code)
            var value : UInt32 = 0
            scanner.scanHexInt32(&value)
            let c = Character(UnicodeScalar(value)!)
            emojiCode = String.init(c)
        }
    }
    var png : String? {
        didSet {
            guard let png = png else { return }
            //全路径
            pngPath = Bundle.main.bundlePath + "/Emoticons.bundle/" + png
        }
    }
    var chs : String?
    
    // MARK:- 处理属性
    var pngPath : String?
    var emojiCode : String?
    var isRemove : Bool = false
    var isEmpty : Bool = false
    var bundlePath : String?
    
    init(dict : [String : String]) {
        super.init()
        setValuesForKeys(dict)
    }
    init(isRemove : Bool) {
        super.init()
        self.isRemove = isRemove
        bundlePath = Bundle.main.bundlePath + "/Emoticons.bundle/"
    }
    init(isEmpty : Bool) {
        super.init()
        self.isEmpty = isEmpty
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
}
