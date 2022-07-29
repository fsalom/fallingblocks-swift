![author](https://img.shields.io/badge/author-fernando%20salom-red)

# Falling blocks

## About this game

This game is an experiment to create a simple game where objects are falling continuously. I didn't know what kind of game should I build so in this first approach it will be about avoiding those falling blocks 

## Problems solving

**Fall of random objects**

The first problem is how to make those rocks fall from different random locations. For this reason the following code generate UIView with a random X position and then creates an animation from starting point (x, -200) to final point (x, screen.height + 200). And finally we remove this UIView.

```swift
func throwRock() {
	let randomW = Int.random(in: 10..<200)
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
```

Ok this code is great but it just generate one object, ¿How do you generate infinite objects?. We can make this by creating a Timer. This timer has an interval of 0.5 that we can modify to make it more dificult.

```swift
timerRocks = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
    self.throwRock()
})
```

## License
[MIT](https://choosealicense.com/licenses/mit/)