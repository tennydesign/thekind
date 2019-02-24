//
//  KindDeckManagement.swift
//  TheKind
//
//  Created by Tenny on 2/23/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore



enum KindCardId: Int {
    case angel = 1,
    trailblazer = 2,
    entertainer = 3,
    leader = 4,
    grinder = 5,
    idealist = 6,
    teamplayer = 7,
    visionary = 8,
    founder = 9,
    explorer = 10,
    mentor = 11,
    misfit = 12,
    agnostic = 13,
    believer = 14,
    guided = 15,
    simulation = 16,
    onelikethesky = 17,
    aequanimus = 18,
    keeper = 19,
    nomad = 20,
    servant = 21,
    blindfolded = 22,
    original = 23,
    player = 24,
    bonvivant = 25,
    achiever = 26,
    director = 27,
    controller = 28,
    enthusiast = 29,
    optmistic = 30,
    empathetic = 31,
    poet = 32,
    mindful = 33,
    connector = 34,
    shapeshifter = 35,
    ingenius = 36,
    artist = 37,
    realist = 38,
    ally = 39,
    champion = 40,
    perfectionist = 41,
    juggler = 42,
    adventurer = 43,
    jumper = 44,
    seeker = 45,
    traditionalist = 46,
    modernist = 47,
    moderator = 48
}


class KindDeckManagement {
    static var intellect: [KindCardId] = [.explorer, .mentor, .misfit]
    static var imagination: [KindCardId] = [.visionary, .founder]
    static var intuition: [KindCardId] = [.leader, .grinder, .idealist, .teamplayer]
    static var Empathy: [KindCardId] = [.angel, .trailblazer, .angel]
    
    static var kindDeck: [KindCardId] = []
    
    func updateKindDeck() {
        // set value KindDeckManagement.kindDeck
        KindDeckManagement.kindDeck.append(KindCardId.angel)
    }
}
