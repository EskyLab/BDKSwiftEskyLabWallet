//
//  BackupInfo.swift
//  BDKSwiftExampleWallet
//
//  Created by Matthew Ramsden on 8/5/23.
//

import Foundation

struct BackupInfo: Codable, Equatable {
    var mnemonic: String
    var descriptor: String
    var changeDescriptor: String

    // Custom initializer for future-proofing and clarity
    init(mnemonic: String, descriptor: String, changeDescriptor: String) {
        self.mnemonic = mnemonic
        self.descriptor = descriptor
        self.changeDescriptor = changeDescriptor
    }

    // Explicit Equatable conformance for clarity or future-proofing
    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        return lhs.mnemonic == rhs.mnemonic && lhs.descriptor == rhs.descriptor
            && lhs.changeDescriptor == rhs.changeDescriptor
    }
}

#if DEBUG
let mockBackupInfo = BackupInfo(
    mnemonic: "example mnemonic",
    descriptor: "example descriptor",
    changeDescriptor: "example changeDescriptor"
)
#endif
