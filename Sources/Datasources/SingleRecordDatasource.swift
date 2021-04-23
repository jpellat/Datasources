//
//  DataSource.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/11/20.
//

import Foundation
import Combine

public protocol SingleRecordDatasource {
    associatedtype DataType
    
    func getData() -> DataType?
    func getPublisher() -> AnyPublisher<DataType?, Never>
}

public extension SingleRecordDatasource {
    func toAnySingleRecordDatasource() -> AnySingleRecordDatasource<DataType> {
        AnySingleRecordDatasource(self)
    }
}

public struct AnySingleRecordDatasource<DT>: SingleRecordDatasource {
    private let datasource: Any
    private let getDataFunc: () -> DT?
    private let getPublisherFunc: () -> AnyPublisher<DT?, Never>

    public init<D: SingleRecordDatasource>(_ datasource: D) where D.DataType == DT {
        self.datasource = datasource
        getDataFunc = datasource.getData
        getPublisherFunc = datasource.getPublisher
    }

    public func getPublisher() -> AnyPublisher<DT?, Never> {
        getPublisherFunc()
    }

    public func getData() -> DT? {
        getDataFunc()
    }
}
