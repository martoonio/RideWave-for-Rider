import 'package:ridewave_riders/constants.dart';
import 'package:ridewave_riders/global/global_var.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ridewave_riders/widgets/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController carTextEditingController = TextEditingController();

  setDriverInfo() {
    setState(() {
      nameTextEditingController.text = riderName;
      phoneTextEditingController.text = riderPhone;
      emailTextEditingController.text =
          FirebaseAuth.instance.currentUser!.email.toString();
      carTextEditingController.text =
          "$vehicleNumber - $vehicleColor - $vehicleModel";
    });
  }

  @override
  void initState() {
    super.initState();

    setDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //image
              Container(
                width: 180,
                height: 180,
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
                height: 16,
              ),
              const SizedBox(
                height: 10,
              ),
              //driver name
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
                child: TextField(
                  controller: nameTextEditingController,
                  textAlign: TextAlign.start,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              //driver phone
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: phoneTextEditingController,
                  textAlign: TextAlign.start,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android_outlined,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              //driver email
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: emailTextEditingController,
                  textAlign: TextAlign.start,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              //driver car info
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: carTextEditingController,
                  textAlign: TextAlign.start,
                  enabled: false,
                  style: const TextStyle(fontSize: 16, color: kPrimaryColor),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: kPrimaryColor,
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.motorcycle,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              //logout btn
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 18)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.logout,
                      color: whiteColor,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text("Logout",
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 2.2,
                          color: whiteColor,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
