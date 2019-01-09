//
//  NotificationTokenProtocol.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift

public protocol NotificationTokenProtocol {
    
    func invalidate()
}

extension NotificationToken: NotificationTokenProtocol {
    
}
