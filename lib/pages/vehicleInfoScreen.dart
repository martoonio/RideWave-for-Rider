// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/pages/dashboard.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final vehicleNameTextEditingController = TextEditingController();
  final vehicleNumberTextEditingController = TextEditingController();
  final vehicleColorTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  _submit() {
    if (_formKey.currentState!.validate()) {
      Map riderVehicleInfoMap = {
        "vehicleModel": vehicleNameTextEditingController.text.trim(),
        "vehicleNumber": vehicleNumberTextEditingController.text.trim(),
        "vehicleColor": vehicleColorTextEditingController.text.trim(),
      };

      User? user = FirebaseAuth.instance.currentUser;

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("riders");
      userRef
          .child(user!.uid)
          .child("vehicle_details")
          .set(riderVehicleInfoMap);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: kPrimaryColor,
            elevation: 0,
            title: Text(
              "Register Vehicle",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        backgroundColor: kPrimaryColor,
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Text(
                  "Enter your vehicle details",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Plat Nomor",
                                  hintStyle: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                        color: Colors.white),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.motorcycle_rounded,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please enter the vehicle number';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  vehicleNumberTextEditingController.text =
                                      text;
                                }),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Merk Motor",
                                  hintStyle: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                        color: Colors.white),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.motorcycle_rounded,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please enter the vehicle number';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  vehicleNameTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Warna Motor",
                                  hintStyle: GoogleFonts.poppins(
                                    color: kPrimaryColor,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                        color: Colors.white),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.motorcycle_rounded,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Please enter the vehicle color';
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  vehicleColorTextEditingController.text = text;
                                }),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF054C67),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    side: BorderSide(
                                        color: Colors.white,
                                        width:
                                            3), // Add this line for the white border
                                  ),
                                  minimumSize: Size(200, 50),
                                ),
                                onPressed: () {
                                  _submit();
                                },
                                child: Text(
                                  "Continue",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors
                                        .white, // Add text color to ensure visibility
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
