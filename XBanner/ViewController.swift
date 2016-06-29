//
//  ViewController.swift
//  XBanner
//
//  Created by 徐鹏飞 on 16/6/27.
//  Copyright © 2016年 XBanner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var banner: XBanner!
    
    @IBOutlet weak var page: UIPageControl!
    
    
    @IBAction func pageClick(sender: UIPageControl) {
        
        banner.index = sender.currentPage
        
    }
    
    var timer:XTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 20
        timer = XTimer(time: 1.0) {[weak self]()->Void in
            
            i -= 1
            
            
            
            print( i)
            
            if i == 0
            {
                self?.timer?.cancel()
                self?.timer=nil
            }
            
        }
        
        timer?.start()
        
        var arr:[XBannerModel] = []
        for i in 1...4
        {
            let model = XBannerModel()
            model.image = "\(i).jpg"
            arr.append(model)
        }
        
        banner.bannerArr = arr
        page.numberOfPages = arr.count
        
       banner.Block(index: { [weak self](index, m) in
        
        self?.page.currentPage = index
        
        }) { [weak self](m) in
            
            print(m.image)
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }


}

