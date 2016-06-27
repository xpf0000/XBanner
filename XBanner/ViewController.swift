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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var arr:[XBannerModel] = []
        for i in 1...4
        {
            let model = XBannerModel()
            model.image = "\(i).jpg"
            arr.append(model)
        }
        
        banner.bannerArr = arr
        
       banner.click { (model) in
        
        print(model.image)
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }


}

