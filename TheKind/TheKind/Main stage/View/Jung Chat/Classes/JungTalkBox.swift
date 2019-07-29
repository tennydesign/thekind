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

struct SnippetToEmission {
    let snippet: BehaviorSubject<Snippet>
}

//create a publisher


class JungTalkBox {
    
    var jungClearRoutine: JungRoutine {
        return JungRoutine(snippets: nil, userResponseOptions: nil, sender: .ClearAll)
    }
    
    var jungClearButtonsRoutine: JungRoutine {
       return JungRoutine(snippets: nil, userResponseOptions: nil, sender: .ClearButtons)
    }
    
    var kindExplanationPublisher = PublishSubject<JungRoutineToEmission>()
    var kindExplanationObserver: Observable<JungRoutineToEmission> {
        return kindExplanationPublisher.asObservable()
    }
    
    var actionExecutionPublisher = PublishSubject<SnippetToEmission>()
    var actionExecutionPublisherObserver: Observable<SnippetToEmission> {
        return actionExecutionPublisher.asObservable()
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

                let rm = JungRoutineToEmission(routine: BehaviorSubject(value: routine))
                self.jungChatUIRoutinePublisher.onNext(rm)
                
                self.isProcessingSpeech = true
            })
            .disposed(by: disposeBag)
    }
    
//=============
    // Constructors for routines and snippets
//=============

    func routineFromText(dialog: String, snippetId: [Int]? = nil, sender: Sender? = nil, actions: [KindActionTypeEnum]?, actionViews: [ViewForActionEnum]?, options: (Snippet,Snippet)? = nil) -> JungRoutine? {
        
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
                                       id: snippetId?[index] ?? 0, actionView: actionViews?[index] ?? ViewForActionEnum.none)
            snippets.append(snippet) 
        }
        

        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    func routineWithNoText(snippetId: [Int]? = nil, sender: Sender? = nil, actions: [KindActionTypeEnum]?, actionViews: [ViewForActionEnum]?, options: (Snippet,Snippet)? = nil) -> JungRoutine? {
        
        var snippets:[Snippet] = []
        
        guard let actions = actions else {return nil}
        for index in 0...actions.count-1 {
            let snippet = Snippet.init(message: "", action: actions[index] ,
                                       id: snippetId?[index] ?? 0, actionView: actionViews?[index] ?? ViewForActionEnum.none)
            snippets.append(snippet)
        }
        
        
        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    // this assumes right and left for the same view
    func createUserOptions(opt1: String, opt2: String, actionView: UIView, id: Int? = nil) -> (Snippet,Snippet)? {
        
        let actionOpt: (KindActionTypeEnum, KindActionTypeEnum) = (.leftOptionClicked, .rightOptionClicked)
        
        let actionViewName: ViewForActionEnum = ViewForActionEnum(rawValue: actionView.tag) ?? .none
        
        let userOptionA = Snippet.init(message: opt1, action: actionOpt.0, id: id ?? 0, actionView: actionViewName)
        let userOptionB = Snippet.init(message: opt2, action: actionOpt.1, id: id ?? 0, actionView: actionViewName)
        
        return (userOptionA,userOptionB)
        
    }
    
    // This one assumes right an left but allow for other views.
    func createUserOptions(opt1: String, opt2: String, actionViews: (ViewForActionEnum, ViewForActionEnum), id: Int? = nil) -> (Snippet,Snippet)? {
        
        let actionOpt: (KindActionTypeEnum, KindActionTypeEnum) = (.leftOptionClicked, .rightOptionClicked)
        
        let userOptionA = Snippet.init(message: opt1, action: actionOpt.0, id: id ?? 0, actionView: actionViews.0)
        let userOptionB = Snippet.init(message: opt2, action: actionOpt.1, id: id ?? 0, actionView: actionViews.1)
        
        return (userOptionA,userOptionB)
        
    }
    
    // this one assumes nothing. Full constructor.
    func createUserOptions(opt1: String, opt2: String, actionViews: (ViewForActionEnum,ViewForActionEnum), actions: (KindActionTypeEnum,KindActionTypeEnum), id: Int? = nil) -> (Snippet,Snippet)? {
        
        let userOptionA = Snippet.init(message: opt1, action: actions.0 , id: id ?? 0, actionView: actionViews.0)
        let userOptionB = Snippet.init(message: opt2, action: actions.1 , id: id ?? 0, actionView: actionViews.1)
        
        return (userOptionA,userOptionB)
        
    }
    
    // ===== NEW CONSTRUCTORS
    
    func routineGenerator(explainer: JungChatExplainer) -> JungRoutine? {
        var messages: [String]?
        var actions: [KindActionTypeEnum]?
        var viewsForActions: [ViewForActionEnum]?
        var snippets:[Snippet] = []
        var options: (Snippet,Snippet)?
        
        if let txt = explainer.txt {
              messages = Array(txt.split(separator: "-").map({ (substring) -> String in
                    return String(substring)
                }))
        }
        
        if let acts = explainer.actions {
            actions = acts
        }
        
        if messages != nil {
            for index in 0...messages!.count-1 {
                let snippet = Snippet.init(message: messages![index], action: actions?[index] ?? .none,
                                           id: 0, actionView: viewsForActions?[index] ?? ViewForActionEnum.none)
                snippets.append(snippet)
            }
        } else {
            //HERE: Something is off from explainerNavigator to here. Action not being executed.
            if actions != nil {
                guard viewsForActions?.count == actions?.count else {fatalError("Number of actions must be same as number of views")}
                for index in 0...actions!.count-1 {
                    let snippet = Snippet.init(message: "", action: actions![index] ,
                                               id: 0, actionView: viewsForActions?[index] ?? ViewForActionEnum.none)
                    snippets.append(snippet)
                }
            }
        }
        
        if let opttxts = explainer.optButtonText, let viewsForAction = explainer.optButtonViews, let optActions = explainer.optActions{
            options = createUserOptions(opt: opttxts, actionOptions: optActions, actionViews: viewsForAction)
        }
        
        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    
    func createUserOptions(opt: (String,String), actionOptions:(KindActionTypeEnum, KindActionTypeEnum), actionViews: (ViewForActionEnum,ViewForActionEnum)) -> (Snippet,Snippet)? {
        
        let userOptionA = Snippet.init(message: opt.0, action: .leftOptionClicked , id: 0, actionView: actionViews.0)
        let userOptionB = Snippet.init(message: opt.1, action: .rightOptionClicked , id: 0, actionView: actionViews.1)
        
        return (userOptionA,userOptionB)
        
    }
    
    

 

    
    
//=============
// Triggers
//=============

    
    func triggerSnippetAction(_ view: KindActionTriggerView, _ action: KindActionTypeEnum) {
        switch action {
            case .leftOptionClicked:
                view.leftOptionClicked()
            case .activate:
                view.activate()
            case .fadeInView:
                view.fadeInView()
            case .fadeOutView:
                view.fadeOutView()
            case .talk:
                view.talk()
            case .rightOptionClicked:
                view.rightOptionClicked()
            case .none:
                ()
            case .deactivate:
                view.deactivate()
        }
    }

    func loadMainViewContentSnippetAction(_ snippet: Snippet) {
        let sn = SnippetToEmission(snippet: BehaviorSubject(value: snippet))
        actionExecutionPublisher.onNext(sn)
        
    }
    
    func emmitSignalToClearUI() {
        let rmClear = JungRoutineToEmission(routine: BehaviorSubject(value: jungClearRoutine))
        kindExplanationPublisher.onNext(rmClear)
    }
    
}

