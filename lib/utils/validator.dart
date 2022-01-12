import 'package:flutter/material.dart';

class Validator {
  String? validateName(String value) {
    String pattern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return '';
  }

  Future<String?> validateMobile(String value) async {
    String pattern = r'(^[0-9]*$)';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "Mobile is Required";
    } else if (value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return '';
  }

  String? validatePasswordLength(String value){
    if(value.isEmpty){
      return "This field is required.";
    } else if (value.length < 8){
      return "Password must be longer than 8 characters";
    }
    return '';
  }

  String? validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return "This field is required.";
    } else if (!regExp.hasMatch(value)) {
      return "Please input valid Email address";
    } else {
      return '';
    }
  }
}
