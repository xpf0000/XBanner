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

typealias XTimerBlock = (XTimer)->Void

class XTimer:NSObject
{
    private var timer:dispatch_source_t!
    //private var eventBlock:dispatch_block_t!
    private var eventBlock:XTimerBlock?
    
    var delay = 0.0  //延迟时间
    var interval = 1.0 //每次间隔
    var leeway:UInt64 = 0 //期望误差范围
    var repeats = 0
    
    private var index = 0
    
    var nowTimes:Int{
        return index
    }
    
    func setEvent(block:XTimerBlock)
    {
        eventBlock = block
    }
    
    override init() {
        super.init()
    }
    
    init(interval:Double) {
        super.init()
        self.interval = interval
    }
    
    init(interval:Double,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        eventBlock = block
    }
    
    init(interval:Double,leeway:UInt64,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        self.leeway = leeway
        eventBlock = block
    }
    
    init(interval:Double,repeats:Int,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        self.repeats = repeats
        eventBlock = block
    }

    
    init(delay:Double,interval:Double,leeway:UInt64,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        self.delay = delay
        self.leeway = leeway
        eventBlock = block
    }
    
    init(delay:Double,interval:Double,repeats:Int,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        self.delay = delay
        self.repeats = repeats
        eventBlock = block
    }
    
    init(delay:Double,interval:Double,block:XTimerBlock)
    {
        super.init()
        self.interval = interval
        self.delay = delay
        eventBlock = block
    }

    
    func start()
    {
        self.cancel()
        
        // 获得队列
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 创建一个定时器(dispatch_source_t本质还是个OC对象)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        
        // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
        // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
        // 何时开始执行第一个任务
        // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
        let start = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)));
        let i = UInt64(interval * Double(NSEC_PER_SEC))
        
        
        //其中的dispatch_source_set_timer的最后一个参数，是最后一个参数（leeway），它告诉系统我们需要计时器触发的精准程度。所有的计时器都不会保证100%精准，这个参数用来告诉系统你希望系统保证精准的努力程度。如果你希望一个计时器每5秒触发一次，并且越准越好，那么你传递0为参数。另外，如果是一个周期性任务，比如检查email，那么你会希望每10分钟检查一次，但是不用那么精准。所以你可以传入60，告诉系统60秒的误差是可接受的。他的意义在于降低资源消耗。
        
        dispatch_source_set_timer(timer, start, i, leeway)
        
        //dispatch_source_set_event_handler(timer, eventBlock)
        
        dispatch_source_set_event_handler(timer) {[weak self]()->Void in
            
            self?.eventBlock?(self!)
            
            self?.index += 1
            
            if self?.repeats > 0 && self?.index == self?.repeats
            {
                self?.cancel()
            }
        }

        dispatch_resume(timer)
        
        
    }
    
    func cancel()
    {
        if timer != nil
        {
            dispatch_source_cancel(timer)
            timer=nil
            
            print("任务完成!!!!!!!!!!!!")
        }
        
    }
    
    
    class func MainDo(block:dispatch_block_t)
    {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    class func AsyncDo(block:dispatch_block_t)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    class func DelayDo(time:NSTimeInterval,block:dispatch_block_t)
    {
        let delayInSeconds:Double=time
        let popTime:dispatch_time_t=dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(popTime, dispatch_get_main_queue(),block)
        
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
