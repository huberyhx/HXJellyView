//
//  ViewController.swift
//  HXJellyView
//
//  Created by hubery on 2017/6/5.
//  Copyright © 2017年 hubery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let jellyView = HXJellyView()
        jellyView.frame = CGRect.init(x: 0, y: 0, width: Main_Width, height: Main_Height)
        view.addSubview(jellyView)
    }


}

