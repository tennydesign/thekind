//
//  OnboardingView.swift
//  TheKind
//
//  Created by Tenny on 10/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import UIKit

// TODO: ADJUST SCREEN FOR X-FAMILY
class ChooseDriverView: KindActionTriggerView {

    @IBOutlet var chooseDriverView: UIView!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var lineWidthAnchor: NSLayoutConstraint!

    var talkbox: JungTalkBox?

    @IBOutlet var runOnView: UIView!
    var selected: String = "Imagination."
    var mainViewController: MainViewController?
    
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
        pickerView.selectRow(0, inComponent: 0, animated: false)
        lineWidthAnchor.constant = (estimateFrameFromText(pickerData.first!, bounding: boudingRect, fontSize: 18, fontName: PRIMARYFONT)).width

    }

    
    fileprivate func lineAnimationBasedOnTextSize(_ size: CGRect) {
        lineWidthAnchor.constant = size.width
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func talk() {
        let txt = "Now...-What drives you the most?.-We all have a stronger one."
        let actions: [KindActionType] = [.none, .fadeInView, .none]
        let actionViews: [ActionViewName] = [.none,.ChooseDriverView, .none]
        
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "I identify with this one.", actionView: self)
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
    }
    
    override func activate() {
        if mainViewController?.kindUserManager != nil {
            mainViewController?.kindUserManager.userFields[UserFieldTitle.currentLandingView.rawValue] = ActionViewName.ChooseDriverView.rawValue
            talk()
        } else {
            fatalError("Cant find user manager in UserNameView - We need a user manager for onboarding logging")
        }
        
    }
    
    override func deactivate() {
        self.fadeOutView()
    }
    
    override func rightOptionClicked() {
        let txt = "Ohhh \(selected)...-Great choice!"
        let actions: [KindActionType] = [.deactivate,.activate]
        let actionViews: [ActionViewName] = [.ChooseDriverView,.BrowseKindView]
        
        let driverName = (selected.dropLast()).lowercased()
        mainViewController?.kindUserManager.userFields[UserFieldTitle.driver.rawValue] = driverName
        
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: nil))
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
        selected = pickerData[row]
        let size: CGRect = estimateFrameFromText(selected, bounding: boudingRect, fontSize: 18, fontName: PRIMARYFONT)
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
            .font:  UIFont.init(name: PRIMARYFONT, size: 18) ?? UIFont.systemFont(ofSize: 18)]
        pickerLabel.attributedText = NSAttributedString(string: pickerData[row], attributes: attributes)
        return pickerLabel
    }
}
