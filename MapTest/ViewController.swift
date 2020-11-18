//
//  ViewController.swift
//  MapTest
//
//  Created by Maksim Kalik on 18/11/2020.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let service = Client(hostName: "ios-test.printful.lv", port: 6111)
        service.start()
        service.send(line: "AUTHORIZE maxkalik@gmail.com")
    }

}
