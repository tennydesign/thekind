//
//  ConfirmationView.swift
//  TheKind
//
//  Created by Tenny on 5/6/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import UIKit

protocol ConfirmationViewProtocol {
    func userConfirmed()
    func userCancelled()
}

enum ConfirmButtonActions: Int {
    case removeUserFromCircle = 1, transferCircleToUser = 2
}

class ConfirmationView: KindActionTriggerView {

    @IBOutlet var mainView: PassthroughView!
    var delegate: ConfirmationViewProtocol?
    var actionEnum: ConfirmButtonActions?
    @IBOutlet var confirmAction: KindButton!
    @IBOutlet var cancelAction: KindButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("ConfirmationView", owner: self, options: nil)
        addSubview(mainView)
    }
    
    @IBAction func confirm(_ sender: KindButton) {
        delegate?.userConfirmed()
    }
    
    @IBAction func cancelled(_ sender: KindButton) {
        delegate?.userCancelled()
    }
    
    override func activate() {
        self.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1
        }


    }
    
    override func deactivate() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0
        }) { (completed) in
            self.isHidden = true
            self.confirmAction.setTitle("", for: .normal)
            self.delegate = nil
        }


    }
    
}
