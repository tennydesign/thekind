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

//HERE Introduced the ENUM
class KindDeckManagement {
    
    
    static var userKindDeckArray: [KindCard] = [] {
        didSet{
            saveKindDeck() { (err) in
                if let err = err {
                    fatalError(err.localizedDescription)
                } else {
                    print("kind deck updated succesfully")
                }
            }
        }
    }
    
    static var antagonisticDeck: [KindCardId: KindCard] = [:]
    static var userMainKind: KindCard?
    
    //RETRIEVE
    static func getCurrentUserDeck(completion:@escaping ()->()) {
        let db = Firestore.firestore()
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).getDocument { (document, err) in
            if let err = err {
                print("error \(err)")
                completion()
            } else {
                if let document = document, document.exists{
                    if let result = document.data() {
                        if let cardIds = result[KindDecksFields.userdeck.rawValue] as? [Int] {
                            KindDeckManagement.userKindDeckArray = self.createKindCardDeck(ids: cardIds)
                            completion()
                        } else {
                            fatalError("couldn't load card decks")
                        }
                    }
                }

            }
        }
    }
    
    //SAVE
    private static func saveKindDeck(completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        var cards:[Int] = []
        userKindDeckArray.forEach { (card) in
            cards.append(card.kindId.rawValue)
        }
        let cardsDict:[String: [Int]] = [KindDecksFields.userdeck.rawValue:cards]
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).setData(cardsDict, completion: { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
    
    
    //CREATE
    private static func createKindCardDeck(ids: [Int]) -> [KindCard] {
        var kindcards: [KindCard] = []
        ids.forEach { (id) in
            if let kindIdEnum = KindCardId(rawValue: id) {
                if let card = (GameKinds.allCardsOriginalArray.filter{$0.kindId == kindIdEnum}).first {
                    kindcards.append(card)
                }
            }
        }

        return kindcards
    }
    
}

