//
//  EmoticonCell.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/9.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit

class EmoticonCell: UICollectionViewCell {
    
    var emoticon : Emoticon? {
        didSet {
            guard let emoticon = emoticon else { return }
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon.pngPath ?? ""), for: .normal)
            emoticonButton.setTitle(emoticon.emojiCode, for: .normal)
            
            guard emoticon.isRemove else { return }
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon.bundlePath! + "compose_emotion_delete"), for: .normal)
            
            guard emoticon.isEmpty else { return }
            emoticonButton.setImage(nil, for: .normal)
            emoticonButton.setTitle(nil, for: .normal)
        }
    }
    fileprivate lazy var emoticonButton : UIButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmoticonCell {
    fileprivate func setupUI() {
        contentView.addSubview(emoticonButton)
        emoticonButton.frame = contentView.bounds
        emoticonButton.isUserInteractionEnabled = false
        emoticonButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
}
