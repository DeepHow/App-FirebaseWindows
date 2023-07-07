// ignore_for_file: require_trailing_commas
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// The entry point of the Firebase Authentication SDK.
class FirebaseAuth extends FirebasePluginPlatform {
  // Cached instances of [FirebaseAuth].
  static Map<String, FirebaseAuth> _firebaseAuthInstances = {};

  // Cached and lazily loaded instance of [FirebaseAuthPlatform] to avoid
  // creating a [MethodChannelFirebaseAuth] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseAuthPlatform? _delegatePackingProperty;

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  FirebaseAuthPlatform get _delegate {
    _delegatePackingProperty ??= FirebaseAuthPlatform.instanceFor(
      app: app,
      pluginConstants: pluginConstants,
    );
    return _delegatePackingProperty!;
  }

  /// The [FirebaseApp] for this current Auth instance.
  FirebaseApp app;

  FirebaseAuth._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_auth');

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseAuth get instance {
    FirebaseApp defaultAppInstance = Firebase.app();

    return FirebaseAuth.instanceFor(app: defaultAppInstance);
  }

  /// Returns an instance using a specified [FirebaseApp].
  factory FirebaseAuth.instanceFor({required FirebaseApp app}) {
    return _firebaseAuthInstances.putIfAbsent(app.name, () {
      return FirebaseAuth._(app: app);
    });
  }

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// This getter only provides a snapshot of user state. Applications that need
  /// to react to changes in user state should instead use [authStateChanges],
  /// [idTokenChanges] or [userChanges] to subscribe to updates.
  User? get currentUser {
    if (_delegate.currentUser != null) {
      return User._(_delegate.currentUser!);
    }

    return null;
  }

  /// Changes this instance to point to an Auth emulator running locally.
  ///
  /// Set the [origin] of the local emulator, such as "http://localhost:9099"
  ///
  /// Note: Must be called immediately, prior to accessing auth methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  ///
  /// Note: auth emulator is not supported for web yet. firebase-js-sdk does not support
  /// auth.useEmulator until v8.2.4, but FlutterFire does not support firebase-js-sdk v8+ yet
  @Deprecated(
    'Will be removed in future release. '
    'Use useAuthEmulator().',
  )
  Future<void> useEmulator(String origin) async {
    assert(origin.isNotEmpty);
    String mappedOrigin = origin;

    // Android considers localhost as 10.0.2.2 - automatically handle this for users.
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      if (mappedOrigin.startsWith('http://localhost')) {
        mappedOrigin =
            mappedOrigin.replaceFirst('http://localhost', 'http://10.0.2.2');
      } else if (mappedOrigin.startsWith('http://127.0.0.1')) {
        mappedOrigin =
            mappedOrigin.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
      }
    }

    // Native calls take the host and port split out
    final hostPortRegex = RegExp(r'^http:\/\/([\w\d.]+):(\d+)$');
    final RegExpMatch? match = hostPortRegex.firstMatch(mappedOrigin);
    if (match == null) {
      throw ArgumentError('firebase.auth().useEmulator() origin format error');
    }
    // Two non-empty groups in RegExp match - which is null-tested - these are non-null now
    final String host = match.group(1)!;
    final int port = int.parse(match.group(2)!);

    await useAuthEmulator(host, port);
  }

  /// Changes this instance to point to an Auth emulator running locally.
  ///
  /// Set the [host] of the local emulator, such as "localhost"
  /// Set the [port] of the local emulator, such as "9099" (port 9099 is default for auth package)
  ///
  /// Note: Must be called immediately, prior to accessing auth methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  Future<void> useAuthEmulator(String host, int port) async {
    String mappedHost = host;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (mappedHost == 'localhost' || mappedHost == '127.0.0.1') {
        // ignore: avoid_print
        print('Mapping Auth Emulator host "$mappedHost" to "10.0.2.2".');
        mappedHost = '10.0.2.2';
      }
    }

    await _delegate.useAuthEmulator(mappedHost, port);
  }

  /// The current Auth instance's tenant ID.
  String? get tenantId {
    return _delegate.tenantId;
  }

  /// Set the current Auth instance's tenant ID.
  ///
  /// When you set the tenant ID of an Auth instance, all future sign-in/sign-up
  /// operations will pass this tenant ID and sign in or sign up users to the
  /// specified tenant project. When set to null, users are signed in to the
  /// parent project. By default, this is set to `null`.
  set tenantId(String? tenantId) {
    _delegate.tenantId = tenantId;
  }

  /// Internal helper which pipes internal [Stream] events onto
  /// a users own Stream.
  Stream<User?> _pipeStreamChanges(Stream<UserPlatform?> stream) {
    return stream.map((delegateUser) {
      if (delegateUser == null) {
        return null;
      }

      return User._(delegateUser);
    }).asBroadcastStream(onCancel: (sub) => sub.cancel());
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<User?> authStateChanges() =>
      _pipeStreamChanges(_delegate.authStateChanges());

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  Stream<User?> idTokenChanges() =>
      _pipeStreamChanges(_delegate.idTokenChanges());

  /// Notifies about changes to any user updates.
  ///
  /// This is a superset of both [authStateChanges] and [idTokenChanges]. It
  /// provides events on all user changes, such as when credentials are linked,
  /// unlinked and when updates to the user profile are made. The purpose of
  /// this Stream is for listening to realtime updates to the user state
  /// (signed-in, signed-out, different user & token refresh) without
  /// manually having to call [reload] and then rehydrating changes to your
  /// application.
  Stream<User?> userChanges() => _pipeStreamChanges(_delegate.userChanges());

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
  ///    asserted by the credential.
  ///    Resolve this by calling [fetchSignInMethodsForEmail] and then asking
  ///    the user to sign in using one of the returned providers.
  ///    Once the user is signed in, the original credential can be linked to
  ///    the user with [linkWithCredential].
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
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    try {
      return UserCredential._(
        await _delegate.signInWithCredential(credential),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Tries to sign in a user with a given custom token.
  ///
  /// Custom tokens are used to integrate Firebase Auth with existing auth
  /// systems, and must be generated by the auth backend.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **custom-token-mismatch**:
  ///  - Thrown if the custom token is for a different Firebase App.
  /// - **invalid-custom-token**:
  ///  - Thrown if the custom token format is incorrect.
  Future<UserCredential> signInWithCustomToken(String token) async {
    try {
      return UserCredential._(await _delegate.signInWithCustomToken(token));
    } catch (e) {
      rethrow;
    }
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
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return UserCredential._(
        await _delegate.signInWithEmailAndPassword(email, password),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  ///
  /// If successful, it also updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  Future<void> signOut() async {
    await _delegate.signOut();
  }

  @override
  String toString() {
    return 'FirebaseAuth(app: ${app.name})';
  }
}
