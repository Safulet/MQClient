//
//  MQTTManager.swift
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


enum SessionState {
    case initial
    case connecting
    case connected
    case reconnecting
    case disconnected(reason: DisconnectReason)
    case disconnectedFromServer(reason: MQTTManagerDisconnectReason.ServerReason?)
    case connectionFailure(error: Error)
    
    var isConnected: Bool {
        switch self {
        case .connected:
            return true
        default:
            return false
        }
    }
    
    var message: String {
        switch self {
        case .initial:
            return "idel"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .reconnecting:
            return "reconnecting"
        case let .disconnected(reason):
            return "disconnected: \(reason)"
        case let .disconnectedFromServer(reason):
            return "disconnected from server \(reason?.message ?? "")"
        case let .connectionFailure(error):
            return "connection failure \(error)"
        }
    }
}

enum DisconnectReason {
    case manually
    case connectionClosed
    
    /// The received packet does not conform to this specification.
    case malformedPacket
    
    /// An unexpected or out of order packet was received.
    case protocolError
    
    /// The topic alias was greater than the allowed maximum.
    case topicAliasInvalid
    
    /// The packet that was sent exceeded the maximum permissible size.
    case packetTooLarge
}


class MQTTMDClient {

    static var shared = try! MQTTMDClient(endPoint: .safuletQA2, clientId: "client111")
    var endPoint: MQTTEndpoint
    var clientId: String
    var client: MQTTClientProtocol!
    var logger: Logger = Logger(label: "MQTTConnector")
    var subscriptions = [String: Set<MQTTSubscription>]()
    var decoders = [String: MQTTDecoder]()
    
    private var state: SessionState {
        get {
            lock.withLock {
                return self._state
            }
        }
        set {
            lock.withLock {
                _state = newValue
            }
        }
    }
    
    private var _state: SessionState = .initial
    
    private let lock = Lock()
    
    init(endPoint: MQTTEndpoint, clientId: String) throws {
        self.endPoint = endPoint
        self.clientId = clientId
        let client = try MQTTClientBuilder.buildClient(endPoint: endPoint, clientID: clientId)
        self.client = client
        bindCallback()
    }

    func setupClient(endPoint: MQTTEndpoint, clientId: String) throws {
        if endPoint.host != self.endPoint.host {
            self.endPoint = endPoint
            self.clientId = clientId
            let client = try MQTTClientBuilder.buildClient(endPoint: endPoint, clientID: clientId)
            self.client = client
            connectIfNeeded()
            bindCallback()
        } else {
            logger.notice("setup same client")
        }
    }
    
    func connectIfNeeded() {
        if client.isConnected && state.isConnected {
            return
        }
        state = .connecting
        client.connect()
    }

    func bindCallback() {
        setupConnectionCallbacks(onConnected: { [weak self] response in
            self?.logger.notice(
                "MQTT Connect on connected",
                metadata: [
                    "keepAliveInterval": "\(response.keepAliveInterval)",
                    "assignedClientIdentifier": "\(response.assignedClientIdentifier)",
                    "responseInformation": "\(response.responseInformation ?? "")"
                ]
            )
            self?.state = .connected
        }, onReconnecting: { [weak self] in
            self?.logger.notice("MQTT Connect connecting")
            self?.state = .reconnecting
        }, onDisconnected: { [weak self] reason in
            switch reason {
            case .userInitiated:
                self?.logger.notice("MQTT disconnect manually")
                self?.state = .disconnected(reason: .manually)
            case let .connectionClosed(error):
                self?.logger.error("MQTT connection closed, error: \(error?.localizedDescription ?? "")")
                self?.state = .disconnected(reason: .connectionClosed)
            case let .client(error):
                switch error.code {
                case .malformedPacket:
                    self?.state = .disconnected(reason: .malformedPacket)
                case .protocolError:
                    self?.state = .disconnected(reason: .protocolError)
                case .topicAliasInvalid:
                    self?.state = .disconnected(reason: .topicAliasInvalid)
                case .packetTooLarge:
                    self?.state = .disconnected(reason: .packetTooLarge)
                }
                self?.logger.error("MQTT disconnected by client, error: \(error.message)")
            case let .server(reason):
                self?.state = .disconnectedFromServer(reason: reason)
                self?.logger.error("MQTT disconnected by server, reason: \(reason?.message ?? "")")
            }
        }, onConnectionFailure: { [weak self] error in
            self?.logger.error("MQTT connection failed, error: \(error)")
            self?.state = .connectionFailure(error: error)
        })
        
        client.whenReceiveMessage { [weak self] message in
            self?.subscriptions[message.topic]?.forEach {
                $0.didReceiveMessage(message)
            }
        }
    }
}

extension MQTTMDClient {
#if canImport(Combine)
    
    public func messagePublisher(forTopic topicFilter: String) -> AnyPublisher<MQTTManagerMessage, Never> {
        messagePublisher
            .filter { self.matchesMqttTopicFilter($0.topic, topicFilter: topicFilter) }
            .eraseToAnyPublisher()
    }
#endif
    
    private func matchesMqttTopicFilter(_ topic: String, topicFilter: String) -> Bool {
        if topic.starts(with: "$") && (topicFilter.starts(with: "#") || topicFilter.starts(with: "+")) {
            return false
        }
        
        var filterParts = topicFilter.split(separator: "/", omittingEmptySubsequences: false)
        var topicParts = topic.split(separator: "/", omittingEmptySubsequences: false)
        
        while !filterParts.isEmpty && !topicParts.isEmpty {
            guard filterParts[0] == topicParts[0] || filterParts[0] == "+" else {
                return filterParts.count == 1 && filterParts[0] == "#"
            }
            
            filterParts.removeFirst()
            topicParts.removeFirst()
        }
        
        return (filterParts.isEmpty || (filterParts.count == 1 && filterParts[0] == "#")) && topicParts.isEmpty
    }
    
    func autoDecodeMessage() {
        
    }
}

extension MQTTMDClient {
    
    var isConnected: Bool {
        client.isConnected
    }
    
    var isConnecting: Bool {
        client.isConnecting
    }
    
    func connect() {
        client.connect()
    }
    
    func reconnect() {
        client.reconnect()
    }
    
    func disconnect() {
        subscriptions.removeAll()
        client.disconnect()
    }
    
    func subscribe(to subscription: MQTTSubscription, callback: @escaping (Result<MQTTManagerSingleSubscribeResponse, Error>) -> Void) {
        var subscriptions = subscriptions[subscription.topic] ?? []
        subscriptions.insert(subscription)
        self.subscriptions[subscription.topic] = subscriptions
        client.subscribe(to: subscription.topic, callback: callback)
    }
    
    func unsubscribe(from subscription: MQTTSubscription, callback: @escaping (Result<MQTTManagerSingleUnsubscribeResponse, Error>) -> Void) {
        var subscriptions = subscriptions[subscription.topic]
        subscriptions?.remove(subscription)
        self.subscriptions[subscription.topic] = subscriptions
        client.unsubscribe(from: subscription.topic, callback: callback)
    }
    
    func publish(_ payload: String, to topic: String, qos: MQTTManagerQoS, retain: Bool, callback: @escaping (Result<Void, Error>) -> Void) {
        client.publish(payload, to: topic, qos: qos, retain: retain, callback: callback)
    }
    
    func publish(_ payload: MQTTManagerPayload, to topic: String, qos: MQTTManagerQoS, retain: Bool, callback: @escaping (Result<Void, Error>) -> Void) {
        client.publish(payload, to: topic, qos: qos, retain: retain, callback: callback)
    }
    
    func setupConnectionCallbacks(onConnected: @escaping (MQTTManagerConnectResponse) -> Void, onReconnecting: @escaping () -> (), onDisconnected: @escaping (MQTTManagerDisconnectReason) -> Void, onConnectionFailure: @escaping (Error) -> (Void)) {
        client.setupConnectionCallbacks(onConnected: onConnected, onReconnecting: onReconnecting, onDisconnected: onDisconnected, onConnectionFailure: onConnectionFailure)
    }
    
    var messagePublisher: AnyPublisher<MQTTManagerMessage, Never> {
        client.messagePublisher
    }
    
    var connectPublisher: AnyPublisher<MQTTManagerConnectResponse, Never> {
        client.connectPublisher
    }
    
    var reconnectPublisher: AnyPublisher<Void, Never> {
        client.reconnectPublisher
    }
    
    var disconnectPublisher: AnyPublisher<MQTTManagerDisconnectReason, Never> {
        client.disconnectPublisher
    }
    
    var connectionFailurePublisher: AnyPublisher<Error, Never> {
        client.connectionFailurePublisher
    }
}
