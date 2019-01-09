//
//  Person.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift

final class Person: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var birthdate = Date(timeIntervalSince1970: 1)
    
    let dogs = List<Dog>()
}
