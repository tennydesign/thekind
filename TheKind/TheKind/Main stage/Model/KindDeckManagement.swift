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
    
    static var userMainKind: KindCard?
    
    static var userKindDeckChanged: (()->())?
    
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
                        
                        // GET DECK
                        if let cardIds = result[KindDecksFields.userdeck.rawValue] as? [Int] {
                            KindDeckManagement.userKindDeckArray = self.createKindCardDeck(ids: cardIds)
                        } else {
                            fatalError("couldn't load card decks")
                        }
                        
                        // GET MAINKIND
                        if let maincardId = result[KindDecksFields.mainkind.rawValue] as? Int {
                            if let mainKind = self.createKindCard(id: maincardId) {
                                KindDeckManagement.userMainKind = mainKind
                            }
                        } else {
                            fatalError("couldn't load main card from firestore")
                        }
                        
                         completion()
                        
                    }
                }

            }
        }
    }
    

    //HERE: OBSERVE MAINKIND!
    
     static func saveMainKind() {
        guard let mainKind = userMainKind else {fatalError("can't find mainkind to save")}
        let db = Firestore.firestore()
        
        let mainKindDict:[String: Any] = [KindDecksFields.mainkind.rawValue:mainKind.kindId.rawValue]
        
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).updateData(mainKindDict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //create
                    db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).setData(mainKindDict, merge: true, completion: { (err) in
                        if let err = err {
                            print(err)
                            return
                        }
                        print("a new main kind field was created and updated")
                        userKindDeckChanged?()
                        return

                    })
                }
                //If there is. Update.
                print("an existent main kind field was updated")
                userKindDeckChanged?()
                
            }
        }
        
    }
    
    private static func saveKindDeck(completion: @escaping (Error?)->()) {
        let db = Firestore.firestore()
        var cards:[Int] = []
        userKindDeckArray.forEach { (card) in
            cards.append(card.kindId.rawValue)
        }
        let cardsDict:[String: Any] = [KindDecksFields.userdeck.rawValue:cards]
        
        db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).updateData(cardsDict) { (err) in
            if let err = err {
                if err.localizedDescription.contains("No document to update") {
                    //create
                    db.collection(KindDeckDocument.alldecks.rawValue).document((Auth.auth().currentUser?.uid)!).setData(cardsDict, merge: true, completion: { (err) in
                        if let err = err {
                            completion(err)
                            return
                        }
                        completion(nil)
                        print("a new kind deck field was created and updated")
                        
                        return
                    })
                }
            }
                //If there is. Update.
                print("an existent kind deck field was updated")
                completion(nil)
            }
    }
    
    
    //CREATE
    private static func createKindCard(id: Int) -> KindCard? {
        var kindcard: KindCard
        if let kindIdEnum = KindCardId(rawValue: id) {
            if let card = (GameKinds.allCardsOriginalArray.filter{$0.kindId == kindIdEnum}).first {
                kindcard = card
                return kindcard
            }
        }
        return nil
    }
    
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

