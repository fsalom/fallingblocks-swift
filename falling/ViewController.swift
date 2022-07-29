//
//  ViewController.swift
//  falling
//
//  Created by Fernando Salom Carratala on 28/7/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bgImage: UIImageView!
    let numberOfRocks = 10000
    var rocks: [UIImageView] = []
    var player: UIImageView!
    var timerRocks: Timer!
    var timerCollision: Timer!
    var lastPosition: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("hola")
        timerRocks = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            self.start()
        })
        timerCollision = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.trackCollision()
        })
        loadPlayer()
        addGesture()
        start()
        lastPosition = bgImage.center
    }


    func start() {

            let randomW = Int.random(in: 10..<200)
            let randomH = Int.random(in: 10..<200)
            let randomX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width))) - Int(randomW / 2)
            let rock = UIImageView(frame: CGRect(x: randomX, y: -200, width: 50, height: 50))
        rock.image = UIImage(named: "meteor")
            self.rocks.append(rock)
            self.view.addSubview(rock)
            UIView.animate(withDuration: 3, delay: TimeInterval(2), options: .curveLinear) {

                rock.frame.origin.y =  rock.frame.origin.y + UIScreen.main.bounds.height + 200
            } completion: { _ in
                self.rocks.removeFirst()
                rock.removeFromSuperview()
            }


    }

    func loadPlayer(){
        player = UIImageView(frame: CGRect(x: -50, y: -300, width: 50, height: 50))
        player.image = UIImage(named: "ovni")
        player.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 300)
        self.view.addSubview(player)
    }

    func addGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(trackUser))
        player.isUserInteractionEnabled = true
        player.addGestureRecognizer(pan)

    }

    func trackCollision() {
        let rocksOnScreen = rocks
        for rock in rocksOnScreen {
            guard let currentPosition = rock.layer.presentation()?.frame else{
                return
            }
            if player.frame.intersects(currentPosition) {
                endGame()
            }
        }
    }

    func endGame() {
        for rock in rocks {
            pauseLayer(layer: rock.layer)
            timerRocks.invalidate()
        }
        pauseLayer(layer: player.layer)
    }

    @objc func trackUser(gesture: UIGestureRecognizer) {
        let fingerLocation = gesture.location(in: self.view)
        player.center = CGPoint(x: fingerLocation.x, y: fingerLocation.y - 40)

    }

    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    enum Direction {
        case up
        case down
        case left
        case right
    }
    func trackMovement(fingerLocation: CGPoint){
//        let x = fingerLocation.x - lastPosition.x
//        if x <= 0 {
//            bgImage.center.x = bgImage.center.x + 30
//        }else{
//            bgImage.center.x = bgImage.center.x - 30
//        }
        lastPosition = fingerLocation
    }

}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180) / .pi
    }
}

extension CGPoint {
    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - x
        let originY = comparisonPoint.y - y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees

        while bearingDegrees < 0 {
            bearingDegrees += 360
        }

        return bearingDegrees
    }
}
