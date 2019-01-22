//
//  Jungtalkbox.swift
//  TheKind
//
//  Created by Tenny on 04/12/18.
//  Copyright © 2018 tenny. All rights reserved.


import Foundation
import UIKit
class JungTalkBox {
    let tempoBetweenPlayerResponseAndJungResponse: Double = 2
    //var mainViewController: MainViewController?
    
    var delegate: KindActionTriggerView?
    
    var injectRoutineMessageObserver: ((JungRoutineProtocol?)->())?
    
    
    func displayRoutine(routine: JungRoutineProtocol?, wait: Double? = nil) {
        delay(bySeconds: wait ?? 0) {
            self.injectRoutineMessageObserver?(routine)
        }
    }
    
    func displayRoutine(for userResponseOption: Snippet?, wait: Double? = nil) {
        guard let userResponseOption = userResponseOption else {return}
        
        let playerMessage = Snippet.init(message: userResponseOption.message, action: userResponseOption.action, id: userResponseOption.id, actionView: userResponseOption.actionView ?? .none)
        let playerPostRoutine = JungRoutine.init(snippets: [playerMessage], userResponseOptions: nil, sender: .Player)
        
        // 1 - send the user message to the chat
        injectRoutineMessageObserver?(playerPostRoutine)
        
        // 2 - get Jung routine response to the chat. FIRESTORE
        let jungPostRoutine = retrieveRoutineForUserOption(userOptionId: userResponseOption.id)
        
        // 3 - Send response routine to chat.
        delay(bySeconds: tempoBetweenPlayerResponseAndJungResponse) {
            self.injectRoutineMessageObserver?(jungPostRoutine)
        }
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

    func routineFromText(dialog: String, snippetId: [Int]? = nil, sender: Sender? = nil, action: [KindActionType], actionView: [ActionViewName], options: (Snippet,Snippet)? = nil) -> JungRoutine? {
        
        let messages = Array(dialog.split(separator: "-").map({ (substring) -> String in
            return String(substring)
        }))
    
        if messages.isEmpty {return nil}
        if messages.count != action.count || messages.count != actionView.count {
            fatalError("Messages count is diff than action and actioView count")
        }
        print(messages)
        var snippets:[Snippet] = []
        
        for index in 0...messages.count-1 {
            let snippet = Snippet.init(message: messages[index], action: action[index],
                                       id: snippetId?[index] ?? 0, actionView: actionView[index])
            snippets.append(snippet)
        }
        

        return JungRoutine.init(snippets: snippets, userResponseOptions: options, sender: .Jung)
        
    }
    
    func createUserOptions(opt1: String, opt2: String, actionViews: (ActionViewName, ActionViewName), id: Int? = nil) -> (Snippet,Snippet)? {
        
        let actionOpt: (KindActionType, KindActionType) = (.leftOptionClicked, .rightOptionClicked)
        
        let userOptionA = Snippet.init(message: opt1, action: actionOpt.0, id: id ?? 0, actionView: actionViews.0)
        let userOptionB = Snippet.init(message: opt2, action: actionOpt.1, id: id ?? 0, actionView: actionViews.1)
        
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
