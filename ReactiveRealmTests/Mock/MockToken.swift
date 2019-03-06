//
//  MockToken.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation

@testable import ReactiveRealm

final class MockToken: NotificationTokenProtocol {
    
    private(set) var isInvalidated = false
    
    func invalidate() {
        isInvalidated = true
    }
}
