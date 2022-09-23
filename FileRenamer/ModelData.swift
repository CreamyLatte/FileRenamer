//
//  ModelData.swift
//  FileRenamer
//
//  Created by Eisuke KASAHARA on 2022/09/23.
//

import Foundation

extension String {
    func reEncoding(using: String.Encoding, encoding: String.Encoding) -> String? {
        guard let stringData = self.data(using: using) else {
            return nil
        }
        guard let reString = String(data: stringData, encoding: .utf8) else {
            return nil
        }
        
        return reString
    }
}

class ModelData: ObservableObject {
    let fileManager = FileManager()
    
    let encodingList: Array<String.Encoding> = [.ascii, .iso2022JP, .isoLatin1, .isoLatin2, .japaneseEUC, .macOSRoman, .nextstep, .nonLossyASCII, .shiftJIS, .symbol, .unicode, .utf16, .utf16BigEndian, .utf16LittleEndian, .utf32, .utf32BigEndian, .utf32LittleEndian, .utf8, .windowsCP1250, .windowsCP1251, .windowsCP1252, .windowsCP1253, .windowsCP1254]
    
    @Published var usingEncodeIndex: Int {
        didSet {
            UserDefaults.standard.set(usingEncodeIndex, forKey: "usingEncodeIndex")
        }
    }
    var usingEncode: String.Encoding {
        return encodingList[usingEncodeIndex]
    }
    
    @Published var selectFiles = Array<URL>()
    
    init() {
        usingEncodeIndex = UserDefaults.standard.integer(forKey: "usingEncodeIndex")
    }
    
    func filesRename() {
        for encodingFile in selectFiles {
            let fileName = encodingFile.lastPathComponent
            let fileDirectory = encodingFile.deletingLastPathComponent()
            
            guard let encodedFileName = fileName.reEncoding(using: usingEncode, encoding: .utf8) else {
                continue
            }
            let renamedURL = fileDirectory.appendingPathComponent(encodedFileName)
            do {
                try fileManager.moveItem(at: encodingFile, to: renamedURL)
            } catch let error {
                print(error)
            }
        }
        selectFiles.removeAll()
    }
    
}
