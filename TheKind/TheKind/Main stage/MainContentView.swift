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

class MainContentView: KindActionTriggerView{
   
    let disposeBag = DisposeBag()
    
    @IBOutlet var mainView: UIView!
    
    var presentingKindActionView: KindActionTriggerView?
    var viewToPresent: UIView? {
        didSet {
            if let viewToPresent = viewToPresent {
                viewToPresent.frame = self.bounds
                viewToPresent.autoresizingMask = [.flexibleHeight,.flexibleWidth]
                self.addSubview(viewToPresent)
            }
        }
    }
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
                guard let tag = snippet.actionView?.rawValue else {return}
        
                
                switch snippet.action {
                    case .leftOptionClicked:
                        self?.presentingKindActionView?.leftOptionClicked()
                    case .activate:
                        self?.presentingKindActionView?.activate()
                    case .fadeInView:
                        self?.presentingKindActionView?.fadeInView()
                    case .fadeOutView:
                        self?.presentingKindActionView?.fadeOutView()
                    case .talk:
                        self?.presentingKindActionView?.talk()
                    case .none:
                        ()
                    case .loadView:
                        self?.activateView(tag: tag)
                    case .deactivate:
                        self?.unload()
                    case .rightOptionClicked:
                        self?.presentingKindActionView?.rightOptionClicked()
                }
            })
            .disposed(by: disposeBag)
        
        print("activated!!!!")
    }
    
    //HERE IMPROVE THIS NUMBER THING.
    func activateView(tag: Int) {
        if tag == 105 { // MAP
            self.loadMapView()
        }
    }
        
    func loadMapView() {
        //clean it first with unload or won't load.
        if  presentingKindActionView == nil {
            let mapview:MapActionTriggerView = MapActionTriggerView()
            viewToPresent = mapview //.mainView
            mapview.mainViewController2 = mainViewController2
            mapview.talkBox2 = talkBox2
            mapview.activate() // creates mainview
           
            presentingKindActionView = mapview
        }
    }
    
    func unload() {
        viewToPresent?.removeFromSuperview()
        presentingKindActionView = nil
        viewToPresent = nil
    }
    
}
