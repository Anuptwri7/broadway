import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../const/strinConst.dart';
import '../const/styleConst.dart';
import '../models/weather.dart';
import 'apiServiceWeather.dart';
import 'notificationWeather.dart';


String addressByPlace = '';
String formattedTemperatureCurrentTemp = '';
int visibility = 0;
double temperatureFeelsLike = 0.0;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  TextEditingController hour =TextEditingController();
  TextEditingController min =TextEditingController();
  String locationMessage = '';
  String address = '';
  String description = '';
  double wind = 0.0;
  double temperature = 0.0;
  ApiServices apiServices = ApiServices();

  void getLocation() async {
    try {
      var permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage =
          'Location permission denied. Enable it in app settings.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        locationMessage =
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        getAddress(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        locationMessage = 'Error getting location: $e';
      });
    }
  }

  Future<String?> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          Placemark placemark = placemarks[0];
          address =
          "${placemark.street}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}";
          addressByPlace = "${placemark.street}, ${placemark.locality}";
        });
        return address;
      } else {
        return "No address found";
      }
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

  double latitude = 0.0;
  double longitude = 0.0;
  String apiKey = '31cae416c96a430580fec55352eb2f00';
  late String formattedDate;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    final now = DateTime.now();
    formattedDate = DateFormat('hh:mm a - E, d MMM yyyy').format(now);
    Notific.initialize(flutterLocalNotificationsPlugin);
  }

  void setReminder()async {
    Notific.scheduleCustomNotification(
      fln: flutterLocalNotificationsPlugin,
      reminderTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, int.parse(hour.text), int.parse(min.text)), // 3:30 PM
    );
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:100,left: 10),
                    child: Text(
                      addressByPlace,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:10,left: 10),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:40,left: 10),
                        child: Text(
                          "${formattedTemperatureCurrentTemp}°C",
                          style: TextStyle(color: Colors.white,fontSize: 70,),

                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:40,right: 10),
                        child: Column(
                          children: [
                            Text(
                              "Wind Speed:",
                              style: TextStyle(color: Colors.white,fontSize: 15),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: Text(
                                  "${wind} m/s",
                                  style: TextStyle(color: Colors.white,fontSize: 20),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Expanded(
                    flex: 1,
                    child: FutureBuilder<List<WeatherModel>?>(
                      future: apiServices.fetchWeather(latitude, longitude, apiKey),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return CircularProgressIndicator();
                          default:
                            if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return _pickOrderCards(snapshot.data);
                            }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBar(
            actions: [

              GestureDetector(
                onTap: () => openDialogToAddTime(context),
                child: Icon(
                  Icons.access_alarm,
                  color: Colors.white,
                ),
              ),
            ],
            title: Text(
              StringConst.appBarHomePage,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Increased font size
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
        ],
      ),
    );
  }



  _pickOrderCards(List<WeatherModel>? data) {
    temperature = data![0].main!.temp!.toDouble() - 273.15;
    formattedTemperatureCurrentTemp = temperature.toStringAsFixed(0);
    temperatureFeelsLike = data[0].main!.feelsLike!.toDouble() - 273.15;
    String formattedTemperatureFeelsLike =
    temperatureFeelsLike.toStringAsFixed(0);
    visibility = data[0].visibility!;
    description = data[0].weather![0].description!;
    wind = data[0].wind!.speed!;
    return Padding(
      padding: const EdgeInsets.only(top: 400),
      child: Container(
        padding: kMarginPaddSmall,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Center(
                child: Column(
                  children: [
                    Text(
                      "Visibility :",
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                    ),
                    Text(
                      "${data[0].visibility}",
                      style: TextStyle(color: Colors.white,fontSize: 25),
                    ),
                  ],
                )),
            kHeightSmall,
            Column(
              children: [
                Text(
                  "Feels Like:",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Center(
                    child: Text(
                      "${formattedTemperatureFeelsLike}°C",
                      style: TextStyle(color: Colors.white,fontSize: 25),
                    )),
              ],
            ),
            kHeightSmall,
            Column(
              children: [
                Text(
                  "Pressure:",
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Center(
                    child: Text(
                      "${data[0].main!.pressure} mmHg",
                      style: TextStyle(color: Colors.white,fontSize: 25),
                    )),
              ],
            ),
            kHeightSmall,
          ],
        ),
      ),
    );
  }
  Future openDialogToAddTime(BuildContext context) =>
      showDialog(
        barrierColor: Colors.black38,
        context: context,

        builder: (context) => Dialog(
          backgroundColor: Colors.indigo.shade50,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  // height:600,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Set The reminder',
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex:1,
                              child: TextFormField(
                                controller: hour,
                                cursorColor: Color(0xff3667d4),
                                keyboardType: TextInputType.number,

                                style: TextStyle(color: Colors.grey),
                                decoration: kFormFieldDecoration.copyWith(

                                  hintText: 'Hour',
                                  prefixIcon: const Icon(
                                    Icons.add_box,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex:1,
                              child: TextFormField(
                                controller: min,
                                cursorColor: Color(0xff3667d4),
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.grey),
                                decoration: kFormFieldDecoration.copyWith(
                                  hintText: 'Minute',
                                  prefixIcon: const Icon(
                                    Icons.add_box,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(onPressed: (){
                          if(int.parse(hour.text)>24||hour.text.length>2){}else if(int.parse(min.text)>60||min.text.length>2){}else{
                            setReminder();
                            Navigator.pop(context);}

                        }, child: Text("Set"))
                      ],
                    ),
                  ),

                ),
              ),
              Positioned(
                  top:-35,

                  child: CircleAvatar(
                    child: Icon(Icons.ac_unit_sharp,size: 40,),
                    radius: 40,

                  )),

            ],
          ),
        ),

      );
}