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

    var vertexBuffer: MTLBuffer!
    var rps: MTLRenderPipelineState! = nil

    var indexBuffer: MTLBuffer!

    var uniformBuffer: MTLBuffer!

    var rotation: Float = 0

    required init(coder: NSCoder) {
        super.init(coder: coder)

        self.device = MTLCreateSystemDefaultDevice()

        self.createBuffer()
        self.registerShaders()
    }

    func createBuffer() {
        let vertexData = [Vertex(position: [-1.0, -1.0,  1.0, 1.0], color: [1, 0, 0, 1]),
                          Vertex(position: [ 1.0, -1.0,  1.0, 1.0], color: [0, 1, 0, 1]),
                          Vertex(position: [ 1.0,  1.0,  1.0, 1.0], color: [0, 0, 1, 1]),
                          Vertex(position: [-1.0,  1.0,  1.0, 1.0], color: [1, 1, 1, 1]),
                          Vertex(position: [-1.0, -1.0, -1.0, 1.0], color: [0, 0, 1, 1]),
                          Vertex(position: [ 1.0, -1.0, -1.0, 1.0], color: [1, 1, 1, 1]),
                          Vertex(position: [ 1.0,  1.0, -1.0, 1.0], color: [1, 0, 0, 1]),
                          Vertex(position: [-1.0,  1.0, -1.0, 1.0], color: [0, 1, 0, 1])]
        let dataSize = vertexData.count * MemoryLayout<Vertex>.size
        self.vertexBuffer = self.device?.makeBuffer(bytes: vertexData, length: dataSize, options: [])

        let indexData: [UInt16] = [0, 1, 2, 2, 3, 0, // front
                                   1, 5, 6, 6, 2, 1, // right
                                   3, 2, 6, 6, 7, 3, // top
                                   4, 5, 1, 1, 0, 4, // bottom
                                   4, 0, 3, 3, 7, 4, // left
                                   7, 6, 5, 5, 4, 7] // back
        self.indexBuffer = self.device?.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size * indexData.count, options: [])

        self.uniformBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
        let bufferPointer = self.uniformBuffer.contents()

        let aspect = Float(self.drawableSize.width / self.drawableSize.height)
        let projMatrix = projectionMatrix(near: 1, far: 100, aspect: aspect, fovy: 1.1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix(), modelMatrix()))
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }

    func update() {
        let scaled = scalingMatrix(scale: 0.5)
        self.rotation += 1 / 100 * Float.pi / 4
        let rotatedY = rotationMatrix(angle: self.rotation, axis: float3(0, 1, 0))
        let rotatedX = rotationMatrix(angle: Float.pi / 4, axis: float3(1, 0, 0))
        let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
        let cameraPosition = vector_float3(0, 0, -3)
        let viewMatrix = translationMatrix(position: cameraPosition)
        let aspect = Float(self.drawableSize.width / self.drawableSize.height)
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: aspect, fovy: 1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        let bufferPointer = self.uniformBuffer.contents()
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
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

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.update()

        guard let rpd = self.currentRenderPassDescriptor else { return }
        guard let drawable = self.currentDrawable else { return }
        let bleen = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
//        rpd.colorAttachments[0].texture = drawable.texture
        rpd.colorAttachments[0].clearColor = bleen
//        rpd.colorAttachments[0].loadAction = .clear

        let commandBuffer = self.device?.makeCommandQueue().makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)

        encoder?.setFrontFacing(MTLWinding.counterClockwise)
        encoder?.setCullMode(MTLCullMode.back)
        encoder?.setRenderPipelineState(self.rps)
        encoder?.setVertexBuffer(self.vertexBuffer, offset: 0, at: 0)
        encoder?.setVertexBuffer(self.uniformBuffer, offset: 0, at: 1)
        encoder?.setTriangleFillMode(MTLTriangleFillMode.lines)
        encoder?.drawIndexedPrimitives(type: .triangle, indexCount: self.indexBuffer.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: self.indexBuffer, indexBufferOffset: 0)

        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
