//: Playground - noun: a place where people can play

import UIKit
import MetalKit
import PlaygroundSupport

var weights = [Float](repeating: 0.0, count: 9)
weights[8] = 0

//let device = MTLCreateSystemDefaultDevice()!
let frame = CGRect(x: 0, y: 0, width: 400, height: 400)
//let view = MetalView(frame: frame, device: device)
let view = UIView(frame: frame)
view.backgroundColor = .black

let subview = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 30))
subview.backgroundColor = .white
view.addSubview(subview)
subview.center = view.center

subview.layer.cornerRadius = subview.bounds.height / 2.0
//subview.layer.shadowColor = UIColor.white.cgColor
//subview.layer.shadowOffset = CGSize.zero
//subview.layer.shadowRadius = 10.0
//subview.layer.shadowOpacity = 1.0

subview.layer.shadowColor = UIColor.white.cgColor
subview.layer.shadowRadius = 20.0
subview.layer.shadowOpacity = 0.9
subview.layer.shadowOffset = CGSize.zero
subview.layer.masksToBounds = false

PlaygroundPage.current.liveView = view

let dd: [String: Any] = ["x": "y"]
let ttx = String(describing: type(of: dd["x"] as! String))
let tty = String(describing: String.self)
let ttz = type(of: String.self)

let cos_1 = cos(14.24)

let tx = 1.9
let txPow: Double = pow(2, 2)
let txInt: Int = Int(tx)
let tRound = round(tx)
let tFloor = floor(tx)
let tCeil = ceil(tx)

let x: Float = 10.0
let y: Float = 5.0

let res: CGFloat = CGFloat(fmodf(x, y))
let x1: CGPoint = CGPoint(x: 0.0, y: 0.0)
let y1: CGPoint = CGPoint(x: 0.0, y: 1.0)
let res1 = (x1.x / y1.y)

let x2: CGPoint = CGPoint(x: 2.0, y: 4.0)
let y2: CGPoint = CGPoint(x: 5.0, y: 1.0)

atan2(y2.y - x2.y, y2.x - x2.x)
//let translate = CGAffineTransform(translationX: x2.x, y: x2.y)
let rotate = CGAffineTransform(rotationAngle: 30.0 * .pi / 180.0)
y2.applying(CGAffineTransform(translationX: -x2.x, y: -x2.y).concatenating(rotate))


"103호(1호)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)

var tt: [Int] = [Int]()
for i in 0 ... 6 {
    tt.append(Int(arc4random_uniform(3)) + 3)
}
