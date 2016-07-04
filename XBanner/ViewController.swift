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
    var timer1:XTimer?
    var timer2:XTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var i = 20
        
        timer = XTimer(interval: 1.0, block: { [weak self](o) in
            
            i -= 1
            
            print( i)
            //print(NSThread.currentThread())
            
            if i == 0
            {
                o.cancel()
                self?.timer=nil
            }

            
        })
        
        //self.timer?.start()
        
        timer1 = XTimer(interval: 1.0, repeats: 10, block: {[weak self] (o) in
            
            print("nowTimes: \(o.nowTimes)")
            
            if o.nowTimes == 9
            {
                self?.timer1 = nil
            }
            
        })
        
        //timer1?.start()
        
        timer2 = XTimer(delay: 5.0, interval: 1.0, repeats: 1) { [weak self](o) in
            
            print("延迟执行!!!!!")
            
        }
        
        //timer2?.start()
        
        XTimer.AsyncDo { 
            self.timer?.start()
        }
        
        XTimer.AsyncDo {
            self.timer1?.start()
        }
        
        XTimer.AsyncDo {
            self.timer2?.start()
        }
        
        
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

