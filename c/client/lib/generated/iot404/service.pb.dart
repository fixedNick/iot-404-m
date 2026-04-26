// This is a generated file - do not edit.
//
// Generated from service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class WindSpeedResponse extends $pb.GeneratedMessage {
  factory WindSpeedResponse({
    $core.int? status,
    $core.String? message,
    $core.double? speed,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (message != null) result.message = message;
    if (speed != null) result.speed = speed;
    return result;
  }

  WindSpeedResponse._();

  factory WindSpeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WindSpeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WindSpeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'status')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aD(3, _omitFieldNames ? '' : 'speed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindSpeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindSpeedResponse copyWith(void Function(WindSpeedResponse) updates) =>
      super.copyWith((message) => updates(message as WindSpeedResponse))
          as WindSpeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WindSpeedResponse create() => WindSpeedResponse._();
  @$core.override
  WindSpeedResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WindSpeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WindSpeedResponse>(create);
  static WindSpeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get status => $_getIZ(0);
  @$pb.TagNumber(1)
  set status($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get speed => $_getN(2);
  @$pb.TagNumber(3)
  set speed($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpeed() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpeed() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
