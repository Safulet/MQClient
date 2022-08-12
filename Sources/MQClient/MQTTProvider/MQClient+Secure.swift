//
//  MQClient+Secure.swift
//  
//
//  Created by User on 28/07/2022.
//

import Foundation
import NIO
import Logging
import NIOConcurrencyHelpers
#if canImport(Combine)
import Combine
#endif
import CryptoSwift
import SwCrypt

enum SecureError: Error {
    case privateKeyMissing
}

// MARK: -- Secure
extension MQClient {
    
    public func publishSecure(
        clientIds: [String],
        topic: String,
        typeId: String,
        sessionId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String,
        callback: @escaping (Result<Void, Error>) -> Void
    ) throws {
        let clientKeys = try keyring.findPublicKeys(clientIds: clientIds)
        try packSecureMessage(typeId: typeId, sessionId: sessionId, clientIds: clientIds, clientKeys: clientKeys, payload: data)
    }
    
    func packSecureMessage(typeId: String, sessionId: String, clientIds: [String], clientKeys: [Data], payload: String) throws -> SecureMessage {
        guard let privateKey = keyring.privateKey else {
            throw SecureError.privateKeyMissing
        }
        let secureMessage = try Message.packSecureMessage(ourClientId: clientId, typeId: typeId, sessionId: sessionId, ourKey: privateKey, toClientIds: [], toKeys: [], payload: payload.data(using: .utf8) ?? Data())
        return secureMessage
    }
    func unpackSecureMessage(sessionId: String, ourKey: Data, senderKey: Data, secureMessage: SecureMessage) throws -> Data {
        try Message.unpackSecureMessage(ourClientId: clientId, sessionId: sessionId, ourKey: ourKey, senderKey: senderKey, secMsg: secureMessage)
    }
    
    func randomData(count: Int) -> [UInt8] {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        if status != errSecSuccess {
            assert(false, "Couldn't create random data")
        }
        return randomBytes
    }
  
}
    
//    
//    func packSecureMessage(ourClientId, typeId, sessionId string, ourKey *grsa.PrivateKey, toClientIds []string, toKeys []*grsa.PublicKey, payload []byte) (*SecureMessage, error) {
//        
//        secMsg := &SecureMessage{
//            ClientId:    ourClientId,
//            TypeId:      typeId,
//            SessionId:   sessionId,
//            ToClientIds: toClientIds,
//            EncNonces:   make([][]byte, len(toClientIds)),
//            EncKeys:     make([][]byte, len(toClientIds)),
//            EncPayloads: make([][]byte, len(toClientIds)),
//        }
//        hash256 := crypto.SHA256.New()
//        for i, toKey := range toKeys {
//            // generate a one-time aes key for this client-payload pair, encrypt it with the recipient's RSA public key
//            var encKey []byte
//            var cph cipher2.AEAD
//            {
//                // the plain aesKey is discarded once encrypted for sending
//                var err error
//                aesKey := makeRandomKeyOrNonce(32)
//                encKey, err = grsa.EncryptOAEP(crypto.SHA256.New(), rand.Reader, toKey, aesKey, []byte(sessionId))
//                if err != nil {
//                    return nil, err
//                }
//                cph, _, err = cipher.CreateAEADSuite(aesKey)
//                if err != nil {
//                    return nil, err
//                }
//            }
//            aesNonce := makeRandomKeyOrNonce(cph.NonceSize())
//            encBuf := make([]byte, 0, len(payload))
//            encBuf = cph.Seal(encBuf, aesNonce, payload, []byte(sessionId))
//            // a hash write should never throw an error, but we will check it just to be safe
//            if _, err := hash256.Write(encBuf); err != nil {
//                return nil, err
//            }
//            secMsg.EncNonces[i] = aesNonce
//            secMsg.EncKeys[i] = encKey
//            secMsg.EncPayloads[i] = encBuf
//        }
//        sum256 := hash256.Sum(nil)
//        // unfortunately SHA512/256 is not supported by SignPKCS1v15. SHA256 is hardware accelerated on arm64
//        sig, err := grsa.SignPSS(rand.Reader, ourKey, crypto.SHA256, sum256[:], &grsa.PSSOptions{
//            SaltLength: grsa.PSSSaltLengthEqualsHash,
//            Hash:       crypto.SHA256,
//        })
//        if err != nil {
//            return nil, err
//        }
//        secMsg.PayloadsHashSenderSignature = sig
//        return secMsg, nil
//    }
//    
//    
//    
//    // PublishSecure publishes a secure payload to the specified clients and MQTT topic.
//    func publishSecure(clientIdsCommaSeparated string, topic, typeId, sessionId string, qos2, retained bool, payload []byte) error {
//        toClientIds := strings.Split(clientIdsCommaSeparated, ",")
//        clientKeys, err := c.keyring.FindPublicKeys(toClientIds)
//        if err != nil {
//            return err
//        }
//        secMsg, err := packSecureMessage(c.clientId, typeId, sessionId, c.keyring.OurPrivateKey, toClientIds, clientKeys, payload)
//        if err != nil {
//            return err
//        }
//        bz, err := proto.Marshal(secMsg)
//        if err != nil {
//            return err
//        }
//        qos := byte(1)
//        if qos2 {
//            qos = 2
//        }
//        if token := c.client.Publish(topic, qos, retained, bz); token.Wait() && token.Error() != nil {
//            return fmt.Errorf("failed to publish to: %s, reason: %v", topic, token.Error())
//        }
//        return nil
//    }
//
//    // SubscribeSecure subscribes to E2EE secured messages from the specified clients and MQTT topic.
//    func (c *GoMqttClient) SubscribeSecure(topic string, handler MessageHandler) error {
//        first := c.addSubscriptionForType(topic, true, handler)
//        if first {
//            if token := c.client.Subscribe(topic, 1, c.subscriptionHandler); token.Wait() && token.Error() != nil {
//                fmt.Printf("failed to subscribe to: %s, reason: %v", topic, token.Error())
//                return fmt.Errorf("failed to subscribe to: %s, reason: %v", topic, token.Error())
//            }
//        } else {
//            return fmt.Errorf("sub for topic %s already exist, updated the handler", topic) // XXX: this error message is hardcoded in objc bridge code, please change together
//        }
//
//        return nil
//    }
//
//    // ----- //
//
//    func (c *GoMqttClient) subscriptionHandlerImplSecure(sub MessageHandlerSubscription, pbSecMsg *SecureMessage, clientId string, kr *rsa.KeyRing) func(_ mqtt.Client, msg mqtt.Message) {
//        return func(_ mqtt.Client, msg mqtt.Message) {
//            ourSK := kr.OurPrivateKey
//            senderPK, err := kr.FindPublicKey(pbSecMsg.ClientId)
//            if err != nil {
//                fmt.Printf("unable to find the sender's key in the keyring: %s", err.Error())
//                return
//            }
//            payload, err := unpackSecureMessage(clientId, pbSecMsg.SessionId, ourSK, senderPK, pbSecMsg)
//            if err != nil {
//                fmt.Printf("incoming secure message decryption error: %s\n", err.Error())
//                return
//            }
//            hMsg := &HandlerMessage{
//                clientId: pbSecMsg.ClientId,
//                typeId:   pbSecMsg.TypeId,
//                payload:  payload,
//                msg:      msg,
//                secure:   true,
//            }
//            fmt.Println("native handler is going to handle message (fire to ios)")
//            sub.handler.HandleMessage(hMsg)
//        }
//    
//    
//
//    func unpackSecureMessage(ourClientId, sessionId string, ourKey *grsa.PrivateKey, senderKey *grsa.PublicKey, secMsg *SecureMessage) ([]byte, error) {
//        if ourKey == nil || secMsg == nil {
//            return nil, errors.New("the privKey and secMsg should be provided")
//        }
//        ourIdx := -1
//        for i, clientId := range secMsg.ToClientIds {
//            if ourClientId == clientId {
//                ourIdx = i
//                break
//            }
//        }
//        if ourIdx == -1 {
//            return nil, fmt.Errorf("this message was not sent to our clientId %s, but %v", ourClientId, secMsg.ToClientIds)
//        }
//        if len(secMsg.EncKeys) <= ourIdx {
//            return nil, errors.New("malformed message; insufficient keys in the decoded message")
//        }
//        if len(secMsg.EncNonces) <= ourIdx {
//            return nil, errors.New("malformed message; insufficient nonces in the decoded message")
//        }
//        if len(secMsg.EncPayloads) <= ourIdx {
//            return nil, errors.New("malformed message; insufficient payloads in the decoded message")
//        }
//        if len(secMsg.EncKeys) != len(secMsg.EncNonces) || len(secMsg.EncNonces) != len(secMsg.EncPayloads) {
//            return nil, errors.New("malformed message; inconsistent keys, nonces or payloads len")
//        }
//        // compute and verify the sender's signature
//        {
//            hash256 := crypto.SHA256.New()
//            for _, encPayload := range secMsg.EncPayloads {
//                if _, err := hash256.Write(encPayload); err != nil {
//                    return nil, err
//                }
//            }
//            sum256 := hash256.Sum(nil)
//            if err := grsa.VerifyPSS(senderKey, crypto.SHA256, sum256, secMsg.PayloadsHashSenderSignature, &grsa.PSSOptions{
//                SaltLength: grsa.PSSSaltLengthEqualsHash,
//                Hash:       crypto.SHA256,
//            }); err != nil {
//                return nil, err
//            }
//        }
//        // unpack the AES key
//        aesKey, err := grsa.DecryptOAEP(crypto.SHA256.New(), rand.Reader, ourKey, secMsg.EncKeys[ourIdx], []byte(sessionId))
//        if err != nil {
//            return nil, err
//        }
//        aesNonce := secMsg.EncNonces[ourIdx]
//        cph, _, err := cipher.CreateAEADSuite(aesKey)
//        if err != nil {
//            return nil, err
//        }
//        payload := make([]byte, 0, len(secMsg.EncPayloads[ourIdx]))
//        if payload, err = cph.Open(payload, aesNonce, secMsg.EncPayloads[ourIdx], []byte(sessionId)); err != nil {
//            return nil, err
//        }
//        return payload, nil
//    }
//
//    func makeRandomKeyOrNonce(sizeInBytes ...int) []byte {
//        size := defaultKeyBytesSize
//        if 0 < len(sizeInBytes) {
//            size = sizeInBytes[0]
//        }
//        var bz []byte
//        for size != len(bz) {
//            bz = common.MustGetRandomInt(size * 8).Bytes()
//        }
//        return bz[:]
//    }
//}




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
