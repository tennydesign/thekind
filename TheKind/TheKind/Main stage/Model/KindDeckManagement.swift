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
    
    static var userKindDeck: [KindName : KindCard] = [:]
    static var antagonisticDeck: [String: KindCard] = [:]
    
    init() {
        KindDeckManagement.userKindDeck[.founder] = KindCard(kindId: .founder, antagonists: nil, kindName: .founder, iconImageName:.founder)
    }
    
    
    func getAntagonists(_ id: KindCardId)->[KindCard]? {
        return nil
    }
    
    
    func getKindCard(id: KindCardId, name: KindName, image: KindImageName) -> KindCard {
        return KindCard(kindId: id, antagonists: getAntagonists(id), kindName: name, iconImageName: image)
    }
    
//    func getAvailableDeck() -> [KindCard]{
//        
//        //
//        
//    }
    
}

