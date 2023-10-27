//
//  AqcAutoCompleteEmail.swift
//  TextField-Swift
//
//  Created by Luccas Santana Marinho on 27/10/23.
//

import UIKit

public class AqcAutoCompleteEmail: UITextField {
    
    // Fonte de dados AutoCompleteTextField
    weak public var dataSource: AqcAutoCompleteEmailDataSource?
    // Delegado notificador opcional AutoCompleteTextField
    weak public var actfDelegate: AqcAutoCompleteTextFieldDelegate?
    
    // Fonte de dados AutoCompleteTextField acessível por meio de IB
    weak internal var _actfDataSource: AnyObject? {
        didSet {
            dataSource = _actfDataSource as? AqcAutoCompleteEmailDataSource
        }
    }
    
    // Fonte de dados AutoCompleteTextField acessível por meio de IB
     weak internal var _actfDelegate: AnyObject? {
        didSet {
            actfDelegate = _actfDelegate as? AqcAutoCompleteTextFieldDelegate
        }
    }
    
    fileprivate var actfLabel: AqcAutoCompleteEmailLabel!
    fileprivate var delimiter: CharacterSet?
    
    fileprivate var xOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .bezel, .roundedRect:
                return 6.0
            case .line:
                return 1.0
            default:
                return 0.0
            }
        }
    }
    
    fileprivate var yOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .line, .roundedRect:
                return 0.5
            default:
                return 0.0
            }
        }
    }
    
    // Sinalizador de conclusão automática
    public var autoCompleteDisabled: Bool = false
    
    // Pesquisa de caso
    public var ignoreCase: Bool = true
    
    // Aleatorizar sinalizador de sugestão. O padrão é 'falso, sempre usará a primeira sugestão encontrada'
    public var isRandomSuggestion: Bool = false
    
    // Nomes de domínio suportados
    static public let domainNames: [AqcAutoCompleteEmailDomain] = []
    
    // Configurações de fonte de texto
    override public var font: UIFont? {
        didSet { actfLabel?.font = font }
    }
    
    public var suggestionColor: UIColor? {
        didSet {
            actfLabel.textColor = suggestionColor
        }
    }
    
    // MARK: Inicialização
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    // Inicialize 'AutoCompleteTextField' com 'AutoCompleteTextFieldDataSourc' e opcional 'AutoCompleteTextFieldDelegate'
    convenience public init(frame: CGRect, dataSource source: AqcAutoCompleteEmailDataSource? = nil, delegate d: UITextFieldDelegate? = nil) {
        self.init(frame: frame)
        
        dataSource = source
        delegate = d
        
        prepareLayers()
        setupTargetObserver()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        prepareLayers()
        setupTargetObserver()
    }
    
    // MARK: Respondentes
    
    override public func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        
        if !autoCompleteDisabled {
            actfLabel.isHidden = false
            
            if clearsOnBeginEditing {
                actfLabel.text = ""
            }
            processAutoCompleteEvent()
        }
        return becomeFirstResponder
    }
    
    override public func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        
        if !autoCompleteDisabled {
            actfLabel.isHidden = true
            
            commitAutocompleteText()
        }
        return resignFirstResponder
    }
    
    // MARK: Funções Privadas
    
    fileprivate func prepareLayers() {
        actfLabel = AqcAutoCompleteEmailLabel(frame: .zero)
        addSubview(actfLabel)
        
        actfLabel.font = font
        actfLabel.backgroundColor = .clear
        actfLabel.textColor = .lightGray
        actfLabel.lineBreakMode = .byClipping
        actfLabel.baselineAdjustment = .alignCenters
        actfLabel.isHidden = true
    }
    
    fileprivate func setupTargetObserver() {
        addTarget(self, action: #selector(autoCompleteTextFieldDidChanged(_:)), for: .editingChanged)
    }
    
    fileprivate func performDomainSuggestionsSearch(_ queryString: String) -> AqcAutoCompleteEmailDomain? {
        guard let dataSource else { return processSourceData([], queryString: queryString) }
        let sourceData = dataSource.autoCompleteTextFieldDataSource(self)
        return processSourceData(sourceData, queryString: queryString)
    }
    
    fileprivate func processSourceData(_ dataSource: [AqcAutoCompleteEmailDomain], queryString: String) -> AqcAutoCompleteEmailDomain? {
        let stringFilter = ignoreCase ? queryString.uppercased() : queryString
        let suggestedDomains = dataSource.filter { (domain) -> Bool in
            if ignoreCase {
                return domain.text.uppercased().hasPrefix(stringFilter)
            } else {
                return domain.text.hasPrefix(stringFilter)
            }
        }
        
        if suggestedDomains.isEmpty {
            return nil
        }
        
        if isRandomSuggestion {
            let maxCount = suggestedDomains.count
            let randomIdx = arc4random_uniform(UInt32(maxCount))
            let suggestedDomain = suggestedDomains[Int(randomIdx)]
            
            return suggestedDomain
        } else {
            guard let suggestedDomain = suggestedDomains.sorted(by: { (domain1, domain2) -> Bool in
                return domain1.weight > domain2.weight && domain1.text < domain2.text
            }).first else { return nil }
            return suggestedDomain
        }
    }
    
    fileprivate func performTextCull(domain: AqcAutoCompleteEmailDomain, stringFilter: String) -> String {
        guard let filterRange = ignoreCase ? domain.text.uppercased().range(of: stringFilter) : domain.text.range(of: stringFilter) else { return "" }
        
        let culledString = domain.text.replacingCharacters(in: filterRange, with: "")
        return culledString
    }
    
    fileprivate func actfBoundingRect(_ autocompleteString: String) -> CGRect {
        // obter limites para toda a área de texto
        let textRectBounds = textRect(forBounds: bounds)
        
        // obter reto para o texto real
//        let endRange = self.position(from: endOfDocument, offset: 1) ?? endOfDocument
        guard let textRange = textRange(from: beginningOfDocument, to: endOfDocument) else { return .zero }
        
//        let tRect = caretRect(for: endOfDocument).integral
        let tRect = firstRect(for: textRange).integral
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let textAttributes: [NSAttributedString.Key: Any] = [.font: font!, .paragraphStyle: paragraphStyle]
        
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let prefixTextRect = (text ?? "").boundingRect(with: textRectBounds.size, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let autoCompleteRectSize = CGSize(width: textRectBounds.width - prefixTextRect.width, height: textRectBounds.height)
        let autoCompleteTextRect = autocompleteString.boundingRect(with: autoCompleteRectSize, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let rectX = tRect.maxX + xOffsetCorrection
        let newOffset = CGFloat(Int(rectX) % 14)
        
        let xOrigin = rectX + 4.5
        let actfLabelFrame = actfLabel.frame
        let finalX = xOrigin + autoCompleteTextRect.width
        let finalY = textRectBounds.minY + ((textRectBounds.height - actfLabelFrame.height) / 2) - yOffsetCorrection
        
//        print("-----> \(prefixTextRect.width) prefixTextRect")
        print("-----> \(xOrigin) xOrigin")
        print("-----> \(tRect.width), \(tRect.maxX) tRect")
//        let x = Int(tRect.maxX) % 14
//        print("-----> \(x) x")
        print("-----> \((xOffsetCorrection < newOffset ? xOffsetCorrection : newOffset)) newOffset")
        
        if finalX >= textRectBounds.width {
            let autoCompleteRect = CGRect(x: textRectBounds.width, y: finalY, width: 0, height: actfLabelFrame.height)
            return autoCompleteRect
        } else {
            let autoCompleteRect = CGRect(x: xOrigin, y: finalY, width: autoCompleteTextRect.width, height: actfLabelFrame.height)
            return autoCompleteRect
        }
    }
    
    fileprivate func processAutoCompleteEvent() {
        if autoCompleteDisabled { return }
        
        guard let text = text?.uppercased(), text.count > 0 else { return }
        
        if let delimiter {
            guard let _ = text.rangeOfCharacter(from: delimiter) else { return }

            let textComponents = text.components(separatedBy: delimiter)
            
            if textComponents.count > 2 { return }
            
            guard let textToLookFor = textComponents.last else { return }
            
            let domain = performDomainSuggestionsSearch(textToLookFor)
            updateAutocompleteLabel(domain: domain, originalString: textToLookFor)
        } else {
            let domain = performDomainSuggestionsSearch(text)
            updateAutocompleteLabel(domain: domain, originalString: text)
        }
    }
    
    fileprivate func updateAutocompleteLabel(domain: AqcAutoCompleteEmailDomain?, originalString stringFilter: String) {
        guard let domain else {
            actfLabel.text = ""
            actfLabel.sizeToFit()
            
            return
        }
        
        let culledString = performTextCull(domain: domain, stringFilter: stringFilter)
        
        actfLabel.domain = domain
        actfLabel.text = culledString.uppercased()
        actfLabel.sizeToFit()
        actfLabel.frame = actfBoundingRect(culledString)
    }
    
    fileprivate func commitAutocompleteText() {
        guard let autoCompleteString = actfLabel.text , !autoCompleteString.isEmpty else { return }
        let originalInputString = text ?? ""
        
        actfLabel.text = ""
        actfLabel.sizeToFit()
        
        if let actfDelegate {
            actfDelegate.autoCompleteTextField(self, didSuggestDomain: actfLabel.domain)
        }
        
        actfLabel.domain = nil
        text = originalInputString + autoCompleteString
        sendActions(for: .valueChanged)
    }
}

    // MARK: Controles internos

extension AqcAutoCompleteEmail {
    @objc internal func autoCompleteButtonDidTapped(_ sender: UIButton) {
        endEditing(true)
        
        commitAutocompleteText()
    }
    
    @objc internal func autoCompleteTextFieldDidChanged(_ textField: UITextField) {
        if !autoCompleteDisabled {
            processAutoCompleteEvent()
        }
    }
}

    // MARK: Controles Públicos

extension AqcAutoCompleteEmail {
    // Definir delimitador. Realizará a pesquisa se o delimitador for encontrado
    public func setDelimiter(_ delimiterString: String) {
        delimiter = CharacterSet(charactersIn: delimiterString)
    }
    
    // Forçar evento de conclusão de texto
    public func forceRefresh() {
        processAutoCompleteEvent()
    }
}
