// ignore_for_file: require_trailing_commas

library firebase_windows;

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_windows/src/pigeon/messages.pigeon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:firebase_windows/src/pigeon/messages.pigeon.dart';
export 'package:firebase_windows/firebase_windows.dart'
    show
        FirebaseOptions,
        defaultFirebaseAppName,
        FirebaseException,
        FirebaseAuth,
        FirebaseAuthException,
        User,
        UserCredential;

part 'src/auth/providers/email_auth.dart';
part 'src/auth/providers/oauth.dart';
part 'src/auth/additional_user_info.dart';
part 'src/auth/auth_credential.dart';
part 'src/auth/auth_provider.dart';
part 'src/auth/id_token_result.dart';
part 'src/auth/user_credential.dart';
part 'src/auth/user_info.dart';
part 'src/auth/user_metadata.dart';
part 'src/auth/user.dart';

part 'src/method_channel/utils/exception.dart';
part 'src/method_channel/method_channel_firebase_app.dart';
part 'src/method_channel/method_channel_firebase_auth.dart';
part 'src/method_channel/method_channel_firebase.dart';
part 'src/method_channel/method_channel_user_credential.dart';
part 'src/method_channel/method_channel_user.dart';

part 'src/platform_interface/platform_interface_firebase_app.dart';
part 'src/platform_interface/platform_interface_firebase_auth.dart';
part 'src/platform_interface/platform_interface_firebase_plugin.dart';
part 'src/platform_interface/platform_interface_firebase.dart';
part 'src/platform_interface/platform_interface_user_credential.dart';
part 'src/platform_interface/platform_interface_user.dart';

part 'src/firebase_app.dart';
part 'src/firebase_auth_exception.dart';
part 'src/firebase_auth.dart';
part 'src/firebase_core_exceptions.dart';
part 'src/firebase_exception.dart';
part 'src/firebase_options.dart';
part 'src/firebase.dart';

/// The default Firebase application name.
const String defaultFirebaseAppName = '[DEFAULT]';
