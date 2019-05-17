//
//  UserNameSetupView.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 1/4/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit
import GoogleSignIn
//TODO: REFACTOR THIS

class dobOnboardingView: KindActionTriggerView, UIPickerViewDelegate,UIPickerViewDataSource {
    
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
        Bundle.main.loadNibNamed("DobOnboardingView", owner: self, options: nil)
        addSubview(mainView)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        pickerView.transform = CGAffineTransform(rotationAngle: -rotationAngle)
        
        pickerView.frame = CGRect(x: -100, y: 0, width: self.frame.width - 200, height: 100)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
      
        pickerView.selectRow(90, inComponent:0, animated:true)
 
        
    }
    
    override func activate() {
            self.logCurrentLandingView(tag: ActionViewName.DobOnboardingView.rawValue)
            self.talk()
    }
    
    override func talk() {
        let txt = "Sorry,not trying to be indiscrete.-But...what is your year of birth?-Choose from the options above."
        let actions: [KindActionType] = [.none, .none,.fadeInView]
        let actionViews: [ActionViewName] = [.none,.none, .DobOnboardingView]
        
        let options = self.talkbox?.createUserOptions(opt1: "", opt2: "Confirm year.", actionView: self)
        
        delay(bySeconds: 0.3, dispatchLevel: .main) {
            self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: .Jung, action: actions, actionView: actionViews, options: options))
        }
    }
    

    
    override func fadeInView() {
        self.alpha = 0
        self.isHidden = false
        self.talkbox?.delegate = self
        UIView.animate(withDuration: 1) {
            self.alpha = 1
        }
    }
    
     override func deactivate() {
        UIView.animate(withDuration: 1) {
            self.pickerView.alpha = 0
        }
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
        
        let txt = "I understand you are about \(age) years old.- We are almost finished with the setup."
        let actions: [KindActionType] = [.none,.activate]
        let actionViews: [ActionViewName] = [.none,.ChooseDriverView]
        self.talkbox?.displayRoutine(routine: self.talkbox?.routineFromText(dialog: txt, snippetId: nil, sender: nil, action: actions, actionView: actionViews, options: nil))
        
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
