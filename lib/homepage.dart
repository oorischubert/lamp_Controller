import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:led_controller/usersettings.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import 'decor.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String uid = "";
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

  Future _setURL(bool barrier) async {
    uid = UserSettings.getUID(); //reset uid
    showDialog(
        barrierDismissible: barrier,
        context: context,
        builder: (context) =>
            Consumer(builder: (context, UserProvider notifier, child) {
              return AlertDialog(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text('Set Key')]),
                content: TextFormField(
                  initialValue: notifier.uid,
                  decoration: InputDecoration(
                    labelText: 'Device Key:',
                    enabledBorder: Decor.inputformdeco(),
                    focusedBorder: Decor.inputformdeco(),
                  ),
                  onChanged: (value) {
                    uid = value.trim();
                  },
                ),
                actions: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                        onPressed: () {
                          if (uid != "" && uid != notifier.uid) {
                            notifier.uid = uid;
                            setSwitch(value: notifier.uid);
                          }
                          if (uid != "") {
                            Navigator.pop(context);
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
    uid = UserSettings.getUID();
    (uid == "")
        ?
        //does only after widgets are built!
        WidgetsBinding.instance.addPostFrameCallback((_) => _setURL(false))
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
      setSwitch(value: UserSettings.getUID());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, UserProvider notifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lamp Switch'),
          leading: GestureDetector(
              onTap: () {
                //open info page or popup!
                _setURL(true);
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: SizedBox(
                    height: 40,
                    width: 40,
                    child: FittedBox(
                        child: Icon(
                      Icons.settings, //Icons.settings
                    ))),
              )),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                setSwitch(value: notifier.uid);
              },
              child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.refresh_rounded,
                      ))),
            ),
          ],
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
                                        value: "H", key: notifier.uid)
                                    : _buttonController.setState(
                                        value: "L", key: notifier.uid);
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
