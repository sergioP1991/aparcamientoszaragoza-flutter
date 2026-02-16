// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HomeProviders.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchHomeHash() => r'7bf3abea474d2fbf6a3397c4b5747483527bb2ab';

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

/// See also [fetchHome].
@ProviderFor(fetchHome)
const fetchHomeProvider = FetchHomeFamily();

/// See also [fetchHome].
class FetchHomeFamily extends Family<AsyncValue<HomeData?>> {
  /// See also [fetchHome].
  const FetchHomeFamily();

  /// See also [fetchHome].
  FetchHomeProvider call({
    required bool allGarages,
    bool onlyMine = false,
  }) {
    return FetchHomeProvider(
      allGarages: allGarages,
      onlyMine: onlyMine,
    );
  }

  @override
  FetchHomeProvider getProviderOverride(
    covariant FetchHomeProvider provider,
  ) {
    return call(
      allGarages: provider.allGarages,
      onlyMine: provider.onlyMine,
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
  String? get name => r'fetchHomeProvider';
}

/// See also [fetchHome].
class FetchHomeProvider extends FutureProvider<HomeData?> {
  /// See also [fetchHome].
  FetchHomeProvider({
    required bool allGarages,
    bool onlyMine = false,
  }) : this._internal(
          (ref) => fetchHome(
            ref as FetchHomeRef,
            allGarages: allGarages,
            onlyMine: onlyMine,
          ),
          from: fetchHomeProvider,
          name: r'fetchHomeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchHomeHash,
          dependencies: FetchHomeFamily._dependencies,
          allTransitiveDependencies: FetchHomeFamily._allTransitiveDependencies,
          allGarages: allGarages,
          onlyMine: onlyMine,
        );

  FetchHomeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.allGarages,
    required this.onlyMine,
  }) : super.internal();

  final bool allGarages;
  final bool onlyMine;

  @override
  Override overrideWith(
    FutureOr<HomeData?> Function(FetchHomeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchHomeProvider._internal(
        (ref) => create(ref as FetchHomeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        allGarages: allGarages,
        onlyMine: onlyMine,
      ),
    );
  }

  @override
  FutureProviderElement<HomeData?> createElement() {
    return _FetchHomeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchHomeProvider &&
        other.allGarages == allGarages &&
        other.onlyMine == onlyMine;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, allGarages.hashCode);
    hash = _SystemHash.combine(hash, onlyMine.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchHomeRef on FutureProviderRef<HomeData?> {
  /// The parameter `allGarages` of this provider.
  bool get allGarages;

  /// The parameter `onlyMine` of this provider.
  bool get onlyMine;
}

class _FetchHomeProviderElement extends FutureProviderElement<HomeData?>
    with FetchHomeRef {
  _FetchHomeProviderElement(super.provider);

  @override
  bool get allGarages => (origin as FetchHomeProvider).allGarages;
  @override
  bool get onlyMine => (origin as FetchHomeProvider).onlyMine;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
