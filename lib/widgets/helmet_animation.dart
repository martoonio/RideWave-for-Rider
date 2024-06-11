import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelmetAnimation extends StatefulWidget {
  const HelmetAnimation({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _HelmetAnimationState createState() => _HelmetAnimationState();
}

class _HelmetAnimationState extends State<HelmetAnimation> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      // Navigator.pop(context);
      // Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: height * 0.4,
          decoration: BoxDecoration(
            // color: const Color.fromARGB(31, 92, 90, 90),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/sloganHelmet.png',
                height: height * 0.1,
              ),
              SizedBox(
                child: Lottie.asset('images/helmet.json'),
              ),
            ],
          ),
        ));
  }
}
