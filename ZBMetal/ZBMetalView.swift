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

        let vertexData: [Float] = [-1.0, -1.0, 0.0, 1.0,
                                   1.0, -1.0, 0.0, 1.0,
                                   0.0, 1.0, 0.0, 1.0]
        let dataSize = vertexData.count * MemoryLayout<Float>.size
        let vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        guard let library = self.device?.newDefaultLibrary() else { return }
        let vertexFunc = library.makeFunction(name: "vertex_func")
        let fragFunc = library.makeFunction(name: "fragment_func")

        let rpd = MTLRenderPassDescriptor()
        guard let drawable = self.currentDrawable else { return }
        let bleen = MTLClearColor(red: 0, green: 0.5, blue: 0.5, alpha: 1)
        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear

        let commandBuffer = self.device?.makeCommandQueue().makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)

        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertexFunc
        rpld.fragmentFunction = fragFunc
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm

        guard let rps = try! self.device?.makeRenderPipelineState(descriptor: rpld) else { return }
        encoder?.setRenderPipelineState(rps)
        encoder?.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)

        // display
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.render()
    }
}
