import 'package:flutter/material.dart';

class BackgroundDesign extends StatefulWidget {
  const BackgroundDesign({Key? key}) : super(key: key);

  @override
  State<BackgroundDesign> createState() => _BackgroundDesignState();
}

class _BackgroundDesignState extends State<BackgroundDesign> {
  Widget build(BuildContext context) {
    var safePadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(

          appBar: AppBar(
            toolbarHeight: 56,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            actions: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Material(
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: Colors.grey.withOpacity(0.5),
                            child: const Icon(Icons.keyboard_arrow_left,
                                color: Color.fromARGB(255, 25, 61, 94)),
                            onTap: () {
                              Future.delayed(
                                const Duration(milliseconds: 50),
                                    () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'App Bar',
                      style: TextStyle(
                          color: Color.fromARGB(255, 25, 61, 94),
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height:
                (MediaQuery.of(context).size.height - 56 - safePadding) *
                    0.4,
                color: const Color.fromARGB(255, 25, 61, 94),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(75),
                      topRight: Radius.circular(0),
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                height:
                (MediaQuery.of(context).size.height - 56 - safePadding) *
                    0.6,
                child: Container(
                  padding: const EdgeInsets.only(right: 30, left: 30),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(75),
                      ),
                      color: Color.fromARGB(255, 25, 61, 94)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

