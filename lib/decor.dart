import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Decor {
  //function to add border and rounded edges to our form
  static OutlineInputBorder inputformdeco() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
          width: 1.0, color: Colors.blue, style: BorderStyle.solid),
    );
  }

//custom text styler
  static TextStyle textStyler(
      {required double size, Color color = Colors.black}) {
    return TextStyle(fontSize: size, color: color);
  }

//custom notification logic
  static notification(
      {required String text,
      Color color = Colors.white,
      required context,
      double margin = 20}) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(text),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: EdgeInsets.only(
            //bottom: MediaQuery.of(context).size.height - 200, //(makes notifications appear from top)
            right: margin,
            left: margin),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: color,
      ));
  }

//makes the haptics feel more realistic
  static doubleHaptics({milliseconds = 250}) {
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(milliseconds: milliseconds))
        .then((value) => HapticFeedback.heavyImpact());
  }
}

class ScaledBox extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const ScaledBox(
      {Key? key,
      required this.child,
      required this.height,
      required this.width})
      : super(key: key);

  Widget build(BuildContext context) {
    return SizedBox(
        height: height, width: width, child: FittedBox(child: child));
  }
}
