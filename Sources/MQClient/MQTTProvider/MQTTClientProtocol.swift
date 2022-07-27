
import Foundation
import NIOSSL
#if canImport(Combine)
import Combine
#endif
import NIO

protocol MQTTClientProtocol {

    // - MARK: connect
    func connect()
    func reconnect()
    func disconnect()
    func setupConnectionCallbacks(
        onConnected: @escaping (MQConnectResponse) -> Void,
        onReconnecting: @escaping () -> (),
        onDisconnected: @escaping (MQDisconnectReason) -> Void,
        onConnectionFailure: @escaping (Error) -> (Void)
    )
    
    // - MARK: publish
    func publish(
        _ payload: String,
        to topic: String,
        qos: MQQoS,
        retain: Bool,
        callback: @escaping (Result<Void, Error>) -> Void
    )
    
    func publish(
        _ payload: MQPayload,
        to topic: String,
        qos: MQQoS,
        retain: Bool,
        callback: @escaping (Result<Void, Error>) -> Void
    ) 
    
    // - MARK: subscribe
    func subscribe(
        to topic: String,
        callback: @escaping (Result<MQSingleSubscribeResponse, Error>) -> Void
    )
    
    func unsubscribe(from topic: String, callback: @escaping (Result<MQSingleUnsubscribeResponse, Error>) -> Void)
    
    func whenReceiveMessage(_ callback: @escaping (MQMessage) -> Void)
    
    // - MARK: combine
    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var messagePublisher: AnyPublisher<MQMessage, Never> { get }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var connectPublisher: AnyPublisher<MQConnectResponse, Never> { get }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var reconnectPublisher: AnyPublisher<Void, Never> { get }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var disconnectPublisher: AnyPublisher<MQDisconnectReason, Never> { get }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    var connectionFailurePublisher: AnyPublisher<Error, Never> { get }
    #endif
}


// Focus on structure
// Anticipate expensive choices
// Core decisions for high quality


// First, get context
// Functional requirements
// Non-functional requirements, functionality, reliability, usability, effiency, maintainability, scalability

// Second, prioritize

// Design the architecture

// Wrap up

// Layer architecture - typical but no sliver bullet.
/*
 Architecture will evolve:
  - Requirements will change
  - Some changes will be expensive
  - Balance to avoid over/under engineering

*/


// Will it scale
// Horizontal scaling CAP theorem


/*
 
 MQTTClient ------ Subject -----> Publisher   ---------> ViewModel ------> State -------> View
 
 MQTTClient ------ Configuration
                   TLSConfiguration
                   Connection / Disconnection
                        
                   Subscribe / Unsubscribe topics
                        Topic management
                        
                   Message flow
                   
 
 
 Client:
  - Subjects when connect, disconnect, reconnect, connectionFailure
  - Subject when receive new messages
 
 Combine:
  - Publisher
 
 ViewModel:
  - State
  - Published
 
 
 Functional Requirement:
 subscribe topics and reflection to view
 
 
 Non-functional Requirement:
 
 
 "The many meanings of Event Driven architecture"
 

 
 Event-Driven architecture
 Component
 Producer -> Broker -> Consumer
 
 Benefits:
 It allows you to decouple different components, it also allows you to invert dependencies, and finally it allows you to scale better and I will show you that right now in an example.
 
 
Service1 -> Service2
Service1 need to know about the existence of Service2 in order to call it
 
 Service1 -> Event -> Service2
 Events are immutable
 
 Microservice Architecture
 a way to design software as a suite of indenpendently deployable services
 usually around a business capability
 
 Saga pattern
 
 */

    
