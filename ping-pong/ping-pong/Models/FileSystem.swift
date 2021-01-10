//
//  FileSystem.swift
//  ping-pong
//
//  Created by Libor Kučera on 10.01.2021.
//  Copyright © 2021 IC Servis, s.r.o. All rights reserved.
//

import Foundation

class FileSystem {
    private static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()

    static func fileURLFromDocuments(fileName: String) -> URL {
        return self.documentsDirectory.appendingPathComponent(fileName)
    }

    @discardableResult
    static func writeResource(
        fileName: String,
        contents: Data?,
        attributes: [FileAttributeKey: Any]? = nil
    ) -> Bool {
        let resourceDir: URL = FileSystem.documentsDirectory.appendingPathComponent(fileName)
        return FileManager.default.createFile(
            atPath: resourceDir.path,
            contents: contents,
            attributes: attributes
        )
    }

    static func removeResource(fileName: String) {
        let resourceDir: URL = FileSystem.documentsDirectory.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: resourceDir.path) {
                try FileManager.default.removeItem(atPath: resourceDir.path)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

private extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

private extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
