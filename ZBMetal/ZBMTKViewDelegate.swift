//
//  ZBMTKViewDelegate.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 28..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import MetalKit

public class ZBMTKViewDelegate: NSObject, MTKViewDelegate, UIGestureRecognizerDelegate {

    var device: MTLDevice!
    var queue: MTLCommandQueue!
    var cps: MTLComputePipelineState!

    var timer: Float = 0
    var timerBuffer: MTLBuffer!
    var pos: CGPoint!
    var mouseBuffer: MTLBuffer!

    var tapGesture: UITapGestureRecognizer!

    public override init() {
        super.init()

        self.device = MTLCreateSystemDefaultDevice()
        self.registerShaders()

        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    }

    func registerShaders() {
        self.queue = self.device.makeCommandQueue()

        guard let library = self.device.newDefaultLibrary() else { return }
        let kernel = library.makeFunction(name: "computeMin")

        do {
            self.cps = try self.device?.makeComputePipelineState(function: kernel!)
        } catch let error {
            print("\(error)")
        }
        self.timerBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        self.mouseBuffer = self.device?.makeBuffer(length: MemoryLayout<CGPoint>.size, options: [])
    }

    func update() {
        self.timer += 0.01
        var bufferPointer = self.timerBuffer.contents()
        memcpy(bufferPointer, &self.timer, MemoryLayout<Float>.size)
        bufferPointer = self.mouseBuffer.contents()
        memcpy(bufferPointer, &self.pos, MemoryLayout<CGPoint>.size)
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }

    var drawnView: MTKView!

    public func draw(in view: MTKView) {
        view.framebufferOnly = false

        view.addGestureRecognizer(self.tapGesture)
        self.drawnView = view

        guard let drawable = view.currentDrawable else { return }

        let commandBuffer = self.queue.makeCommandBuffer()
        let encoder = commandBuffer.makeComputeCommandEncoder()

        encoder.setComputePipelineState(self.cps)
        encoder.setTexture(drawable.texture, at: 0)
        encoder.setBuffer(self.timerBuffer, offset: 0, at: 1)
        encoder.setBuffer(self.mouseBuffer, offset: 0, at: 2)
        self.update()

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func handleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.pos = gesture.location(in: self.drawnView)
            let scale = self.drawnView.layer.contentsScale
            pos.x *= scale
            pos.y *= scale
        }
    }
}
