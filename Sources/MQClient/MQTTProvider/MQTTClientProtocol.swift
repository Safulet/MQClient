
import Foundation
import NIOSSL
#if canImport(Combine)
import Combine
#endif
import NIO

protocol MQTTClientProtocol {
    func connect(callback: @escaping (Result<Bool, Error>) -> Void)
    func flushConnect(callback: @escaping (Result<Bool, Error>) -> Void)
    func publish(
        topic: String,
        typeId: String,
        isQos2: Bool,
        isRetained: Bool,
        data: String,
        callback: @escaping (Result<Void, Error>) -> Void
    )
    func subscribe(topic: String, callback: @escaping (Result<MQSuback, Error>) -> Void)
    func unsubscribe(topicId: String, callback: @escaping (Result<Void, Error>) -> Void)
//    func createCsr(privateKeyPem: String, dnsName: String) throws -> String
//    func verifyCert(rootCA: String, privateKeyPem: String, dnsName: String) throws
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

    
