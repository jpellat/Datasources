//
//  InMemoryStorage.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/11/20.
//

import Foundation
import Combine

public class InMemoryStorage<DataType>: SingleRecordStorage {
    private var data: DataType?
    private let subjectPublisher: CurrentValueSubject<DataType?, Never>
    private let initialValue: DataType?
    
    public init(initialValue: DataType?) {
        self.initialValue = initialValue
        data = initialValue
        subjectPublisher = CurrentValueSubject(initialValue)
    }

    public func getPublisher() -> AnyPublisher<DataType?, Never> {
        subjectPublisher.eraseToAnyPublisher()
    }

    public func getData() -> DataType? {
        data
    }

    public func update(data: DataType?) {
        self.data = data
        subjectPublisher.send(data)
    }

    public func clean() {
        update(data: initialValue)
    }
}
