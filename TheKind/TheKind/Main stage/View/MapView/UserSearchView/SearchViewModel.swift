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

//class SearchViewModel {
//    var userFields: [String: Any] = [:]
//    //TODO: Replace with retrieveAllUsers from KindUserManager
//    func retrieveAllUsers(completion:@escaping ([KindUser]?)->()) {
//        let db = Firestore.firestore()
//        var users: [KindUser] = []
//        db.collection("usersettings").getDocuments {  (document,err) in
//            if let err = err {
//                print(err)
//                completion(nil)
//                return
//            }
//            document?.documents.forEach({ (document) in
//                let user: KindUser = KindUser(document: document)
//                if user.kind != nil {
//                    users.append(user)
//                }
//            })
//            completion(users)
//
//        }
//    }
//    
//    // TODO OPT:
//    // IMPLEMENT
//    // func retrieveUsersByKeyStroke(keyword: String, completion:@escaping ([KindUser]?)->()) {
//    // USE:
//    //    citiesRef.whereField("state", isEqualTo: "CA")
//    //    citiesRef.whereField("population", isLessThan: 100000)
//    //    citiesRef.whereField("name", isGreaterThanOrEqualTo: "San Francisco")
//}
