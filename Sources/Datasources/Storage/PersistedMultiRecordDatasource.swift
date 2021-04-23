//
//  InMemoryMultiRecordStorage.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/14/20.
//

import Foundation
import Combine

public class PersistedMultiRecordStorage<DT>: MultiRecordStorage where DT: Recordable {
    var lastId = 0
    private var fileName: String
    
    let recordsPublisher: CurrentValueSubject<[DT], Never>
    
    public init(fileName: String) {
        recordsPublisher = CurrentValueSubject<[DataType], Never>([])
        self.fileName = fileName
        
        loadFromStorage()
    }
    
    public func save(_ data: DT) -> DT {
        var records = recordsPublisher.value
        var newData = data
        
        if let id = data.id {
            records.removeAll { (record) -> Bool in
                record.id == id
            }
        } else {
            lastId += 1
            newData.id = String(lastId)
        }
        
        records.append(newData)
        recordsPublisher.send(records)
        self.saveToStorage(data: records)
        
        return newData
    }
    
    public func queryAll() -> AnyPublisher<[DT], Never> {
        recordsPublisher.eraseToAnyPublisher()
    }
    
    private func loadFromStorage() {
        let defaults = UserDefaults.standard
        let stringData = defaults.data(forKey: fileName)
        if let stringData = stringData {
            let decoder = JSONDecoder()
            do {
                let object: [DataType] = try decoder.decode([DataType].self, from: stringData)
                recordsPublisher.send(object)
            } catch {}
        }
    }
    
    private func saveToStorage(data: [DataType]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(data)
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: fileName)

        } catch {}
    }
    
    public func clean() {
        recordsPublisher.send([])
        saveToStorage(data: [])
    }
}
