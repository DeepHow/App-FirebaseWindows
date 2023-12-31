// Autogenerated from Pigeon (v9.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

class PigeonFirebaseOptions {
  PigeonFirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.databaseURL,
    this.storageBucket,
    this.measurementId,
    this.trackingId,
    this.deepLinkURLScheme,
    this.androidClientId,
    this.iosClientId,
    this.iosBundleId,
    this.appGroupId,
  });

  String apiKey;

  String appId;

  String messagingSenderId;

  String projectId;

  String? authDomain;

  String? databaseURL;

  String? storageBucket;

  String? measurementId;

  String? trackingId;

  String? deepLinkURLScheme;

  String? androidClientId;

  String? iosClientId;

  String? iosBundleId;

  String? appGroupId;

  Object encode() {
    return <Object?>[
      apiKey,
      appId,
      messagingSenderId,
      projectId,
      authDomain,
      databaseURL,
      storageBucket,
      measurementId,
      trackingId,
      deepLinkURLScheme,
      androidClientId,
      iosClientId,
      iosBundleId,
      appGroupId,
    ];
  }

  static PigeonFirebaseOptions decode(Object result) {
    result as List<Object?>;
    return PigeonFirebaseOptions(
      apiKey: result[0]! as String,
      appId: result[1]! as String,
      messagingSenderId: result[2]! as String,
      projectId: result[3]! as String,
      authDomain: result[4] as String?,
      databaseURL: result[5] as String?,
      storageBucket: result[6] as String?,
      measurementId: result[7] as String?,
      trackingId: result[8] as String?,
      deepLinkURLScheme: result[9] as String?,
      androidClientId: result[10] as String?,
      iosClientId: result[11] as String?,
      iosBundleId: result[12] as String?,
      appGroupId: result[13] as String?,
    );
  }
}

class PigeonInitializeResponse {
  PigeonInitializeResponse({
    required this.name,
    required this.options,
    this.isAutomaticDataCollectionEnabled,
    required this.pluginConstants,
  });

  String name;

  PigeonFirebaseOptions options;

  bool? isAutomaticDataCollectionEnabled;

  Map<String?, Object?> pluginConstants;

  Object encode() {
    return <Object?>[
      name,
      options.encode(),
      isAutomaticDataCollectionEnabled,
      pluginConstants,
    ];
  }

  static PigeonInitializeResponse decode(Object result) {
    result as List<Object?>;
    return PigeonInitializeResponse(
      name: result[0]! as String,
      options: PigeonFirebaseOptions.decode(result[1]! as List<Object?>),
      isAutomaticDataCollectionEnabled: result[2] as bool?,
      pluginConstants: (result[3] as Map<Object?, Object?>?)!.cast<String?, Object?>(),
    );
  }
}

class _FirebaseCoreHostApiCodec extends StandardMessageCodec {
  const _FirebaseCoreHostApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is PigeonFirebaseOptions) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is PigeonInitializeResponse) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128: 
        return PigeonFirebaseOptions.decode(readValue(buffer)!);
      case 129: 
        return PigeonInitializeResponse.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class FirebaseCoreHostApi {
  /// Constructor for [FirebaseCoreHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  FirebaseCoreHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _FirebaseCoreHostApiCodec();

  Future<PigeonInitializeResponse> initializeApp(String arg_appName, PigeonFirebaseOptions arg_initializeAppRequest) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseCoreHostApi.initializeApp', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_appName, arg_initializeAppRequest]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as PigeonInitializeResponse?)!;
    }
  }

  Future<List<PigeonInitializeResponse?>> initializeCore() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseCoreHostApi.initializeCore', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as List<Object?>?)!.cast<PigeonInitializeResponse?>();
    }
  }

  Future<PigeonFirebaseOptions> optionsFromResource() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseCoreHostApi.optionsFromResource', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as PigeonFirebaseOptions?)!;
    }
  }
}

class FirebaseAppHostApi {
  /// Constructor for [FirebaseAppHostApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  FirebaseAppHostApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = StandardMessageCodec();

  Future<void> setAutomaticDataCollectionEnabled(String arg_appName, bool arg_enabled) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseAppHostApi.setAutomaticDataCollectionEnabled', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_appName, arg_enabled]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> setAutomaticResourceManagementEnabled(String arg_appName, bool arg_enabled) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseAppHostApi.setAutomaticResourceManagementEnabled', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_appName, arg_enabled]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  Future<void> delete(String arg_appName) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.FirebaseAppHostApi.delete', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_appName]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }
}
