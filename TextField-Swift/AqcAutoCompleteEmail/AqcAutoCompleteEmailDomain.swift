//
//  AqcAutoCompleteEmailDomain.swift
//  TextField-Swift
//
//  Created by Luccas Santana Marinho on 27/10/23.
//

import UIKit

public class AqcAutoCompleteEmailDomain: Codable {
    public let text: String
    public var weight: Int
    // Armazenará automaticamente na atualização de 'peso' usando 'texto' padrão como 'true'
    public let isAutoStoringEnabled: Bool
    
    // MARK: Inicializador
    
    public init(text t: String, weight w: Int, isAutoStoringEnabled autoStoringEnabled: Bool = true) {
        text = t
        weight = w
        isAutoStoringEnabled = autoStoringEnabled
    }
}
