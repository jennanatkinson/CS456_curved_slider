import 'dart:math';

import 'package:curved_slider/slider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Working Slider'),
        backgroundColor: Colors.grey,
      ),
      body: CurvedSliderWidget(height: 200, width: 300),
    ),
  ));
}

/// Slider State with variables to be accessed within SliderTextWidgetState
class CurvedSliderValues extends Object {
  // static double scaleMin = 0;
  // static double scaleMax = 400;
  static double rY = 100;
  static double rX = 100;
  static double theta = radians(90);
}

/// Slider State with variables to be accessed within CurvedSliderState and Slider Painter
class SliderValues extends Object {
  static double thumbX = 0.0;
  static double thumbY = 0.0;
  static double centerX = 0.0;
  static double centerY = CurvedSliderValues.rY;
  static double sliderMin = 0.0;
  static double sliderMax = 0.0; //will be set by slider_painter
  static const double thumbRadius = 15.0;

  static bool active = false;
  static Color activeColor = Colors.blue;
  static Color inactiveColor = Colors.black;

  static Function activeCallback = (() {});
  static Function inactiveCallback = (() {});
}

/// SliderTextWidget allows us to pass and set state between SliderWidget and Text
class CurvedSliderWidget extends StatefulWidget {
  //Constructor with required named parameter
  // ignore: use_key_in_widget_constructors
  CurvedSliderWidget(
      {required double height,
      required double width /*, required double xMin, required double xMax*/}) {
    CurvedSliderValues.rY = height;
    CurvedSliderValues.rX = width;
    // CurvedSliderValues.scaleMin = xMin;
    // CurvedSliderValues.scaleMax = xMax;
  }
  @override
  _CurvedSliderWidgetState createState() => _CurvedSliderWidgetState();
}

class _CurvedSliderWidgetState extends State<CurvedSliderWidget> {
  int xDisplay = SliderValues.thumbX.toInt();
  Color textColor = SliderValues.inactiveColor;

  //Sets new string for Text() to display and color when active
  void _setActive() {
    setState(() {
      // xDisplay = ((((SliderValues.thumbX - SliderValues.sliderMin) *
      //                 (CurvedSliderValues.scaleMax -
      //                     CurvedSliderValues.scaleMin)) /
      //             (SliderValues.sliderMax - SliderValues.sliderMin)) +
      //         CurvedSliderValues.scaleMin)
      //     .toInt();
      // textColor = SliderValues.activeColor;
    });
  }

  //Changes color to inactive and does not update x
  void _setInactive() {
    setState(() {
      // textColor = SliderValues.inactiveColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 500.0, top: 500.00),
        child: Container(
          height: CurvedSliderValues.rY,
          width: CurvedSliderValues.rX,
          color: Colors.blue,
          child: CurvedSlider(
            activeCallback: _setActive,
            inactiveCallback: _setInactive,
            activeColor: Colors.purple,
          ),
          // Padding(
          //     padding: const EdgeInsets.all(30.0),
          //     child: Text("X Value is $xDisplay",
          //         style: TextStyle(
          //             fontWeight: FontWeight.bold,
          //             fontSize: 40,
          //             color: textColor)))
        ));
  }
}

/// CurvedSlider Stateful Widget
class CurvedSlider extends StatefulWidget {
  //Constructor with named optional parameter
  CurvedSlider(
      {Function? activeCallback,
      Function? inactiveCallback,
      required Color activeColor}) {
    if (activeCallback != null) {
      SliderValues.activeCallback = activeCallback;
    }
    if (inactiveCallback != null) {
      SliderValues.inactiveCallback = inactiveCallback;
    }
    SliderValues.activeColor = activeColor;
  }

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

class _CurvedSliderState extends State<CurvedSlider> {
  //Checks to see if the finger down actually touches the slider's thumb
  bool _isClickOnThumb(double x, double y) {
    double dist = sqrt(
        pow(SliderValues.thumbX - x, 2) + pow((SliderValues.thumbY) - y, 2));
    //after experimentation, this formula was the most accurately responsive to an actual finger
    return dist <= SliderValues.thumbRadius * 5;
  }

  void setThumbPosition(double positionX, double positionY) {
    CurvedSliderValues.theta = atan((positionY - SliderValues.centerY) /
        (positionX - SliderValues.centerX)); //in radians
    if (CurvedSliderValues.theta > 0) {
      CurvedSliderValues.theta = 0;
    }
    double r = (CurvedSliderValues.rX * CurvedSliderValues.rY) /
        sqrt((pow(CurvedSliderValues.rX, 2) *
                pow(sin(CurvedSliderValues.theta), 2)) +
            (pow(CurvedSliderValues.rY, 2) *
                pow(cos(CurvedSliderValues.theta), 2)));
    SliderValues.thumbX =
        (r * cos(CurvedSliderValues.theta)) + SliderValues.centerX;
    SliderValues.thumbY =
        (r * sin(CurvedSliderValues.theta)) + SliderValues.centerY;
  }

  //Checks if the thumb is active or if it should become active
  void _activateSlider(PointerEvent details) {
    setState(() {
      if (SliderValues.active) {
        //this is a UX choice to continue moving even if the thumb is not on the slider
        setThumbPosition(details.localPosition.dx, details.localPosition.dy);
        SliderValues.activeCallback.call();
      } else if (_isClickOnThumb(
          details.localPosition.dx, details.localPosition.dy)) {
        SliderValues.active = true;
        setThumbPosition(details.localPosition.dx, details.localPosition.dy);
        SliderValues.activeCallback.call();
      }
    });
  }

  //Sets slider to inactive
  void _deactivateSlider(PointerEvent details) {
    setState(() {
      SliderValues.active = false;
      SliderValues.inactiveCallback.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Listener(
          //override listeners
          onPointerDown: _activateSlider,
          onPointerUp: _deactivateSlider,
          onPointerMove: _activateSlider,
          child: CustomPaint(
            painter: SliderPainter(), //painter widget
          )),
    );
  }
}
