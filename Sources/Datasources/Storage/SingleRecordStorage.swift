//
//  SingleRecordStorage.swift
//  Urna-iOS
//
//  Created by Jordi Pellat Massó on 2/16/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import Foundation
import Combine

public protocol SingleRecordStorage: SingleRecordDatasource {
    associatedtype DataType
    
    func update(data: DataType?) -> Void
    func clean() -> Void
}

public extension SingleRecordStorage {
    public func toAnySingleRecordStorage() -> AnySingleRecordStorage<DataType> {
        AnySingleRecordStorage(self)
    }
}

public struct AnySingleRecordStorage<DT>: SingleRecordStorage {
    private let storage: Any
    private let getDataFunc: () -> DT?
    private let getPublisherFunc: () -> AnyPublisher<DT?, Never>
    private let updateFunc: (DT?) -> Void
    private let cleanFunc: () -> Void

    public init<D: SingleRecordStorage>(_ storage: D) where D.DataType == DT {
        self.storage = storage
        getDataFunc = storage.getData
        getPublisherFunc = storage.getPublisher
        updateFunc = storage.update
        cleanFunc = storage.clean
    }

    public func getPublisher() -> AnyPublisher<DT?, Never> {
        getPublisherFunc()
    }

    public func getData() -> DT? {
        getDataFunc()
    }

    public func update(data: DT?) {
        updateFunc(data)
    }

    public func clean() {
        cleanFunc()
    }
}
