//
//  ObjectObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

/// `ObservableObject` is a protocol that abstracts `Object` for testing.
public protocol ObservableObject {
    
    associatedtype NotificationTokenType: NotificationTokenProtocol
    
    var isInvalidated: Bool { get }
    
    func observe(_ block: @escaping (ObjectChange) -> ()) -> NotificationTokenType
}

extension Object: ObservableObject, ReactiveExtensionsProvider {
    
}

// MARK: -

public extension Reactive where Base: ObservableObject {
    
    /// A producer that sends property changes each time the object's properties are updated.
    /// When the realm notifies an error or the object is deleted, it ends with the error.
    var propertyChanges: SignalProducer<[PropertyChange], RealmObjectError> {
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
    
    /// A producer that sends a value each time the object's properties are updated.
    /// When the realm notifies an error or the object is deleted, it ends with the error.
    var producer: SignalProducer<Base, RealmObjectError> {
        return propertyChanges.map(value: base)
    }
    
    /// A property that sends its changes when the object is updated.
    var property: ReactiveSwift.Property<Base> {
        return ReactiveSwift.Property(initial: base, then: producer.ignoreError())
    }
    
    /// A property that its value is true while the object is valid
    /// When the object is invalidated or an error occured, the value will be false.
    var isInvalidated: ReactiveSwift.Property<Bool> {
        let isInvalidated = base.isInvalidated
        guard !isInvalidated else {
            return Property(value: isInvalidated)
        }
        
        let isDeleted = producer.map(value: false).mapError(to: true).filter { $0 }
        return Property(
            initial: isInvalidated,
            then: isDeleted
        )
    }
}
