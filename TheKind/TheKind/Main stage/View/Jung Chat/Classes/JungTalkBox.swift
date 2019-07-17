//
//  Jungtalkbox.swift
//  TheKind
//
//  Created by Tenny on 04/12/18.
//  Copyright © 2018 tenny. All rights reserved.


import Foundation
import UIKit
import RxCocoa
import RxSwift


struct JungRoutineToEmission {
    let routine: BehaviorSubject<JungRoutine>
}


class JungTalkBox {
    
    var jungClearRoutine: JungRoutine {
        return JungRoutine(snippets: nil, userResponseOptions: nil, sender: .Clear)
    }
    
    var kindExplanationPublisher = PublishSubject<JungRoutineToEmission>()
    var kindExplanationObserver: Observable<JungRoutineToEmission> {
        return kindExplanationPublisher.asObservable()
    }
    
    //To JungChatLogger UI
    private var jungChatUIRoutinePublisher = PublishSubject<JungRoutineToEmission>()
    var jungChatUIRoutineObserver: Observable<JungRoutineToEmission> {
        return jungChatUIRoutinePublisher.asObservable()
    }
    
    var disposeBag = DisposeBag()
    
    var isProcessingSpeech = false
    let tempoBetweenPlayerResponseAndJungResponse: Double = 2

    var delegate: KindActionTriggerView?
    
   
    init(){
        setupkindExplanationObserver()
    }
    
    func setupkindExplanationObserver() {
        kindExplanationObserver.share()
            .flatMapLatest {
                $0.routine
            }
            .subscribe(onNext: { routine in
                print("THIS---->",routine.snippets?[0].message ?? "No snippet")

                //Sends it to JungChatLogger // old inject.
                let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                self.jungChatUIRoutinePublisher.onNext(rm)
                
                self.isProcessingSpeech = true
            })
            .disposed(by: disposeBag)
    }
    
//=============
    // Constructors for routines and snippets
//=============

    func routineFromText(dialog: String, snippetId: [Int]? = nil, sender: Sender? = nil, actions: [KindActionType]?, actionViews: [ActionViewName]?, options: (Snippet,Snippet)? = nil) -> JungRoutine? {
        
        //cuts the message at the special character "-"
        let messages = Array(dialog.split(separator: "-").map({ (substring) -> String in
            return String(substring)
        }))
        
        if messages.isEmpty {return nil}
    
        
        if let actions = actions,let actionViews = actionViews {
            if messages.count != actions.count || messages.count != actionViews.count {
                fatalError("Messages count is diff than action and actionView count")
            }
        }

        
        var snippets:[Snippet] = []
        
        for index in 0...messages.count-1 {
            let snippet = Snippet.init(message: messages[index], action: actions?[index] ?? .none,
                                       id: snippetId?[index] ?? 0, actionView: actionViews?[index] ?? ActionViewName.none)
            snippets.append(snippet) 
        }
        

        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    func routineWithNoText(snippetId: [Int]? = nil, sender: Sender? = nil, actions: [KindActionType]?, actionViews: [ActionViewName]?, options: (Snippet,Snippet)? = nil) -> JungRoutine? {
        
        var snippets:[Snippet] = []
        
        guard let actions = actions else {return nil}
        for index in 0...actions.count-1 {
            let snippet = Snippet.init(message: "", action: actions[index] ,
                                       id: snippetId?[index] ?? 0, actionView: actionViews?[index] ?? ActionViewName.none)
            snippets.append(snippet)
        }
        
        
        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    // Create user option labels. Return as touple to
    func createUserOptions(opt1: String, opt2: String, actionViews: (ActionViewName, ActionViewName), id: Int? = nil) -> (Snippet,Snippet)? {
        
        let actionOpt: (KindActionType, KindActionType) = (.leftOptionClicked, .rightOptionClicked)
        
        let userOptionA = Snippet.init(message: opt1, action: actionOpt.0, id: id ?? 0, actionView: actionViews.0)
        let userOptionB = Snippet.init(message: opt2, action: actionOpt.1, id: id ?? 0, actionView: actionViews.1)
        
        return (userOptionA,userOptionB)
        
    }
 
    func createUserOptions(opt1: String, opt2: String, actionView: UIView, id: Int? = nil) -> (Snippet,Snippet)? {
        
        let actionOpt: (KindActionType, KindActionType) = (.leftOptionClicked, .rightOptionClicked)
        
        let actionViewName: ActionViewName = ActionViewName(rawValue: actionView.tag) ?? .none
        
        let userOptionA = Snippet.init(message: opt1, action: actionOpt.0, id: id ?? 0, actionView: actionViewName)
        let userOptionB = Snippet.init(message: opt2, action: actionOpt.1, id: id ?? 0, actionView: actionViewName)
        
        return (userOptionA,userOptionB)
        
    }
    
    
//=============
// Triggers
//=============
    
    func executeSnippetAction(_ snippet: SnippetProtocol) {
        guard let tag = snippet.actionView?.rawValue else {return}
        

        if snippet.action == .fadeInView {
            returnActionTriggerView(by: tag)?.fadeInView()
        }

        if snippet.action == .fadeOutView {
            returnActionTriggerView(by: tag)?.fadeOutView()
        }
 
        if snippet.action == .activate {
            returnActionTriggerView(by: tag)?.activate()
        }
        
        if snippet.action == .deactivate {
            returnActionTriggerView(by: tag)?.deactivate()
        }

        if snippet.action == .leftOptionClicked {
            returnActionTriggerView(by: tag)?.leftOptionClicked()
        }

        if snippet.action == .rightOptionClicked {
            returnActionTriggerView(by: tag)?.rightOptionClicked()
        }
        
        if snippet.action == .talk {
            returnActionTriggerView(by: tag)?.talk()
        }
        
    }
    
    func clearJungChat() {
        let rm = JungRoutineToEmission(routine: BehaviorSubject(value: jungClearRoutine))
        kindExplanationPublisher.onNext(rm)
    }
    
}

