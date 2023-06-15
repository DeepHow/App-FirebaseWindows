// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_windows;

/// A user account.
class User {
  final UserPlatform _delegate;

  User._(this._delegate) {
    UserPlatform.verify(_delegate);
  }

  /// The users display name.
  ///
  /// Will be `null` if signing in anonymously or via password authentication.
  String? get displayName {
    return _delegate.displayName;
  }

  /// The users email address.
  ///
  /// Will be `null` if signing in anonymously.
  String? get email {
    return _delegate.email;
  }

  /// Returns whether the users email address has been verified.
  ///
  /// To send a verification email, see [sendEmailVerification].
  ///
  /// Once verified, call [reload] to ensure the latest user information is
  /// retrieved from Firebase.
  bool get emailVerified {
    return _delegate.emailVerified;
  }

  /// Returns whether the user is a anonymous.
  bool get isAnonymous {
    return _delegate.isAnonymous;
  }

  /// Returns additional metadata about the user, such as their creation time.
  UserMetadata get metadata {
    return _delegate.metadata;
  }

  /// Returns the users phone number.
  ///
  /// This property will be `null` if the user has not signed in or been has
  /// their phone number linked.
  String? get phoneNumber {
    return _delegate.phoneNumber;
  }

  /// Returns a photo URL for the user.
  ///
  /// This property will be populated if the user has signed in or been linked
  /// with a 3rd party OAuth provider (such as Google).
  String? get photoURL {
    return _delegate.photoURL;
  }

  /// Returns a list of user information for each linked provider.
  List<UserInfo> get providerData {
    return _delegate.providerData;
  }

  /// Returns a JWT refresh token for the user.
  ///
  /// This property will be an empty string for native platforms (android, iOS & macOS) as they do not
  /// support refresh tokens.
  String? get refreshToken {
    return _delegate.refreshToken;
  }

  /// The current user's tenant ID.
  ///
  /// This is a read-only property, which indicates the tenant ID used to sign
  /// in the current user. This is `null` if the user is signed in from the
  /// parent project.
  String? get tenantId {
    return _delegate.tenantId;
  }

  /// The user's unique ID.
  String get uid {
    return _delegate.uid;
  }

  /// Returns a JSON Web Token (JWT) used to identify the user to a Firebase
  /// service.
  ///
  /// Returns the current token if it has not expired. Otherwise, this will
  /// refresh the token and return a new one.
  ///
  /// If [forceRefresh] is `true`, the token returned will be refreshed regardless
  /// of token expiration.
  Future<String> getIdToken([bool forceRefresh = false]) {
    return _delegate.getIdToken(forceRefresh);
  }

  /// Returns a [IdTokenResult] containing the users JSON Web Token (JWT) and
  /// other metadata.
  ///
  /// Returns the current token if it has not expired. Otherwise, this will
  /// refresh the token and return a new one.
  ///
  /// If [forceRefresh] is `true`, the token returned will be refreshed regardless
  /// of token expiration.
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    return _delegate.getIdTokenResult(forceRefresh);
  }

  /// Refreshes the current user, if signed in.
  Future<void> reload() async {
    await _delegate.reload();
  }

  @override
  String toString() {
    return '$User('
        'displayName: $displayName, '
        'email: $email, '
        'emailVerified: $emailVerified, '
        'isAnonymous: $isAnonymous, '
        'metadata: $metadata, '
        'phoneNumber: $phoneNumber, '
        'photoURL: $photoURL, '
        'providerData, $providerData, '
        'refreshToken: $refreshToken, '
        'tenantId: $tenantId, '
        'uid: $uid)';
  }
}
