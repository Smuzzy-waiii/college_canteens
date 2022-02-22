import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_canteens/shared/conts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum ScreenState { MOBILE_NO_STATE, OTP_STATE }

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  ScreenState curr_state = ScreenState.MOBILE_NO_STATE;
  final mobFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  String mob_no = "";
  String otp = "";
  String countryCode = "+91";
  String? _verificationId;

  bool showLoading = false;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        var user = FirebaseFirestore.instance
            .doc('Users/${_auth.currentUser!.phoneNumber}');
        DocumentSnapshot user_data = await user.get();
        //ISTG SMARAN IF U SHIP TO PROD WITH CLIENT SIDE ACCESS TO BALANCE FIELD
        //I WILL SMASH UR PC AND DELETE UR GITHUB INTO DATALOSS OBLIVION and pain.
        //TODO: Enable Cloud functions to create doc in users collection and DO NOT give client access to users collection via security rules
        if (!user_data.exists) {
          await user.set({
            "isAdmin": false,
            "Balance": 0,
          });
          //user_data = await user.get(); //re-getting doc since its updated now
        }
        //Map usrdata = user_data.data() as Map<String, dynamic>;
        //usrdata['username'] = _auth.currentUser!.uid;

        await Navigator.pushReplacementNamed(
          context,
          '/init',
        );
      }

      setState(() {
        showLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  Widget get_mob_state(BuildContext context) {
    return Form(
      key: mobFormKey,
      child: Column(
        children: [
          Spacer(
            flex: 2,
          ),
          Row(
            children: [
              Expanded(
                child: CountryCodePicker(
                    onChanged: (val) {
                      countryCode = val.toString();
                    },
                    initialSelection: "IN",
                    showFlagMain: false,
                    textStyle: TextStyle(fontSize: 17, color: Colors.black),
                    dialogSize: Size(300, 400)),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: textInputDecoration.copyWith(
                      fillColor: Colors.blueGrey[50], hintText: "Phone Number"),
                  validator: (val) {
                    if (val == null) {
                      return "Please enter a valid moble number.";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => setState(() {
                    mob_no = value!;
                  }),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text("Verify"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)),
            onPressed: () async {
              final isValid = mobFormKey.currentState!.validate();
              if (isValid) {
                mobFormKey.currentState!.save();

                setState(() {
                  showLoading = true;
                });
                await _auth.verifyPhoneNumber(
                    phoneNumber: countryCode + mob_no,
                    verificationCompleted: (phoneAuthCredential) async {
                      setState(() {
                        showLoading = false;
                      });

                      signInWithPhoneAuthCredential(phoneAuthCredential);
                    },
                    verificationFailed: (verificationFailed) async {
                      setState(() {
                        showLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(verificationFailed.message!),
                          duration: const Duration(minutes: 2)));
                    },
                    codeSent: (verificationId, resendingToken) async {
                      setState(() {
                        showLoading = false;
                        curr_state = ScreenState.OTP_STATE;
                        _verificationId = verificationId;
                      });
                    },
                    codeAutoRetrievalTimeout: (verificationId) async {
                      print("AutoRetrievalTimeout");
                      Navigator.popAndPushNamed(context, '/auth');
                    });
              }
            },
          ),
          Spacer(
            flex: 1,
          )
        ],
      ),
    );
  }

  //TODO: Impement a good otp entry field
  Widget get_otp_state(BuildContext context) {
    return Form(
      key: otpFormKey,
      child: Column(
        children: [
          Spacer(
            flex: 2,
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: textInputDecoration.copyWith(
                fillColor: Colors.blueGrey[50], hintText: "OTP"),
            onSaved: (value) => setState(() {
              otp = value!;
            }),
            validator: (val) {
              if (val!.length != 6) {
                return "Enter valid OTP";
              } else {
                return null;
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child: Text("Confirm"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.pinkAccent)),
            onPressed: () async {
              final isValid = otpFormKey.currentState!.validate();
              if (isValid) {
                otpFormKey.currentState!.save();
                print(otp);
                PhoneAuthCredential phoneAuthCredential =
                    PhoneAuthProvider.credential(
                        verificationId: _verificationId!, smsCode: otp);

                signInWithPhoneAuthCredential(phoneAuthCredential);
              }
            },
          ),
          Spacer(
            flex: 1,
          )
        ],
      ),
    );
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Bolt Snack"),
        ),
        body: showLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: curr_state == ScreenState.MOBILE_NO_STATE
                    ? get_mob_state(context)
                    : get_otp_state(context),
              ));
  }
}


/* bool isSignIn = true;

  void toggleView() {
    setState(() {
      isSignIn = !isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return Register(toggleView: toggleView);
    }
  } */
