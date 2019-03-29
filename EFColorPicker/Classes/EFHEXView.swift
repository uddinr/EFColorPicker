//
//  EFHEXView.swift
//  EFColorPicker
//
//

import UIKit

// The view to edit HSB color components.
public class EFHEXView: UIView, EFColorView, UITextFieldDelegate {
    
    let EFColorSampleViewHeight: CGFloat = 30.0
    let EFViewMargin: CGFloat = 20.0
    
    private let colorSample: UIView = UIView()
    private let hexLabel: UILabel = UILabel()
    private let textField: UITextField = UITextField()
    
    private var colorComponents: HSB = HSB(1, 1, 1, 1)
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    weak public var delegate: EFColorViewDelegate?
    
    public var isTouched: Bool {
        if self.textField.isTouchInside {
            return true
        }
        
        return false
    }
    
    public var color: UIColor {
        get {
            return UIColor(
                hue: colorComponents.hue,
                saturation: colorComponents.saturation,
                brightness: colorComponents.brightness,
                alpha: colorComponents.alpha
            )
        }
        set {
            colorComponents = EFRGB2HSB(rgb: EFRGBColorComponents(color: newValue))
            self.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ef_baseInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ef_baseInit()
    }
    
    func reloadData() {
        colorSample.backgroundColor = self.color
        let hexString = EFHexStringFromColor(color: self.color)
        colorSample.accessibilityValue = hexString
        self.hexLabel.text = hexString
    }
    
    override public func updateConstraints() {
        self.ef_updateConstraints()
        super.updateConstraints()
    }
    
    // MARK:- Private methods
    private func ef_baseInit() {
        self.accessibilityLabel = "hex_view"
        
        colorSample.accessibilityLabel = "color_sample"
        colorSample.layer.borderColor = UIColor.black.cgColor
        colorSample.layer.borderWidth = 0.5
        colorSample.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(colorSample)
        
        hexLabel.accessibilityLabel = "label_field"
        hexLabel.textAlignment = .center
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(hexLabel)
        
        textField.accessibilityLabel = "text_field"
        textField.textAlignment = .center
        textField.placeholder = NSLocalizedString("HEX Value", comment: "")
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textField)
        
        textField.addTarget(
            self, action: #selector(ef_colorDidChangeValue(sender:)), for: UIControl.Event.editingChanged
        )
        
        self.setNeedsUpdateConstraints()
    }
    
    private func ef_updateConstraints() {
        // remove all constraints first
        if !layoutConstraints.isEmpty {
            self.removeConstraints(layoutConstraints)
        }
        
        layoutConstraints = UIUserInterfaceSizeClass.compact == self.traitCollection.verticalSizeClass
            ? self.ef_constraintsForCompactVerticalSizeClass()
            : self.ef_constraintsForRegularVerticalSizeClass()
        
        self.addConstraints(layoutConstraints)
    }
    
    private func ef_constraintsForRegularVerticalSizeClass() -> [NSLayoutConstraint] {
        let metrics = [
            "margin" : EFViewMargin,
            "height" : EFColorSampleViewHeight
        ]
        let views = [
            "colorSample" : colorSample,
            "labelField" : hexLabel,
            "textField" : textField
        ]
        
        var layoutConstraints: [NSLayoutConstraint] = []
        let visualFormats = [
            "H:|-margin-[colorSample]-margin-|",
            "H:|-margin-[labelField]-margin-|",
            "H:|-margin-[textField]-margin-|",
            "V:|-margin-[colorSample(height)]-margin-[labelField]-margin-[textField]-(>=margin@250)-|"
        ]

        for visualFormat in visualFormats {
            layoutConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: visualFormat,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
        }

        return layoutConstraints
    }
    
    private func ef_constraintsForCompactVerticalSizeClass() -> [NSLayoutConstraint] {
        let metrics = [
            "margin" : EFViewMargin,
            "height" : EFColorSampleViewHeight
        ]
        let views = [
            "colorSample" : colorSample,
            "labelField" : hexLabel,
            "textField" : textField
        ]
        
        var layoutConstraints: [NSLayoutConstraint] = []
        let visualFormats = [
            "H:|-margin-[colorSample]-margin-|",
            "H:|-margin-[labelField]-margin-|",
            "H:|-margin-[textField]-margin-|",
            "V:|-margin-[colorSample(height)]-margin-[labelField]-margin-[textField]-(>=margin@500)-|"
        ]
        
        for visualFormat in visualFormats {
            layoutConstraints.append(
                contentsOf: NSLayoutConstraint.constraints(
                    withVisualFormat: visualFormat,
                    options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                    metrics: metrics,
                    views: views
                )
            )
        }
        
        return layoutConstraints
    }
    
    @objc private func ef_colorDidChangeValue(sender: EFColorWheelView) {
        if let hexString = self.textField.text, let c = EFColorFromHexString(hexColor: !hexString.hasPrefix("#") ? "#\(hexString)" : hexString){
            self.color = c
        }

        self.delegate?.colorView(self, didChangeColor: self.color)
        self.reloadData()
    }
    
    @objc private func ef_brightnessDidChangeValue(sender: EFColorComponentView) {
        colorComponents.brightness = sender.value
        self.delegate?.colorView(self, didChangeColor: self.color)
        self.reloadData()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let maxLength = currentString.hasPrefix("#") ? 9 : 8
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
