# Experiment with MQTT client library on iOS

- [CocoaMQTT](https://github.com/emqx/CocoaMQTT)
- [MQTT-Client-Framework](https://github.com/novastone-media/MQTT-Client-Framework)


## CocoaMQTT

Everything is working as expected, but still facing the following two issues:

### 1. didSubscribeTopic handler not called

When subscribing to a topic, the delegate function of `didSubscribeTopic` is not called. The following warning is also shown in the log: `CocoaMQTT(warning): UNEXPECT SUBACK Recivied: SUBACK(id: 2)`. 

It is currrently an open issue on their github [here](https://github.com/emqx/CocoaMQTT/issues/420)


### 2. didPublishAck not called

Not sure why, maybe because I did not manually publish a ACK myself
