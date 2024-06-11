
import 'package:google_fonts/google_fonts.dart';
import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/global/global_var.dart';
import 'package:ridewave_riders/models/trip_details.dart';
import 'package:flutter/material.dart';


class CobaDialog extends StatefulWidget {
  TripDetails? tripDetailsInfo;

  CobaDialog({
    super.key,
    this.tripDetailsInfo,
  });

  @override
  State<CobaDialog> createState() => _CobaDialogState();
}

class _CobaDialogState extends State<CobaDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: kPrimaryColor,
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                  "NEW TRIP REQUEST",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: whiteColor,
                  ),
                ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //title
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage(
                        "images/avatarman.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Angger Ilham",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: whiteColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "STEI-K",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            //pick - dropoff
            Center(
              // padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  //pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_pin, color: whiteColor, size: 16,),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          "ITB Jatinangor",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  //dropoff
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_pin, color: whiteColor, size: 16,),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Text(
                          "Kopilah!",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.poppins(
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //decline btn - accept btn
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        audioPlayer.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        side: const BorderSide(color: Colors.white,
                        width: 2,
                        ),
                      ),
                      child: const Text(
                        "DECLINE",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // audioPlayer.stop();

                        // setState(() {
                        //   tripRequestStatus = "accepted";
                        // });

                        // checkAvailabilityOfTripRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        side: const BorderSide(color: Colors.white,
                        width: 2,
                        ),
                      ),
                      child: const Text(
                        "ACCEPT",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
