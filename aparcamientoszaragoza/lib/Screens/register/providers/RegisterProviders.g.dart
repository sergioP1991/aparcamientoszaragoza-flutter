// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RegisterProviders.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchRegisterUserHash() => r'0837bd6b597e9c7f3880c521e8c343454e1024b9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [fetchRegisterUser].
@ProviderFor(fetchRegisterUser)
const fetchRegisterUserProvider = FetchRegisterUserFamily();

/// See also [fetchRegisterUser].
class FetchRegisterUserFamily extends Family<AsyncValue<UserCredential?>> {
  /// See also [fetchRegisterUser].
  const FetchRegisterUserFamily();

  /// See also [fetchRegisterUser].
  FetchRegisterUserProvider call(
    String? mail,
    String? password,
  ) {
    return FetchRegisterUserProvider(
      mail,
      password,
    );
  }

  @override
  FetchRegisterUserProvider getProviderOverride(
    covariant FetchRegisterUserProvider provider,
  ) {
    return call(
      provider.mail,
      provider.password,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchRegisterUserProvider';
}

/// See also [fetchRegisterUser].
class FetchRegisterUserProvider extends FutureProvider<UserCredential?> {
  /// See also [fetchRegisterUser].
  FetchRegisterUserProvider(
    String? mail,
    String? password,
  ) : this._internal(
          (ref) => fetchRegisterUser(
            ref as FetchRegisterUserRef,
            mail,
            password,
          ),
          from: fetchRegisterUserProvider,
          name: r'fetchRegisterUserProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchRegisterUserHash,
          dependencies: FetchRegisterUserFamily._dependencies,
          allTransitiveDependencies:
              FetchRegisterUserFamily._allTransitiveDependencies,
          mail: mail,
          password: password,
        );

  FetchRegisterUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mail,
    required this.password,
  }) : super.internal();

  final String? mail;
  final String? password;

  @override
  Override overrideWith(
    FutureOr<UserCredential?> Function(FetchRegisterUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchRegisterUserProvider._internal(
        (ref) => create(ref as FetchRegisterUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mail: mail,
        password: password,
      ),
    );
  }

  @override
  FutureProviderElement<UserCredential?> createElement() {
    return _FetchRegisterUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchRegisterUserProvider &&
        other.mail == mail &&
        other.password == password;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mail.hashCode);
    hash = _SystemHash.combine(hash, password.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FetchRegisterUserRef on FutureProviderRef<UserCredential?> {
  /// The parameter `mail` of this provider.
  String? get mail;

  /// The parameter `password` of this provider.
  String? get password;
}

class _FetchRegisterUserProviderElement
    extends FutureProviderElement<UserCredential?> with FetchRegisterUserRef {
  _FetchRegisterUserProviderElement(super.provider);

  @override
  String? get mail => (origin as FetchRegisterUserProvider).mail;
  @override
  String? get password => (origin as FetchRegisterUserProvider).password;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
