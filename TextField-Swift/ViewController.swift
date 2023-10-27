////import UIKit
////
////class ViewController: UIViewController {
////
////    let textField = UITextField()
////    let button = UIButton()
////    let label = UILabel()
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        // Configurar o UITextField
////        textField.frame = CGRect(x: 50, y: 100, width: 200, height: 40)
////        textField.borderStyle = .roundedRect
////        textField.placeholder = "Digite um CPF"
////        view.addSubview(textField)
////
////        // Configurar o UIButton
////        button.frame = CGRect(x: 50, y: 150, width: 200, height: 40)
////        button.setTitle("Exibir CPF", for: .normal)
////        button.backgroundColor = .orange
////        button.addTarget(self, action: #selector(exibirCPF), for: .touchUpInside)
////        view.addSubview(button)
////
////        // Configurar a UILabel
////        label.frame = CGRect(x: 50, y: 200, width: 200, height: 40)
////        view.addSubview(label)
////    }
////
////    @objc func exibirCPF() {
////        if let cpfDigitado = textField.text {
////            // Remover todos os caracteres não numéricos do CPF
////            let numerosCPF = cpfDigitado.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
////
////            // Verificar se há pelo menos 11 dígitos no CPF
////            if numerosCPF.count >= 11 {
////                // Formatar o CPF como "123-***-***-10"
////                let cpfFormatado = "\(numerosCPF.prefix(3))-***-***-\(numerosCPF.suffix(2))"
////
////                let vc = TesteViewController()
////                vc.receivedText = cpfFormatado
////                present(vc, animated: true)
////
////            } else {
////                // Exibir uma mensagem de erro se o CPF não for válido
////                label.text = "CPF inválido"
////            }
////        }
////    }
////}
///

//
//  ViewController.swift
//  TextField-Swift
//
//  Created by Luccas Santana Marinho on 27/10/23.
//

import UIKit

class ViewController: UIViewController, AqcAutoCompleteEmailDataSource, AqcAutoCompleteTextFieldDelegate, UITextFieldDelegate {
    var txtEmail: AqcAutoCompleteEmail!
    
    var weightedDomains: [AqcAutoCompleteEmailDomain] = []
    var tfOffset: Int?
    
    let domain1 = AqcAutoCompleteEmailDomain(text: "BOL.COM.BR", weight: 1)
    let domain2 = AqcAutoCompleteEmailDomain(text: "GMAIL.COM", weight: 1)
    let domain3 = AqcAutoCompleteEmailDomain(text: "GLOBO.COM", weight: 0)
    let domain4 = AqcAutoCompleteEmailDomain(text: "HOTMAIL.COM", weight: 1)
    let domain5 = AqcAutoCompleteEmailDomain(text: "IG.COM.BR", weight: 1)
    let domain6 = AqcAutoCompleteEmailDomain(text: "MSN.COM", weight: 1)
    let domain7 = AqcAutoCompleteEmailDomain(text: "OUTLOOK.COM", weight: 1)
    let domain8 = AqcAutoCompleteEmailDomain(text: "TERRA.COM.BR", weight: 1)
    let domain9 = AqcAutoCompleteEmailDomain(text: "UOL.COM.BR", weight: 1)
    let domain10 = AqcAutoCompleteEmailDomain(text: "YAHOO.COM", weight: 1)
    let domain11 = AqcAutoCompleteEmailDomain(text: "YAHOO.COM.BR", weight: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weightedDomains = [domain1, domain2, domain3, domain4, domain5, domain6, domain7, domain8, domain9, domain10, domain11]
        txtEmail = AqcAutoCompleteEmail.init(frame: .zero, dataSource: self, delegate: self)
        
        txtEmail.delegate = self
        txtEmail.setDelimiter("@")
        txtEmail.frame = CGRect(x: 50, y: 100, width: 300, height: 40)
        txtEmail.borderStyle = .roundedRect
        txtEmail.placeholder = "Digite um Email"
        view.addSubview(txtEmail)
        txtEmail.addTarget(self, action: #selector(myTextFieldTextChanged), for: .editingChanged)
    }

    @objc func myTextFieldTextChanged(textField: UITextField) {
        textField.text = textField.text?.uppercased()
        
        if let tfOffset, let currentPosition = textField.selectedTextRange?.end, let newPosition = textField.position(from: textField.beginningOfDocument, offset: tfOffset + 1) {
            let offset = textField.offset(from: textField.beginningOfDocument, to: currentPosition)
            
            if tfOffset + 1 < offset {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentPosition = textField.selectedTextRange?.end {
            tfOffset = textField.offset(from: textField.beginningOfDocument, to: currentPosition)
        }
        if string.hasBackSpace {
            return false
        }
        return true
    }
    
    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AqcAutoCompleteEmail) -> [AqcAutoCompleteEmailDomain] {
        return weightedDomains
    }
    
    func autoCompleteTextField(_ autoCompleteTextField: AqcAutoCompleteEmail, didSuggestDomain domain: AqcAutoCompleteEmailDomain) {}
}

extension String {
    var hasBackSpace: Bool {
        guard !isEmpty else { return false }
        let whitespaceChars = NSCharacterSet.whitespaces
        return self.unicodeScalars.filter { !whitespaceChars.contains($0) }.count == 0
    }
}
