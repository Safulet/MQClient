//
//  HomeView.swift
//  mqtt-nio-demo
//
//  Created by Swee Sen on 24/3/22.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            TextField("Enter topic input", text: $viewModel.topicInput)
                .padding()
            TextField("Enter message payload input", text: $viewModel.messageInput)
                .padding()
            List(viewModel.output, id: \.self) { output in
                Text(output)
            }
            HStack {
                Button(action: {
                    viewModel.connectMqtt()
                }) {
                    Text("Connect")
                }
                
                Button(action: {
                    viewModel.subscribeTopic(topic: viewModel.topicInput)
                }) {
                    Text("Sub Topic")
                }.foregroundColor(.green)
                
                Button(action: {
                    viewModel.unsubscribeTopic(topic: viewModel.topicInput)
                }) {
                    Text("Unsub Topic")
                }.foregroundColor(.green)
                
            }
            HStack {
                Button(action: {
                    viewModel.publishMessage(topic: viewModel.topicInput, message: viewModel.messageInput)
                }) {
                    Text("Publish Msg")
                }.foregroundColor(.purple)
                
                Button(action: {
                    viewModel.disconnectMqtt()
                }) {
                    Text("Disconnect")
                }.foregroundColor(.red)
                
                Button(action: {
                    viewModel.clearOutput()
                }) {
                    Text("Clear")
                }.foregroundColor(.red)
            }
            .padding()
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

