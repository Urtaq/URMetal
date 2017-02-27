//
//  ViewController.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

//        let delegate = ZBMTKViewDelegate()
//        let view = MTKView(frame: CGRect.zero, device: delegate.device)
//        view.delegate = delegate
//
//        self.view.addSubview(view)
//
//        view.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["view" : view]))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[view(300)]", options: [], metrics: nil, views: ["view" : view]))
//
//        view.layoutIfNeeded()
//        view.delegate?.draw(in: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

