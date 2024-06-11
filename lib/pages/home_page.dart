import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/main.dart';
import 'package:ridewave_riders/methods/map_theme_methods.dart';
import 'package:ridewave_riders/pages/profile_page.dart';
import 'package:ridewave_riders/pages/trips_history_page.dart';
import 'package:ridewave_riders/pushNotification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridewave_riders/widgets/logout_dialog.dart';

import '../global/global_var.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = kPrimaryColor;
  String titleToShow = "OFFLINE";
  bool isDriverAvailable = false;
  DatabaseReference? newTripRequestReference;
  MapThemeMethods themeMethods = MapThemeMethods();
  bool visibility = false;

  getCurrentLiveLocationOfDriver() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = positionOfUser;
    riderCurrentPosition = currentPositionOfDriver;

    // LatLng positionOfUserInLatLng = LatLng(
    //     currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    // CameraPosition cameraPosition =
    //     CameraPosition(target: positionOfUserInLatLng, zoom: 15);
    // controllerGoogleMap!
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  goOnlineNow() {
    //all drivers who are Available for new trip requests
    Geofire.initialize("activeRiders");

    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");
    newTripRequestReference!.set("waiting");

    // newTripRequestReference!.onValue.listen((event) {
    //   var snapshot = event.snapshot;
    //   PushNotificationSystem.retrieveTripRequestInfo(
    //       snapshot.value.toString(), context);
    // });
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!
          .animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOfflineNow() {
    //stop sharing driver live location updates
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //stop listening to the newTripStatus
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem() {
    PushNotificationSystem notificationSystem = PushNotificationSystem();
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  retrieveCurrentDriverInfo() async {
    await FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      riderName = (snap.snapshot.value as Map)["name"];
      riderPhone = (snap.snapshot.value as Map)["phone"];
      riderPhoto = (snap.snapshot.value as Map)["photo"];
      riderFaculty = (snap.snapshot.value as Map)["faculty"];
      // riderEarnings = (snap.snapshot.value as Map)["earnings"];

      vehicleColor =
          (snap.snapshot.value as Map)["vehicle_details"]["vehicleColor"];
      vehicleModel =
          (snap.snapshot.value as Map)["vehicle_details"]["vehicleModel"];
      vehicleNumber =
          (snap.snapshot.value as Map)["vehicle_details"]["vehicleNumber"];
    });

    initializePushNotificationSystem();
  }

  @override
  void initState() {
    super.initState();
    getCurrentLiveLocationOfDriver();
    retrieveCurrentDriverInfo();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // channel.description,
              icon: android.smallIcon,
              sound: const RawResourceAndroidNotificationSound('notif'),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        hoverColor: kSecondaryColor,
        foregroundColor: Colors.white,
        elevation: 5,
        enableFeedback: true,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isDismissible: false,
              builder: (BuildContext context) {
                return Container(
                  decoration: const BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,
                        ),
                      ),
                    ],
                  ),
                  height: height * 0.5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: width * 0.15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        titleToShow == "OFFLINE"
                            ? Image.asset(
                                "images/riderAssset.png",
                                height: height * 0.2,
                              )
                            : Image.asset(
                                "images/offline.png",
                                height: height * 0.2,
                              ),
                        const SizedBox(
                          height: 11,
                        ),
                        Text(
                          (!isDriverAvailable)
                              ? "GO ONLINE NOW"
                              : "GO OFFLINE NOW",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 21,
                        ),
                        Text(
                          (!isDriverAvailable)
                              ? "You are about to go online, you will become available to receive trip requests from wavers."
                              : "You are about to go offline, you will stop receiving new trip requests from wavers.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jost(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                          Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Back",
                                    style: GoogleFonts.poppins(
                                      color: kPrimaryColor,
                                    )),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (!isDriverAvailable) {
                                    //go online
                                    goOnlineNow();
                                    audioPlayer.open(
                                      Audio("audio/notif.mp3"),
                                    );

                                    audioPlayer.play();

                                    //get driver location updates
                                    setAndGetLocationUpdates();

                                    Navigator.pop(context);

                                    setState(() {
                                      colorToShow = Colors.red;
                                      titleToShow = "ONLINE";
                                      isDriverAvailable = true;
                                    });
                                  } else {
                                    //go offline
                                    goOfflineNow();

                                    Navigator.pop(context);

                                    setState(() {
                                      colorToShow = kPrimaryColor;
                                      titleToShow = "OFFLINE";
                                      isDriverAvailable = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (titleToShow == "OFFLINE")
                                      ? kPrimaryColor
                                      : Colors.red,
                                ),
                                child: Text("Confirm",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(
              color: kSecondaryColor,
              width: 2,
            )),
        child: Lottie.asset(
          "images/8d1P0sMz7V.json",
          height: 50,
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          icon: const Icon(Icons.person),
        ),
        title: Image.asset(
          "images/riders.png",
          height: 50,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LogOutDialog(
                      title: "Logout",
                      description: "Are you sure you want to logout?",
                    );
                  });
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: kPrimaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hi, $riderName!",
                                        style: GoogleFonts.poppins(
                                          color: whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Current Location",
                                        style: GoogleFonts.poppins(
                                          color: whiteColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "you're now",
                                        style: GoogleFonts.poppins(
                                          color: whiteColor,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        titleToShow,
                                        style: GoogleFonts.poppins(
                                          color: titleToShow == "OFFLINE"
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Stack(
                                children: [
                                  Center(
                                    child: GoogleMap(
                                      initialCameraPosition:
                                          googlePlexInitialPosition,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: true,
                                      zoomControlsEnabled: false,
                                      scrollGesturesEnabled: false,
                                      mapType: MapType.normal,
                                      onMapCreated: (GoogleMapController
                                          controller) async {
                                        currentPositionOfDriver =
                                            await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high,
                                        );
                                        controller.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(
                                                currentPositionOfDriver!
                                                    .latitude,
                                                currentPositionOfDriver!
                                                    .longitude,
                                              ),
                                              zoom: 18,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Lottie.asset("images/helmet.json",
                                          height: 100, repeat: false)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "History",
                        style: GoogleFonts.poppins(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TripsHistoryPage(),
                            ),
                          );
                        },
                        child: Text(
                          "View All",
                          style: GoogleFonts.poppins(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            decorationColor: kPrimaryColor,
                            decorationThickness: 2,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                      height: height * 0.5,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: StreamBuilder(
                          stream: completedTripRequestsOfCurrentUser.onValue,
                          builder: (BuildContext context, snapshotData) {
                            if (snapshotData.hasError) {
                              return Center(
                                child: Text(
                                  "Error Occurred.",
                                  style: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            if (!(snapshotData.hasData)) {
                              return Center(
                                child: Text(
                                  "No record found.",
                                  style: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            Map dataTrips =
                                snapshotData.data!.snapshot.value as Map;
                            List tripsList = [];
                            dataTrips.forEach((key, value) =>
                                tripsList.add({"key": key, ...value}));

                            // Filter trips
                            tripsList = tripsList
                                .where((trip) =>
                                    (trip["status"] == "cancelled" ||
                                        trip["status"] == "ended") &&
                                    trip["riderID"] ==
                                        FirebaseAuth.instance.currentUser!.uid)
                                .toList();

                            visibility = tripsList.isNotEmpty;

                            return visibility
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: tripsList.length,
                                    itemBuilder: ((context, index) {
                                      if (tripsList[index]["status"] ==
                                              "cancelled" ||
                                          tripsList[index]["status"] ==
                                              "ended") {
                                        String dropOffAddress = "";
                                        dropOffAddress =
                                            tripsList[index]["pickUpAddress"];
                                        return Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            0.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      child: Image.network(
                                                        tripsList[index]
                                                                ["userPhoto"]
                                                            .toString(),
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        tripsList[index]
                                                                ["userName"]
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: kPrimaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.pin_drop,
                                                            color:
                                                                kSecondaryColor,
                                                            size: 15,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  5), // Add a small gap between the icon and the text
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.5, // Adjust width as needed
                                                            child: Text(
                                                              dropOffAddress,
                                                              style: GoogleFonts
                                                                  .jost(
                                                                color:
                                                                    kSecondaryColor,
                                                                fontSize: 12,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        DateFormat(
                                                                'dd MMM yyyy HH:mm')
                                                            .format(DateTime.parse(
                                                                tripsList[index]
                                                                        [
                                                                        "publishDateTime"]
                                                                    .toString())),
                                                        style: GoogleFonts.jost(
                                                          color:
                                                              kSecondaryColor,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                tripsList[index]["status"]
                                                            .toString() ==
                                                        "ended"
                                                    ? "Done"
                                                    : "Cancelled",
                                                style: GoogleFonts.jost(
                                                    color: tripsList[index]
                                                                    ["status"]
                                                                .toString() ==
                                                            "ended"
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                                  )
                                : SizedBox(
                                    height: height * 0.4,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                          "images/norecord.json",
                                          height: 100,
                                          repeat: false,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "No record found.",
                                          style: GoogleFonts.poppins(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          })),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
