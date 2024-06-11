import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ridewave_riders/global/global_var.dart';
import 'package:ridewave_riders/models/trip_details.dart';
import 'package:ridewave_riders/widgets/loading_dialog.dart';
import 'package:ridewave_riders/widgets/notification_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;

  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();
    print("Device Token: $deviceRecognitionToken"); // Log untuk token perangkat

    if (deviceRecognitionToken != null) {
      DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
          .ref()
          .child("riders")
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("deviceToken");

      await referenceOnlineDriver.set(deviceRecognitionToken);
      print("Device token saved to database"); // Log untuk penyimpanan token

      await firebaseCloudMessaging.subscribeToTopic("riders");
      await firebaseCloudMessaging.subscribeToTopic("users");
      print("Subscribed to topics"); // Log untuk berlangganan topik
    }

    return deviceRecognitionToken;
  }

  startListeningForNewNotification(BuildContext context) async {
    ///1. Terminated
    //When the app is completely closed and it receives a push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        print("Notification received in terminated state"); // Log untuk notifikasi di state terminated
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    ///2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        print("Notification received in foreground state"); // Log untuk notifikasi di state foreground
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });

    ///3. Background
    //When the app is in the background and it receives a push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        print("Notification received in background state"); // Log untuk notifikasi di state background
        String tripID = messageRemote.data["tripID"];
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  static retrieveTripRequestInfo(String tripID, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "getting details..."),
    );

    // Navigator.pop(context);

    DatabaseReference tripRequestsRef =
        FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

    tripRequestsRef.once().then((dataSnapshot) {
      Navigator.pop(context);

      audioPlayer.open(
        Audio("audio/notif.mp3"),
      );

      audioPlayer.play();

      TripDetails tripDetailsInfo = TripDetails();
      double pickUpLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      tripDetailsInfo.pickupAddress =
          (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse(
          (dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress =
          (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName =
          (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone =
          (dataSnapshot.snapshot.value! as Map)["userPhone"];

      tripDetailsInfo.userFaculty = (dataSnapshot.snapshot.value! as Map)["userFaculty"];
      tripDetailsInfo.userPhoto = (dataSnapshot.snapshot.value! as Map)["userPhoto"];

      tripDetailsInfo.tripID = tripID;

      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(
          tripDetailsInfo: tripDetailsInfo,
        ),
      );
    });
  }
}