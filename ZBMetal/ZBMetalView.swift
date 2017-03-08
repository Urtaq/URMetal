//
//  ZBMetalView.swift
//  ZBMetal
//
//  Created by DongSoo Lee on 2017. 2. 3..
//  Copyright © 2017년 zigbang. All rights reserved.
//

import MetalKit

struct CGFloatPoint {
    var x: Float
    var y: Float

    static var zero: CGFloatPoint {
        return CGFloatPoint(x: 0, y: 0)
    }

    init(x: CGFloat, y: CGFloat) {
        self.x = Float(x)
        self.y = Float(y)
    }
}

func ==(left: CGFloatPoint, right: CGFloatPoint) -> Bool {
    return left.x == right.x && left.y == right.y
}

class ZBMetalView: MTKView, UIGestureRecognizerDelegate {

    var queue: MTLCommandQueue!
    var cps: MTLComputePipelineState!

    var timer: Float = 0
    var timerBuffer: MTLBuffer!

    var texture: MTLTexture!

    var pos: CGFloatPoint = CGFloatPoint.zero
    var gestureBuffer: MTLBuffer!
    var panGesture: UIPanGestureRecognizer!

    required init(coder: NSCoder) {
        super.init(coder: coder)

        self.framebufferOnly = false

        self.device = MTLCreateSystemDefaultDevice()

        self.registerShaders()
        self.setUpTexture()

        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(self.panGesture)
    }

    func registerShaders() {
        self.queue = self.device?.makeCommandQueue()

        guard let library = self.device?.newDefaultLibrary() else { return }
        let kernel = library.makeFunction(name: "compute")

        do {
            self.cps = try self.device?.makeComputePipelineState(function: kernel!)
        } catch let error {
            print("\(error)")
        }
        self.timerBuffer = self.device?.makeBuffer(length: MemoryLayout<Float>.size, options: [])
        self.gestureBuffer = self.device?.makeBuffer(length: MemoryLayout<CGPoint>.size, options: [])
    }

    func setUpTexture() {
        let path = Bundle.main.path(forResource: "texture", ofType: "jpg")
        let textureLoader = MTKTextureLoader(device: self.device!)

        self.texture = try! textureLoader.newTexture(withContentsOf: URL(fileURLWithPath: path!), options: nil)
    }

    func update() {
        if self.timer < 5 {
            self.timer += 0.01
        }
        var bufferPointer = self.timerBuffer.contents()
        memcpy(bufferPointer, &self.timer, MemoryLayout<Float>.size)
        bufferPointer = self.gestureBuffer.contents()
        memcpy(bufferPointer, &self.pos, MemoryLayout<CGFloatPoint>.size)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let drawable = self.currentDrawable else { return }

        let commandBuffer = self.queue.makeCommandBuffer()
        let encoder = commandBuffer.makeComputeCommandEncoder()

        encoder.setComputePipelineState(self.cps)
        encoder.setTexture(drawable.texture, at: 0)
        encoder.setTexture(self.texture, at: 1)
        encoder.setBuffer(self.timerBuffer, offset: 0, at: 0)
        encoder.setBuffer(self.gestureBuffer, offset: 0, at: 1)
        self.update()

        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    var panPosition: CGPoint = CGPoint.zero
    func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            self.panPosition = gesture.location(in: self)
        } else if gesture.state == .changed {
            let location = gesture.location(in: self)
            let movedRatio: CGFloat = (location.x - self.panPosition.x) / UIScreen.main.bounds.width

            let scale = self.layer.contentsScale
            if self.pos == CGFloatPoint.zero {
                self.pos = CGFloatPoint(x: movedRatio, y: 0)
            } else {
                self.pos.x += Float(movedRatio * scale)
            }
        }
    }
}
