//
//  ZBMetalView.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import UIKit
import MetalKit

public class ZBMetalView: MTKView {

    var vertexBuffer: MTLBuffer!
    var rps: MTLRenderPipelineState! = nil

    var uniformBuffer: MTLBuffer!

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)

        self.createBuffer()
        self.registerShaders()
    }

    func createBuffer() {
        let vertexData = [Vertex(pos: [-1.0, -1.0, 0.0, 1.0], col: [1, 0, 0, 1]),
                          Vertex(pos: [1.0, -1.0, 0.0, 1.0], col: [0, 1, 0, 1]),
                          Vertex(pos: [0.0, 1.0, 0.0, 1.0], col: [0, 0, 1, 1])]
        let dataSize = vertexData.count * MemoryLayout<Vertex>.size
        self.vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        self.uniformBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        let bufferPointer = self.uniformBuffer.contents()
        memcpy(bufferPointer, Matrix().modelMatrix(Matrix()).m, MemoryLayout<Float>.size * 16)
    }

    func registerShaders() {
        let path = Bundle.main.path(forResource: "ZBDefaultMetal", ofType: "metal")
        let input: String?
        let library: MTLLibrary
        let vertexFunc: MTLFunction
        let fragFunc: MTLFunction

        do {
            input = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            library = try self.device!.makeLibrary(source: input!, options: nil)
            vertexFunc = library.makeFunction(name: "vertex_func")!
            fragFunc = library.makeFunction(name: "fragment_func")!

            let rpld = MTLRenderPipelineDescriptor()
            rpld.vertexFunction = vertexFunc
            rpld.fragmentFunction = fragFunc
            rpld.colorAttachments[0].pixelFormat = .bgra8Unorm

            self.rps = try self.device?.makeRenderPipelineState(descriptor: rpld)
        } catch let e {
            print(e)
        }
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let rpd = self.currentRenderPassDescriptor else { return }
        guard let drawable = self.currentDrawable else { return }
        let bleen = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
//        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
//        rpd.colorAttachments[0].loadAction = .clear

        let commandBuffer = self.device?.makeCommandQueue().makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)

        encoder?.setRenderPipelineState(self.rps)
        encoder?.setVertexBuffer(self.vertexBuffer, offset: 0, at: 0)
        encoder?.setVertexBuffer(self.uniformBuffer, offset: 0, at: 1)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)

        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
