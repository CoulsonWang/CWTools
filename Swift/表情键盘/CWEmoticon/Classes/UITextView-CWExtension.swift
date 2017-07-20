//
//  UITextView-Extension.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/9.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit

extension UITextView {
    func insertEmoticon(emoticon : Emoticon) -> Void {
        if emoticon.isEmpty {
            return
        }
        if emoticon.isRemove {
            deleteBackward()
            return
        }
        if emoticon.emojiCode != nil {
            replace(selectedTextRange!, withText: emoticon.emojiCode!)
            return
        }
        
        //插入图片
        let attachment = EmoticonAttachment()
        attachment.image = UIImage(contentsOfFile: emoticon.pngPath!)
        attachment.chs = emoticon.chs
        let font = self.font!
        
        attachment.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
        let attrImageStr = NSAttributedString(attachment: attachment)
        
        let attrMStr : NSMutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        let range = selectedRange
        attrMStr.replaceCharacters(in: range, with: attrImageStr)
        attributedText = attrMStr
        
        //重置文字大小
        self.font = font
        
        //将光标移动至原位置
        selectedRange = NSRange(location: range.location + 1 , length: 0)
    }
    
    func getEmoticonString() -> String {
        let attrMStr = NSMutableAttributedString(attributedString: attributedText)
        
        let range = NSRange(location: 0, length: attrMStr.length)
        attrMStr.enumerateAttributes(in: range, options: []) { (dict, range, _) in
            if let attachment = dict["NSAttachment"] as? EmoticonAttachment {
                attrMStr.replaceCharacters(in: range, with: attachment.chs!)
            }
        }
        return attrMStr.string
    }
}
