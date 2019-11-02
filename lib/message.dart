import 'package:mqtt_client/mqtt_client.dart';

class Message {
  String server;
  int port;
  String pubTopic;
  String subTopic;

  String account;
  String password;

  String pubMessage;
  MqttQos Qos;

  Message({this.server, this.port, this.pubTopic, this.subTopic, this.pubMessage, this.Qos});

}
