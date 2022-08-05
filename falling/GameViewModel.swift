import UIKit

final class GameViewModel {

    //MARK:  - Properties
    var screen: UIView!
    var rocks: [UIImageView] = []
    var startButton: UIButton!
    var player: UIImageView!
    var impact: UIImageView!
    var instructionLabel: UILabel!
    var timerRocks: Timer!
    var timerCollision: Timer!
    var isDebug: Bool = false
    var panGesture: UIPanGestureRecognizer!
    var originalPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 300)

    init(screen: UIView) {
        self.screen = screen
    }

    //MARK:  - Life cycle
    func viewReady() {
        customButton()
        customPlayer()
        customLabel()
        animateButton()
        self.screen.addSubview(player)
        self.screen.addSubview(startButton)
        self.screen.addSubview(instructionLabel)
    }
}

extension GameViewModel {
    //MARK:  - Actions and gestures
    func addGesture(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(trackUser))
        player.isUserInteractionEnabled = true
        player.addGestureRecognizer(panGesture)
    }

    @objc func startGame(){
        addGesture()
        animateLabel()
        startButton.layer.removeAllAnimations()
        timerRocks = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true, block: { _ in
            self.throwRock()
        })
        timerCollision = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            self.trackCollision()
        })
        startButton.isHidden.toggle()
    }

    @objc func trackUser(gesture: UIGestureRecognizer) {
        let fingerLocation = gesture.location(in: screen)
        self.player.center = CGPoint(x: fingerLocation.x, y: fingerLocation.y - 40)
    }

    //MARK:  - Timer actions
    func throwRock() {
        let randomW = Int.random(in: 10..<200)
        let randomX = Int(arc4random_uniform(UInt32(UIScreen.main.bounds.width))) - Int(randomW / 2)
        let rock = UIImageView(frame: CGRect(x: randomX, y: -200, width: 30, height: 30))
        let texture = ["meteor", "meteor2", "meteor3"]
        rock.image = isDebug ? nil : UIImage(named: texture.randomElement()!)
        rock.backgroundColor = isDebug ? .blue : .clear
        rocks.append(rock)
        self.screen.addSubview(rock)
        UIView.animate(withDuration: 3, delay: TimeInterval(2), options: .curveLinear) {
            rock.frame.origin.y =  rock.frame.origin.y + UIScreen.main.bounds.height + 200
            rock.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0...600))
        } completion: { _ in
            self.rocks.removeFirst()
            rock.removeFromSuperview()
        }
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
                restartGame()
            }
        }
    }

    //MARK:  - Add remove UI elements
    func removeAllRocks(){
        for rock in rocks {
            rock.removeFromSuperview()
        }
        impact.removeFromSuperview()
    }

    func generateImpact(for intersection: CGRect){
        impact = UIImageView(frame: CGRect(x: intersection.origin.x, y: intersection.origin.y , width: 25, height: 25))
        impact.center = intersection.origin
        impact.image = UIImage(named: "impact")
        self.screen.addSubview(impact)
    }

    //MARK:  - Customization elements
    func customButton() {
        startButton = UIButton(frame: CGRect(x: -50, y: -300, width: 80, height: 80))
        startButton.backgroundColor = .clear
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.layer.borderWidth = 2
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        startButton.clipsToBounds = true
        startButton.center = originalPoint
    }

    func customPlayer() {
        player = UIImageView(frame: CGRect(x: -50, y: -300, width: 50, height: 50))
        player.image = UIImage(named: "ovni")
        player.center = originalPoint
    }

    func customLabel() {
        instructionLabel = UILabel(frame: CGRect(x: -50, y: -300 , width: 200, height: 50))
        instructionLabel.center = CGPoint(x: player.center.x, y: player.center.y - 40)
        instructionLabel.text = "PRESS AND MOVE"
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        instructionLabel.textColor = .white
        instructionLabel.isHidden = true
    }

    func animateLabel() {
        instructionLabel.alpha = 1
        instructionLabel.isHidden = false
        UIView.animate(withDuration: 5, delay: 0, options: .curveEaseInOut) {
            self.instructionLabel.alpha = 0
        } completion: { _ in
        }
    }

    func animateButton() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        startButton.layer.add(pulse, forKey: nil)
    }

    //MARK:  - Game actions
    func endGame() {
        for rock in rocks {
            pauseLayer(layer: rock.layer)
            timerRocks.invalidate()
            timerCollision.invalidate()
        }
        player.gestureRecognizers = nil
        pauseLayer(layer: player.layer)
    }

    func restartGame(){
        startButton.isHidden = false
        startButton.center = originalPoint
        startButton.isEnabled = false
        animateButton()
        resumeAnimation(layer: player.layer)
        player.isUserInteractionEnabled = false
        UIView.animate(withDuration: 2, delay: 2, options: .curveEaseIn) {
            self.player.center = self.originalPoint
        } completion: { _ in
            self.startButton.isEnabled = true
            self.player.isUserInteractionEnabled = true
            self.startButton.isUserInteractionEnabled = true
            self.removeAllRocks()
        }
    }

    //MARK:  - Pause / Resume animation elements
    func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    func resumeAnimation(layer : CALayer){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    //MARK:  - Debug mode
    func debug(mode: Bool){
        isDebug = mode
        //bgImage.image = mode ? nil : UIImage(named: "background")
        player.image = mode ? nil : UIImage(named: "ovni")
        player.backgroundColor = mode ? .red : .clear
        for rock in rocks {
            rock.image = mode ? nil : UIImage(named: "meteor")
            rock.backgroundColor = mode ? .blue : .clear
        }
    }
}
