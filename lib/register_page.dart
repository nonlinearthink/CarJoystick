import 'package:flutter/material.dart';
import 'message.dart';

class RegisterPage extends StatefulWidget {
  final String title;
  Message msg;

  RegisterPage({Key key, this.title, this.msg}) : super(key: key);

  @override
  _RegisterPageState createState() => new _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "IP address",
                    prefixIcon: Icon(Icons.web)
                  ),
                  initialValue: widget.msg.server,
                  validator: (v){
                    return v.trim().length > 0 ? null : "IP地址不能为空";
                  },
                  onSaved: (v){
                    setState(() {
                      widget.msg.server = v;
                    });
                    print(widget.msg.server);
                  },
                ),
                TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "port",
                    prefixIcon: Icon(Icons.web)
                  ),
                  initialValue: widget.msg.port.toString(),
                  onSaved: (v){
                    setState(() {
                      widget.msg.port = int.parse(v);
                    });
                    print(widget.msg.port);
                  },
                ),
                TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "PubTopic",
                      prefixIcon: Icon(Icons.arrow_upward)),
                  initialValue: widget.msg.pubTopic,
                  validator: (v) {
                    return v.trim().length > 0 ? null : "订阅主题不能为空";
                  },
                  onSaved: (v) {
                    setState(() {
                      widget.msg.pubTopic = v;
                    });
                    print(widget.msg.pubTopic);
                  },
                ),
                TextFormField(
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "SubTopic",
                      prefixIcon: Icon(Icons.arrow_downward)),
                  initialValue: widget.msg.subTopic,
                  validator: (v) {
                    return v.trim().length > 0 ? null : "接受主题不能为空";
                  },
                  onSaved: (v) {
                    setState(() {
                      widget.msg.subTopic = v;
                    });
                    print(widget.msg.subTopic);
                  },
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var form = _formKey.currentState;
          if (form.validate()) {
            form.save();
            showDialog<Null>(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("确认是否需要改变信息？"),
                      content: Text("PubTopic: ${widget.msg.pubTopic}\n"
                          "SubTopic: ${widget.msg.subTopic}"),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            _formKey.currentState.reset();
                            Navigator.pop(context);
                          },
                          child: Text("确定"),
                        )
                      ],
                    ));
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
