//
//  ViewController.swift
//  HiraginoTextView
//
//  Created by Yoyo on 6/26/20.
//  Copyright © 2020 Yoyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var originaltTextView: UITextView!
    @IBOutlet weak var placeholderTV: UIView!
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupParagraphStyle()
        setupTextView()
    }
    
    func setupParagraphStyle() {
        // https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/CustomTextProcessing/CustomTextProcessing.html
        let font = UIFont(name: "HiraginoSans-W3", size: 17.0)!
        
        let systemFont = UIFont.systemFont(ofSize: 17)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.maximumLineHeight = 25
        paragraphStyle.minimumLineHeight = 25
        paragraphStyle.lineHeightMultiple = 25
        
        let attrString = NSMutableAttributedString(attributedString: originaltTextView.attributedText)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        
        originaltTextView.attributedText = attrString
    }
    
    func setupTextView() {
        let textStore = MyTextStorage()
        textStore.append(originaltTextView.attributedText)
        
        let layoutManager = NSLayoutManager()
//        layoutManager.allowsNonContiguousLayout = true
        layoutManager.delegate = self
        
        let containerSize = CGSize(width: placeholderTV.bounds.width, height: .greatestFiniteMagnitude)
        let textContainer = NSTextContainer(size: containerSize)
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        textStore.addLayoutManager(layoutManager)
        
        textView = UITextView(frame: placeholderTV.bounds, textContainer: textContainer)
        placeholderTV.addSubview(textView)
        textView.contentSize = textContainer.size
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: placeholderTV.leftAnchor),
            textView.rightAnchor.constraint(equalTo: placeholderTV.rightAnchor),
            textView.bottomAnchor.constraint(equalTo: placeholderTV.bottomAnchor),
            textView.topAnchor.constraint(equalTo: placeholderTV.topAnchor)
        ])
    }
}

extension ViewController: NSLayoutManagerDelegate {
    
}

class MyTextStorage: NSTextStorage {
    private var storage = NSTextStorage()
    
    override var string: String {
        return storage.string
    }
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }
    
    override func replaceCharacters(in range: NSRange, with str: String) {
        storage.replaceCharacters(in: range, with: str)
        edited([.editedAttributes, .editedCharacters], range: range, changeInLength: (str as NSString).length - range.length)
    }
    
    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited([.editedAttributes], range: range, changeInLength: 0)
    }
    
    func applyStylesToRange(searchRange: NSRange) {
        let font = UIFont(name: "HiraginoSans-W3", size: 17.0)!
        let normalAttrs: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        addAttributes(normalAttrs, range: searchRange)
    }
    
    func performReplacementsForRange(changedRange: NSRange) {
        var extendedRange =
            NSUnionRange(changedRange,
                         NSString(string: storage.string).lineRange(for: NSMakeRange(changedRange.location, 0)))
        extendedRange =
            NSUnionRange(changedRange,
                         NSString(string: storage.string).lineRange(for: NSMakeRange(NSMaxRange(changedRange), 0)))
        applyStylesToRange(searchRange: extendedRange)
    }
    
    override func processEditing() {
        performReplacementsForRange(changedRange: editedRange)
        super.processEditing()
    }
    
    
}
