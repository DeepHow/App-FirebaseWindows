// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:firebase_windows/firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_windows/firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';

import 'utils/exception.dart';

/// Method Channel delegate for [UserPlatform] instances.
class MethodChannelUser extends UserPlatform {
  /// Constructs a new [MethodChannelUser] instance.
  MethodChannelUser(FirebaseAuthPlatform auth, Map<String, dynamic> data)
      : super(auth, data);

  /// Attaches generic default values to method channel arguments.
  Map<String, dynamic> _withChannelDefaults(Map<String, dynamic> other) {
    return {
      'appName': auth.app.name,
      'tenantId': auth.tenantId,
    }..addAll(other);
  }

  @override
  Future<String> getIdToken(bool forceRefresh) async {
    try {
      Map<String, dynamic> data = (await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, dynamic>(
              'User#getIdToken',
              _withChannelDefaults(
                {
                  'forceRefresh': forceRefresh,
                  'tokenOnly': true,
                },
              )))!;

      return data['token'];
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) async {
    try {
      // Map<String, dynamic> data = (await MethodChannelFirebaseAuth.channel
      //     .invokeMapMethod<String, dynamic>(
      //   'User#getIdToken',
      //   _withChannelDefaults({
      //     'forceRefresh': forceRefresh,
      //     'tokenOnly': false,
      //   }),
      // ))!;

      String token = await getIdToken(forceRefresh);

      // Split the base64-encoded claims string from the token.
      String encodedClaims = token.split('.')[1];

      // Padding '=' to complement the length required for base64 encoding.
      while (encodedClaims.length % 4 != 0) {
        encodedClaims += '=';
      }

      Map<String, dynamic> claims =
          jsonDecode(utf8.decode(base64Url.decode(encodedClaims)));

      Map<String, dynamic> data = {
        'token': token,
        'claims': claims,
        'authTimestamp': (claims['auth_time'] as int) * 1000,
        'expirationTimestamp': (claims['exp'] as int) * 1000,
        'issuedAtTimestamp': (claims['iat'] as int) * 1000,
        'signInProvider': claims['firebase'] != null
            ? claims['firebase']['sign_in_provider']
            : null,
      };

      return IdTokenResult(data);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> reload() async {
    try {
      Map<String, dynamic> data = (await MethodChannelFirebaseAuth.channel
          .invokeMapMethod<String, dynamic>(
              'User#reload', _withChannelDefaults({})))!;

      MethodChannelUser user = MethodChannelUser(auth, data);
      auth.currentUser = user;
      auth.sendAuthChangesEvent(auth.app.name, user);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}
