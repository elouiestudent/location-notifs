import 'package:flutter/material.dart';
import 'package:location_notifs/notification_preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location_notifs/storage.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    notifInstantiation().then((response) {
      setState(() {});
    });

    Storage.setNotificationPreference("never");

    bg.BackgroundGeolocation.onLocation((bg.Location location) async {
      print('[location] - $location');
      // fetch new resource data
      // update geofences
      var exists = await bg.BackgroundGeolocation.geofenceExists("home");
      print('[exists] - $exists');
      if (!exists) {
        var home = bg.Geofence(
          identifier: "home",
          radius: 300,
          latitude: 38.997,
          longitude: -77.358,
          notifyOnEntry: true,
          notifyOnDwell: true,
          notifyOnExit: true,
        );
        print("going to add");
        bg.BackgroundGeolocation.addGeofence(home);
        print("Geofence added");
      }
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      if (event.action == "DWELL") {
        var identifier = event.identifier;
        print("dwelling~~~ in $identifier");
        NotificationPreference pref = NotificationPreferenceParser.parse(
            await Storage.getNotificationPreference());
        if (pref == NotificationPreference.ALWAYS ||
            (pref == NotificationPreference.NOTIFY_ONCE &&
                await Storage.getNotificationFrequency(identifier) < 1)) {
          Storage.setNotificationFrequency(identifier, 1);
          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
              'your channel id',
              'your channel name',
              'your channel description',
              importance: Importance.Max,
              priority: Priority.High,
              ticker: 'ticker');
          var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          await flutterLocalNotificationsPlugin.show(0, 'Geofence Event',
              'Dwelling in $identifier', platformChannelSpecifics,
              payload: 'item x');
        }
      }
      if (event.action == "ENTER") {
        // send notification
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final never = SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text('Never'),
        onPressed: () async {
          await Storage.setNotificationPreference("never");
          await Storage.resetNotificationFrequencies();

          await bg.BackgroundGeolocation.stop();
          await bg.BackgroundGeolocation.removeGeofences();
          await bg.BackgroundGeolocation.destroyLocations();
        },
      ),
    );
    final notifyOnce = SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text('Notify me once'),
        onPressed: () async {
          await Storage.setNotificationPreference("notify_once");
          await Storage.resetNotificationFrequencies();

          bg.BackgroundGeolocation.ready(bg.Config(
                  desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
                  distanceFilter: 10.0,
                  stopOnTerminate: false,
                  startOnBoot: true,
                  debug: true,
                  logLevel: bg.Config.LOG_LEVEL_VERBOSE))
              .then((bg.State state) {
            if (!state.enabled) {
              ////
              // 3.  Start the plugin.
              //
              bg.BackgroundGeolocation.start();
            }
          });
        },
      ),
    );
    final notifyMeAlways = SizedBox(
      width: double.maxFinite,
      child: RaisedButton(
        child: Text('Notify me always'),
        onPressed: () async {
          await Storage.setNotificationPreference("always");
          await Storage.resetNotificationFrequencies();

          bg.BackgroundGeolocation.ready(bg.Config(
                  desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
                  distanceFilter: 10.0,
                  stopOnTerminate: false,
                  startOnBoot: true,
                  debug: true,
                  logLevel: bg.Config.LOG_LEVEL_VERBOSE))
              .then((bg.State state) {
            if (!state.enabled) {
              ////
              // 3.  Start the plugin.
              //
              bg.BackgroundGeolocation.start();
            }
          });
        },
      ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter location notifications'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[never, notifyOnce, notifyMeAlways],
            ),
          ),
        ),
      ),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Container(), // or SecondScreen(payload)
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Container()),
    );
  }

  Future notifInstantiation() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }
}
