import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:happy_bash/core/constants/static_words.dart';
import 'package:happy_bash/core/reusable.dart';
import 'package:happy_bash/models/event_type_model.dart';
import 'package:happy_bash/network/base_url.dart';
import 'package:happy_bash/theme/theme_helper.dart';
import 'package:happy_bash/ui/screen/onboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

import '../../core/constants/dialog_box.dart';
import '../../core/constants/navigator.dart';
import 'bottom_navigation_screen.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  List<EventTypeModel> eventTypeList = [];
  List<String> eventTypeNameList = [];
  DateTime? selectedDate;
  TimeOfDay? selectedTime;


  final List<String> typeList = ["Corporate", "Individual"];
  String? selectedType;
  String ? selectedEventType;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController occasionController = TextEditingController();
  final TextEditingController guestController = TextEditingController();
  final TextEditingController massageController = TextEditingController();

  Map<String,int> categoryIdNameMap = {};

  @override
  void initState() {
    super.initState();
    getEventTypeData();

  }

  //Date Picker Function.....
  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Color(0xFF2A9DA0), // Change the primary color of the Date Picker
              //accentColor: themeColor, // Change the accent color
              colorScheme: ColorScheme.light(primary: Color(0xFF2A9DA0)), // Change color scheme
              buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button color
            ),
            child: child!,
          );
        });

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      });
    }


  }
  //Time picker Function.....
  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      initialTime: selectedTime ?? TimeOfDay.now(),
      context: context,
      //initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF2A9DA0),
            colorScheme: const ColorScheme.light(primary: Color(0xFF2A9DA0)), // Change color scheme
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary), // Button color
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
        timeController.text = selectedTime!.format(context);
      });
    }
  }
  //Get Event Type Data from API.....
  Future<void> getEventTypeData() async {
    // you can replace your api link with this link
    // final response = await http.get(Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.eventType}"));
    final response = await http.get(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.categories}"),
      // headers: await getHeaders(),
      headers: {"content-type": "application/json"},
    );
    var responseData = jsonDecode(response.body.toString());
    if (response.statusCode == 200) {
      for (Map i in responseData) {
        categoryIdNameMap[i["name"]] = i["id"];
        eventTypeNameList.add(i["name"]);
        setState(() {
          eventTypeNameList;
        });
      }
    } else {
      // Handle error if needed
    }
  }
  //Quotation Post Api....
  Future<void> quotationPostApi() async {
    String requestData = jsonEncode({
      'name': fullNameController.text,
      'type': selectedType,
      'email': emailController.text,
      'date': dateController.text,
      'time': timeController.text,
      'area': areaController.text,
      'block': blockController.text,
      'street': streetController.text,
      'eventType': selectedEventType,
      'occasion': occasionController.text,
      'guests': guestController.text,
      'message': massageController.text,
      'event_id':categoryIdNameMap[selectedEventType]
    });
    // final response = await http.post(Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.submitInquiry}"  ,
    //   headers: {
    //     "Accept": "application/json"
    //   },
    //   body: reqParam,
    // ));
    final response = await http.post(
      Uri.parse("${BaseUrl.globalUrl}/${BaseUrl.submitInquiry}"),
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: requestData,
    );
    ModelUtils.showSimpleAlertDialog(
      context,
      title: const Text("Quotation Submitted"),
      content: "Quotation has been submitted successfully.",
      okBtnFunction: () => navigateReplaceAll(
          context,
          BottomNavigationBarScreen(
              selectedIndex: 0)),
    );
    // if (response.statusCode == 302) {
    //   var snackBar = const SnackBar(content: Text('Quotation Submitted Successfully'), );
    //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // } else {
    //   // If the request failed, handle the error
    //   print('Request failed with status: ${response.statusCode}');
    // }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColors().white,
        elevation: 1.0,
        titleSpacing: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: PrimaryColors().black900,
            size: 20,
          ),
        ),
        title: const Text(
          "Quotation",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: poppinsSemiBold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  //Full Name Field.....
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: 'Full name',
                      hintStyle: TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    cursorColor: Colors.black,
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter full name";
                      }
                      return null;
                    },
                    // onSaved: (value) {
                    //   fullName = value!;
                    //   printMsgTag("email", fullName);
                    // },
                  ),
                  20.ph,
                  DropdownButtonFormField2<String>(
                    validator: (value) {
                      if (value == null) {
                        return "   Please select type";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDEDED)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEDEDED)),
                        ),

                    ),
                    iconStyleData: const IconStyleData(icon: Padding(
                      padding: EdgeInsets.only(bottom : 20),
                      child: Icon(Icons.arrow_drop_down, color: Color(0xFF9B9B9B),),
                    ), iconEnabledColor: Colors.black),
                    alignment: AlignmentDirectional.centerStart,
                    hint: const Text('Type', style: TextStyle(
                      color: Color(0xFF9B9B9B),
                      fontSize: 14,
                      fontFamily: poppinsRegular,
                      fontWeight: FontWeight.w400,
                    ),),
                    items: typeList.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    value: selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue;
                      });
                    },
                  ),
                  10.ph,
                  //email Field....
                  TextFormField(
                    controller: emailController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Email",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    cursorColor: Colors.black,
                    validator: (email) {
                      if (email == null || email.isEmpty) {
                        return "Please enter email";
                      } else if (!EmailValidator.validate(email)) {
                        return "Enter valid email id";
                      }
                      return null;
                    },
                  ),
                  20.ph,
                  GestureDetector(
                    onTap: () => selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: dateController,
                        decoration:const InputDecoration(
                          // isDense: true,
                          suffixIcon: Icon(Icons.calendar_month, color: Color(0xFF9B9B9B),),
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          hintText: "Date",
                          //labelText: "Type",
                          hintStyle: const TextStyle(
                            color: Color(0xFF9B9B9B),
                            fontSize: 14,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                        ),
                        validator: (fullName) {
                          if (fullName == null || fullName.isEmpty) {
                            return "Please enter Date";
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                      ),
                    ),
                  ),
                  20.ph,
                  GestureDetector(
                    onTap: () => selectTime(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        readOnly: true,
                        controller: timeController,
                        decoration:const InputDecoration(
                          suffixIcon: Icon(Icons.watch_later_rounded, color: Color(0xFF9B9B9B),),
                          // isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          hintText: "Time",
                          //labelText: "Type",
                          hintStyle: const TextStyle(
                            color: Color(0xFF9B9B9B),
                            fontSize: 14,
                            fontFamily: poppinsRegular,
                            fontWeight: FontWeight.w400,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                        ),
                        validator: (fullName) {
                          if (fullName == null || fullName.isEmpty) {
                            return "Please enter Time";
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                      ),
                    ),
                  ),
                  20.ph,
                  TextFormField(
                    controller: areaController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Area",
                      //labelText: "Type",
                      hintStyle:  TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter Area";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),
                  20.ph,
                  TextFormField(
                    controller: blockController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Block",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter Block";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),
                  20.ph,
                  TextFormField(
                    controller: streetController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Street",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter Street";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),
                  20.ph,
                  DropdownButtonFormField2<String>(
                    validator: (value) {
                      if (value == null) {
                        return "   Please select type";
                      }
                      return null;
                    },
                        decoration: const InputDecoration(
                          focusedBorder: InputBorder.none,
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFEDEDED)),
                          )
                        ),
                        iconStyleData: const IconStyleData(icon: Padding(
                          padding: EdgeInsets.only(bottom : 20),
                          child: Icon(Icons.arrow_drop_down, color: Color(0xFF9B9B9B),),
                        ), iconEnabledColor: Colors.black),
                        alignment: AlignmentDirectional.centerStart,
                        hint: const Text("Event Type", style: TextStyle(
                          color: Color(0xFF9B9B9B),
                          fontSize: 14,
                          fontFamily: poppinsRegular,
                          fontWeight: FontWeight.w400,
                        ),),
                        items: eventTypeNameList.map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.toString()),
                          ),
                        ).toList(),
                        value: selectedEventType,
                        onChanged: (newValue) {
                          setState(() {
                            selectedEventType = newValue;
                          });
                        },
                      ),
                  20.ph,
                  TextFormField(
                    controller: occasionController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Occasion",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter Occasion";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),
                  20.ph,
                  TextFormField(
                    controller: guestController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "How many Guest",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter number of Guests";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),
                  20.ph,
                  TextFormField(
                    controller: massageController,
                    decoration:const InputDecoration(
                      // isDense: true,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      hintText: "Message",
                      //labelText: "Type",
                      hintStyle: const TextStyle(
                        color: Color(0xFF9B9B9B),
                        fontSize: 14,
                        fontFamily: poppinsRegular,
                        fontWeight: FontWeight.w400,
                      ),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEDEDED)),
                      ),
                    ),
                    validator: (fullName) {
                      if (fullName == null || fullName.isEmpty) {
                        return "Please enter Message";
                      }
                      return null;
                    },
                    cursorColor: Colors.black,
                  ),

                  26.ph,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0,),
                    child: MaterialButton(
                      onPressed: () {
                        if(formKey.currentState!.validate()){
                          quotationPostApi();
                          // navigateReplaceAll(
                          //     context,
                          //     BottomNavigationBarScreen(
                          //         selectedIndex: 0));
                        }
                        },

                      minWidth: double.infinity,
                      height: 40,
                      color: PrimaryColors().primarycolor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36)),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: poppinsSemiBold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  20.ph,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
