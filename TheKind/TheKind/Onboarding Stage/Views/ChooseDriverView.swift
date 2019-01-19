//
//  OnboardingView.swift
//  TheKind
//
//  Created by Tenny on 10/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

// TODO: ADJUST SCREEN FOR X-FAMILY
class ChooseDriverView: UIView {

    @IBOutlet var chooseDriverView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var lineWidthAnchor: NSLayoutConstraint!
    @IBOutlet var nextButton: UIButton!
    

    @IBOutlet var runOnView: UIView!

    var onBoardingViewController: OnBoardingViewController?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    var pickerData = ["Imagination.", "Intellect.", "Intuition.", "Empathy."]
    
    lazy var boudingRect = CGSize(width: pickerView.bounds.width, height: pickerView.bounds.height)
    
    func commonInit() {
        Bundle.main.loadNibNamed("ChooseDriverView", owner: self, options: nil)
        chooseDriverView.frame = self.bounds
        chooseDriverView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        addSubview(chooseDriverView)
        pickerView.delegate = self
        pickerView.dataSource = self

        lineWidthAnchor.constant = (estimateFrameFromText(pickerData.first!, bounding: boudingRect, fontSize: 18, fontName: "Acrylic Hand Sans")).width

    }
    
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        onBoardingViewController?.switchViewsInsideController(toViewName: .chooseKindCard, originView: self, removeOriginFromSuperView: false)
    }
    
    fileprivate func lineAnimationBasedOnTextSize(_ size: CGRect) {
        lineWidthAnchor.constant = size.width
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
}

extension ChooseDriverView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = pickerData[row]
        let size: CGRect = estimateFrameFromText(selected, bounding: boudingRect, fontSize: 18, fontName: "Acrylic Hand Sans")
        lineAnimationBasedOnTextSize(size)
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        return attributeTextToLabel(view, row)
    }

    fileprivate func attributeTextToLabel(_ view: UIView?, _ row: Int) -> UILabel {
        var pickerLabel: UILabel
        if let label = view as? UILabel{
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
            pickerLabel.textAlignment = .left
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font:  UIFont.init(name: "Acrylic Hand Sans", size: 18)!]
        pickerLabel.attributedText = NSAttributedString(string: pickerData[row], attributes: attributes)
        return pickerLabel
    }
}
