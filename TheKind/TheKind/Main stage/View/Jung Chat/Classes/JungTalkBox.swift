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


struct RoutineToEmission {
    let routine: BehaviorSubject<JungRoutineProtocol>
}


class JungTalkBox {
    
    var kindExplanationPublisher = PublishSubject<RoutineToEmission>()
    var kindExplanationObserver: Observable<RoutineToEmission> {
        return kindExplanationPublisher.asObserver()
    }
    var disposeBag = DisposeBag()
    
  //  private var clearJungChatPublisher = Completable()
    
    var isProcessingSpeech = false
    let tempoBetweenPlayerResponseAndJungResponse: Double = 2
    //var mainViewController: MainViewController?
    
    var delegate: KindActionTriggerView?
    
    var injectRoutineMessageObserver: ((JungRoutineProtocol?)->())?
    
    init(){
        kindExplanationObserver
            .flatMapLatest {
                $0.routine
            }
            .subscribe(onNext: { routine in
                //print("THIS---->",routine.snippets[0].message)
                self.injectRoutineMessageObserver?(routine)
                self.isProcessingSpeech = true
            })
        .disposed(by: disposeBag)
    }
    
    func displayRoutine(routine: JungRoutineProtocol?, wait: Double? = nil) {
        //if !isProcessingSpeech {
           // delay(bySeconds: wait ?? 0) {
                self.injectRoutineMessageObserver?(routine)
                self.isProcessingSpeech = true
          //  }
        //}
    }
    
    func displayRoutine(for userResponseOption: Snippet?, wait: Double? = nil) {
        guard let userResponseOption = userResponseOption else {return}

        let playerMessage = Snippet.init(message: userResponseOption.message, action: userResponseOption.action, id: userResponseOption.id, actionView: userResponseOption.actionView ?? ActionViewName.none)
        
        let playerPostRoutine = JungRoutine.init(snippets: [playerMessage], userResponseOptions: nil, sender: .Player)

        // 1 - send the user message to the chat
        injectRoutineMessageObserver?(playerPostRoutine)

        // 2 - get Jung routine response to the chat. FIRESTORE
        let jungPostRoutine = retrieveRoutineForUserOption(userOptionId: userResponseOption.id)

        // 3 - Send response routine to chat.
        //delay(bySeconds: tempoBetweenPlayerResponseAndJungResponse) {
        self.injectRoutineMessageObserver?(jungPostRoutine)
        //}
    }

    // BASED ON USER RESPONSE
    private func retrieveRoutineForUserOption(userOptionId: Int ) -> JungRoutine {
        
        
        // 1 - Use userOptionId
        // 2 - find routine to play related to userOptionId. FIRESTORE
        // 3 - post it
        
        //Dummy data:
        let linesForJungReplyTest : [Snippet] = [Snippet(message: "", action: .none,id: 2, actionView: nil)]
        
        let testJungRoutine = JungRoutine.init(snippets: linesForJungReplyTest, userResponseOptions:nil, sender: .Jung)
        
        return testJungRoutine
        
    }

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
    
}



// MODEL/TEST DATA.






var userResponseOptionsForSelfie : [Snippet] = [Snippet.init(message: "A Something no trigger", action: .none, id: 1113, actionView: nil)]



var linesForJungReplyPhotoTest : [Snippet] = [Snippet(message: "Thanks Tenny.", action: .none, id: 1, actionView: nil),
                                         Snippet(message: "I totally understand.", action: .none,id: 2, actionView: nil),
                                         Snippet(message: "Sometimes we need time alone.", action: .none, id: 3, actionView: nil)]
