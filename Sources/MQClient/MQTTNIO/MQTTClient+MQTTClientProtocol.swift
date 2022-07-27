//
//  MQTTClient+Extensions.swift
//  mqtt-nio-demo
//
//  Created by 仇弘扬 on 2022/5/24.
//

import Foundation
import MQTTNIO
import NIO

extension MQTTClient: MQTTClientProtocol {
    
    func flushConnect() {
        disconnect().whenComplete { result in
            switch result {
            case .success:
                self.connect()
            case .failure:
                break
            }
        }
    }
    
    func publish(
        topic: String,
        typeId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String) {
            
        }

    func publishSecure(
        clientIds: [String],
        topic: String,
        typeId: String,
        sessionId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String) {
            
        }
    
    func subscribe(topic: String) {
        
    }
    
    
    func subscribeInAdvance(topic: String) {
        
    }
    
    func subscribeSecure(topic: String) {
        
    }
    
    func unsubscribe(topicId: String) {
        
    }
    
    func forceUnsubscribe(topicId: String) {
        
    }
    
    func createCsr(privateKeyPem: String, dnsName: String) {
        
    }
    
    
    func verifyCert(rootCA: String, privateKeyPem: String, dnsName: String) {
        
    }
}



