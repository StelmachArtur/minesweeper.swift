//
//  SetupViewController.swift
//  Minesweeper iOS
//
//  Created by Artur Stelmach on 14/01/2021.
//  Copyright © 2021 NSScreencast. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var setupNameField: UITextField!
    @IBOutlet weak var setupBombsField: UITextField!
    @IBOutlet weak var setupGridSizeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func launchGame(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "game_vc") as? GameViewController else {
            return
        }
        vc.setupVC = self	
        vc.modalPresentationStyle = .fullScreen
        present(vc,animated: true)
    }
    
    

}
