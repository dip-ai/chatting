import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
  final String image;
  const CircleContainer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 120,
            width: 120,
            // clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple,
            ),
          ),
          Positioned(
            child: Image.asset(
              image,
              // scale: 1,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}
