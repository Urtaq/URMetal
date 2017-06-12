//
//  DetailViewController.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 3. 7..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import MetalKit

class DetailViewController: UIViewController {
    var mtkView: MTKView!
    var loadable: Bool = true

    var delegate: ZBMTKViewDelegate! = ZBMTKViewDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mtkView = MTKView(frame: CGRect.zero, device: self.delegate.device)
        self.mtkView.delegate = self.delegate

        self.view.addSubview(self.mtkView)

        self.mtkView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: ["view": self.mtkView]))
        self.view.addConstraint(NSLayoutConstraint(item: self.mtkView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: self.mtkView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.mtkView, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0))

        self.mtkView.layoutIfNeeded()
        self.mtkView.draw()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.loadable = false
    }

    @IBAction func buttonDidTap(_ sender: Any) {
        if self.delegate != nil {
            self.delegate = nil
        } else {
            self.delegate = ZBMTKViewDelegate()

            self.mtkView.delegate = self.delegate
            self.mtkView.draw()
        }
    }
}
