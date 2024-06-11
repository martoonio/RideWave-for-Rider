// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/methods/common_methods.dart';
import 'package:ridewave_riders/methods/map_theme_methods.dart';
import 'package:ridewave_riders/models/trip_details.dart';
import 'package:ridewave_riders/widgets/info_dialog.dart';
import 'package:ridewave_riders/widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../global/global_var.dart';
import '../widgets/loading_dialog.dart';

// ignore: must_be_immutable
class NewTripPage extends StatefulWidget {
  TripDetails? newTripDetailsInfo;

  NewTripPage({
    super.key,
    this.newTripDetailsInfo,
  });

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  MapThemeMethods themeMethods = MapThemeMethods();
  double googleMapPaddingFromBottom = 0;
  List<LatLng> coordinatesPolylineLatLngList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Marker> markersSet = <Marker>{};
  Set<Circle> circlesSet = <Circle>{};
  Set<Polyline> polyLinesSet = <Polyline>{};
  BitmapDescriptor? carMarkerIcon;
  bool directionRequested = false;
  String statusOfTrip = "accepted";
  String durationText = "", distanceText = "";
  String buttonTitleText = "Arrived";
  Color buttonColor = kPrimaryColor;
  CommonMethods cMethods = CommonMethods();
  DatabaseReference? newTripRequestReference;

  Future<void> handleSlideAction() async {
    DatabaseReference tripStatus = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    String newTripStatus = "";
    await tripStatus.once().then((snap) => {
          if (snap.snapshot.value != null)
            {newTripStatus = snap.snapshot.value.toString()}
          else
            {newTripStatus = "not found"}
        });

    if (newTripStatus == "cancelled") {
      Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
      cancelTripNow();
      setState(() {
        statusOfTrip = "cancelled";
        buttonTitleText = "Cancelled";
        buttonColor = Colors.red;
      });
      return;
    }

    if (statusOfTrip == "accepted" && newTripStatus != "cancelled") {
      setState(() {
        buttonTitleText = "Start Trip";
        buttonColor = Colors.green;
      });

      statusOfTrip = "arrived";

      if (newTripStatus != "cancelled") {
        FirebaseDatabase.instance
            .ref()
            .child("tripRequests")
            .child(widget.newTripDetailsInfo!.tripID!)
            .child("status")
            .set("arrived");

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) => LoadingDialog(
                  messageText: 'Please wait...',
                ));

        await obtainDirectionAndDrawRoute(
          widget.newTripDetailsInfo!.pickUpLatLng,
          widget.newTripDetailsInfo!.dropOffLatLng,
        );

        Navigator.pop(context);
      } else {
        Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
        cancelTripNow();
      }
    } else if (statusOfTrip == "arrived") {
      setState(() {
        buttonTitleText = "End Trip";
        buttonColor = Colors.green;
      });

      statusOfTrip = "ontrip";

      if (newTripStatus != "cancelled") {
        FirebaseDatabase.instance
            .ref()
            .child("tripRequests")
            .child(widget.newTripDetailsInfo!.tripID!)
            .child("status")
            .set("ontrip");
      } else {
        Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
        cancelTripNow();
      }
    } else if (statusOfTrip == "ontrip") {
      Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
      endTripNow();
    }
  }

  makeMarker() {
    if (carMarkerIcon == null) {
      ImageConfiguration configuration =
          createLocalImageConfiguration(context, size: const Size(2, 2));

      BitmapDescriptor.fromAssetImage(configuration, "images/motor.png")
          .then((valueIcon) {
        carMarkerIcon = valueIcon;
      });
    }
  }

  obtainDirectionAndDrawRoute(
      sourceLocationLatLng, destinationLocationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            LoadingDialog(messageText: "Please wait..."));

    var tripDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
        sourceLocationLatLng, destinationLocationLatLng);

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPoints =
        pointsPolyline.decodePolyline(tripDetailsInfo!.encodedPoints!);

    coordinatesPolylineLatLngList.clear();

    if (latLngPoints.isNotEmpty) {
      for (var pointLatLng in latLngPoints) {
        coordinatesPolylineLatLngList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    //draw polyline
    polyLinesSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          polylineId: const PolylineId("routeID"),
          color: kPrimaryColor,
          points: coordinatesPolylineLatLngList,
          jointType: JointType.round,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polyLinesSet.add(polyline);
    });

    //fit the polyline on google map
    LatLngBounds boundsLatLng;

    if (sourceLocationLatLng.latitude > destinationLocationLatLng.latitude &&
        sourceLocationLatLng.longitude > destinationLocationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: destinationLocationLatLng,
        northeast: sourceLocationLatLng,
      );
    } else if (sourceLocationLatLng.longitude >
        destinationLocationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
            sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
        northeast: LatLng(
            destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
      );
    } else if (sourceLocationLatLng.latitude >
        destinationLocationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(
            destinationLocationLatLng.latitude, sourceLocationLatLng.longitude),
        northeast: LatLng(
            sourceLocationLatLng.latitude, destinationLocationLatLng.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: sourceLocationLatLng,
        northeast: destinationLocationLatLng,
      );
    }

    controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    //add marker
    Marker sourceMarker = Marker(
      markerId: const MarkerId('sourceID'),
      position: sourceLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      position: destinationLocationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    //add circle
    Circle sourceCircle = Circle(
      circleId: const CircleId('sourceCircleID'),
      strokeColor: Colors.orange,
      strokeWidth: 4,
      radius: 14,
      center: sourceLocationLatLng,
      fillColor: whiteColor,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationCircleID'),
      strokeColor: whiteColor,
      strokeWidth: 4,
      radius: 14,
      center: destinationLocationLatLng,
      fillColor: Colors.orange,
    );

    setState(() {
      circlesSet.add(sourceCircle);
      circlesSet.add(destinationCircle);
    });
  }

  getLiveLocationUpdatesOfDriver() {
    positionStreamNewTripPage =
        Geolocator.getPositionStream().listen((Position positionDriver) {
      riderCurrentPosition = positionDriver;

      LatLng riderCurrentPositionLatLng = LatLng(
          riderCurrentPosition!.latitude, riderCurrentPosition!.longitude);

      Marker carMarker = Marker(
        markerId: const MarkerId("carMarkerID"),
        position: riderCurrentPositionLatLng,
        icon: carMarkerIcon!,
        infoWindow: const InfoWindow(title: "My Location"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: riderCurrentPositionLatLng, zoom: 16);
        controllerGoogleMap!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markersSet
            .removeWhere((element) => element.markerId.value == "carMarkerID");
        markersSet.add(carMarker);
      });

      //update Trip Details Information
      updateTripDetailsInformation();

      //update driver location to tripRequest
      Map updatedLocationOfDriver = {
        "latitude": riderCurrentPosition!.latitude,
        "longitude": riderCurrentPosition!.longitude,
      };
      FirebaseDatabase.instance
          .ref()
          .child("tripRequests")
          .child(widget.newTripDetailsInfo!.tripID!)
          .child("riderLocation")
          .set(updatedLocationOfDriver);
    });
  }

  updateTripDetailsInformation() async {
    if (!directionRequested) {
      directionRequested = true;

      if (riderCurrentPosition == null) {
        return;
      }

      var driverLocationLatLng = LatLng(
          riderCurrentPosition!.latitude, riderCurrentPosition!.longitude);

      LatLng dropOffDestinationLocationLatLng;
      if (statusOfTrip == "accepted") {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.pickUpLatLng!;
      } else {
        dropOffDestinationLocationLatLng =
            widget.newTripDetailsInfo!.dropOffLatLng!;
      }

      var directionDetailsInfo = await CommonMethods.getDirectionDetailsFromAPI(
          driverLocationLatLng, dropOffDestinationLocationLatLng);

      if (directionDetailsInfo != null) {
        directionRequested = false;

        setState(() {
          durationText = directionDetailsInfo.durationTextString!;
          distanceText = directionDetailsInfo.distanceTextString!;
        });
      }
    }
  }

  endTripNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(
        messageText: 'Please wait...',
      ),
    );

    var driverCurrentLocationLatLng =
        LatLng(riderCurrentPosition!.latitude, riderCurrentPosition!.longitude);

    var directionDetailsEndTripInfo =
        await CommonMethods.getDirectionDetailsFromAPI(
      widget.newTripDetailsInfo!.pickUpLatLng!, //pickup
      driverCurrentLocationLatLng, //destination
    );

    Navigator.pop(context);

    String fareAmount =
        (cMethods.calculateFareAmount(directionDetailsEndTripInfo!)).toString();

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("fareAmount")
        .set(fareAmount);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("status")
        .set("ended");

    //dialog for collecting fare amount
    displayPaymentDialog(fareAmount);

    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    newTripRequestReference = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    //stop listening to the newTripStatus
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
    positionStreamNewTripPage!.cancel();

    //save fare amount to driver total earnings
    saveFareAmountToDriverTotalEarnings(fareAmount);
  }

  cancelTripNow() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(
        messageText: 'Please wait...',
      ),
    );

    Navigator.pop(context);

    String fareAmount = 0.toString();

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("fareAmount")
        .set(0);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("status")
        .set("cancelled");

    positionStreamNewTripPage!.cancel();

    //dialog for cancelled
    cancelledDialog();

    //save fare amount to driver total earnings
    saveFareAmountToDriverTotalEarnings(fareAmount);
  }

  cancelledDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InfoDialog(
              title: "Cancelled",
              description:
                  "Your trip has been\ncancelled by ${widget.newTripDetailsInfo!.userName!}.",
            ));
    setState(() {
      statusOfTrip = "cancelled";
    });
  }

  displayPaymentDialog(fareAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount),
    );
  }

  saveFareAmountToDriverTotalEarnings(String fareAmount) async {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance
        .ref()
        .child("riders")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");

    await driverEarningsRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double previousTotalEarnings =
            double.parse(snap.snapshot.value.toString());
        double fareAmountForTrip = double.parse(fareAmount);

        double newTotalEarnings = previousTotalEarnings + fareAmountForTrip;

        driverEarningsRef.set(newTotalEarnings);
      } else {
        driverEarningsRef.set(fareAmount);
      }
    });
  }

  saveDriverDataToTripInfo() async {
    Map<String, dynamic> driverDataMap = {
      "status": "accepted",
      "riderID": FirebaseAuth.instance.currentUser!.uid,
      "riderName": riderName,
      "riderPhone": riderPhone,
      "riderPhoto": riderPhoto,
      "riderFaculty": riderFaculty,
      "vehicle_model": vehicleModel,
      "vehicle_color": vehicleColor,
      "vehicle_number": vehicleNumber,
    };

    Map<String, dynamic> driverCurrentLocation = {
      'latitude': riderCurrentPosition!.latitude.toString(),
      'longitude': riderCurrentPosition!.longitude.toString(),
    };

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .update(driverDataMap);

    await FirebaseDatabase.instance
        .ref()
        .child("tripRequests")
        .child(widget.newTripDetailsInfo!.tripID!)
        .child("riderLocation")
        .update(driverCurrentLocation);
  }

  @override
  void initState() {
    super.initState();

    saveDriverDataToTripInfo();
  }

  @override
  Widget build(BuildContext context) {
    makeMarker();
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          "RideWave",
          style: GoogleFonts.poppins(
            color: whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ///google map
          GoogleMap(
            padding: EdgeInsets.only(bottom: googleMapPaddingFromBottom),
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: markersSet,
            circles: circlesSet,
            polylines: polyLinesSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) async {
              controllerGoogleMap = mapController;
              themeMethods.updateMapTheme(controllerGoogleMap!);
              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                googleMapPaddingFromBottom = 262;
              });

              var driverCurrentLocationLatLng = LatLng(
                  riderCurrentPosition!.latitude,
                  riderCurrentPosition!.longitude);

              var userPickUpLocationLatLng =
                  widget.newTripDetailsInfo!.pickUpLatLng;

              await obtainDirectionAndDrawRoute(
                  driverCurrentLocationLatLng, userPickUpLocationLatLng);

              getLiveLocationUpdatesOfDriver();
            },
          ),

          ///trip details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              height: height * 0.40,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: whiteColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Estimated Time",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: whiteColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          durationText,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    // top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      height: height * 0.40 - 42,
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 0, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //user name - call user icon btn
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: kPrimaryColor,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: Image.network(
                                              widget.newTripDetailsInfo!
                                                  .userPhoto!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Expanded(
                                                child: Text(
                                                  widget.newTripDetailsInfo!
                                                      .userName!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: GoogleFonts.jost(
                                                    color: kPrimaryColor,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              widget.newTripDetailsInfo!
                                                  .userFaculty!,
                                              style: GoogleFonts.jost(
                                                color: kPrimaryColor,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    //call user icon btn
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                              Uri.parse(
                                                  "tel://${widget.newTripDetailsInfo!.userPhone.toString()}"),
                                            );
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: whiteColor,
                                                border: Border.all(
                                                  color: kPrimaryColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(
                                                  8), // Sesuaikan sesuai kebutuhan
                                              child: const Icon(
                                                Icons.phone,
                                                color: kPrimaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            launchUrl(
                                              Uri.parse(
                                                  "https://wa.me/${widget.newTripDetailsInfo!.userPhone.toString()}"),
                                            );
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: whiteColor,
                                                border: Border.all(
                                                  color: kPrimaryColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(
                                                  8), // Sesuaikan sesuai kebutuhan
                                              child: const Icon(
                                                Icons.chat,
                                                color: kPrimaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 15,
                                ),

                                //pickup icon and location
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Pickup Location",
                                      style: GoogleFonts.jost(
                                        color: kPrimaryColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        // color: kPrimaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: kPrimaryColor,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_pin,
                                            color: kPrimaryColor,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              widget.newTripDetailsInfo!
                                                  .pickupAddress
                                                  .toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.jost(
                                                  fontSize: 18,
                                                  color: kPrimaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Center(
                              child: SlideAction(
                                onSubmit: handleSlideAction,
                                outerColor: buttonColor,
                                innerColor: Colors.white,
                                sliderButtonIcon: const Icon(
                                  Icons.chevron_right,
                                  color: kPrimaryColor,
                                ),
                                child: Text(
                                  buttonTitleText,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
