//
//  ViewController.swift
//  falling
//
//  Created by Fernando Salom Carratala on 28/7/22.
//

import UIKit

class GameController: UIViewController {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var debugSwitch: UISwitch!

    var viewModel : GameViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = GameViewModel(screen: self.view)
        viewModel.viewReady()
    }

    @IBAction func switchChanged(_ sender: UISwitch) {        
        viewModel.debug(mode: sender.isOn)
    }
}
