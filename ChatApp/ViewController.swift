//
//  ViewController.swift
//  ChatApp
//
//  Created by Игорь Клюжев on 15.02.2021.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("\nView did load : \(#function)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("\nView will appear : \(#function)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        NSLog("\nView will layout subviews : \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLog("\nView did layout subviews : \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("\nView did appear : \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NSLog("\nView will disappear : \(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NSLog("\nView did disappear : \(#function)")
    }
}

