//
//  Realm+Extension.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    static func inMemory(identifier: String = "\(#function) - \(UUID().uuidString)") -> Realm {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.inMemoryIdentifier = identifier
        return try! Realm(configuration: configuration)
    }
    
    func forceWrite(_ block: () -> Void) {
        try! write(block)
    }
    
    func forceAdd(_ object: Object) {
        forceWrite {
            add(object)
        }
    }
    
    func forceAdd(_ objects: [Object]) {
        forceWrite {
            add(objects)
        }
    }
    
    func forceDelete(_ object: Object) {
        forceWrite {
            delete(object)
        }
    }
}
