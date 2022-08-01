//
//  ViewController.swift
//  falling
//
//  Created by Fernando Salom Carratala on 28/7/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var debugSwitch: UISwitch!
    var rocks: [UIImageView] = []
    var player: UIImageView!
    var timerRocks: Timer!
    var timerCollision: Timer!
    var isDebug: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        timerRocks = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true, block: { _ in
            self.throwRock()
        })
        timerCollision = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.trackCollision()
        })
        loadPlayer()
        addGesture()
    }


    func throwRock() {
        let randomW = Int.random(in: 10..<200)
        let randomX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width))) - Int(randomW / 2)
        let rock = UIImageView(frame: CGRect(x: randomX, y: -200, width: 30, height: 30))
        let texture = ["meteor", "meteor2", "meteor3"]
        rock.image = isDebug ? nil : UIImage(named: texture.randomElement()!)
        rock.backgroundColor = isDebug ? .blue : .clear
        self.rocks.append(rock)
        self.view.addSubview(rock)
        UIView.animate(withDuration: 3, delay: TimeInterval(2), options: .curveLinear) {
            rock.frame.origin.y =  rock.frame.origin.y + UIScreen.main.bounds.height + 200
            rock.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0...600))
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
            guard let currentRockPosition = rock.layer.presentation()?.frame else{
                return
            }
            guard let currentPlayerPosition = player.layer.presentation()?.frame else{
                return
            }
            if currentPlayerPosition.intersects(currentRockPosition) {
                let intersection = currentPlayerPosition.intersection(currentRockPosition)
                generateImpact(for: intersection)
                endGame()
            }

        }
    }

    func generateImpact(for intersection: CGRect){
        let impact = UIImageView(frame: CGRect(x: intersection.origin.x, y: intersection.origin.y , width: 25, height: 25))
        impact.center = intersection.origin
        impact.image = UIImage(named: "impact")
        self.view.addSubview(impact)
    }

    func endGame() {
        for rock in rocks {
            pauseLayer(layer: rock.layer)
            timerRocks.invalidate()
        }
        player.gestureRecognizers = nil
        pauseLayer(layer: player.layer)
    }

    @objc func trackUser(gesture: UIGestureRecognizer) {
        let fingerLocation = gesture.location(in: self.view)
        self.player.center = CGPoint(x: fingerLocation.x, y: fingerLocation.y - 40)
    }

    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func debug(mode: Bool){
        bgImage.image = mode ? nil : UIImage(named: "background")
        player.image = mode ? nil : UIImage(named: "ovni")
        player.backgroundColor = mode ? .red : .clear
        for rock in rocks {
            rock.image = mode ? nil : UIImage(named: "meteor")
            rock.backgroundColor = mode ? .blue : .clear
        }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        isDebug = sender.isOn
        debug(mode: sender.isOn)
    }
}
