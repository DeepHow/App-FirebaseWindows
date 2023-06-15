// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_windows;

/// Method Channel delegate for [FirebaseAuthPlatform].
class MethodChannelFirebaseAuth extends FirebaseAuthPlatform {
  /// The [MethodChannelFirebaseAuth] method channel.
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  /// Map of [MethodChannelFirebaseAuth] that can be get with Firebase App Name.
  static Map<String, MethodChannelFirebaseAuth>
      methodChannelFirebaseAuthInstances =
      <String, MethodChannelFirebaseAuth>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _authStateChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _idTokenChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

  static final Map<String, StreamController<_ValueWrapper<UserPlatform>>>
      _userChangesListeners =
      <String, StreamController<_ValueWrapper<UserPlatform>>>{};

  StreamController<T> _createBroadcastStream<T>() {
    return StreamController<T>.broadcast();
  }

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAuth get instance {
    return MethodChannelFirebaseAuth._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseAuth._() : super(appInstance: null);

  /// Creates a new instance with a given [FirebaseApp].
  MethodChannelFirebaseAuth({required FirebaseApp app})
      : super(appInstance: app) {
    channel.invokeMethod<String>('Auth#registerIdTokenListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen(
        (arguments) {
          _handleIdTokenChangesListener(app.name, arguments);
        },
      );
    });

    channel.invokeMethod<String>('Auth#registerAuthStateListener', {
      'appName': app.name,
    }).then((channelName) {
      final events = EventChannel(channelName!, channel.codec);
      events
          .receiveGuardedBroadcastStream(onError: convertPlatformException)
          .listen(
        (arguments) {
          _handleAuthStateChangesListener(app.name, arguments);
        },
      );
    });

    // Create a app instance broadcast stream for native listener events
    _authStateChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
    _idTokenChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
    _userChangesListeners[app.name] =
        _createBroadcastStream<_ValueWrapper<UserPlatform>>();
  }

  @override
  UserPlatform? currentUser;

  @override
  String? languageCode;

  @override
  void sendAuthChangesEvent(String appName, UserPlatform? userPlatform) {
    assert(_userChangesListeners[appName] != null);

    _userChangesListeners[appName]!.add(_ValueWrapper(userPlatform));
  }

  /// Handles any incoming [authChanges] listener events.
  // Duplicate setting of [currentUser] in [_handleAuthStateChangesListener] & [_handleIdTokenChangesListener]
  // as iOS & Android do not guarantee correct ordering
  Future<void> _handleAuthStateChangesListener(
      String appName, Map<dynamic, dynamic> arguments) async {
    // ignore: close_sinks
    final streamController = _authStateChangesListeners[appName]!;
    MethodChannelFirebaseAuth instance =
        methodChannelFirebaseAuthInstances[appName]!;

    final userMap = arguments['user'];
    if (userMap == null) {
      instance.currentUser = null;
      streamController.add(const _ValueWrapper.absent());
    } else {
      final MethodChannelUser user =
          MethodChannelUser(instance, userMap.cast<String, dynamic>());

      // TODO(rousselGit): should this logic be moved to the setter instead?
      instance.currentUser = user;
      streamController.add(_ValueWrapper(instance.currentUser));
    }
  }

  /// Handles any incoming [idTokenChanges] listener events.
  ///
  /// This handler also manages the [currentUser] along with sending events
  /// to any [userChanges] stream subscribers.
  Future<void> _handleIdTokenChangesListener(
      String appName, Map<dynamic, dynamic> arguments) async {
    final StreamController<_ValueWrapper<UserPlatform>>
        // ignore: close_sinks
        idTokenStreamController = _idTokenChangesListeners[appName]!;
    final StreamController<_ValueWrapper<UserPlatform>>
        // ignore: close_sinks
        userChangesStreamController = _userChangesListeners[appName]!;
    MethodChannelFirebaseAuth instance =
        methodChannelFirebaseAuthInstances[appName]!;

    final userMap = arguments['user'];
    if (userMap == null) {
      instance.currentUser = null;
      idTokenStreamController.add(const _ValueWrapper.absent());
      userChangesStreamController.add(const _ValueWrapper.absent());
    } else {
      final MethodChannelUser user =
          MethodChannelUser(instance, userMap.cast<String, dynamic>());

      // TODO(rousselGit): should this logic be moved to the setter instead?
      instance.currentUser = user;
      idTokenStreamController.add(_ValueWrapper(user));
      userChangesStreamController.add(_ValueWrapper(user));
    }
  }

  /// Attaches generic default values to method channel arguments.
  Map<String, dynamic> _withChannelDefaults(Map<String, dynamic> other) {
    return {
      'appName': app.name,
      'tenantId': tenantId,
    }..addAll(other);
  }

  /// Gets a [FirebaseAuthPlatform] with specific arguments such as a different
  /// [FirebaseApp].
  ///
  /// Instances are cached and reused for incoming event handlers.
  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return methodChannelFirebaseAuthInstances.putIfAbsent(app.name, () {
      return MethodChannelFirebaseAuth(app: app);
    });
  }

  @override
  MethodChannelFirebaseAuth setInitialValues({
    Map<String, dynamic>? currentUser,
    String? languageCode,
  }) {
    if (currentUser != null) {
      this.currentUser = MethodChannelUser(this, currentUser);
    }

    this.languageCode = languageCode;
    return this;
  }

  @override
  Future<void> useAuthEmulator(String host, int port) async {
    try {
      await channel.invokeMethod<void>(
          'Auth#useEmulator',
          _withChannelDefaults({
            'host': host,
            'port': port,
          }));
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Stream<UserPlatform?> authStateChanges() async* {
    yield currentUser;
    yield* _authStateChangesListeners[app.name]!
        .stream
        .map((event) => event.value);
  }

  @override
  Stream<UserPlatform?> idTokenChanges() async* {
    yield currentUser;
    yield* _idTokenChangesListeners[app.name]!
        .stream
        .map((event) => event.value);
  }

  @override
  Stream<UserPlatform?> userChanges() async* {
    yield currentUser;
    yield* _userChangesListeners[app.name]!.stream.map((event) => event.value);
  }

  @override
  Future<UserCredentialPlatform> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      Map<String, dynamic> data =
          (await channel.invokeMapMethod<String, dynamic>(
              'Auth#signInWithCredential',
              _withChannelDefaults({
                'credential': credential.asMap(),
              })))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithCustomToken(String token) async {
    try {
      Map<String, dynamic> data =
          (await channel.invokeMapMethod<String, dynamic>(
              'Auth#signInWithCustomToken',
              _withChannelDefaults({
                'token': token,
              })))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<UserCredentialPlatform> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      Map<String, dynamic> data =
          (await channel.invokeMapMethod<String, dynamic>(
              'Auth#signInWithEmailAndPassword',
              _withChannelDefaults({
                'email': email,
                'password': password,
              })))!;

      MethodChannelUserCredential userCredential =
          MethodChannelUserCredential(this, data);

      currentUser = userCredential.user;
      return userCredential;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await channel.invokeMethod<void>(
          'Auth#signOut', _withChannelDefaults({}));

      currentUser = null;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}

/// Simple helper class to make nullable values transferable through StreamControllers.
class _ValueWrapper<T> {
  const _ValueWrapper(this.value);

  const _ValueWrapper.absent() : value = null;

  final T? value;
}
