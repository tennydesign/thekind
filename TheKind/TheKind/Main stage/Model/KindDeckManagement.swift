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





class KindDeckManagement {
    
//    static var intellect: [KindName: KindCard] = [.explorer : KindCard(kindId: .explorer, antagonists: nil, kindName: KindName.explorer),
//                                        .mentor : KindCard(kindId: .mentor, antagonists: nil, kindName: KindName.mentor),
//                                        .misfit : KindCard(kindId: .misfit, antagonists: nil, kindName: KindName.misfit)]
//
//
//    static var imagination: [KindName: KindCard] = [.visionary : KindCard(kindId: .visionary, antagonists: nil, kindName: KindName.visionary),
//                                        .founder : KindCard(kindId: .founder, antagonists: nil, kindName: KindName.founder)]
//
//    static var intuition: [KindName: KindCard] = [.leader : KindCard(kindId: .leader, antagonists: nil, kindName: KindName.leader),
//                                        .grinder : KindCard(kindId: .grinder, antagonists: nil, kindName: KindName.grinder),
//                                        .idealist : KindCard(kindId: .idealist, antagonists: nil, kindName: KindName.idealist),
//                                        .teamplayer : KindCard(kindId: .teamplayer, antagonists: nil, kindName: KindName.teamplayer)]
//
//
//    static var Empathy: [KindName: KindCard] = [.angel : KindCard(kindId: .angel, antagonists: nil, kindName: KindName.angel),
//                                        .trailblazer : KindCard(kindId: .trailblazer, antagonists: nil, kindName: KindName.trailblazer),
//                                        .entertainer : KindCard(kindId: .entertainer, antagonists: nil, kindName: KindName.entertainer)]
    
    
    static var userKindDeck: [KindName : KindCard] = [:] //{
//        didSet {
//            userKindDeck.forEach { (card) in
//                if let anti = card.value.antagonists {
//                    anti.forEach({ (antiCard) in
//                        antagonisticDeck[antiCard.kindName] = antiCard
//                    })
//                }
//            }
//        }
 //   }
    
    //HERE: MAYBE change the array to: [String: KindCard]
    static var antagonisticDeck: [String: KindCard] = [:]
    
    init() {
        KindDeckManagement.userKindDeck[.founder] = KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImage: #imageLiteral(resourceName: "mountain"))
    }
    
    func updateKindDeck() {
        // set value KindDeckManagement.kindDeck
       // KindDeckManagement.userKindDeck["The Explorer"] = KindDeckManagement.intellect["The Explorer"]
    }
    
    func getDrawDeckForUser() {
        // drawDeck = fullDeck - antagonisticDeck
        // return drawDeck
    }
    
    func getAntagonists() {
        
    }
    
    func getKindCard(type: KindCardId) -> KindCard {
        switch type {
            case .achiever:
                return KindCard(kindId: .achiever, antagonists: nil, kindName: .achiever, iconImage:#imageLiteral(resourceName: "achiever"))
            case .adventurer:
                return KindCard(kindId: .adventurer, antagonists: nil, kindName: .adventurer, iconImage:#imageLiteral(resourceName: "adventurer"))
            case .aequanimus:
                return KindCard(kindId: .aequanimus, antagonists: nil, kindName: .aequanimus, iconImage:#imageLiteral(resourceName: "aequanimus"))
            case .agnostic:
                return KindCard(kindId: .agnostic, antagonists: nil, kindName: .agnostic, iconImage:#imageLiteral(resourceName: "agnostic"))
            case .ally:
                return KindCard(kindId: .agnostic, antagonists: nil, kindName: .agnostic, iconImage:#imageLiteral(resourceName: "Ally"))
            case .angel:
                return KindCard(kindId: .angel, antagonists: nil, kindName: .angel, iconImage:#imageLiteral(resourceName: "angel"))
            case .artist:
                return KindCard(kindId: .artist, antagonists: nil, kindName: .artist, iconImage:#imageLiteral(resourceName: "artist"))
            case .believer:
                return KindCard(kindId: .believer, antagonists: nil, kindName: .believer, iconImage:#imageLiteral(resourceName: "believer"))
            case .blindfolded:
                return KindCard(kindId: .blindfolded, antagonists: nil, kindName: .blindfolded, iconImage:#imageLiteral(resourceName: "blindfolded"))
            case .bonvivant:
                return KindCard(kindId: .bonvivant, antagonists: nil, kindName: .bonvivant, iconImage:#imageLiteral(resourceName: "bonvivant"))
            case .champion:
                return KindCard(kindId: .champion, antagonists: nil, kindName: .champion, iconImage:#imageLiteral(resourceName: "champion"))
            case .connector:
                return KindCard(kindId: .connector, antagonists: nil, kindName: .connector, iconImage:#imageLiteral(resourceName: "connector"))
            case .controller:
                return KindCard(kindId: .controller, antagonists: nil, kindName: .controller, iconImage:#imageLiteral(resourceName: "controller"))
            case .director:
                return KindCard(kindId: .director, antagonists: nil, kindName: .director, iconImage:#imageLiteral(resourceName: "director"))
            case .empathetic:
                return KindCard(kindId: .empathetic, antagonists: nil, kindName: .empathetic, iconImage:#imageLiteral(resourceName: "empathetic"))
            case .entertainer:
                return KindCard(kindId: .entertainer, antagonists: nil, kindName: .entertainer, iconImage:#imageLiteral(resourceName: "entertainer"))
            case .enthusiast:
                return KindCard(kindId: .enthusiast, antagonists: nil, kindName: .enthusiast, iconImage:#imageLiteral(resourceName: "enthusiast"))
            case .explorer:
                return KindCard(kindId: .explorer, antagonists: nil, kindName: .explorer, iconImage:#imageLiteral(resourceName: "explorer"))
            case .founder:
                return KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImage:#imageLiteral(resourceName: "founder"))
            case .grinder:
                return KindCard(kindId: .grinder, antagonists: nil, kindName: .grinder, iconImage:#imageLiteral(resourceName: "grinder"))
            case .guided:
                return KindCard(kindId: .guided, antagonists: nil, kindName: .guided, iconImage:#imageLiteral(resourceName: "guided"))
            case .idealist:
                return KindCard(kindId: .idealist, antagonists: nil, kindName: .idealist, iconImage:#imageLiteral(resourceName: "idealist"))
            case .ingenius:
                return KindCard(kindId: .ingenius, antagonists: nil, kindName: .ingenius, iconImage:#imageLiteral(resourceName: "ingenius"))
            case .juggler:
                return KindCard(kindId: .juggler, antagonists: nil, kindName: .juggler, iconImage:#imageLiteral(resourceName: "juggler"))
            case .jumper:
                return KindCard(kindId: .jumper, antagonists: nil, kindName: .jumper, iconImage:#imageLiteral(resourceName: "jumper"))
            case .keeper:
                return KindCard(kindId: .keeper, antagonists: nil, kindName: .keeper, iconImage:#imageLiteral(resourceName: "keeper"))
            case .leader:
                return KindCard(kindId: .leader, antagonists: nil, kindName: .leader, iconImage: #imageLiteral(resourceName: "leader"))
            case .mentor:
                return KindCard(kindId: .mentor, antagonists: nil, kindName: .mentor, iconImage: #imageLiteral(resourceName: "mentor"))
            case .still:
                return KindCard(kindId: .still, antagonists: nil, kindName: .still, iconImage: #imageLiteral(resourceName: "still"))
            case .rebel:
                return KindCard(kindId: .rebel, antagonists: nil, kindName: .rebel, iconImage: #imageLiteral(resourceName: "rebel"))
        default:
            return KindCard(kindId: .adventurer, antagonists: nil, kindName: .adventurer, iconImage:#imageLiteral(resourceName: "noX"))
        }
    }
}

struct KindCard {
    var kindId: KindCardId!
    var antagonists: [KindCard]?
    var kindName: KindName
    let iconImage: UIImage
}


//        didSet {
//            userKindDeck.forEach { (card) in
//                if let antiArray = card.antagonists {
//                    antiArray.forEach({ (antiCard) in
//                        //check if already exists in antagonistic deck. If it does, does not add it again
//                        if !antagonisticDeck.contains(where: { card in card.type == antiCard.type }) {
//                            antagonisticDeck.append(antiCard)
//                        }
//                    })
//
//                }
//            }
//        }
