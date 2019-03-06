//
//  RealmCollectionChange+Extension.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

extension RealmCollectionChange: Equatable where CollectionType: Equatable {
    
    public static func == (lhs: RealmCollectionChange<CollectionType>, rhs: RealmCollectionChange<CollectionType>) -> Bool {
        switch (lhs, rhs) {
        case (.initial(let left), .initial(let right)):
            return left == right
        case (.update(let left), .update(let right)):
            return left == right
        case (.error(let left), .error(let right)):
            return left == right
        default:
            return false
        }
    }
}
