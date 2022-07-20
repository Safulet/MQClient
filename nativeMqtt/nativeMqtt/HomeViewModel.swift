//
//  HomeViewModel.swift
//  nativeMqtt
//
//  Created by Swee Sen on 17/3/22.
//

import Foundation
import SwiftUI

extension HomeView {
    @MainActor class HomeViewModel: ObservableObject {
        @Published var topicInput = ""
        @Published var messageInput = ""
        @Published var output = [String]()
        
        init() {
            MqttManager.shared.didConnect { [weak self] mqtt, ack in
                guard let self = self else { return }
                self.output.append("Connected")
            }
            MqttManager.shared.didSubscribeTopics { [weak self] mqtt, success, failed in
                // ALWAYS NOT CALLED
                guard let self = self else { return }
                self.output.append("Subscribed topic with success: \(success), failure: \(failed)")
            }
            MqttManager.shared.didUnsubscribeTopics { [weak self] mqtt, topics in
                guard let self = self else { return }
                self.output.append("Unsubscribe topics: \(topics)")
            }
            MqttManager.shared.didPublishMessage { [weak self] mqtt, message, id in
                guard let self = self else { return }
                if let outputString = String(bytes: message.payload, encoding: .utf8) {
                    self.output.append("Did publish this: \(outputString)")
                } else {
                    self.output.append("Did publish message but cannot decode payload")
                }
            }
            MqttManager.shared.didPublishAck { [weak self] mqtt, id in
                // ALWAYS NOT CALLED
                guard let self = self else { return }
                self.output.append("Did publish ack with id: \(id)")
            }
            MqttManager.shared.didReceiveMessage { [weak self] mqtt, message, id in
                guard let self = self else { return }
                if let outputString = String(bytes: message.payload, encoding: .utf8) {
                    self.output.append("Did receive this: \(outputString)")
                } else {
                    self.output.append("Did receive message but cannot decode payload")
                }
            }
            MqttManager.shared.didPing { [weak self] mqtt in
                guard let self = self else { return }
                self.output.append("Ping ping!")
            }
            MqttManager.shared.didPong { [weak self] mqtt in
                guard let self = self else { return }
                self.output.append("Pong pong!")
            }
            MqttManager.shared.didDisconnect { [weak self] mqtt, err in
                guard let self = self else { return }
                self.output.append("Disconnected with error: \(String(describing: err))")
            }
        }
        
        func connectMqtt() {
            MqttManager.shared.connect(clientId: "CLIENTID11", username: "USERNAME11", password: "PASSWORD")
        }
        
        func disconnectMqtt() {
            MqttManager.shared.disconnect()
        }
        
        func subscribeTopic(topic: String) {
            MqttManager.shared.subscribe(topics: [(topic, .qos0)])
        }
        
        func unsubscribeTopic(topic: String) {
            MqttManager.shared.unsubscribe(topics: [topic])
        }
        
        func publishMessage(topic: String, message: String) {
            MqttManager.shared.publish(topic: topic, message: message)
        }
        
        func clearOutput() {
            self.output.removeAll()
        }
    }
}
