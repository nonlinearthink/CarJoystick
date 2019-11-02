import 'package:flutter/material.dart';
import 'register_page.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';
import 'message.dart';

class HomePage extends StatefulWidget {
  final String title;

  HomePage({Key key, this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _retainValue = false;

  ScrollController subMsgScrollController = new ScrollController();

  //mqtt方面的设定
  String broker = 'mqtt.zhzh.xyz';
  MqttClient client;
  MqttConnectionState connectionState;
  StreamSubscription subscription;

  //给滚动控件呈现的数据
  Message messages = Message(pubTopic: "ZXJ_FANmsg");

  int speed = 0;
  int check = 0;
  int status;
  List<String> pageName = ["MQTT设置", "关于开发者"];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _pubMessage() {
    //发布消息

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();

    messages.pubMessage = '{"start":$check,"turn":$status,"speed":$speed}';
    builder.addString(messages.pubMessage);
    print("pub message ${messages.pubTopic}:${messages.pubMessage}");
    client.publishMessage(
      messages.pubTopic,
      MqttQos.values[0],
      builder.payload,
      retain: _retainValue,
    );
  }

  void _reverseCheck(bool val) {
    setState(() {
      check = check == 1 ? 0 : 1;
    });
  }

  void _connect() async {
    //client连接的初始化配置
    //默认端口1883，如果不是1883就采用
    //client = mqtt.MqttClient.withPort(broker, '',1883);
    client = MqttClient(broker, '');
    client.logging(on: true);

    client.keepAlivePeriod = 30;

    client.onDisconnected = _onDisconnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Gats')
        .startClean()
        .keepAliveFor(30)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect("user", "password"); //请自己购买MQTT服务器账号和密码
    } catch (e) {
      print(e);
      _disconnect();
    }

    if (client.connectionState == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionState;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');

      _disconnect();
    }

    subscription = client.updates.listen(_onMessage);
  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      connectionState = client.connectionState;
      client = null;
      subscription.cancel();
      subscription = null;
    });
    print('MQTT client disconnected');
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    print(event.length);
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    setState(() {
      messages = Message(
        pubTopic: event[0].topic,
        pubMessage: message,
        Qos: recMess.payload.header.qos,
      );
      try {
        subMsgScrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // ScrollController not attached to any scroll views.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  color: Colors.white,
                  iconSize: 30,
                ),
          ),
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                print(client);
              },
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.account_circle),
                ),
                title: Text(pageName[0]),
                onLongPress: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<String>(
                          builder: (BuildContext context) => RegisterPage(
                                title: pageName[0],
                                msg: messages,
                              )));
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.adb),
                ),
                title: Text(pageName[1]),
                onLongPress: null,
              )
            ],
          ),
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("前进"),
                        color: Colors.white70,
                        onPressed: () {
                          setState(() {
                            this.status = 1;
                            _pubMessage();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: RaisedButton(
                              child: Text("左转"),
                              color: Colors.white70,
                              onPressed: () {
                                setState(() {
                                  this.status = 4;
                                  _pubMessage();
                                });
                              },
                            ),
                            flex: 10,
                          ),
                          Spacer(flex: 1),
                          Flexible(
                            child: RaisedButton(
                              child: Text("右转"),
                              color: Colors.white70,
                              onPressed: () {
                                setState(() {
                                  this.status = 3;
                                  _pubMessage();
                                });
                              },
                            ),
                            flex: 10,
                          )
                        ],
                      ),
                      RaisedButton(
                        child: Text("后退"),
                        color: Colors.white70,
                        onPressed: () {
                          setState(() {
                            this.status = 2;
                            _pubMessage();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text("OFF"),
                      flex: 1,
                    ),
                    Flexible(
                      child: Switch(
                          value: check == 1 ? true : false,
                          activeColor: Colors.amber,
                          onChanged: _reverseCheck),
                      flex: 2,
                    ),
                    Flexible(
                      child: Text("ON"),
                      flex: 1,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: CircleAvatar(
                        child: CircleAvatar(
                          child: Text("速度：" + speed.toString()),
                          radius: 70.0,
                          backgroundColor: Colors.white,
                        ),
                        radius: 85.0,
                        backgroundColor: Colors.white70,
                      ),
                      flex: 10,
                    ),
                  ],
                ),
                Slider(
                    value: speed.toDouble(),
                    min: 0.0,
                    max: 90.0,
                    onChanged: (double newValue) {
                      setState(() {
                        speed = newValue.round();
                      });
                    }),
              ],
            ),
          ),
          decoration: BoxDecoration(
              gradient: RadialGradient(
                  colors: [Colors.white, Colors.cyanAccent, Colors.cyan],
                  radius: 1,
                  tileMode: TileMode.mirror)),
        ));
  }
}
