import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";

String googleMapKey = "AIzaSyDlN7pUZ_oPhroD-gHODW-f6uQ1sR6fH4Y";

const CameraPosition googlePlexInitialPosition = CameraPosition(
  target: LatLng(-6.929851, 107.769440),
  zoom: 14.4746,
);

int riderEarnings = 0;

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;

final completedTripRequestsOfCurrentUser =
    FirebaseDatabase.instance.ref().child("tripRequests");

int driverTripRequestTimeout = 20;



final audioPlayer = AssetsAudioPlayer();

Position? riderCurrentPosition;

String riderName = "";
String riderPhone = "";
String riderPhoto = "";
String riderFaculty = "";
String vehicleColor = "";
String vehicleModel = "";
String vehicleNumber = "";
