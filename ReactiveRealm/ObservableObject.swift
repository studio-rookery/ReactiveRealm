//
//  ObjectObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import RealmSwift

public protocol ObservableObject {
    
    associatedtype NotificationTokenType: NotificationTokenProtocol
    
    var isInvalidated: Bool { get }
    
    func observe(_ block: @escaping (ObjectChange) -> ()) -> NotificationTokenType
}

extension Object: ObservableObject, ReactiveExtensionsProvider {
    
}

public extension Reactive where Base: ObservableObject {
    
    var objectChange: SignalProducer<[PropertyChange], RealmObjectError> {
        return SignalProducer<[PropertyChange], RealmObjectError> { observer, lifetime in
            let token = self.base.observe { change in
                switch change {
                case .change(let propertyChanges):
                    observer.send(value: propertyChanges)
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
    
    var producer: SignalProducer<Base, RealmObjectError> {
        return objectChange.map(value: base)
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

