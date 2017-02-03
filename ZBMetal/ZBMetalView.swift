//
//  ZBMetalView.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import UIKit
import MetalKit

class ZBMetalView: MTKView {

    func render() {
        self.device = MTLCreateSystemDefaultDevice()

        let rpd = MTLRenderPassDescriptor()
        let bleen = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
        rpd.colorAttachments[0].texture = self.currentDrawable!.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear

        let commandQueue = self.device?.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        encoder?.endEncoding()
        commandBuffer?.present(currentDrawable!)
        commandBuffer?.commit()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.render()
    }
}
