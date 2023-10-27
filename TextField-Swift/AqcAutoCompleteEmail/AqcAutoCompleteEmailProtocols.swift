//
//  AqcAutoCompleteEmailProtocols.swift
//  TextField-Swift
//
//  Created by Luccas Santana Marinho on 27/10/23.
//

import UIKit

    // MARK: Protocolo AutoCompleteTextField

public protocol AqcAutoCompleteEmailDataSource: AnyObject {
    // protocolos exigidos
    
    // chamado quando precisa de sugestões.
    func autoCompleteTextFieldDataSource(_ autoCompleteTextField: AqcAutoCompleteEmail) -> [AqcAutoCompleteEmailDomain]
}

public protocol AqcAutoCompleteTextFieldDelegate: AnyObject {
    // será chamado após sugestão bem sucedida
    func autoCompleteTextField(_ autoCompleteTextField: AqcAutoCompleteEmail, didSuggestDomain domain: AqcAutoCompleteEmailDomain)
}
