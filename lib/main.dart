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
  const MyApp2()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nested Reorderable Lists')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.red.shade100,
              padding: EdgeInsets.all(8),
              child: Text('Red List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverReorderableList(
            itemCount: redItems.length,
            itemBuilder: (context, index) {
              return ReorderableDragStartListener(
                key: ValueKey('red${redItems[index]}'),
                index: index,
                child: Card(
                  color: Colors.red.shade200,
                  child: ListTile(
                    title: Text(redItems[index]),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = redItems.removeAt(oldIndex);
                redItems.insert(newIndex, item);
              });
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.blue.shade100,
              padding: EdgeInsets.all(8),
              child: Text('Blue List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverReorderableList(
            itemCount: blueItems.length,
            itemBuilder: (context, index) {
              return ReorderableDragStartListener(
                key: ValueKey('blue${blueItems[index]}'),
                index: index,
                child: Card(
                  color: Colors.blue.shade200,
                  child: ListTile(
                    title: Text(blueItems[index]),
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = blueItems.removeAt(oldIndex);
                blueItems.insert(newIndex, item);
              });
            },
          ),
        ],
      ),
    );
  }
}