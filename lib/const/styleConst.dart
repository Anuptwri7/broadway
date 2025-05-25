import 'dart:async';

import 'package:flutter/material.dart';
const kHeightMedium = SizedBox(
  height: 16,
);
const kHeightSmall = SizedBox(
  height: 8,
);
const kCardElevation = 8.0;
const kMarginPaddMedium = EdgeInsets.all(16.0);
const kMarginPaddSmall = EdgeInsets.all(8.0);

const kFormFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  labelStyle: TextStyle(color: Colors.grey,fontSize: 14),
  hintStyle: TextStyle(color: Colors.grey,fontSize: 14),
  hintText: 'Enter a Value',
  contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
  border: OutlineInputBorder(

    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
  ),
);