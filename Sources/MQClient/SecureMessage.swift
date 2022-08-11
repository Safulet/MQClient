//
//  SecureMessage.swift
//  SwCrypt
//
//  Created by User on 01/08/2022.
//  Copyright © 2022 irl. All rights reserved.
//

import Foundation
import CryptoSwift
import SwCrypt

public struct SecureMessage {
    var clientId: String
    var typeId: String
    var sessionId: String
    var toClientIds: [String]
    var encNonces: [Data]
    var encKeys: [Data]
    var encPayloads: [Data]
    var payloadsHashSenderSignature: Data
    
    public init(
        clientId: String,
        typeId: String,
        sessionId: String,
        toClientIds: [String],
        encNonces: [Data],
        encKeys: [Data],
        encPayloads: [Data],
        payloadsHashSenderSignature: Data
    ) {
        self.clientId = clientId
        self.typeId = typeId
        self.sessionId = sessionId
        self.toClientIds = toClientIds
        self.encNonces = encNonces
        self.encKeys = encKeys
        self.encPayloads = encPayloads
        self.payloadsHashSenderSignature = payloadsHashSenderSignature
    }
}

public enum SecurePackError: Error {
    case clientIdEmpty
    case payloadEmpty
    case countNotEqualbetweenClientAndKey
}

public enum SecureUnpackError: Error {
    case keyIsEmpty
    case clientIdEmpty
    case payloadEmpty
    case countNotEqualbetweenClientAndKey
    case clientIdNotMatch
    case keysInsufficient
    case noncesInsufficient
    case payloadsInsufficient
    case elementInconsistent
    case validateFailed
    case decryptError
    case tagNotMatch
}

public class Message {
    public static func packSecureMessage(ourClientId: String, typeId: String, sessionId: String, ourKey: Data, toClientIds: [String], toKeys: [Data], payload: Data) throws -> SecureMessage {
        guard !ourClientId.isEmpty else {
            throw SecurePackError.clientIdEmpty
        }
        guard !payload.isEmpty else {
            throw SecurePackError.payloadEmpty
        }
        guard toClientIds.count == toKeys.count else {
            throw SecurePackError.countNotEqualbetweenClientAndKey
        }
        let tag = sessionId.data(using: .utf8) ?? Data()
        
        var secMessage = SecureMessage(clientId: ourClientId, typeId: typeId, sessionId: sessionId, toClientIds: toClientIds, encNonces: [], encKeys: [], encPayloads: [], payloadsHashSenderSignature: Data())
        
        for key in toKeys {
            let aesKey = CC.generateRandom(32)
            let aesNonce = CC.generateRandom(12)
            let encKey = try CC.RSA.encrypt(aesKey, derKey: key, tag: tag, padding: .oaep, digest: .sha256)
            let encBuf = try CC.cryptAuth(.encrypt, blockMode: .gcm, algorithm: .aes, data: payload, aData: Data(), key: aesKey, iv: aesNonce, tagLength: 16)
            secMessage.encNonces.append(aesNonce)
            secMessage.encKeys.append(encKey)
            secMessage.encPayloads.append(encBuf)
        }
        var result = Data()
        secMessage.encPayloads.forEach{ result.append($0) }
        let hash = CC.digest(result, alg: .sha256)
        
        let signature = try CC.RSA.sign(hash, derKey: ourKey, padding: .pss, digest: .sha256, saltLen: hash.count)
        secMessage.payloadsHashSenderSignature = signature
        return secMessage
    }

    public static func unpackSecureMessage(ourClientId: String, sessionId: String, ourKey: Data, senderKey: Data, secMsg: SecureMessage) throws -> Data {
        guard !ourKey.isEmpty else {
            throw SecureUnpackError.keyIsEmpty
        }
        var ourIndex = -1
        for (index, clientId) in secMsg.toClientIds.enumerated() {
            if ourClientId == clientId {
                ourIndex = index
            }
        }
        if ourIndex == -1 {
            throw SecureUnpackError.clientIdNotMatch
        }
        if secMsg.encKeys.count <= ourIndex {
            throw SecureUnpackError.keysInsufficient
        }
        if secMsg.encNonces.count <= ourIndex {
            throw SecureUnpackError.noncesInsufficient
        }
        if secMsg.encPayloads.count <= ourIndex {
            throw SecureUnpackError.payloadsInsufficient
        }
        if secMsg.encKeys.count != secMsg.encNonces.count || secMsg.encNonces.count != secMsg.encPayloads.count {
            throw SecureUnpackError.elementInconsistent
        }
        
        var result = Data()
        secMsg.encPayloads.forEach{ result.append($0) }
        let hash = CC.digest(result, alg: .sha256)
        let isValidated = try CC.RSA.verify(result, derKey: senderKey, padding: .pss, digest: .sha256, saltLen: hash.count, signedData: secMsg.payloadsHashSenderSignature)
        if !isValidated {
            throw SecureUnpackError.validateFailed
        }
        let tag = sessionId.data(using: .utf8) ?? Data()
        
        let aesKey = try CC.RSA.decrypt(secMsg.encKeys[ourIndex], derKey: ourKey, tag: tag, padding: .oaep, digest: .sha256)
        let aesNonce = secMsg.encNonces[ourIndex]
        
        let sharedKeyArray = try! HKDF(password: aesKey.0.bytes, salt: nil, info: nil, keyLength: 32, variant: .sha2(.sha512_256)).calculate()
        let sharedKey = Data(bytes: sharedKeyArray, count: sharedKeyArray.count)
        
        let data = secMsg.encPayloads[ourIndex]
        let tagLength = 16
        let cipher = data.subdata(in: 0..<(data.count - tagLength))
        let expectedTag = data.subdata(
            in: (data.count - tagLength)..<data.count)
        
        let payload = try CC.GCM.crypt(.decrypt, algorithm: .aes, data: cipher, key: sharedKey, iv: aesNonce, aData: tag, tagLength: tagLength)
        guard expectedTag == payload.1 else {
            throw SecureUnpackError.tagNotMatch
        }
        return payload.0
    }
}
