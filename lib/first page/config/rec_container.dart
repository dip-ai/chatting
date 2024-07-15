import 'package:flutter/material.dart';

class RecContainer extends StatelessWidget {
  final String image;
  const RecContainer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(150),
            bottomRight: Radius.circular(150),
            topRight: Radius.circular(150)),
        color: Colors.deepPurple,
      ),
      child: Image.asset(
        image,
        fit: BoxFit.contain,
      ),
    );
  }
}

class RectContainer extends StatelessWidget {
  final String image;
  const RectContainer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 120,
          height: 120,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(150),
                topLeft: Radius.circular(150),
                bottomLeft: Radius.circular(150)),
            color: Colors.deepPurple,
          ),
        ),
        Positioned(
          top: -10,
          // right: 0,
          // left: 0,
          bottom: 2,
          child: Image.asset(
            image,
            height: 50,
            width: 100,
            // scale: 1,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
