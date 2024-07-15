import 'package:chat_app/first%20page/config/circle_container.dart';
import 'package:chat_app/first%20page/config/rec_container.dart';
import 'package:chat_app/second%20page/contact_page.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 50),
            const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RecContainer(image: "assets/images/woman.jpg"),
                    SizedBox(width: 20),
                    CircleContainer(image: "assets/images/woman2.jpg"),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleContainer(image: "assets/images/man1.jpg"),
                    SizedBox(width: 20),
                    RectContainer(image: "assets/images/man2.webp"),
                  ],
                ),
              ],
            ),
            Container(
              color: Colors.white38,
              child: const Column(
                children: [
                  SizedBox(height: 90),
                  Text(
                    "Enjoy the new experience of chatting with global friends",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Connect people around the world for free",
                    style: TextStyle(fontSize: 16, color: Colors.black38),
                  ),
                  SizedBox(height: 90),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContactPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A1BF8), // Button color
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0), // Button height
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white, // Text color
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Powered by ",
                  style: TextStyle(color: Color(0xFF9C27B0), fontSize: 12),
                ),
                Image.asset(
                  "assets/images/option.png",
                  color: const Color(0xFF5A1BF8),
                  height: 10,
                  width: 10,
                ),
                const Text(
                  " usage",
                  style: TextStyle(
                      color: Color(0xFF673AB7),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
