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

class XTimer:NSObject
{
    private var timer:dispatch_source_t!
    
    init(time:Double,block:dispatch_block_t)
    {
        super.init()
        
        // 获得队列
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
        let start = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)));
        let interval = UInt64(1.0 * Double(NSEC_PER_SEC))
        dispatch_source_set_timer(timer, start, interval, 0)

        dispatch_source_set_event_handler(timer, block)
        
    }
    
    func start()
    {
        dispatch_resume(timer)
    }
    
    func cancel()
    {
        dispatch_source_cancel(timer)
        timer=nil
    }
    
    deinit
    {
        print("XTimer deinit !!!!!!!!")
    }
}

typealias XBannerClickBlock = (XBannerModel)->Void

typealias XBannerIndexBlock = (Int,XBannerModel)->Void

class XBanner: UICollectionView ,UICollectionViewDelegate,UICollectionViewDataSource{

    let flowLayout = UICollectionViewFlowLayout()
    
    
    
    private var clickBlock:XBannerClickBlock?
    private var indexBlock:XBannerIndexBlock?
    
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
            flowLayout.itemSize = CGSizeZero
            layoutIfNeeded()
            setNeedsLayout()
        }
    }
    
    
    
    var index:Int = 0
    {
        didSet
        {
            print("index: \(index)")
            
            if bannerArr.count > 1
            {
                indexBlock?(index,bannerArr[index])
                scrollToItemAtIndexPath(NSIndexPath.init(forRow: index+2, inSection: 0), atScrollPosition: .Left, animated: true)
            }
            
        }
    }
    
    func pageClick()
    {
        if bannerArr.count > 1
        {
            //index = page.currentPage
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
        registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        delegate = self
        dataSource = self
        
    
        
        //page.addTarget(self, action: #selector(pageClick), forControlEvents: .ValueChanged)
        
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
            flowLayout.itemSize = CGSizeMake(frame.size.width, frame.size.height)
            reloadData()
            
            let row:CGFloat = bannerArr.count == 1 ? 0 : 2
            let w:CGFloat = (row*row+CGFloat(bannerArr.count))*frame.size.width
            contentSize = CGSizeMake(w, 0)
            
            contentOffset.x = frame.size.width * row
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if bannerArr.count == 1
        {
            return 1;
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
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
            if let filePath=NSBundle.mainBundle().pathForResource(image, ofType:"")
            {
                if NSFileManager.defaultManager().fileExistsAtPath(filePath)
                {
                    img = UIImageView()
                    img.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)
                    (img as! UIImageView).image = UIImage(contentsOfFile: filePath)
                }
            }
            else
            {
                //网络图片下载
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
        
        print("offset: \(scrollView.contentOffset.x)")
        
        if !scrollView.scrollEnabled{return}

        if(scrollView.contentOffset.x <= frame.size.width )
        {
            scrollView.contentOffset.x=CGFloat(1+bannerArr.count)*frame.size.width
        }
        
        if(scrollView.contentOffset.x >= frame.size.width*CGFloat(bannerArr.count+2))
        {
            scrollView.contentOffset.x=CGFloat(2)*frame.size.width
        }
        
        if(Int(scrollView.contentOffset.x*100)%Int(frame.size.width*100)==0)
        {
            let nowIndex:Int=Int(Int(scrollView.contentOffset.x*100)/Int(frame.size.width*100))-2;
            if(nowIndex != index)
            {
                index = nowIndex
            }
        }
        
    }
    


}
