//
//  UserNameSetupView.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 1/4/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import GoogleSignIn
import RxCocoa
import RxSwift


class DobOnboardingView: KindActionTriggerView, UIPickerViewDelegate,UIPickerViewDataSource {
    
    var mainViewController: MainViewController?
    var talkbox: JungTalkBox?
    @IBOutlet var mainView: UIView!
    var pickerData = Array(1900...2019)
    lazy var boudingRect = CGSize(width: pickerView.bounds.width, height: pickerView.bounds.height)
    @IBOutlet weak var pickerView: UIPickerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }

    var selectedYear: Int = 1990
    
    let rotationAngle: CGFloat = 90 * (.pi/180)
    func commonInit() {
    }
    
    override func activate() {
        Bundle.main.loadNibNamed("DobOnboardingView", owner: self, options: nil)
        addSubview(mainView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.transform = CGAffineTransform(rotationAngle: -rotationAngle)
        
        pickerView.frame = CGRect(x: -100, y: 0, width: self.frame.width - 200, height: 100)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView.selectRow(90, inComponent:0, animated:true)
        self.logCurrentLandingView(tag: ViewForActionEnum.DobOnboardingView.rawValue)
        self.talk()
    }

    
    override func talk() {
        fetchAgeExplainer()
    }
    

    
    override func fadeInView() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        self.fadeIn(1)
    }
    
     override func deactivate() {
        self.pickerView.fadeOut(1)
//        UIView.animate(withDuration: 1) {
//            self.pickerView.alpha = 0
//        }
        self.talkbox?.delegate = nil
    }
    
     override func leftOptionClicked() {
        
    }
    
    
    override func rightOptionClicked() {
        
        // Last words.
        let year = Calendar.current.component(.year, from: Date())
        let age = year-selectedYear
        // TODO: moving forward.

         KindUserSettingsManager.sharedInstance.userFields[UserFieldTitle.year.rawValue] = selectedYear
         KindUserSettingsManager.sharedInstance.updateUserSettings(completion: nil)
        
        NavigateAwayExplainer(age)
        
        // Move next.
        self.fadeOutView()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedYear = pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        return attributeTextToLabel(view, row)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
    

    
    fileprivate func attributeTextToLabel(_ view: UIView?, _ row: Int) -> UILabel {
        var pickerLabel: UILabel
        if let label = view as? UILabel{
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
            pickerLabel.textAlignment = .center
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: FULLWHITECOLOR,
            .font: UIFont.init(name: PRIMARYFONT, size: 21) ?? UIFont.systemFont(ofSize: 21) ]//UIFont.systemFont(ofSize: 21)]
        pickerLabel.attributedText = NSAttributedString(string: String(pickerData[row]), attributes: attributes)

        pickerLabel.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        return pickerLabel
    }

}
