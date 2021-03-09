//
//  PlistDatasource.swift
//  Urna-iOS
//
//  Created by Jordi Pellat Massó on 2/16/20.
//  Copyright © 2020 Urna. All rights reserved.
//

import Foundation
import Combine

public class BundlePlistDataSource<DT: Decodable>: MultiRecordDatasource {
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
