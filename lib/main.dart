import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
      MyMidiApp()
    // MyApp(settingsController: settingsController)
  );
}

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nested Reorderable Lists Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NestedReorderableLists(),
    );
  }
}

class NestedReorderableLists extends StatefulWidget {
  const NestedReorderableLists({Key? key}) : super(key: key);

  @override
  _NestedReorderableListsState createState() => _NestedReorderableListsState();
}

class _NestedReorderableListsState extends State<NestedReorderableLists> {
  final List<String> redItems = [
    'Red Item 1',
    'Red Item 2',
    'Red Item 3',
    'Red Item 4',
    'Red Item 5',
    'Red Item 6'
  ];
  final List<String> blueItems = [
    'Blue Item 1',
    'Blue Item 2',
    'Blue Item 3',
    'Blue Item 4',
    'Blue Item 5',
    'Blue Item 6'
  ];
  bool isRedExpanded = true;
  bool isBlueExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nested Reorderable Lists')),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              if (index == 0) {
                isRedExpanded = isExpanded;
              } else {
                isBlueExpanded = isExpanded;
              }
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  tileColor: Colors.red.shade100,
                  title: const Text('Red List', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
              body: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: redItems.length,
                itemBuilder: (context, index) {
                  return buildListItem(
                      redItems[index], Colors.red.shade200, 'red$index');
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = redItems.removeAt(oldIndex);
                    redItems.insert(newIndex, item);
                  });
                },
              ),
              isExpanded: isRedExpanded,
            ),
            ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  tileColor: Colors.blue.shade100,
                  title: const Text('Blue List', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
              body: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blueItems.length,
                itemBuilder: (context, index) {
                  return buildListItem(
                      blueItems[index], Colors.blue.shade200, 'blue$index');
                },
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = blueItems.removeAt(oldIndex);
                    blueItems.insert(newIndex, item);
                  });
                },
              ),
              isExpanded: isBlueExpanded,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(String text, Color color, String key) {
    return Card(
      key: ValueKey(key),
      color: color,
      child: ListTile(
        title: Text(text),
        trailing: ReorderableDragStartListener(
          index: int.parse(key.substring(key.length - 1)),
          child: const Icon(Icons.drag_handle),
        ),
      ),
    );
  }
}

class MyMidiApp extends StatefulWidget {
  const MyMidiApp({Key? key}) : super(key: key);

  @override
  MyMidiAppState createState() => MyMidiAppState();
}

class MyMidiAppState extends State<MyMidiApp> {
  StreamSubscription<String>? _setupSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final MidiCommand _midiCommand = MidiCommand();

  String _midiNote = "---";

  bool _virtualDeviceActivated = false;
  bool _iOSNetworkSessionEnabled = false;

  bool _didAskForBluetoothPermissions = false;

  @override
  void initState() {
    super.initState();

    // Subscribe to MIDI data received
    _midiDataSubscription =
        _midiCommand.onMidiDataReceived?.listen((MidiPacket packet) {
          _handleMidiData(packet);
        });

    _setupSubscription = _midiCommand.onMidiSetupChanged?.listen((data) async {
      if (/*kDebugMode*/true) {
        print("setup changed $data");
      }
      setState(() {});
    });

    _bluetoothStateSubscription =
        _midiCommand.onBluetoothStateChanged.listen((data) {
          if (/*kDebugMode*/true) {
            print("bluetooth state change $data");
          }
          setState(() {});
        });

    _updateNetworkSessionState();
  }

  @override
  void dispose() {
    _setupSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  // Handle received MIDI data
  void _handleMidiData(MidiPacket packet) {
    setState(() {
      _midiNote = '${packet.data}';
    });
  }

  _updateNetworkSessionState() async {
    var nse = await _midiCommand.isNetworkSessionEnabled;
    if (nse != null) {
      setState(() {
        _iOSNetworkSessionEnabled = nse;
      });
    }
  }

  IconData _deviceIconForType(String type) {
    switch (type) {
      case "native":
        return Icons.devices;
      case "network":
        return Icons.language;
      case "BLE":
        return Icons.bluetooth;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _informUserAboutBluetoothPermissions(
      BuildContext context) async {
    if (_didAskForBluetoothPermissions) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Please Grant Bluetooth Permissions to discover BLE MIDI Devices.'),
          content: const Text(
              'In the next dialog we might ask you for bluetooth permissions.\n'
                  'Please grant permissions to make bluetooth MIDI possible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok. I got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions = true;

    return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_midiNote),
          actions: <Widget>[
            Switch(
                value: _iOSNetworkSessionEnabled,
                onChanged: (newValue) {
                  _midiCommand.setNetworkSessionEnabled(newValue);
                  setState(() {
                    _iOSNetworkSessionEnabled = newValue;
                  });
                }),
            Switch(
                value: _virtualDeviceActivated,
                onChanged: (newValue) {
                  setState(() {
                    _virtualDeviceActivated = newValue;
                  });
                  if (newValue) {
                    _midiCommand.addVirtualDevice(name: "Flutter MIDI Command");
                  } else {
                    _midiCommand.removeVirtualDevice(
                        name: "Flutter MIDI Command");
                  }
                }),
            Builder(builder: (context) {
              return IconButton(
                  onPressed: () async {
                    // Ask for bluetooth permissions
                    await _informUserAboutBluetoothPermissions(context);

                    // Start bluetooth
                    if (/*kDebugMode*/true) {
                      print("start ble central");
                    }
                    await _midiCommand
                        .startBluetoothCentral()
                        .catchError((err) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(err),
                      ));
                    });

                    if (/*kDebugMode*/true) {
                      print("wait for init");
                    }
                    await _midiCommand
                        .waitUntilBluetoothIsInitialized()
                        .timeout(const Duration(seconds: 5), onTimeout: () {
                      if (/*kDebugMode*/true) {
                        print("Failed to initialize Bluetooth");
                      }
                    });

                    // If bluetooth is powered on, start scanning
                    if (_midiCommand.bluetoothState ==
                        BluetoothState.poweredOn) {
                      _midiCommand
                          .startScanningForBluetoothDevices()
                          .catchError((err) {
                        if (/*kDebugMode*/true) {
                          print("Error $err");
                        }
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Scanning for bluetooth devices ...'),
                        ));
                      }
                    } else {
                      final messages = {
                        BluetoothState.unsupported:
                        'Bluetooth is not supported on this device.',
                        BluetoothState.poweredOff:
                        'Please switch on bluetooth and try again.',
                        BluetoothState.poweredOn: 'Everything is fine.',
                        BluetoothState.resetting:
                        'Currently resetting. Try again later.',
                        BluetoothState.unauthorized:
                        'This app needs bluetooth permissions. Please open settings, find your app and assign bluetooth access rights and start your app again.',
                        BluetoothState.unknown:
                        'Bluetooth is not ready yet. Try again later.',
                        BluetoothState.other:
                        'This should never happen. Please inform the developer of your app.',
                      };
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(messages[_midiCommand.bluetoothState] ??
                              'Unknown bluetooth state: ${_midiCommand
                                  .bluetoothState}'),
                        ));
                      }
                    }

                    if (/*kDebugMode*/true) {
                      print("done");
                    }
                    // If not show a message telling users what to do
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh));
            }),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(24.0),
          child: const Text(
            "Tap to connnect/disconnect, long press to control.",
            textAlign: TextAlign.center,
          ),
        ),
        body:
            Center(
              child: FutureBuilder(
                future: _midiCommand.devices,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var devices = snapshot.data as List<MidiDevice>;
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        MidiDevice device = devices[index];

                        return ListTile(
                          title: Text(
                            device.name,
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall,
                          ),
                          subtitle: Text(
                              "ins:${device.inputPorts.length} outs:${device
                                  .outputPorts.length}, ${device.id}, ${device
                                  .type}"),
                          leading: Icon(device.connected
                              ? Icons.radio_button_on
                              : Icons.radio_button_off),
                          trailing: Icon(_deviceIconForType(device.type)),
                          onLongPress: () {
                            _midiCommand.stopScanningForBluetoothDevices();
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute<void>(
                            //   builder: (_) => ControllerPage(device),
                            // ))
                            //     .then((value) {
                            //   setState(() {});
                            // });
                          },
                          onTap: () {
                            if (device.connected) {
                              if (/*kDebugMode*/true) {
                                print("disconnect");
                              }
                              _midiCommand.disconnectDevice(device);
                            } else {
                              if (/*kDebugMode*/true) {
                                print("connect");
                              }
                              _midiCommand.connectToDevice(device).then((_) {
                                if (/*kDebugMode*/true) {
                                  print("device connected async");
                                }
                              }).then((abc) {
                                print(abc);
                              }).catchError((err) {
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                //     content: Text(
                                //         "Error: ${(err as PlatformException?)?.message}")));
                              });
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
      ),
    );
  }
}