//
//  EmoticonKeyboardController.swift
//  表情键盘
//
//  Created by Coulson_Wang on 2017/7/8.
//  Copyright © 2017年 Coulson_Wang. All rights reserved.
//

import UIKit

private let EmoticonCellID = "EmoticonCellID"
private let colum : Int = 7
private let row : Int = 3
private let spaceBetweenEmoticon : CGFloat = 0

class EmoticonKeyboardController: UIViewController {
    
    var emoticonCallBack : (_ emoticon : Emoticon) -> ()
    
    
    fileprivate lazy var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonCollectionViewLayout())
    fileprivate lazy var toolBar : UIToolbar = UIToolbar()
    fileprivate lazy var manager = EmoticonManager()
    
    init(emoticonCallBack : @escaping (_ emoticon : Emoticon) -> ()) {
        self.emoticonCallBack = emoticonCallBack
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

}
// MARK:- 初始化设置
extension EmoticonKeyboardController  {
    fileprivate func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        collectionView.backgroundColor = UIColor.lightGray
        //用VFL设置约束
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let views : [String : Any] = ["TB" : toolBar, "CV" : collectionView]
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[TB]-0-|", options: [], metrics: nil, views: views)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[CV]-0-[TB]-0-|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views)
        view.addConstraints(cons)
        
        prepareForCollectionView()
        
        prepareForToolBar()
    }
    
    private func prepareForCollectionView() {
        collectionView.register(EmoticonCell.self, forCellWithReuseIdentifier: EmoticonCellID)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func prepareForToolBar() {
        let titles = ["最近","默认","emoji","浪小花"]
        
        var index = 0
        var tempItems = [UIBarButtonItem]()
        for title in titles {
            let item : UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(itemClick(item:)))
            item.tag = index
            index += 1
            tempItems.append(item)
            tempItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        tempItems.removeLast()
        toolBar.items = tempItems
        toolBar.tintColor = UIColor.orange
    }
    
    func itemClick(item : UIBarButtonItem) {
        let tag = item.tag
        let indexPath = IndexPath(item: 0, section: tag)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

// MARK:- 代理和数据源
extension EmoticonKeyboardController : UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager.packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let package = manager.packages[section]
        
        return package.emoticons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonCellID, for: indexPath) as! EmoticonCell
        
        let package = manager.packages[indexPath.section]
        let emoticon = package.emoticons[indexPath.item]
        cell.emoticon = emoticon
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let package = manager.packages[indexPath.section]
        let emoticon = package.emoticons[indexPath.item]
        
        insertRecentlyEmoticon(emoticon: emoticon)
        
        emoticonCallBack(emoticon)
    }
    
    /// 给最近使用中插入选中的表情
    ///
    /// - Parameter emoticon: 选中的表情
    private func insertRecentlyEmoticon(emoticon : Emoticon) {
        guard !emoticon.isEmpty && !emoticon.isRemove else {
            return
        }
        //删除一个表情
        if manager.packages.first!.emoticons.contains(emoticon) {
            let index = (manager.packages.first?.emoticons.index(of: emoticon))!
            manager.packages.first?.emoticons.remove(at: index)
        } else {
            manager.packages.first?.emoticons.remove(at: 19)
        }
        //插入表情
        manager.packages.first?.emoticons.insert(emoticon, at: 0)
    }
}

// MARK:- 自定义流水布局
class EmoticonCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        let itemWH = (UIScreen.main.bounds.width - CGFloat(colum - 1) * spaceBetweenEmoticon) / CGFloat(colum)
        
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = spaceBetweenEmoticon
        minimumInteritemSpacing = spaceBetweenEmoticon
        scrollDirection = .horizontal
        
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        
        let insetMargin = ((collectionView?.bounds.height)! - CGFloat(row) * itemWH - CGFloat(row) * spaceBetweenEmoticon) / 2
        collectionView?.contentInset = UIEdgeInsets(top: insetMargin, left: 0, bottom: insetMargin, right: 0)
    }
}
