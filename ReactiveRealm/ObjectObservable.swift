//
//  ObjectObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

public protocol ObjectObservable {
    
    associatedtype NotificationTokenType: NotificationTokenProtocol
    
    var isInvalidated: Bool { get }
    
    func observe(_ block: @escaping (ObjectChange) -> ()) -> NotificationTokenType
}

extension Object: ObjectObservable, ReactiveExtensionsProvider {
    
}

public extension Reactive where Base: ObjectObservable {
    
    var producer: SignalProducer<Base, RealmObjectError> {
        return SignalProducer<Base, RealmObjectError> { observer, lifetime in
            let object = self.base
            
            let token = object.observe { change in
                switch change {
                case .change:
                    observer.send(value: object)
                case .deleted:
                    observer.send(error: .deleted)
                case .error(let error):
                    observer.send(error: .unknown(error))
                }
            }
            
            lifetime.observeEnded {
                token.invalidate()
            }
        }
    }
    
    var property: ReactiveSwift.Property<Base> {
        return ReactiveSwift.Property(initial: base, then: producer.ignoreError())
    }
    
    var isInvalidated: ReactiveSwift.Property<Bool> {
        let isInvalidated = base.isInvalidated
        guard !isInvalidated else {
            return Property(value: isInvalidated)
        }
        
        let isDeleted = producer.map(value: false).mapError(to: true)
        return Property(
            initial: isInvalidated,
            then: isDeleted
        )
    }
}

