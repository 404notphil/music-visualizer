import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

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
  MyApp2()
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
  final List<String> redItems = ['Red Item 1', 'Red Item 2', 'Red Item 3', 'Red Item 4', 'Red Item 5', 'Red Item 6'];
  final List<String> blueItems = ['Blue Item 1', 'Blue Item 2', 'Blue Item 3', 'Blue Item 4', 'Blue Item 5', 'Blue Item 6'];
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
                  title: const Text('Red List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
              body: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: redItems.length,
                itemBuilder: (context, index) {
                  return buildListItem(redItems[index], Colors.red.shade200, 'red$index');
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
                  title: const Text('Blue List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                );
              },
              body: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: blueItems.length,
                itemBuilder: (context, index) {
                  return buildListItem(blueItems[index], Colors.blue.shade200, 'blue$index');
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