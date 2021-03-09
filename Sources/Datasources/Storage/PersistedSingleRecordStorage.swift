//
//  PersistedSingleRecordStorage.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/12/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import Foundation
import Combine

public class PersistedSingleRecordStorage<DataType: Codable>: SingleRecordStorage {
    private var data: DataType?
    private let subjectPublisher: CurrentValueSubject<DataType?, Never>
    private let fileName: String
    private let defaultValue: DataType?
    
    public init(fileName: String, defaultValue: DataType?) {
        data = defaultValue
        subjectPublisher = CurrentValueSubject(defaultValue)
        self.fileName = fileName
        self.defaultValue = defaultValue
        loadFromStorage()
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
        saveToStorage(data: data)
    }
    
    public func clean() {
        update(data: defaultValue)
    }
    
    private func loadFromStorage() {
        let defaults = UserDefaults.standard
        let stringData = defaults.data(forKey: fileName)
        if let stringData = stringData {
            let decoder = JSONDecoder()
            do {
                let object: DataType = try decoder.decode(DataType.self, from: stringData)
                data = object
                subjectPublisher.send(object)
            } catch {}
        }
    }
    
    private func saveToStorage(data: DataType?) {
        if let data = data {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(data)
                let defaults = UserDefaults.standard
                defaults.set(data, forKey: fileName)

            } catch {}
        } else {
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: fileName)
        }
        
    }
}

