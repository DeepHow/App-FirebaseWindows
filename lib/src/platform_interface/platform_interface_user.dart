// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_windows;

/// A user account.
abstract class UserPlatform extends PlatformInterface {
  // ignore: public_member_api_docs
  UserPlatform(this.auth, Map<String, dynamic> user)
      : _user = user,
        super(token: _token);

  static final Object _token = Object();

  /// Ensures that any delegate class has extended a [UserPlatform].
  static void verify(UserPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// The [FirebaseAuthPlatform] instance.
  final FirebaseAuthPlatform auth;

  final Map<String, dynamic> _user;

  /// The users display name.
  ///
  /// Will be `null` if signing in anonymously or via password authentication.
  String? get displayName {
    return _user['displayName'];
  }

  /// The users email address.
  ///
  /// Will be `null` if signing in anonymously.
  String? get email {
    return _user['email'];
  }

  /// Returns whether the users email address has been verified.
  ///
  /// To send a verification email, see [sendEmailVerification].
  ///
  /// Once verified, call [reload] to ensure the latest user information is
  /// retrieved from Firebase.
  bool get emailVerified {
    return _user['emailVerified'];
  }

  /// Returns whether the user is a anonymous.
  bool get isAnonymous {
    return _user['isAnonymous'];
  }

  /// Returns additional metadata about the user, such as their creation time.
  UserMetadata get metadata {
    return UserMetadata(
        _user['metadata']['creationTime'], _user['metadata']['lastSignInTime']);
  }

  /// Returns the users phone number.
  ///
  /// This property will be `null` if the user has not signed in or been has
  /// their phone number linked.
  String? get phoneNumber {
    return _user['phoneNumber'];
  }

  /// Returns a photo URL for the user.
  ///
  /// This property will be populated if the user has signed in or been linked
  /// with a 3rd party OAuth provider (such as Google).
  String? get photoURL {
    return _user['photoURL'];
  }

  /// Returns a list of user information for each linked provider.
  List<UserInfo> get providerData {
    return List.from(_user['providerData'])
        .map((data) => UserInfo(Map<String, String?>.from(data)))
        .toList();
  }

  /// Returns a JWT refresh token for the user.
  ///
  /// This property will be an empty string for native platforms (android, iOS & macOS) as they do not
  /// support refresh tokens.
  String? get refreshToken {
    return _user['refreshToken'];
  }

  /// The current user's tenant ID.
  ///
  /// This is a read-only property, which indicates the tenant ID used to sign
  /// in the current user. This is `null` if the user is signed in from the
  /// parent project.
  String? get tenantId {
    return _user['tenantId'];
  }

  /// The user's unique ID.
  String get uid {
    return _user['uid'];
  }

  /// Returns a JSON Web Token (JWT) used to identify the user to a Firebase
  /// service.
  ///
  /// Returns the current token if it has not expired. Otherwise, this will
  /// refresh the token and return a new one.
  ///
  /// If [forceRefresh] is `true`, the token returned will be refresh regardless
  /// of token expiration.
  Future<String> getIdToken(bool forceRefresh) {
    throw UnimplementedError('getIdToken() is not implemented');
  }

  /// Returns a [IdTokenResult] containing the users JSON Web Token (JWT) and
  /// other metadata.
  ///
  /// Returns the current token if it has not expired. Otherwise, this will
  /// refresh the token and return a new one.
  ///
  /// If [forceRefresh] is `true`, the token returned will be refresh regardless
  /// of token expiration.
  Future<IdTokenResult> getIdTokenResult(bool forceRefresh) {
    throw UnimplementedError('getIdTokenResult() is not implemented');
  }

  /// Refreshes the current user, if signed in.
  Future<void> reload() async {
    throw UnimplementedError('reload() is not implemented');
  }
}
