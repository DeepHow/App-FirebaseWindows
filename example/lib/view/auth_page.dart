import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_windows/firebase_windows.dart';

import '../debug_widget.dart';

enum SignInMethod { password, credential, customToken }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.app});

  final FirebaseApp app;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _debugTextEditingController =
      TextEditingController();
  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();

  FirebaseAuth? _auth;
  SignInMethod? _signInMethod = SignInMethod.password;

  bool get isSignIn => _auth?.currentUser != null;

  bool get isSignInEnable =>
      !isSignIn &&
      _textEditingController1.text.isNotEmpty &&
      ((_textEditingController2.text.isNotEmpty &&
              (_signInMethod == SignInMethod.password ||
                  _signInMethod == SignInMethod.credential)) ||
          _signInMethod == SignInMethod.customToken);

  Future<void> signInWithEmailAndPassword() async {
    final email = _textEditingController1.text;
    final password = _textEditingController2.text;
    UserCredential? credential;
    try {
      credential = await _auth!
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      log('[Error] e.code: ${e.code}, e.message: ${e.message}');
    }
    setState(() {});
    log('signInWithEmailAndPassword, credential.user: ${credential?.user}');
  }

  Future<void> signInWithCredential() async {
    final providerId = _textEditingController1.text;
    final idToken = _textEditingController2.text;
    final accessToken = _textEditingController3.text;
    OAuthCredential oAuthCredential = OAuthProvider(providerId).credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    UserCredential? credential;
    try {
      credential = await _auth!.signInWithCredential(oAuthCredential);
    } on FirebaseAuthException catch (e) {
      log('[Error] e.code: ${e.code}, e.message: ${e.message}');
    }
    setState(() {});
    log('signInWithCredential, credential.user: ${credential?.user}');
  }

  Future<void> signInWithCustomToken() async {
    final token = _textEditingController1.text;
    UserCredential? credential;
    try {
      credential = await _auth!.signInWithCustomToken(token);
    } on FirebaseAuthException catch (e) {
      log('[Error] e.code: ${e.code}, e.message: ${e.message}');
    }
    setState(() {});
    log('signInWithCustomToken, credential.user: ${credential?.user}');
  }

  Future<void> signOut() async {
    await _auth!.signOut();
    setState(() {});
    log('signOut, Auth.currentUser is ${_auth!.currentUser}');
  }

  Future<void> getIdTokenResult() async {
    IdTokenResult? tokenResult;
    try {
      tokenResult = await _auth!.currentUser?.getIdTokenResult(true);
    } on FirebaseAuthException catch (e) {
      log('[Error] e.code: ${e.code}, e.message: ${e.message}');
    }
    log('getIdTokenResult, IdTokenResult: $tokenResult');
  }

  void log(String msg) {
    if (kDebugMode) print(msg);
    _debugTextEditingController.text += '$msg\n';
  }

  void onRadioChanged(SignInMethod? method) {
    setState(() {
      _signInMethod = method;
      _textEditingController1.clear();
      _textEditingController2.clear();
      _textEditingController3.clear();
    });
  }

  String? getTextFieldLabel(int id) {
    String? label;
    switch (id) {
      case 1:
        _signInMethod == SignInMethod.password
            ? label = 'Email'
            : _signInMethod == SignInMethod.credential
                ? label = 'Provider ID'
                : label = 'Token';
        break;
      case 2:
        _signInMethod == SignInMethod.password
            ? label = 'Password'
            : label = 'ID Token';
        break;
      case 3:
        label = 'Access Token';
        break;
    }
    return label;
  }

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instanceFor(app: widget.app);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 14);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Auth example page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Text('Current user: ${_auth?.currentUser?.displayName}\n'),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text('Sign in method:'),
                ),
                SizedBox(
                  width: 180,
                  child: ListTile(
                    title: const Text('email and password', style: textStyle),
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    enabled: !isSignIn,
                    leading: Radio<SignInMethod>(
                      value: SignInMethod.password,
                      groupValue: _signInMethod,
                      onChanged: isSignIn ? null : onRadioChanged,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ListTile(
                    title: const Text('credential', style: textStyle),
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    enabled: !isSignIn,
                    leading: Radio<SignInMethod>(
                      value: SignInMethod.credential,
                      groupValue: _signInMethod,
                      onChanged: isSignIn ? null : onRadioChanged,
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ListTile(
                    title: const Text('custom token', style: textStyle),
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    enabled: !isSignIn,
                    leading: Radio<SignInMethod>(
                      value: SignInMethod.customToken,
                      groupValue: _signInMethod,
                      onChanged: isSignIn ? null : onRadioChanged,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 600,
              child: TextField(
                enabled: !isSignIn,
                controller: _textEditingController1,
                decoration: InputDecoration(
                  labelText: getTextFieldLabel(1),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Visibility(
              visible: _signInMethod != SignInMethod.customToken,
              child: SizedBox(
                width: 600,
                child: TextField(
                enabled: !isSignIn,
                  controller: _textEditingController2,
                  decoration: InputDecoration(
                    labelText: getTextFieldLabel(2),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
            Visibility(
              visible: _signInMethod == SignInMethod.credential,
              child: SizedBox(
                width: 600,
                child: TextField(
                enabled: !isSignIn,
                  controller: _textEditingController3,
                  decoration: InputDecoration(
                    labelText: getTextFieldLabel(3),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ),
            Container(
              width: 600,
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: isSignInEnable
                        ? _signInMethod == SignInMethod.password
                            ? signInWithEmailAndPassword
                            : _signInMethod == SignInMethod.credential
                                ? signInWithCredential
                                : signInWithCustomToken
                        : null,
                    child: const Text('Sign in'),
                  ),
                  ElevatedButton(
                    onPressed: isSignIn ? signOut : null,
                    child: const Text('Sign out'),
                  ),
                  ElevatedButton(
                    onPressed: isSignIn ? getIdTokenResult : null,
                    child: const Text('Get id token'),
                  ),
                ],
              ),
            ),
            DebugWidget(controller: _debugTextEditingController),
          ],
        ),
      ),
    );
  }
}
