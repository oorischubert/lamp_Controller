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

  Future _devSettings(
      {required bool barrier,
      bool newDev = false,
      bool firstDev = false}) async {
    if (newDev) {
      devName = "";
      uid = "";
    } else {
      uid = json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
          ['key']; //reset uid
      devName =
          json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
              ['name']; //reset devName
    }
    showDialog(
        barrierDismissible: !barrier,
        context: context,
        builder: (context) =>
            Consumer(builder: (context, UserProvider notifier, child) {
              return AlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text('Settings')]),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    initialValue: devName,
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
                    initialValue: uid,
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Spacer(),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              if (uid != "" &&
                                  uid !=
                                      json.decode(notifier.deviceList)[
                                          notifier.device]["key"] &&
                                  !newDev) {
                                List newList = json.decode(notifier.deviceList);
                                newList[notifier.device]["key"] = uid;
                                notifier.deviceList = json.encode(newList);
                              }
                              if (devName != "" &&
                                  devName !=
                                      json.decode(notifier.deviceList)[
                                          notifier.device]["name"] &&
                                  !newDev) {
                                List newList = json.decode(notifier.deviceList);
                                newList[notifier.device]["name"] = devName;
                                notifier.deviceList = json.encode(newList);
                              }

                              if (uid != "" && devName != "") {
                                if (newDev) {
                                  List newList =
                                      json.decode(notifier.deviceList);
                                  if (firstDev) {
                                    //if first device need to replace empty device with info
                                    newList = [
                                      {"name": devName, "key": uid}
                                    ];
                                    notifier.deviceList = json.encode(newList);
                                  } else {
                                    //if nto first device add to end and increade device list length
                                    newList.add({"name": devName, "key": uid});
                                    notifier.deviceList = json.encode(newList);
                                    notifier.device = newList.length - 1;
                                  }
                                }
                                setSwitch(
                                    value: json.decode(notifier.deviceList)[
                                        notifier.device]["key"]);
                                Navigator.pop(context);
                              }
                              if (devName == "") {
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(const SnackBar(
                                      content:
                                          Text('Please input device name!')));
                              }
                              if (uid == "") {
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(const SnackBar(
                                      content:
                                          Text('Please input device key!')));
                              }
                            },
                            child: Transform.scale(
                                scale: 1.5, child: const Text('Save'))),
                        const Spacer(),
                        if (!newDev)
                          TextButton(
                            onPressed: () async {
                              bool delete = await Decor.verifyPopUp(
                                  context: context,
                                  titleText:
                                      "Delete ${json.decode(notifier.deviceList)[notifier.device]["name"]} ?");
                              if (delete) {
                                //delete device from deviceList in UserSettings
                                List newList = json.decode(notifier.deviceList);
                                newList.removeAt(notifier.device);
                                notifier.deviceList = json.encode(newList);
                                if (notifier.device > 0) {
                                  notifier.device -= 1;
                                } else if (newList.isEmpty) {
                                  notifier.deviceList = json.encode([
                                    {"name": "", "key": ""}
                                  ]);
                                  _devSettings(
                                      barrier: true,
                                      newDev: true,
                                      firstDev: true);
                                }
                                setSwitch(
                                    value: json.decode(notifier.deviceList)[
                                        notifier.device]["key"]);
                              }
                            },
                            child: Transform.scale(
                                scale: 1.5,
                                child: const Icon(
                                  Icons.delete, //refresh_rounded
                                )),
                          )
                        else
                          const Spacer(),
                      ]),
                ],
              );
            }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); //app state observer
    (json.decode(UserSettings.getDeviceList())[UserSettings.getDevice()]
                ["key"] ==
            "")
        ?
        //does only after widgets are built!
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _devSettings(barrier: true, newDev: true, firstDev: true))
        : {
            uid = json.decode(
                UserSettings.getDeviceList())[UserSettings.getDevice()]["key"],
            devName = json.decode(
                UserSettings.getDeviceList())[UserSettings.getDevice()]["name"],
            setSwitch(value: uid)
          };
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
              UserSettings.getDeviceList())[UserSettings.getDevice()]["key"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, UserProvider notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
              onTap: () {
                setSwitch(
                    value: json.decode(notifier.deviceList)[notifier.device]
                        ["key"]);
              },
              child: Text(
                  json.decode(notifier.deviceList)[notifier.device]["name"])),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                _devSettings(barrier: false);
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
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text(
                      "Menu",
                      style: Decor.textStyler(size: 30, color: Colors.white),
                    )
                  ])),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: json.decode(notifier.deviceList).length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(json.decode(notifier.deviceList)[index]["name"]),
                      onTap: () {
                        notifier.device = index;
                        setSwitch(
                            value: json.decode(
                                notifier.deviceList)[notifier.device]["key"]);
                        Navigator.pop(context);
                      },
                    );
                  }),
              ElevatedButton(
                  //add new device to deviceList in UserSettings
                  onPressed: () {
                    Navigator.pop(context);
                    _devSettings(barrier: false, newDev: true);
                  },
                  child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.add,
                      )))
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
                                            notifier.device]["key"])
                                    : _buttonController.setState(
                                        value: "L",
                                        key: json.decode(notifier.deviceList)[
                                            notifier.device]["key"]);
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
