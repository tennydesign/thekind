//
//  Bindable.swift
//  TheKind
//
//  Created by Tenny on 09/12/18.
//  Copyright © 2018 tenny. All rights reserved.
//

import Foundation

class Bindable<T> {
    
    //trigger
    var value: T? {
        didSet {
            //passage to view
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping(T?) -> ()) {
        self.observer = observer
    }
    
}
