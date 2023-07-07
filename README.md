# firebase_windows

Windows implementations of the Firebase Flutter plugin for Flutter apps.

> Note: This plugin code is based on https://github.com/firebase/flutterfire. ([3f1608a5](https://github.com/firebase/flutterfire/commit/3f1608a59452833b078c6db2a3872cf0aa27d5ba))
>
> - _flutterfire_internals: [v1.3.0](https://github.com/firebase/flutterfire/tree/_flutterfire_internals-v1.3.0/packages/_flutterfire_internals)
> - firebase_core_platform_interface: [v4.8.0](https://github.com/firebase/flutterfire/tree/firebase_core_platform_interface-v4.8.0/packages/firebase_core/firebase_core_platform_interface)
> - firebase_core: [v2.12.0](https://github.com/firebase/flutterfire/tree/firebase_core-v2.12.0/packages/firebase_core/firebase_core)
> - firebase_auth_platform_interface: [v6.15.0](https://github.com/firebase/flutterfire/tree/firebase_auth_platform_interface-v6.15.0/packages/firebase_auth/firebase_auth_platform_interface)
> - firebase_auth: [v4.6.0](https://github.com/firebase/flutterfire/tree/firebase_auth-v4.6.0/packages/firebase_auth/firebase_auth)
> 
> And file *windows/CMakeLists.txt* is based on firebase_core: v2.13.1. [CMakeLists.txt](https://github.com/firebase/flutterfire/blob/firebase_core-v2.13.1/packages/firebase_core/firebase_core/windows/CMakeLists.txt)

## Getting Started

This is a windows implementation of flutterfire. Currently, only a part of the modules/functions are implemented. For usage, please refer to https://github.com/firebase/flutterfire.

## Support

Currently only the following modules/features are implemented.

- [firebase_core](https://github.com/firebase/flutterfire/tree/master/packages/firebase_core/firebase_core)
- [firebase_auth](https://github.com/firebase/flutterfire/tree/master/packages/firebase_auth/firebase_auth)
  - `FirebaseAuth.signInWithCredential`
  - `FirebaseAuth.signInWithCustomToken`
  - `FirebaseAuth.signInWithEmailAndPassword`
  - `FirebaseAuth.signOut`
  - `User.getIdTokenResult`

