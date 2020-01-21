import 'dart:async';
import 'dart:math';

import 'package:block_clock/clock_app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class AnalogGearClock extends StatefulWidget {
  final ClockModel model;

  const AnalogGearClock(this.model);

  @override
  _AnalogGearClockState createState() => _AnalogGearClockState();
}

class _AnalogGearClockState extends State<AnalogGearClock> with TickerProviderStateMixin {

  DateTime _dateTime = DateTime.now();
  Timer _timer;

  /// Total distance traveled by a second or a minute hand, each second or minute,
  /// respectively.
  final radiansPerTick = pi / 30;

  /// Total distance traveled by an hour hand, each hour, in radians.
  final radiansPerHour = pi / 6;

  int gear1, gear2, gear3;

  AnimationController _controllerBackground;
  AnimationController _controllerWeatherSpinnerChange;

  WeatherCondition _weatherCondition = WeatherCondition.sunny;

  final Map weatherIcon = {
    WeatherCondition.snowy: ClockApp.snow_heavy,
    WeatherCondition.cloudy: ClockApp.clouds,
    WeatherCondition.sunny: ClockApp.sun,
    WeatherCondition.foggy: ClockApp.fog_cloud,
    WeatherCondition.rainy: ClockApp.rain,
    WeatherCondition.thunderstorm: ClockApp.cloud_flash,
    WeatherCondition.windy: ClockApp.windy,
  };

  final Map weatherSpeed = {
    WeatherCondition.snowy: Offset(5, 10),
    WeatherCondition.cloudy: Offset(10, 5),
    WeatherCondition.sunny: Offset(10, -10),
    WeatherCondition.foggy: Offset(5, 10),
    WeatherCondition.rainy: Offset(5, 10),
    WeatherCondition.thunderstorm: Offset(10, 5),
    WeatherCondition.windy: Offset(10, 10),
  };

  final weatherTotal = 20;

  @override
  void initState() {
    super.initState();

    _dateTime = DateTime.now();

    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();

    gear1 = _dateTime.second;
    gear2 = gear1 ~/ 4;
    gear3 = gear1 ~/ 10;

    gear1 = _dateTime.minute * 60 + _dateTime.second; // max 3600
    gear2 = (_dateTime.minute * 60 + _dateTime.second) % 320;     // max 320 =
    gear3 = _dateTime.second % 30;  // max 30

    _controllerBackground = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1)
    )..repeat(min: 0, max: 1);

    _controllerWeatherSpinnerChange = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controllerWeatherSpinnerChange.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _weatherCondition = widget.model.weatherCondition;
        _randomBackgroundIcon(context, weatherTotal, weatherSpeed[_weatherCondition]);
        setState(() {

        });
        _controllerWeatherSpinnerChange.reverse(from: 1);
      }
    });

  }


  @override
  void didUpdateWidget(AnalogGearClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }


  @override
  void dispose() {
    _controllerWeatherSpinnerChange.dispose();
    _controllerBackground.dispose();

    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();

    super.dispose();
  }


  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.

    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );


      /*
      // try next weather
      if (_dateTime.second % 5 == 0) {
        randomWeather();
      }

      if (_dateTime.second % 6 == 0) {
        //randomTemp();
      }

       */
    });
  }


  void randomTemp() {
    Random random = new Random();
    double distance = 5 + (random.nextInt(50) / 10);
    widget.model.low = random.nextInt(20).toDouble();
    widget.model.high = widget.model.low + distance;
    widget.model.temperature = widget.model.low + random.nextInt((distance * 10).toInt()) / 10;
  }

  int _currentWeatherIndex = -1;
  void randomWeather() {
    _currentWeatherIndex++;

    if (_currentWeatherIndex >= WeatherCondition.values.length)
      _currentWeatherIndex = 0;

    widget.model.weatherCondition = WeatherCondition.values[_currentWeatherIndex];
  }

  @override
  Widget build(BuildContext context) {

    for (int i = 0; i < offsets.length; i++) {
      offsets[i] += speeds[i];
    }
    
    if (widget.model.weatherCondition != _weatherCondition) {
      if (_controllerWeatherSpinnerChange.isAnimating == false) {
        _controllerWeatherSpinnerChange.forward(from: 0).then((void v) {
        });
      }
    }

    return Stack(
          children: <Widget>[
            //_createBackground(context, weatherIcon[_weatherCondition], 32 ),
            _createStaticBackground(),

            Positioned(left: 100, child: _createWeatherWidget(context)),
            Positioned(left: 100, child: _createTempWidget(context)),
            Positioned(left: 100, child: _createClockWidget(context)),
          ],
        );
  }

  List<Offset> offsets = new List<Offset>();
  List<Offset> speeds = new List<Offset>();

  Widget _createStaticBackground() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              colors: [Color(0xffd3c5a8), Color(0xff444444)])),
    );
  }

  void _randomBackgroundIcon(BuildContext context, int total, Offset speed) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    Random random = new Random();
    for (int i = 0; i < total; i++) {
      offsets.add(Offset(random.nextInt(width.toInt()).toDouble(),
          random.nextInt(height.toInt()).toDouble()));
      speeds.add(speed);
    }
  }

  List<Widget> _createBackgroundIcon(BuildContext context, IconData iconData, double size) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    List<Widget> widgets = new List<Widget>();

    for (int i = 0; i < offsets.length; i++) {
        widgets.add(
            AnimatedPositioned(
              child: Icon(iconData, color: Color(0x66d3c5a8), size: size,),
              duration: Duration(seconds: 1),
              top: offsets[i].dy,
              left: offsets[i].dx,
              onEnd: () {
                if (offsets[i].dx < -size) {
                  speeds[i] = Offset(speeds[i].dx.abs(), speeds[i].dy);
                }
                else if (offsets[i].dx >= width) {
                  speeds[i] = Offset(-1 * speeds[i].dx.abs(), speeds[i].dy);
                }

                if (offsets[i].dy < -size) {
                  speeds[i] = Offset(speeds[i].dx, speeds[i].dy.abs());
                }
                else if (offsets[i].dy >= height) {
                  speeds[i] = Offset(speeds[i].dx, -1 * speeds[i].dy.abs());
                }
              },
            )
        );
    }

    return widgets;
  }

  Widget _createBackground(BuildContext context, IconData iconData, double size) {
    double width =  MediaQuery.of(context).size.width;
    double height =  MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              colors: [Color(0xffd3c5a8), Color(0xff444444)])),
      child: Stack(
        children: _createBackgroundIcon(context, iconData, size),
      ),
    );
  }



  Widget _createWeatherWidget(BuildContext context) {
    double width = MediaQuery.of(context).size.height - kToolbarHeight * 0.5;
    double center = width * 0.5;

    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
        width: width,
        height: width,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
                right: -60,
                bottom: 25,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xff444444)),
            )),

            Positioned(
              right: -40,
              bottom: 80,
              child: AnimatedBuilder(
                    animation: _controllerWeatherSpinnerChange,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xffd3c5a8)),
                      child: Icon( weatherIcon[_weatherCondition],
                        size: 24, color: Color(0xff444444),),
                    ),
                    builder: (BuildContext context, Widget child) {
                      return Transform.rotate(
                        angle: -pi * 0.5 * _controllerWeatherSpinnerChange.value, child: child,
                        origin: Offset(-40, 40),
                      );
                    })
            ),

            //widget,

            Positioned(
              left: center + 25,
              bottom: 10,
              width: 300,
              child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Color(0xff444444),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: FittedBox(fit: BoxFit.fitWidth, child: Text(
                ' ' + widget.model.location + ' ',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xffd3c5a8),
                ),
              )),
              padding:
              EdgeInsets.only(left: 100, top: 10, bottom: 10, right: 10),
            )),
          ],
        ));
  }


  Widget _createTempWidget(BuildContext context) {
    double width = MediaQuery.of(context).size.height - kToolbarHeight * 0.5;
    double center = width * 0.5;

    double low = widget.model.low;
    double high = widget.model.high;
    double temperatur = widget.model.temperature;

    double ratio = (temperatur - low) / (high - low);

    // angle start from 0 to 0.25 * pi
    double angle = ratio * -0.25;

    double left = center + (center * 1.15 * cos(pi * angle));

    double top = center  - 10 + (center * 1.15 * sin(pi * angle));

    return Stack(
        overflow: Overflow.visible,
      children: <Widget>[
        Transform.rotate(angle: pi * angle, child: Container(
            width: width,
            height: width,
            child: Align(
              alignment: Alignment.centerRight,
                child: Transform.rotate(angle: pi * 0.25, child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration( shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0xff444444), ),
            )))
        )),

        Positioned(left: width * 1.05, top: center - 10,
            child: Container( color: Color(0xff444444), child: Text(
              (temperatur - 0.1 <= low) ? '' :  ' ' + String.fromCharCode(0x2193) + ' ' + low.toString() + ' ',
              style: TextStyle(fontSize: 16, color: Color(0xffd3c5a8) ),))),

        Positioned(left: width * 0.9, top: center * 0.1,
            child: Container( color: Color(0xff444444), child: Text(
              (temperatur + 0.1 >= high) ? '' : ' ' + String.fromCharCode(0x2191) + ' ' + high.toString() + ' ',
              style: TextStyle(fontSize: 16, color: Color(0xffd3c5a8) ),))),

        Positioned(left: left, top: top,
            child: Container( color: Color(0xff444444), child: Text(
              ' ' + temperatur.toString() + ' ',
              style: TextStyle(fontSize: 24, color: Color(0xffd3c5a8) ),))),


      ]);
  }

  Widget _createClockWidget(BuildContext context) {

    gear1 = _dateTime.minute * 60 + _dateTime.second; // max 3600
    gear2 = (_dateTime.minute * 60 + _dateTime.second) % 320;     // max 320 =
    gear3 = _dateTime.second % 30;  // max 30


    double gear1Tick = 2 * pi / 3600;
    double gear2Tick = -2 * pi / 320;
    double gear3Tick = 2 * pi / 30;

    double width = MediaQuery.of(context).size.height - kToolbarHeight * 0.5;
    double center = width * 0.5 - 20;

    return Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff444444),
        ),
        child: Container(
            margin: EdgeInsets.all(20),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Color(0xfffbf8f0)),
            child: Stack(children: <Widget>[

              Positioned(
                  top: center - 32 + 103,
                  left: center - 32,
                  child: Transform.rotate(
                      angle: gear3 * gear3Tick,
                      child: Icon(ClockApp.gear4, size: 64, color: Color(0xff444444),))
              ),

              Positioned(
                  top: center - 9 + 103,
                  left: center - 9,
                  child: Transform.rotate(
                      angle: gear3 * gear3Tick,
                      child: Icon(ClockApp.gear3, size: 18, color: Color(0xffd3c5a8),))
              ),

              Positioned (
                  top: center - 10 + 59,
                  left: center - 10 - 38,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xff444444)),
                  )
              ),

              Positioned(
                  top: center - 50 + 59.5,
                  left: center - 50 - 38.5,
                  child: Transform.rotate(
                      angle: gear2 * gear2Tick,
                      child: Icon(ClockApp.gear2, size: 100, color: Color(0xffd3c5a8),))
              ),

              Positioned(
                top: center - 64,
                  left: center - 64,
                  child: Transform.rotate(
                      angle: gear1 * gear1Tick,
                      child: Icon(ClockApp.gear1, size: 128, color: Color(0xff444444),))
              ),


              Center(
                  child: Container(
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xff444444)),
              )),


              // clock tick,
              // we can use 'for', but we need to update dart to version 2.3.0
              _clockTick(0),
              _clockTick(radiansPerHour * 1),
              _clockTick(radiansPerHour * 2),
              _clockTick(radiansPerHour * 3),
              _clockTick(radiansPerHour * 4),
              _clockTick(radiansPerHour * 5),
              _clockTick(radiansPerHour * 6),
              _clockTick(radiansPerHour * 7),
              _clockTick(radiansPerHour * 8),
              _clockTick(radiansPerHour * 9),
              _clockTick(radiansPerHour * 10),
              _clockTick(radiansPerHour * 11),

              // clock hand
              _clockHand(_dateTime.minute * radiansPerTick, true),
              _clockHand(_dateTime.hour * radiansPerHour + (_dateTime.minute / 60) * radiansPerHour, false),

              Center(
                  child: Container(
                height: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xff8d8677)),
              )),

              Center(
                  child: Container(
                height: 20,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xff444444)),
              )),

            ])));
  }

  Widget _clockHand(double angle, longHand) {
    return Transform.rotate(
        angle: angle,
        origin: Offset(0, 0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
                bottom: 100,
                top: longHand ? 20 : 60,
                child: Container(
                  width: 15,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Color(0xff8d8677),
                      borderRadius: BorderRadius.circular(10)),
                )),
            Positioned(
                bottom: 100,
                top: longHand ? 20 : 60,
                child: Container(
                  width: 30,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xff8d8677)),
                      )),
                )),
          ],
        ));
  }

  Widget _clockTick(double angle) {
    return Transform.rotate(
        angle: angle,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Positioned(
            top: -10,
            child: Container(
              width: 10,
              height: 25,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Color(0xff444444),
                  borderRadius: BorderRadius.circular(10)),
            ),
          )
        ]));
  }

  Widget _clockGear(angle) {
    return Stack(alignment: Alignment.center, children: <Widget>[
          Positioned(
            top: -10,
            child: Transform.rotate(
              angle: angle, child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff444444),),
              child: Align(alignment: Alignment.bottomCenter, child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff8d8677),),
              )),
            ),
          ))
        ]);
  }
}
