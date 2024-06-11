import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/global/global_var.dart';
import 'package:ridewave_riders/pages/about_page.dart';
import 'package:ridewave_riders/pages/earnings_page.dart';
import 'package:ridewave_riders/pages/profile_page.dart';
import 'package:ridewave_riders/pages/trips_history_page.dart';
import 'package:ridewave_riders/widgets/logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Menu",
            style: GoogleFonts.poppins(
                fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: kPrimaryColor,
          // elevation: 10,
        ),
        backgroundColor: whiteColor,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      riderPhoto,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              riderName,
                              style: GoogleFonts.jost(
                                  fontSize: 25,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              riderFaculty,
                              style: GoogleFonts.jost(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ProfilePage()));
                                    },
                                    child: Text(
                                      "Edit Profile",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.payment,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const EarningsPage()));
                                    },
                                    child: Text(
                                      "Earnings",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TripsHistoryPage()));
                                    },
                                    child: Text(
                                      "History",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.report,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => const PaymentPage()));
                                    },
                                    child: Text(
                                      "Report",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.info,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const AboutPage()));
                                    },
                                    child: Text(
                                      "About Us",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.settings,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => const PaymentPage()));
                                    },
                                    child: Text(
                                      "Settings",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.help,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => const PaymentPage()));
                                    },
                                    child: Text(
                                      "Help and Support",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return LogOutDialog(
                                              title: "Logout",
                                              description:
                                                  "Are you sure you want to logout?",
                                            );
                                          });
                                    },
                                    child: Text(
                                      "Logout",
                                      style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: Colors.red,
                                          fontWeight: FontWeight.normal),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ));
  }
}
