//
//  Mqtt.swift
//  nativeMqtt
//
//  Created by Swee Sen on 10/3/22.
//

import Foundation
import CocoaMQTT

// see here: https://github.com/emqx/CocoaMQTT/blob/698f2d2283c18e68110740c538005b462c3b67f3/Example/Example/ViewController.swift#L56-L65

class MqttManager: CocoaMQTTDelegate {
   
    private var mqtt: CocoaMQTT?
    static let shared = MqttManager()
    
    private let HOST = "safulet-vmq.gywt73aq.xyz"
    private let PORT = 443
    private let CERTNAME = "keystore"
    private let CERTPASSWORD = "swee"
    
    private init() { }
    
    // MARK: PUBLIC METHODS
    
    func connect(clientId: String, username: String, password: String) {
        
        mqtt = CocoaMQTT(clientID: clientId, host: HOST, port: UInt16(PORT))
        
        guard let mqtt = mqtt else { return }
        mqtt.username = username
        mqtt.password = password
        mqtt.allowUntrustCACertificate = true
        mqtt.enableSSL = true
        mqtt.logLevel = .debug
        
        let clientCertArray = getClientCertFromP12File(certName: CERTNAME, certPassword: CERTPASSWORD)
        var sslSettings: [String: NSObject] = [:]
        sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
        
        mqtt.sslSettings = sslSettings
        mqtt.keepAlive = 60
        mqtt.delegate = self
        let _ = mqtt.connect()
    }
    
    func disconnect() {
        guard let mqtt = mqtt else { return }
        mqtt.disconnect()
    }
    
    func subscribe(topics: [(String, CocoaMQTTQoS)]) {
        guard let mqtt = mqtt else { return }
        mqtt.subscribe(topics)
    }
    
    func unsubscribe(topics: [String]) {
        guard let mqtt = mqtt else { return }
        mqtt.unsubscribe(topics)
    }
    
    func publish(topic: String, message: String) {
        guard let mqtt = mqtt else { return }
        mqtt.publish(topic, withString: message)
    }
    
    
    // MARK: DID CONNECT HANDLERS
    
    private var didConnectHandlers: [((_ mqtt: CocoaMQTT, _ ack: CocoaMQTTConnAck) -> Void)] = []
    
    func didConnect(handler : @escaping (_ mqtt: CocoaMQTT, _ ack: CocoaMQTTConnAck) -> Void) {
        didConnectHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        didConnectHandlers.forEach { $0(mqtt, ack) }
    }
    
    
    
    
    // MARK: DID PUBLISH MESSAGE HANDLERS
    
    private var didPublishMessageHandlers: [((_ mqtt: CocoaMQTT, _ message: CocoaMQTTMessage, _ id: UInt16) -> Void)] = []
    
    func didPublishMessage(handler : @escaping (_ mqtt: CocoaMQTT, _ message: CocoaMQTTMessage, _ id: UInt16) -> Void) {
        didPublishMessageHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        didPublishMessageHandlers.forEach { $0(mqtt, message, id) }
    }
    
    
    
    
    // MARK: DID PUBLISH ACK HANDLERS
    
    private var didPublishAckHandlers: [((_ mqtt: CocoaMQTT, _ id: UInt16) -> Void)] = []
    
    func didPublishAck(handler : @escaping (_ mqtt: CocoaMQTT, _ id: UInt16) -> Void) {
        didPublishAckHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        didPublishAckHandlers.forEach { $0(mqtt, id) }
    }
    
    
    
    
    // MARK: DID RECEIVE MESSAGE HANDLERS
    
    private var didReceiveMessageHandlers: [((_ mqtt: CocoaMQTT, _ message: CocoaMQTTMessage, _ id: UInt16) -> Void)] = []
    
    func didReceiveMessage(handler : @escaping (_ mqtt: CocoaMQTT, _ message: CocoaMQTTMessage, _ id: UInt16) -> Void) {
        didReceiveMessageHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        didReceiveMessageHandlers.forEach { $0(mqtt, message, id) }
    }
    
    
    
    
    // MARK: DID SUBSCRIBE TOPICS HANDLERS
    
    private var didSubscribeTopicsHandlers: [((_ mqtt: CocoaMQTT, _ success: NSDictionary, _ failed: [String]) -> Void)] = []
    
    func didSubscribeTopics(handler : @escaping (_ mqtt: CocoaMQTT, _ success: NSDictionary, _ failed: [String]) -> Void) {
        didSubscribeTopicsHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("subscribeddddd")
        didSubscribeTopicsHandlers.forEach { $0(mqtt, success, failed) }
    }
    
    
    
    // MARK: DID UNSUBSCRIBE TOPICS HANDLERS
    
    private var didUnsubscribeTopicsHandlers: [((_ mqtt: CocoaMQTT, _ topics: [String]) -> Void)] = []
    
    func didUnsubscribeTopics(handler : @escaping (_ mqtt: CocoaMQTT, _ topics: [String]) -> Void) {
        didUnsubscribeTopicsHandlers.append(handler)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        didUnsubscribeTopicsHandlers.forEach { $0(mqtt, topics) }
    }
    
    
    
    
    // MARK: DID PING HANDLERS
    
    private var didPingHandlers: [((_ mqtt: CocoaMQTT) -> Void)] = []
    
    func didPing(handler : @escaping (_ mqtt: CocoaMQTT) -> Void) {
        didPingHandlers.append(handler)
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        didPingHandlers.forEach { $0(mqtt) }
    }
    
    
    
    
    // MARK: DID RECEIVE PONG HANDLERS
    
    private var didPongHandlers: [((_ mqtt: CocoaMQTT) -> Void)] = []
    
    func didPong(handler : @escaping (_ mqtt: CocoaMQTT) -> Void) {
        didPongHandlers.append(handler)
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        didPongHandlers.forEach { $0(mqtt) }
    }
    
    
    
    
    // MARK: DID DISCONNECT HANDLERS
    
    private var didDisconnectHandlers: [((_ mqtt: CocoaMQTT, _ err: Error?) -> Void)] = []
    
    func didDisconnect(handler : @escaping (_ mqtt: CocoaMQTT, _ err: Error?) -> Void) {
        didDisconnectHandlers.append(handler)
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        didDisconnectHandlers.forEach { $0(mqtt, err) }
    }
    
    
    
    
    // MARK: OTHERS
    
    // https://github.com/emqx/CocoaMQTT/issues/318#issuecomment-596370553
    // might need to revisit this, something related to the tls/ssl certificate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    // generating p12 file: https://stackoverflow.com/questions/21141215/creating-a-p12-file
    func getClientCertFromP12File(certName: String, certPassword: String) -> CFArray? {
        // get p12 file path
        let resourcePath = Bundle.main.path(forResource: certName, ofType: "p12")
        
        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file: \(certName).p12")
            return nil
        }
        
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else {
                print("Failed to open the certificate file: \(certName).p12")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        
        return certArray
    }
}
