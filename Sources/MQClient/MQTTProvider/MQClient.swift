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
        client.flushConnect(callback: callback)
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
    
    public func publishSecure(
        clientIds: [String],
        topic: String,
        typeId: String,
        sessionId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String,
        callback: @escaping (Result<Void, Error>) -> Void
    ) {
            
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
        let privateKey = try RSAPrivateKey(pemRepresentation: privateKeyPem)
        let publicKeys = (dict?["pks"] as? [String: String]) ?? [:]
        keyring = KeyRing(privateKey: privateKey, publicKeys: publicKeys)
    }
    
    func serializeKeyRing() -> String {
        keyring.serialize()
    }
}




//
//    var endPoint: MQTTEndpoint
//    var clientId: String
//    var client: MQTTClientProtocol!
//    var logger: Logger = Logger(label: "MQTTConnector")
//    var subscriptions = [String: Set<MQSubscription>]()
//    var decoders = [String: MQTTDecoder]()
//
//    private var state: SessionState {
//        get {
//            lock.withLock {
//                return self._state
//            }
//        }
//        set {
//            lock.withLock {
//                _state = newValue
//            }
//        }
//    }
//
//    private var _state: SessionState = .initial
//
//    private let lock = Lock()
//
//
//    func init(
//        endPoint: String,
//        clientId: String,
//        privateKeyPath: String,
//        certificatePath: String,
//        caCertificatePath: String) {
//
//    }
//
//
//    func init(
//        endPoint: String,
//        clientId: String,
//        privateKey: String,
//        certificate: String,
//        caCertificate: String) {
//
//        }
//
//    private init(endPoint: MQTTEndpoint, clientId: String) throws {
//        self.endPoint = endPoint
//        self.clientId = clientId
//        let client = try MQTTClientBuilder.buildClient(endPoint: endPoint, clientID: clientId)
//        self.client = client
//        bindCallback()
//    }
//
//    public func connectIfNeeded() {
//        if client.isConnected && state.isConnected {
//            return
//        }
//        state = .connecting
//        client.connect()
//    }
//
//    func bindCallback() {
//        setupConnectionCallbacks(onConnected: { [weak self] response in
//            self?.logger.notice(
//                "MQTT Connect on connected",
//                metadata: [
//                    "keepAliveInterval": "\(response.keepAliveInterval)",
//                    "assignedClientIdentifier": "\(response.assignedClientIdentifier)",
//                    "responseInformation": "\(response.responseInformation ?? "")"
//                ]
//            )
//            self?.state = .connected
//        }, onReconnecting: { [weak self] in
//            self?.logger.notice("MQTT Connect connecting")
//            self?.state = .reconnecting
//        }, onDisconnected: { [weak self] reason in
//            switch reason {
//            case .userInitiated:
//                self?.logger.notice("MQTT disconnect manually")
//                self?.state = .disconnected(reason: .manually)
//            case let .connectionClosed(error):
//                self?.logger.error("MQTT connection closed, error: \(error?.localizedDescription ?? "")")
//                self?.state = .disconnected(reason: .connectionClosed)
//            case let .client(error):
//                switch error.code {
//                case .malformedPacket:
//                    self?.state = .disconnected(reason: .malformedPacket)
//                case .protocolError:
//                    self?.state = .disconnected(reason: .protocolError)
//                case .topicAliasInvalid:
//                    self?.state = .disconnected(reason: .topicAliasInvalid)
//                case .packetTooLarge:
//                    self?.state = .disconnected(reason: .packetTooLarge)
//                }
//                self?.logger.error("MQTT disconnected by client, error: \(error.message)")
//            case let .server(reason):
//                self?.state = .disconnectedFromServer(reason: reason)
//                self?.logger.error("MQTT disconnected by server, reason: \(reason?.message ?? "")")
//            }
//        }, onConnectionFailure: { [weak self] error in
//            self?.logger.error("MQTT connection failed, error: \(error)")
//            self?.state = .connectionFailure(error: error)
//        })
//
//        client.whenReceiveMessage { [weak self] message in
//            self?.subscriptions[message.topic]?.forEach {
//                $0.didReceiveMessage(message)
//            }
//        }
//    }
//}
//
//extension MQClient {
//#if canImport(Combine)
//
//    public func messagePublisher(forTopic topicFilter: String) -> AnyPublisher<MQMessage, Never> {
//        messagePublisher
//            .filter { self.matchesMqttTopicFilter($0.topic, topicFilter: topicFilter) }
//            .eraseToAnyPublisher()
//    }
//#endif
//
//    private func matchesMqttTopicFilter(_ topic: String, topicFilter: String) -> Bool {
//        if topic.starts(with: "$") && (topicFilter.starts(with: "#") || topicFilter.starts(with: "+")) {
//            return false
//        }
//
//        var filterParts = topicFilter.split(separator: "/", omittingEmptySubsequences: false)
//        var topicParts = topic.split(separator: "/", omittingEmptySubsequences: false)
//
//        while !filterParts.isEmpty && !topicParts.isEmpty {
//            guard filterParts[0] == topicParts[0] || filterParts[0] == "+" else {
//                return filterParts.count == 1 && filterParts[0] == "#"
//            }
//
//            filterParts.removeFirst()
//            topicParts.removeFirst()
//        }
//
//        return (filterParts.isEmpty || (filterParts.count == 1 && filterParts[0] == "#")) && topicParts.isEmpty
//    }
//
//    func autoDecodeMessage() {
//
//    }
//}
//
//extension MQClient {
//
//    public var isConnected: Bool {
//        client.isConnected
//    }
//
//    public var isConnecting: Bool {
//        client.isConnecting
//    }
//
//    public func connect() {
//        client.connect()
//    }
//
//    public func reconnect() {
//        client.reconnect()
//    }
//
//    public func disconnect() {
//        subscriptions.removeAll()
//        client.disconnect()
//    }
//
//    public func subscribe(to subscription: MQSubscription, callback: @escaping (Result<MQSingleSubscribeResponse, Error>) -> Void) {
//        var subscriptions = subscriptions[subscription.topic] ?? []
//        subscriptions.insert(subscription)
//        self.subscriptions[subscription.topic] = subscriptions
//        client.subscribe(to: subscription.topic, callback: callback)
//    }
//
//    public func unsubscribe(from subscription: MQSubscription, callback: @escaping (Result<MQSingleUnsubscribeResponse, Error>) -> Void) {
//        var subscriptions = subscriptions[subscription.topic]
//        subscriptions?.remove(subscription)
//        self.subscriptions[subscription.topic] = subscriptions
//        client.unsubscribe(from: subscription.topic, callback: callback)
//    }
//
//    public func publish(_ payload: String, to topic: String, qos: MQQoS, retain: Bool, callback: @escaping (Result<Void, Error>) -> Void) {
//        client.publish(payload, to: topic, qos: qos, retain: retain, callback: callback)
//    }
//
//    public func publish(_ payload: MQPayload, to topic: String, qos: MQQoS, retain: Bool, callback: @escaping (Result<Void, Error>) -> Void) {
//        client.publish(payload, to: topic, qos: qos, retain: retain, callback: callback)
//    }
//
//    public func setupConnectionCallbacks(onConnected: @escaping (MQConnectResponse) -> Void, onReconnecting: @escaping () -> (), onDisconnected: @escaping (MQDisconnectReason) -> Void, onConnectionFailure: @escaping (Error) -> (Void)) {
//        client.setupConnectionCallbacks(onConnected: onConnected, onReconnecting: onReconnecting, onDisconnected: onDisconnected, onConnectionFailure: onConnectionFailure)
//    }
//
//    public var messagePublisher: AnyPublisher<MQMessage, Never> {
//        client.messagePublisher
//    }
//
//    public var connectPublisher: AnyPublisher<MQConnectResponse, Never> {
//        client.connectPublisher
//    }
//
//    public var reconnectPublisher: AnyPublisher<Void, Never> {
//        client.reconnectPublisher
//    }
//
//    public var disconnectPublisher: AnyPublisher<MQDisconnectReason, Never> {
//        client.disconnectPublisher
//    }
//
//    public var connectionFailurePublisher: AnyPublisher<Error, Never> {
//        client.connectionFailurePublisher
//    }
//}
