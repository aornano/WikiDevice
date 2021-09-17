//
//  ViewController.swift
//  test
//
//  Created by Alessandro Ornano on 14/09/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Using Device, running on: \(UIDevice().type)")
        var deviceModel:String = ""
        WikiDevice.model { (model) in
            print("Using WikiDevice, running on: \(model)")
            deviceModel = model
        }
    }


}

