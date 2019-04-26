//
//  SearchViewModel.swift
//  TheKind
//
//  Created by Tenny on 4/24/19.
//  Copyright © 2019 tenny. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class SearchViewModel {
    var userFields: [String: Any] = [:]
    var users: [UserSearched] = []
    func retrieveAllUserForSearch(completion:@escaping (Bool)->()) {
        let db = Firestore.firestore()
        db.collection("usersettings").getDocuments {  (document,err) in
            if let err = err {
                print(err)
                completion(false)
                return
            }
            document?.documents.forEach({ (document) in
                let user: UserSearched = UserSearched(document: document)
                self.users.append(user)
            })
            completion(true)

        }
    }
}
//
struct UserSearched {
    var name: String?
    var photoURL: String?
    var kind: Int?
    var uid: String
    var ref: DocumentReference?
    
    init(document: DocumentSnapshot) {
        name = document.data()?[UserFieldTitle.name.rawValue] as? String
        photoURL = document.data()?[UserFieldTitle.photoURL.rawValue] as? String
        kind = document.data()?[UserFieldTitle.kind.rawValue] as? Int
        uid = document.documentID
        ref = document.reference
    }
    
}
