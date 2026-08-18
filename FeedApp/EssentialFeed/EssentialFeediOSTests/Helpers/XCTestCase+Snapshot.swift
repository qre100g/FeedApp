//
//  XCTestCase+Snapshot.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 18/08/26.
//

import XCTest

extension XCTestCase {
    
    func assert(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the record method to store a snapshot before asserting.", file: file, line: line)
        }
        
        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(filePath: NSTemporaryDirectory())
                .appendingPathComponent(snapshotURL.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
        }
    }
    
    func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        
        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        return URL(filePath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(
        for snapshot: UIImage,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Fail to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
}
