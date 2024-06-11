import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restart_app/restart_app.dart';
import 'package:ridewave_riders/constants.dart';

// ignore: must_be_immutable
class InfoDialog extends StatefulWidget {
  String? title, description;

  InfoDialog({super.key, this.title, this.description});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: kPrimaryColor, width: 3)
      ),
      backgroundColor: Colors.grey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kSecondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                Text(
                  widget.title.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 27,
                ),
                Text(
                  widget.description.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: 202,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Restart.restartApp();
                    },
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(style: BorderStyle.solid, color: whiteColor, width: 3), backgroundColor: kPrimaryColor,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))), // Set button color to kPrimaryColor
                      elevation: 10,
                    ),
                    child:  Text(
                      "OK",
                      style: GoogleFonts.jost(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}