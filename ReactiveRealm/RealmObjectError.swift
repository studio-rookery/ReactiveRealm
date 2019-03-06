//
//  RealmObjectError.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift

/// `RealmObjectError` represents an error that could be emitted by realm during a observation for Object.
public enum RealmObjectError: Error {
    
    /// An error occured when the observed object was deleted.
    case deleted
    
    /// An error occured when failed to open a realm.
    case unknown(Error)
}
