//
//  ViewController.swift
//  Swiftly Notes
//
//  Created by Michal Géci on 10/09/2019.
//  Copyright © 2019 Michal Géci. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        RestAPI.updateNoteWithId(id: 2, text: "Blablabla") { (model, err) in
            print(model)
        }
        
        
    }


}

