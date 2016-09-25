//
//  XBanner.swift
//  XBanner
//
//  Created by 徐鹏飞 on 16/6/27.
//  Copyright © 2016年 XBanner. All rights reserved.
//

import UIKit

class XBannerModel:NSObject
{
    var title:String=""
    var image:AnyObject?
    var obj:AnyObject?
}

typealias XBannerClickBlock = (XBannerModel)->Void

typealias XBannerIndexBlock = (Int,XBannerModel)->Void

class XBanner: UICollectionView ,UICollectionViewDelegate,UICollectionViewDataSource
{
    
    let flowLayout = UICollectionViewFlowLayout()
    
    private var clickBlock:XBannerClickBlock?
    private var indexBlock:XBannerIndexBlock?
    private var timer:dispatch_source_t!
    
    var scrollInterval = 0.0
        {
        didSet
        {
            if bannerArr.count > 1
            {
                start()
            }
        }
    }
    
    var scrollleftToRight = false
        {
        didSet
        {
            if bannerArr.count > 1 && scrollInterval  > 0
            {
                start()
            }
            
        }
    }
    
    func click(b:XBannerClickBlock)
    {
        clickBlock = b
    }
    
    func nowIndex(b:XBannerIndexBlock)
    {
        indexBlock = b
    }
    
    func Block(index i:XBannerIndexBlock,click c:XBannerClickBlock)
    {
        indexBlock = i
        clickBlock = c
    }
    
    var bannerArr:[XBannerModel]=[]
        {
        didSet
        {
            flowLayout.itemSize = CGSizeMake(1, 1)
            layoutIfNeeded()
            setNeedsLayout()
            
            if bannerArr.count > 1 && scrollInterval > 0
            {
                self.start()
            }
            else
            {
                self.cancel()
            }
        }
    }
    
    var selectIndex = 0
        {
        didSet
        {
            if bannerArr.count <= 1 || selectIndex < 0 || selectIndex >= bannerArr.count  {return}
            
            let old = index
            
            index = selectIndex
            
            if old == bannerArr.count-1 && selectIndex == 0
            {
                scrollToItemAtIndexPath(NSIndexPath.init(forRow: index+2+bannerArr.count, inSection: 0), atScrollPosition: .Left, animated: true)
                
                return
            }
            
            if old == 0 && selectIndex == bannerArr.count-1
            {
                scrollToItemAtIndexPath(NSIndexPath.init(forRow: 1, inSection: 0), atScrollPosition: .Left, animated: true)
                
                return
            }
            
            scrollToItemAtIndexPath(NSIndexPath.init(forRow: index+2, inSection: 0), atScrollPosition: .Left, animated: true)
        }
    }
    
    private var index:Int = 0
        {
        didSet
        {
            if bannerArr.count > 1
            {
                indexBlock?(index,bannerArr[index])
            }
            
        }
    }
    
    func initBanner()
    {
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing=0.0
        flowLayout.itemSize = CGSizeMake(frame.size.width == 0 ? 1 : frame.size.width, frame.size.height == 0 ? 1 : frame.size.height)
        collectionViewLayout = flowLayout
        
        pagingEnabled = true
        layer.masksToBounds=true
        clipsToBounds = true
        
        backgroundColor = UIColor.whiteColor()
        registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "XBannerCell")
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        delegate = self
        dataSource = self
        
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initBanner()
        
    }
    
    init()
    {
        super.init(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: flowLayout)
        
        initBanner()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initBanner()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if flowLayout.itemSize.width != frame.size.width || flowLayout.itemSize.height != frame.size.height
        {
            if timer != nil{
                dispatch_suspend(timer)
            }
            
            flowLayout.itemSize = CGSizeMake(frame.size.width, frame.size.height)
            reloadData()
            
            let row:CGFloat = bannerArr.count == 1 ? 0 : 2
            let w:CGFloat = (row*row+CGFloat(bannerArr.count))*frame.size.width
            
            let r = (row == 0 ? 0 :  2+CGFloat(index))
            
            contentOffset.x = frame.size.width * r
            
            contentSize = CGSizeMake(w, 0)
            
            if timer != nil{
                let delayInSeconds:Double=1.0
                let popTime:dispatch_time_t=dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                
                dispatch_after(popTime, dispatch_get_main_queue(),{
                    
                    dispatch_resume(self.timer)
                    
                })
                
            }
            
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if bannerArr.count == 0
        {
            return 0
        }
        else if bannerArr.count == 1
        {
            return 1
        }
        else
        {
            return bannerArr.count+4
        }
        
    }
    
    func getTrueIndex(row:Int)->Int
    {
        var i = 0
        if bannerArr.count > 1
        {
            switch row
            {
            case 0:
                i = bannerArr.count-2
                
            case 1:
                i = bannerArr.count-1
                
            case bannerArr.count+2:
                i = 0
                
            case bannerArr.count+3:
                i = 1
                
            default:
                i = row - 2
            }
            
        }
        
        return i
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("XBannerCell", forIndexPath: indexPath)
        
        for item in cell.contentView.subviews
        {
            item.removeFromSuperview()
        }
        
        var img:UIView!
        var o:AnyObject!
        let i = getTrueIndex(indexPath.row)
        
        o = bannerArr[i].image
        
        
        if let image = o as? String
        {
            img = UIImageView()
            img.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
            
            if let filePath=NSBundle.mainBundle().pathForResource(image, ofType:"")
            {
                if NSFileManager.defaultManager().fileExistsAtPath(filePath)
                {
                    (img as! UIImageView).image = UIImage(contentsOfFile: filePath)
                }
            }
            else
            {
                //网络图片下载
                //(img as! UIImageView).useAnimation = false
                //(img as! UIImageView).url = image
            }
            
        }
        
        if let  image = o as? UIImage
        {
            img = UIImageView()
            img.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
            (img as! UIImageView).image = image
        }
        
        if let  image = o as? UIView
        {
            img = image
        }
        
        cell.contentView.addSubview(img)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let i = getTrueIndex(indexPath.row)
        let o = bannerArr[i]
        clickBlock?(o)
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !scrollView.scrollEnabled || bannerArr.count == 0{return}
        
        if(scrollView.contentOffset.x <= frame.size.width )
        {
            scrollView.contentOffset.x=CGFloat(1+bannerArr.count)*frame.size.width
        }
        
        if(scrollView.contentOffset.x >= frame.size.width*CGFloat(bannerArr.count+2))
        {
            scrollView.contentOffset.x=CGFloat(2)*frame.size.width
        }
        
        var nowIndex = Int(round(scrollView.contentOffset.x / frame.size.width)) - 2
        
        nowIndex = nowIndex < 0 ? bannerArr.count-1 : nowIndex
        nowIndex = nowIndex >= bannerArr.count ?  0 : nowIndex
        
        if(nowIndex != index)
        {
            self.index = nowIndex
        }
        
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x % frame.size.width != 0
        {
            let x = round(scrollView.contentOffset.x / frame.size.width)
            
            scrollView.contentOffset.x = frame.size.width * x
            
        }
        
    }
    
    func cancel()
    {
        if timer != nil
        {
            dispatch_source_cancel(timer)
            timer=nil
        }
        
    }
    
    func start()
    {
        self.cancel()
        if self.scrollInterval == 0.0 {return}
        // 获得队列
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        //延迟多久执行
        let start = dispatch_time(DISPATCH_TIME_NOW, Int64(scrollInterval * Double(NSEC_PER_SEC)));
        
        //时间间隔
        let i = UInt64(scrollInterval * Double(NSEC_PER_SEC))
        
        
        //其中的dispatch_source_set_timer的最后一个参数，是最后一个参数（leeway），它告诉系统我们需要计时器触发的精准程度。所有的计时器都不会保证100%精准，这个参数用来告诉系统你希望系统保证精准的努力程度。如果你希望一个计时器每5秒触发一次，并且越准越好，那么你传递0为参数。另外，如果是一个周期性任务，比如检查email，那么你会希望每10分钟检查一次，但是不用那么精准。所以你可以传入60，告诉系统60秒的误差是可接受的。他的意义在于降低资源消耗。
        
        dispatch_source_set_timer(timer, start, i, 0)
        
        //执行事件 有次数的话 完成就自动停止
        dispatch_source_set_event_handler(timer) {[weak self]()->Void in
            if self == nil {return}
            
            var i = self!.index
            
            if self!.scrollleftToRight == true
            {
                i  -= 1
            }
            else
            {
                i += 1
            }
            
            i = i < 0 ? self!.bannerArr.count-1 : i
            i = i >= self!.bannerArr.count ?  0 : i
            
            self!.selectIndex = i
            
        }
        
        dispatch_resume(timer)
        
        
    }
    
}
