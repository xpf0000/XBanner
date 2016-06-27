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

typealias XBannerBlock = (XBannerModel)->Void

class XBanner: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    @IBOutlet weak var collect: UICollectionView!
    
    @IBOutlet weak var titleH: NSLayoutConstraint!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var btitle: UILabel!
    
    @IBOutlet weak var page: UIPageControl!
    
    private var block:XBannerBlock?
    
    func click(b:XBannerBlock)
    {
        self.block = b
    }
    
    var bannerArr:[XBannerModel]=[]
    {
        didSet
        {
            print(bannerArr.count)
            page.numberOfPages =  bannerArr.count
            
            layoutIfNeeded()
            setNeedsLayout()
            
        }
    }
    
    
    
    var index:Int = 0
    {
        didSet
        {
            page.currentPage = index
            
            if bannerArr.count > 1
            {
                collect.scrollToItemAtIndexPath(NSIndexPath.init(forRow: index+2, inSection: 0), atScrollPosition: .Left, animated: true)
            }
            
        }
    }
    
    func pageClick()
    {
        if bannerArr.count > 1
        {
            index = page.currentPage
        }
    }
    
    func initBanner()
    {
        let nib = UINib(nibName: "XBanner", bundle: nil)
        let containerView:UIView=(nib.instantiateWithOwner(self, options: nil))[0] as! UIView
        let newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        containerView.frame = newFrame
        self.addSubview(containerView)
      
        collect.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        page.addTarget(self, action: #selector(pageClick), forControlEvents: .ValueChanged)
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.initBanner()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initBanner()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = collect?.collectionViewLayout as? UICollectionViewFlowLayout
        
        layout?.itemSize = CGSizeMake(frame.size.width, frame.size.height)
        
        collect.reloadData()
        
        let row:CGFloat = bannerArr.count == 1 ? 0 : 2
        let w:CGFloat = (row*row+CGFloat(bannerArr.count))*frame.size.width
        collect.contentSize = CGSizeMake(w, 0)
        
        collect.contentOffset.x = frame.size.width * row
        
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
        block?(o)
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
