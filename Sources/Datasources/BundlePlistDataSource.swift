//
//  PlistDatasource.swift
//  Datasources
//
//  Created by Jordi Pellat Massó on 2/16/20.
//

import Foundation
import Combine

@available(watchOS 6.0, *)
public class BundlePlistDataSource<DT>: MultiRecordDatasource where DT:Recordable, DT:Equatable {
    private var publisher: CurrentValueSubject<[DT], Never>
    private var fileNames: [String]
    private let bundle: Bundle

    public init(bundle: Bundle, fileNames: [String]) {
        publisher = CurrentValueSubject([])
        self.fileNames = fileNames
        self.bundle = bundle
        decodeFiles()
    }
    
    public func queryAll() -> AnyPublisher<[DT], Never> {
        publisher.eraseToAnyPublisher()
    }
    
    func decodeFiles() {
        var objects = [] as! [DT]
        
        let decoder = PropertyListDecoder()
        for filename in fileNames {
            let plistPath: String? = bundle.path(forResource: filename, ofType: "plist")!
            let data = FileManager.default.contents(atPath: plistPath!)!
            do {
                let object = try decoder.decode(DT.self, from: data)
                objects.append(object)
            } catch {
                
            }
        }
        
        publisher.send(objects)
    }
}
