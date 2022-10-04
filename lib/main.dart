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
      body: CurvedSliderWidget(
          backgroundColor: Colors.grey,
          height: 500,
          width: 300,
          scaleMin: 0,
          scaleMax: 200,
          startAngle: radians(-90),
          endAngle: radians(0)),
    ),
  ));
}

/// Slider State with variables to be accessed within SliderTextWidgetState
class CurvedSliderValues extends Object {
  static double scaleMin = 0;
  static double scaleMax = 90;
  static double rY = 100;
  static double rX = 100;
  static double theta = radians(-90);

  static double startAngle = radians(-90);
  static double endAngle = radians(0);
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
  static Color backgroundColor = Colors.white;

  static Function activeCallback = (() {});
  static Function inactiveCallback = (() {});

  static void setThumbPositionFromTheta() {
    if (CurvedSliderValues.theta > CurvedSliderValues.endAngle) {
      CurvedSliderValues.theta = CurvedSliderValues.endAngle;
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
}

/// SliderTextWidget allows us to pass and set state between SliderWidget and Text
class CurvedSliderWidget extends StatefulWidget {
  //Constructor with required named parameter
  // ignore: use_key_in_widget_constructors
  CurvedSliderWidget(
      {required Color backgroundColor,
      required double height,
      required double width,
      required double scaleMin,
      required double scaleMax,
      required double startAngle,
      required double endAngle}) {
    SliderValues.backgroundColor = backgroundColor;
    CurvedSliderValues.rY = height;
    CurvedSliderValues.rX = width;
    CurvedSliderValues.scaleMin = scaleMin;
    CurvedSliderValues.scaleMax = scaleMax;

    CurvedSliderValues.startAngle = startAngle;
    CurvedSliderValues.endAngle = endAngle;
    CurvedSliderValues.theta = startAngle;
    SliderValues.setThumbPositionFromTheta();
  }
  @override
  _CurvedSliderWidgetState createState() => _CurvedSliderWidgetState();
}

class _CurvedSliderWidgetState extends State<CurvedSliderWidget> {
  int interpolatedValue = SliderValues.thumbX.toInt();
  Color textColor = SliderValues.inactiveColor;

  void _calculateInterpolation() {
    interpolatedValue = ((((SliderValues.thumbX - SliderValues.sliderMin) *
                    (CurvedSliderValues.scaleMax -
                        CurvedSliderValues.scaleMin)) /
                (SliderValues.sliderMax - SliderValues.sliderMin)) +
            CurvedSliderValues.scaleMin)
        .toInt();
  }

  //Sets new string for Text() to display and color when active
  void _setActive() {
    setState(() {
      _calculateInterpolation();
      textColor = SliderValues.activeColor;
    });
  }

  //Changes color to inactive and does not update x
  void _setInactive() {
    setState(() {
      textColor = SliderValues.inactiveColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(100.0),
        child: Column(children: [
          Container(
              height: CurvedSliderValues.rY,
              width: CurvedSliderValues.rX,
              color: SliderValues.backgroundColor,
              child: CurvedSlider(
                activeCallback: _setActive,
                inactiveCallback: _setInactive,
                activeColor: SliderValues.activeColor,
              )),
          Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text("X Value is $interpolatedValue",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textColor)))
        ]));
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

  void _setThumbPositionFromLocalPt(double positionX, double positionY) {
    CurvedSliderValues.theta = atan((positionY - SliderValues.centerY) /
        (positionX - SliderValues.centerX)); //in radians

    SliderValues.setThumbPositionFromTheta();
  }

  //Checks if the thumb is active or if it should become active
  void _activateSlider(PointerEvent details) {
    setState(() {
      if (SliderValues.active) {
        //this is a UX choice to continue moving even if the thumb is not on the slider
        _setThumbPositionFromLocalPt(
            details.localPosition.dx, details.localPosition.dy);
        SliderValues.activeCallback.call();
      } else if (_isClickOnThumb(
          details.localPosition.dx, details.localPosition.dy)) {
        SliderValues.active = true;
        _setThumbPositionFromLocalPt(
            details.localPosition.dx, details.localPosition.dy);
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
