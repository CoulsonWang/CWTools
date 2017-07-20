//
//  EmoticonPackage.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/9.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//  表情包模型

import UIKit

class EmoticonPackage: NSObject {
    
    var emoticons : [Emoticon] = [Emoticon]()
    
    init(id : String) {
        super.init()
        if id == "" {
            addEmptyEmoticon(isRecently: true)
            return
        }
        let plistPath = Bundle.main.path(forResource: "\(id)/info.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        guard let array = NSArray(contentsOfFile: plistPath) else { return }
        let dictArray = array as! [[String : String]]
        
        var index = 0
        for var dict in dictArray {
            //给png路径前拼接上文件夹路径
            if let png = dict["png"] {
                dict["png"] = id + "/" + png
            }
            emoticons.append(Emoticon(dict: dict))
            index += 1
            if index == 20 {
                emoticons.append(Emoticon(isRemove: true))
                index = 0
            }
        }
        addEmptyEmoticon(isRecently: false)
    }
    
    private func addEmptyEmoticon(isRecently : Bool) {
        let count = emoticons.count % 21
        if count == 0 && !isRecently {
            return
        }
        
        for _ in count..<20 {
            emoticons.append(Emoticon(isEmpty: true))
        }
        emoticons.append(Emoticon(isRemove: true))
    }
}
