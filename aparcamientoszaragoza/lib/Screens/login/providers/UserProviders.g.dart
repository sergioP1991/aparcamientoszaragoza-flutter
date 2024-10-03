// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserProviders.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userStateHash() => r'b07a6e66b4da17fffaba6d20a6fb42e511b102d3';

/// See also [userState].
@ProviderFor(userState)
final userStateProvider = Provider<UserCredential?>.internal(
  userState,
  name: r'userStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserStateRef = ProviderRef<UserCredential?>;
String _$signInWithGoogleHash() => r'80756be6af12ec656a038abde3a0d508fdad08c4';

/// See also [signInWithGoogle].
@ProviderFor(signInWithGoogle)
final signInWithGoogleProvider = FutureProvider<UserCredential?>.internal(
  signInWithGoogle,
  name: r'signInWithGoogleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInWithGoogleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignInWithGoogleRef = FutureProviderRef<UserCredential?>;
String _$fetchAuthUserHash() => r'cdcaa2561cb4d4a33f8e3bd1d58aea229a0d04a7';

/// See also [fetchAuthUser].
@ProviderFor(fetchAuthUser)
final fetchAuthUserProvider = StreamProvider<User?>.internal(
  fetchAuthUser,
  name: r'fetchAuthUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchAuthUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchAuthUserRef = StreamProviderRef<User?>;
String _$fetchUserHash() => r'd72c332e023e8e84263457b4e6052ad720b4cb35';

/// See also [fetchUser].
@ProviderFor(fetchUser)
final fetchUserProvider = StreamProvider<User?>.internal(
  fetchUser,
  name: r'fetchUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchUserRef = StreamProviderRef<User?>;
String _$fetchIdTokenHash() => r'c2472e5cf60d99a4b7dd412529f5fe2bbae1e9be';

/// See also [fetchIdToken].
@ProviderFor(fetchIdToken)
final fetchIdTokenProvider = StreamProvider<User?>.internal(
  fetchIdToken,
  name: r'fetchIdTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchIdTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FetchIdTokenRef = StreamProviderRef<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
