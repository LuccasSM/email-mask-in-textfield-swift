//
//  TesteViewController.swift
//  TextField-Swift
//
//  Created by Luccas Santana Marinho on 28/06/23.
//

import UIKit

class TesteViewController: UIViewController {
    let label = UILabel()
    
    var receivedText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        
        // Configurar a UILabel
        label.frame = CGRect(x: 50, y: 100, width: 300, height: 40)
        label.text = receivedText
        
        view.addSubview(label)
    }
}
