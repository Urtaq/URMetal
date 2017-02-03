//
//  ZBMetalView.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import UIKit
import MetalKit

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class ZBMetalView: MTKView {

    var vertexBuffer: MTLBuffer!
    var rps: MTLRenderPipelineState! = nil

    func render() {
        self.device = MTLCreateSystemDefaultDevice()

        self.createBuffer()
        self.registerShaders()
        self.sendToGPU()
    }

    func createBuffer() {
        let vertexData = [Vertex(position: [-1.0, -1.0, 0.0, 1.0], color: [1, 0, 0, 1]),
                          Vertex(position: [1.0, -1.0, 0.0, 1.0], color: [0, 1, 0, 1]),
                          Vertex(position: [0.0, 1.0, 0.0, 1.0], color: [0, 0, 1, 1])]
        let dataSize = vertexData.count * MemoryLayout<Vertex>.size
        self.vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    }

    func registerShaders() {
        guard let library = self.device?.newDefaultLibrary() else { return }
        let vertexFunc = library.makeFunction(name: "vertex_func")
        let fragFunc = library.makeFunction(name: "fragment_func")

        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertexFunc
        rpld.fragmentFunction = fragFunc
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            self.rps = try self.device?.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            print("\(error)")
        }
    }

    func sendToGPU() {
        let rpd = MTLRenderPassDescriptor()
        guard let drawable = self.currentDrawable else { return }
        let bleen = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
        rpd.colorAttachments[0].loadAction = .clear

        let commandBuffer = self.device?.makeCommandQueue().makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)

        encoder?.setRenderPipelineState(self.rps)
        encoder?.setVertexBuffer(self.vertexBuffer, offset: 0, at: 0)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)

        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.render()
    }
}
