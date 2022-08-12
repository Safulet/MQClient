//
//  MQ.swift
//  mqtt-nio-demo
//
//  Created by User on 29/06/2022.
//

import Foundation
import NIO
import Logging
import NIOConcurrencyHelpers
#if canImport(Combine)
import Combine
#endif
import NIOSSL
import SwCrypt

public class MQClient {
    
    var endPoint: String
    var port: Int?
    var clientId: String
    var client: MQTTClientProtocol!
    var logger: Logger = Logger(label: "MQTTConnector")
    var decoders = [String: MQTTDecoder]()
    var keyring: KeyRing = .defaultKeyRing

    public init(
        endPoint: String,
        port: Int?,
        clientId: String,
        userName: String? = nil,
        password: String? = nil,
        privateKeyPath: String,
        centificatePath: String,
        caCertificatePath: String
    ) throws {
        let client = try MQTTClientBuilder.buildClient(
            endPoint: endPoint,
            port: port,
            clientId: clientId,
            userName: userName,
            password: password,
            privateKeyPath: privateKeyPath,
            centificatePath: centificatePath,
            caCertificatePath: caCertificatePath
        )
        self.client = client
        self.endPoint = endPoint
        self.port = port
        self.clientId = clientId
    }
    
    public init(
        endPoint: String,
        port: Int?,
        clientId: String,
        userName: String? = nil,
        password: String? = nil,
        privateKey: String,
        certificate: String,
        caCertificate: String
    ) throws {
        let client = try MQTTClientBuilder.buildClient(
            endPoint: endPoint,
            port: port,
            clientId: clientId,
            userName: userName,
            password: password,
            privateKey: privateKey,
            certificate: certificate,
            caCertificate: caCertificate
        )
        self.client = client
        self.endPoint = endPoint
        self.port = port
        self.clientId = clientId
    }
    
    public init(
        endPoint: String,
        port: Int?,
        clientId: String,
        password: String,
        caCertificate: String
    ) throws {
        let client = try MQTTClientBuilder.buildClient(
            endPoint: endPoint,
            port: port,
            clientId: clientId,
            password: password,
            caCertificate: caCertificate
        )
        self.client = client
        self.endPoint = endPoint
        self.port = port
        self.clientId = clientId
    }
    
    public func connect(callback: @escaping (Result<Bool, Error>) -> Void) {
        client.connect(callback: callback)
    }
    
    public func disconnect(callback: @escaping (Result<Void, Error>) -> Void) {
        client.disconnect(callback: callback)
    }
    
    public func flushConnect(callback: @escaping (Result<Bool, Error>) -> Void) {
        client.flushConnect(callback: callback)
    }

    public func subscribe(topic: String, callback: @escaping (Result<MQSuback, Error>) -> Void) {
        client.subscribe(topic: topic, callback: callback)
    }
    
    public func subscribeInAdvance(topic: String, callback: @escaping (Result<MQSuback, Error>) -> Void) {
        
    }
    
    public func subscribeSecure(topic: String, callback: @escaping (Result<MQSuback, Error>) -> Void) {
        
    }
    
    public func unsubscribe(topicId: String, callback: @escaping (Result<Void, Error>) -> Void) {
        client.unsubscribe(topicId: topicId, callback: callback)
    }
    
    public func forceUnsubscribe(topicId: String, callback: @escaping (Result<Void, Error>) -> Void) {
        
    }
    
    public func addPublishListener(named: String, _ listener: @escaping (Result<MQPublishInfo, Error>) -> Void) {
        client.addPublishListener(named: named, listener)
    }
    public func addCloseListener(named: String, _ listener: @escaping (Result<Void, Error>) -> Void) {
        client.addCloseListener(named: named, listener)
    }
    public func addShutdownListener(named: String, _ listener: @escaping (Result<Void, Error>) -> Void) {
        client.addShutdownListener(named: named, listener)
    }
    
    public func createCsr(privateKeyPem: String, dnsName: String) {
        
    }
    
    
    public func verifyCert(rootCA: String, privateKeyPem: String, dnsName: String) {
        
    }
    
    public func publish(
        topic: String,
        typeId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String,
        callback: @escaping (Result<Void, Error>) -> Void
    ) {
        client.publish(topic: topic, typeId: typeId, isQos2: isQos2, isRetained: isRetained, data: data, callback: callback)
    }
    
    
    public func createCsr(privateKeyPem: String, dnsName: String) throws -> String {
        return ""
    }
}


// MARK: -- Keyring
extension MQClient {
    public func setOurPrivateKeyFromPem(privPemStr: String) throws {
        try keyring.savePrivateKeyFromPem(privateKeyPem: privPemStr)
    }
    
    public func addKnownClient(clientId: String, clientPubPemStr: String) {
        keyring.savePublicKeyFromPem(clientId: clientId, publicKeyPem: clientPubPemStr)
    }
    
    public func getKnownClientKey(clientId: String) throws -> String {
        try keyring.findPublicKeyPem(clientId: clientId)
    }
    
    public func loadKeyRing(serialized: String) throws {
        guard !keyring.hasPrivateKey(), let data = serialized.data(using: .utf8) else {
            //TODO: log here or throw exception
            return
        }
        let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        let privateKeyPem = (dict?["sk"] as? String) ?? ""
        let privateKey = try SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKeyPem)
        let publicKeys = (dict?["pks"] as? [String: String]) ?? [:]
        keyring = KeyRing(privateKey: privateKey, publicKeys: publicKeys)
    }
    
    func serializeKeyRing() -> String {
        keyring.serialize()
    }
}
