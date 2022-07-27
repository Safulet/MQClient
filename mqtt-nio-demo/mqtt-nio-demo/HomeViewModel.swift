//
//  HomeViewModel.swift
//  mqtt-nio-demo
//
//  Created by Swee Sen on 24/3/22.
//

import Foundation
import SwiftUI
import NIOSSL
import Combine
//import MQTTNIO


extension HomeView.HomeViewModel {
    func subscribe(to topic: String) {
        provider.client = MQClient.shared
        provider.topic = topic
        provider.subscribe { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    switch response.result {
                    case .success:
                        self?.output.append("Subscribed from \(topic)")
                    case let .failure(reason):
                        self?.output.append("Subscribed from \(topic) failed, due to \(reason)")
                    }
                case let .failure(error):
                    self?.output.append("Subscribed from \(topic) failed, due to \(error)")
                }
            }
        }
        
        provider.receiveMessageCallback = { [weak self] message in
            DispatchQueue.main.async {
                self?.output.append(message.payload.string ?? "Empty message")
            }
            
        }
    }

    func unsubscribe(from topic: String) {
        provider.unsubscribe { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(response):
                    switch response.result {
                    case .success:
                        self?.output.append("Unsubscribed from \(topic)")
                    case let .failure(reason):
                        self?.output.append("Unsubscribed from \(topic) failed, due to \(reason)")
                    }
                case let .failure(error):
                    self?.output.append("Unsubscribed from \(topic) failed, due to \(error)")
                }
            }
        }
    }
}

extension HomeView.HomeViewModel {

    
    
    func publishMessage(topic: String, message: String) {
        struct Test: Encodable {
            var name: String
            var nickname: String
        }
        provider.publish(message, to: topic, qos: .exactlyOnce, retain: false)
    }

}

extension HomeView {

    class HomeViewModel: ObservableObject {
        var provider: MQSubscription = MQSubscription()
        @Published var topicInput = "Test"
        @Published var messageInput = "asdf"
        @Published var output = [String]()

        private var connectStatusReceiver: AnyCancellable!
        
        init() {

            do {
                MQClient.shared.connect()
            } catch {
                print(error)
            }
        }
        
        
        func connectMqtt() {
            MQClient.shared.connect()
        }

        func disconnectMqtt() {
            MQClient.shared.disconnect()
        }

        func subscribeTopic(topic: String) {
            subscribe(to: topic)
        }

        func unsubscribeTopic(topic: String) {
            unsubscribe(from: topic)
        }

        func clearOutput() {
            self.output.removeAll()
        }
    }
}

