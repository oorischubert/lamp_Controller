import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:led_controller/usersettings.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'decor.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String uid = ""; //current device uid
  String devName = ""; //current device name
  final Controller _buttonController = Controller();
  bool swValue = false; //init switch value
  bool swLoaded = false; //ProgressIndicator toggler

  setSwitch({required value}) async {
    setState(() {
      swLoaded = false;
    });
    final bool newValue = await _buttonController.getState(key: value);
    setState(() {
      swValue = newValue;
      swLoaded = true;
    });
  }

  Future _devSettings(bool barrier) async {
    uid = UserSettings.getUID(); //reset uid
    showDialog(
        barrierDismissible: barrier,
        context: context,
        builder: (context) =>
            Consumer(builder: (context, UserProvider notifier, child) {
              return AlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text('Settings')]),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    initialValue:
                        json.decode(notifier.deviceList)[notifier.device][0],
                    decoration: InputDecoration(
                      labelText: 'Device Name:',
                      enabledBorder: Decor.inputformdeco(),
                      focusedBorder: Decor.inputformdeco(),
                    ),
                    onChanged: (value) {
                      devName = value.trim();
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    initialValue:
                        json.decode(notifier.deviceList)[notifier.device][1],
                    decoration: InputDecoration(
                      labelText: 'Device Key:',
                      enabledBorder: Decor.inputformdeco(),
                      focusedBorder: Decor.inputformdeco(),
                    ),
                    onChanged: (value) {
                      uid = value.trim();
                    },
                  ),
                ]),
                actions: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                        onPressed: () {
                          if (uid != "" &&
                              uid !=
                                  json.decode(
                                          notifier.deviceList)[notifier.device]
                                      [1]) {
                            List newList = json.decode(notifier.deviceList);
                            newList[notifier.device][1] = uid;
                            notifier.deviceList = json.encode(newList);
                          }
                          if (devName != "" &&
                              devName !=
                                  json.decode(
                                          notifier.deviceList)[notifier.device]
                                      [1]) {
                            List newList = json.decode(notifier.deviceList);
                            newList[notifier.device][0] = devName;
                            notifier.deviceList = json.encode(newList);
                          }

                          if (uid != "" && devName != "") {
                            setSwitch(
                                value: json.decode(
                                    notifier.deviceList)[notifier.device][1]);
                            Navigator.pop(context);
                          }
                          if (devName == "") {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                  content: Text('Please input device name!')));
                          }
                          if (uid == "") {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                  content: Text('Please input device key!')));
                          }
                        },
                        child: Transform.scale(
                            scale: 1.5, child: const Text('Save')))
                  ]),
                ],
              );
            }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); //app state observer
    uid =
        json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()][1];
    devName =
        json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()][1];
    (uid == "")
        ?
        //does only after widgets are built!
        WidgetsBinding.instance.addPostFrameCallback((_) => _devSettings(false))
        : setSwitch(value: uid);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final unPaused = state == AppLifecycleState.resumed;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) return;

    if (unPaused) {
      setSwitch(
          value: json.decode(
              UserSettings.getDeviceList())[UserSettings.getDevice()][1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, UserProvider notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(json.decode(
              UserSettings.getDeviceList())[UserSettings.getDevice()][0]),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                _devSettings(true);
              },
              child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.settings, //refresh_rounded
                      ))),
            ),
          ],
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(child: Text("Menu")),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: json.decode(notifier.deviceList).length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(json.decode(notifier.deviceList)[index][0]),
                      onTap: () {
                        notifier.device = index;

                        setSwitch(
                            value: json.decode(notifier.deviceList)[index][1]);
                        Navigator.pop(context);
                      },
                    );
                  }),
            ],
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: swLoaded
                      ? ScaledBox(
                          height: 500,
                          width: 500,
                          child: Switch(
                              value: swValue,
                              onChanged: (_) {
                                Decor.doubleHaptics();
                                setState(() {
                                  swValue = !swValue;
                                });
                                swValue
                                    ? _buttonController.setState(
                                        value: "H",
                                        key: json.decode(notifier.deviceList)[
                                            notifier.device][1])
                                    : _buttonController.setState(
                                        value: "L",
                                        key: json.decode(notifier.deviceList)[
                                            notifier.device][1]);
                              }))
                      : Transform.scale(
                          scale: 6,
                          child: const CircularProgressIndicator(),
                        )),
            ],
          ),
        ),
      );
    });
  }
}
