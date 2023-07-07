// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_windows/firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_windows/firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_auth.dart';

/// The interface that implementations of `firebase_auth` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_auth` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAuthPlatform] methods.
abstract class FirebaseAuthPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  /// The current Auth instance's tenant ID.
  ///
  /// When you set the tenant ID of an Auth instance, all future sign-in/sign-up
  /// operations will pass this tenant ID and sign in or sign up users to the
  /// specified tenant project. When set to null, users are signed in to the
  /// parent project. By default, this is set to `null`.
  String? tenantId;

  /// Create an instance using [app]
  FirebaseAuthPlatform({this.appInstance}) : super(token: _token);

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance!;
  }

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAuthPlatform.instanceFor(
      {required FirebaseApp app,
      required Map<dynamic, dynamic> pluginConstants}) {
    return FirebaseAuthPlatform.instance.delegateFor(app: app).setInitialValues(
        languageCode: pluginConstants['APP_LANGUAGE_CODE'],
        currentUser: pluginConstants['APP_CURRENT_USER'] == null
            ? null
            : Map<String, dynamic>.from(pluginConstants['APP_CURRENT_USER']));
  }

  /// The current default [FirebaseAuthPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseAuth]
  /// if no other implementation was provided.
  static FirebaseAuthPlatform get instance {
    _instance ??= MethodChannelFirebaseAuth.instance;
    return _instance!;
  }

  static FirebaseAuthPlatform? _instance;

  /// Sets the [FirebaseAuthPlatform.instance]
  static set instance(FirebaseAuthPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async
  /// calls.
  @protected
  FirebaseAuthPlatform setInitialValues({
    Map<String, dynamic>? currentUser,
    String? languageCode,
  }) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// You should not use this getter to determine the users current state,
  /// instead use [authStateChanges], [idTokenChanges] or [userChanges] to
  /// subscribe to updates.
  UserPlatform? get currentUser {
    throw UnimplementedError('get.currentUser is not implemented');
  }

  /// Sets the current user for the instance.
  set currentUser(UserPlatform? userPlatform) {
    throw UnimplementedError('set.currentUser is not implemented');
  }

  /// The current Auth instance's language code.
  ///
  /// See [setLanguageCode] to update the language code.
  String? get languageCode {
    throw UnimplementedError('languageCode is not implemented');
  }

  /// Sends a Stream event to a [authStateChanges] stream controller.
  void sendAuthChangesEvent(String appName, UserPlatform? userPlatform) {
    throw UnimplementedError('sendAuthChangesEvent() is not implemented');
  }

  /// Changes this instance to point to an Auth emulator running locally.
  ///
  /// Set the [host] and [port] of the local emulator, such as "localhost"
  /// with port 9099
  ///
  /// Note: Must be called immediately, prior to accessing auth methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  Future<void> useAuthEmulator(String host, int port) {
    throw UnimplementedError('useAuthEmulator() is not implemented');
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<UserPlatform?> authStateChanges() {
    throw UnimplementedError('authStateChanges() is not implemented');
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out)
  /// and also token refresh events.
  Stream<UserPlatform?> idTokenChanges() {
    throw UnimplementedError('idTokenChanges() is not implemented');
  }

  /// Notifies about changes to any user updates.
  ///
  /// This is a superset of both [authStateChanges] and [idTokenChanges]. It
  /// provides events on all user changes, such as when credentials are linked,
  /// unlinked and when updates to the user profile are made. The purpose of
  /// this Stream is for listening to realtime updates to the user state
  /// (signed-in, signed-out, different user & token refresh) without
  /// manually having to call [reload] and then rehydrating changes to your
  /// application.
  Stream<UserPlatform?> userChanges() {
    throw UnimplementedError('userChanges() is not implemented');
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// If the user doesn't have an account already, one will be created
  /// automatically.
  ///
  /// **Important**: You must enable the relevant accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **account-exists-with-different-credential**:
  ///  - Thrown if there already exists an account with the email address
  ///    asserted by the credential. Resolve this by calling
  ///    [fetchSignInMethodsForEmail] and then asking the user to sign in using
  ///    one of the returned providers. Once the user is signed in, the original
  ///    credential can be linked to the user with [linkWithCredential].
  /// - **invalid-credential**:
  ///  - Thrown if the credential is malformed or has expired.
  /// - **operation-not-allowed**:
  ///  - Thrown if the type of account corresponding to the credential is not
  ///    enabled. Enable the account type in the Firebase Console, under the
  ///    Auth tab.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given credential has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and the password is invalid for the given email, or if the account
  ///    corresponding to the email does not have a password set.
  /// - **invalid-verification-code**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification code of the credential is not valid.
  /// - **invalid-verification-id**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification ID of the credential is not valid.id.
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential credential,
  ) async {
    throw UnimplementedError('signInWithCredential() is not implemented');
  }

  /// Tries to sign in a user with a given Custom Token [token].
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Use this method after you retrieve a Firebase Auth Custom Token from your
  /// server.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    throw UnimplementedError('signInWithCustomToken() is not implemented');
  }

  /// Attempts to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// **Important**: You must enable Email & Password accounts in the Auth
  /// section of the Firebase console before being able to use them.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Thrown if the password is invalid for the given email, or the account
  ///    corresponding to the email does not have a password set.
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnimplementedError('signInWithEmailAndPassword() is not implemented');
  }

  /// Signs out the current user.
  ///
  /// If successful, it also updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  Future<void> signOut() async {
    throw UnimplementedError('signOut() is not implemented');
  }
}
