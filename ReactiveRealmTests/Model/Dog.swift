//
//  Dog.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift

final class Dog: Object {
    
    @objc dynamic var name = ""
    
    let owners = LinkingObjects(fromType: Person.self, property: "dogs")
}
