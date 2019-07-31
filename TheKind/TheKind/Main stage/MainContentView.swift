//
//  MainContentView.swift
//  TheKind
//
//  Created by Tennyson Pinheiro on 7/24/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


//HERE: TIME TO START INTEGRATING THEM ALL.
class MainContentView: KindActionTriggerView{
    
    let disposeBag = DisposeBag()
    @IBOutlet var mainView: UIView!
    var mainContentViewContainer: KindActionTriggerView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    fileprivate func commonInit() {
    }
    
    override func activate() {
        talkBox2?.actionExecutionPublisherObserver.share()
            .flatMapLatest {
                return $0.snippet
            }
            .subscribe(onNext: { [weak self] snippet in
                
                //extract enum
                guard let viewEnum = snippet.actionView else {return}
                //loads view for enum
                self?.loadView(viewEnum) { view in
                    if let view = view {
                        self?.talkBox2?.triggerSnippetAction(view, snippet.action)
                    }
                }
            })
            .disposed(by: disposeBag)
    
    }

    
    func loadView(_ actionEnum :ViewForActionEnum, completion: ((KindActionTriggerView?)->())?) {
     //  print(mainContentViewContainer?.description)
        guard let view = returnViewForAction(actionEnum) else {return}
        if mainContentViewContainer?.viewName == actionEnum {
            completion?(mainContentViewContainer)
            return
        } //same as view already loaded.
        
        //load new one.

        self.fadeOut(0.5) {
            Bundle.main.loadNibNamed("MainContentView", owner: self, options: nil)
            self.addSubview(self.mainView)
            self.mainView.frame = self.bounds
            self.mainView.autoresizingMask = [.flexibleHeight,.flexibleWidth]

            self.mainView.addSubview(view)
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
            view.mainViewController2 = self.mainViewController2
            view.talkBox2 = self.talkBox2
            view.activate() // the "viewload" only it gives me time to do some other preps, like overlays, loading order etc.
            
            view.viewName = actionEnum
            self.mainContentViewContainer = view
            self.fadeIn(0.5)
            completion?(view)
        }
    }


    func returnViewForAction(_ viewForAction: ViewForActionEnum) -> KindActionTriggerView? {
        var view: KindActionTriggerView? = nil
        guard let typeName = kindActionViewStorage[viewForAction] else {return nil}
        view = factory(type: typeName)
        return view
    }
    
    func factory(type:KindActionTriggerView.Type) -> KindActionTriggerView {
        return type.init()
    }

    func removeView() {
        mainContentViewContainer?.fadeOut(0.5) {
            self.mainContentViewContainer?.removeFromSuperview()
            self.mainContentViewContainer = nil
        }
    }
    

    
}
