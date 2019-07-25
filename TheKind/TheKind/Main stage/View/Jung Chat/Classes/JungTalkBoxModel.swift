//
//  JungTalkBoxModel.swift
//  TheKind
//
//  Created by Tenny on 12/24/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation

// ===> A routine is a colleciton of timerized snippets and response options. <===
struct JungRoutine: JungRoutineProtocol, Equatable {
    
    static func == (lhs: JungRoutine, rhs: JungRoutine) -> Bool {
        return ((lhs.snippets?.first?.message == rhs.snippets?.first?.message) &&
                (lhs.snippets?.last?.message == rhs.snippets?.last?.message) &&
                (lhs.snippets?.count == rhs.snippets?.count))
    }
    
    var snippets : [Snippet]?
    var userResponseOptions : (Snippet,Snippet)?
    var sender: Sender
}

// ===> A snippet is the line to be //printed in the chat window <===
struct Snippet: SnippetProtocol {
    var message: String //printed message
    var action: KindActionType // will be executed at the same time Jung "speaks" the line.
    var id: Int // not being used.
    var actionView: ActionViewName? //view in which the action is executed.
  //  var sender: Sender
    
}

// ===> Player means no animation and quick deliver <===
enum Sender {
    case Jung, Player, ClearAll, ClearButtons
}

// ===> Refer to KindActionTriggerView for how the delegate uses this enum <====
enum KindActionType {
    case fadeInView,
    fadeOutView,
    activate,
    deactivate,
    rightOptionClicked,
    leftOptionClicked,
    talk,
    loadView,
    none
}

// ADDTRIGGERVIEW: Must add it here. 
enum ActionViewName: Int {
    case BadgePhotoSetupView = 100,
        GameBoard = 103,
        GameBoardSceneControlView = 201,
        KindMatchControlView = 202,
        HudView = 12,
        DobOnboardingView = 101,
        UserNameView = 102,
        MapView = 105,
        BrowseKindView = 106,
        ChooseDriverView = 107,
        CardSwipeView = 108,
        mainContentView = 1001,
        none = -1
}

// ===> This is used by functions to call a snippet parameter that can be generic <===
// We may want to have more than one type od snippet in the future.
protocol SnippetProtocol {
    var message: String {get set}
    var id: Int {get set}
    var action: KindActionType {get set}
    var actionView: ActionViewName? {get set}
}

// ===> This is used by functions to call a Routine parameter that can be generic <===
// We may want to have more than one type of Routine in the future.
protocol JungRoutineProtocol {
 //   var snippets: [Snippet] {get}
    var sender: Sender {get}
}
