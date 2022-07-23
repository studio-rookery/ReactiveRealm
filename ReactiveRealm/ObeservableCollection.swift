//
//  CollectionChangeObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Combine
import ReactiveSwift
import RealmSwift

/// `ObeservableCollection` is a protocol that has a common interface between `Results`, `List`,` LinkingObjects`, and `AnyRealmCollection`. Required interfaces are already implemented.
public protocol ObeservableCollection: ReactiveExtensionsProvider where CollectionPublisher.Output == Self {
    
    associatedtype CollectionPublisher: Publisher
    
    var collectionPublisher: CollectionPublisher { get }
}

extension Results: ObeservableCollection {
    
}

extension List: ObeservableCollection {
    
}

extension LinkingObjects: ObeservableCollection {
    
}

extension AnyRealmCollection: ObeservableCollection {
    
}

// MARK: -

public extension Reactive where Base: ObeservableCollection {
    
    /// A producer that sends a value each time the collection is updated.
    /// The initial value is sent immediately.
    /// When the realm of the collection notifies an error, the producer sends the error.
    var producer: SignalProducer<Base, Error> {
        return SignalProducer<Base, Error> { observer, lifetime in
            observer.send(value: self.base)
            
            let cancellable = self.base.collectionPublisher
                .dropFirst()
                .sink { completion in
                    switch completion {
                    case .finished:
                        observer.sendCompleted()
                    case .failure(let error):
                        observer.send(error: error)
                    }
                } receiveValue: { output in
                    observer.send(value: output)
                }
            
            lifetime.observeEnded(cancellable.cancel)            
        }
    }
    
    /// A property that sends its changes when the collection is updated.
    /// When an error occured, the property completes and stops to send a value.
    var property: ReactiveSwift.Property<Base> {
        return Property(initial: base, then: producer.ignoreError())
    }
}

public extension Reactive where Base: ObeservableCollection & Collection, Base.Element: Object {
    
    /// Returns a property representing the first element of the collection.
    /// If the first element is nil, `default` is adopted for its value.
    ///
    /// - Parameter default: the value adopted when the first element is nil.
    /// - Returns: A property that represents the first element or the specified object.
    func first(or default: @autoclosure @escaping () -> Base.Element = Base.Element()) -> ReactiveSwift.Property<Base.Element> {
        return property.map { $0.first ?? `default`() }
    }
}
