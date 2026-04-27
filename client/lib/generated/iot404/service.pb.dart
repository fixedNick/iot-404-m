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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class WindSpeedRequest extends $pb.GeneratedMessage {
  factory WindSpeedRequest() => create();

  WindSpeedRequest._();

  factory WindSpeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WindSpeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WindSpeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindSpeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WindSpeedRequest copyWith(void Function(WindSpeedRequest) updates) =>
      super.copyWith((message) => updates(message as WindSpeedRequest))
          as WindSpeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WindSpeedRequest create() => WindSpeedRequest._();
  @$core.override
  WindSpeedRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WindSpeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WindSpeedRequest>(create);
  static WindSpeedRequest? _defaultInstance;
}

class TemperatureRequest extends $pb.GeneratedMessage {
  factory TemperatureRequest() => create();

  TemperatureRequest._();

  factory TemperatureRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemperatureRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemperatureRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureRequest copyWith(void Function(TemperatureRequest) updates) =>
      super.copyWith((message) => updates(message as TemperatureRequest))
          as TemperatureRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemperatureRequest create() => TemperatureRequest._();
  @$core.override
  TemperatureRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemperatureRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemperatureRequest>(create);
  static TemperatureRequest? _defaultInstance;
}

class HumidityRequest extends $pb.GeneratedMessage {
  factory HumidityRequest() => create();

  HumidityRequest._();

  factory HumidityRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HumidityRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HumidityRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HumidityRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HumidityRequest copyWith(void Function(HumidityRequest) updates) =>
      super.copyWith((message) => updates(message as HumidityRequest))
          as HumidityRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HumidityRequest create() => HumidityRequest._();
  @$core.override
  HumidityRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HumidityRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HumidityRequest>(create);
  static HumidityRequest? _defaultInstance;
}

class WindSpeedResponse extends $pb.GeneratedMessage {
  factory WindSpeedResponse({
    $core.double? voltage,
    $core.double? speed,
    $fixnum.Int64? time,
  }) {
    final result = create();
    if (voltage != null) result.voltage = voltage;
    if (speed != null) result.speed = speed;
    if (time != null) result.time = time;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'voltage', fieldType: $pb.PbFieldType.OF)
    ..aD(2, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..aInt64(3, _omitFieldNames ? '' : 'time')
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
  $core.double get voltage => $_getN(0);
  @$pb.TagNumber(1)
  set voltage($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVoltage() => $_has(0);
  @$pb.TagNumber(1)
  void clearVoltage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get speed => $_getN(1);
  @$pb.TagNumber(2)
  set speed($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpeed() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpeed() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get time => $_getI64(2);
  @$pb.TagNumber(3)
  set time($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearTime() => $_clearField(3);
}

class TemperatureResponse extends $pb.GeneratedMessage {
  factory TemperatureResponse({
    $core.double? temperature,
    $fixnum.Int64? time,
  }) {
    final result = create();
    if (temperature != null) result.temperature = temperature;
    if (time != null) result.time = time;
    return result;
  }

  TemperatureResponse._();

  factory TemperatureResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemperatureResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemperatureResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'temperature', fieldType: $pb.PbFieldType.OF)
    ..aInt64(2, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureResponse copyWith(void Function(TemperatureResponse) updates) =>
      super.copyWith((message) => updates(message as TemperatureResponse))
          as TemperatureResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemperatureResponse create() => TemperatureResponse._();
  @$core.override
  TemperatureResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemperatureResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemperatureResponse>(create);
  static TemperatureResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get temperature => $_getN(0);
  @$pb.TagNumber(1)
  set temperature($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperature() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperature() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get time => $_getI64(1);
  @$pb.TagNumber(2)
  set time($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);
}

class HumidityResponse extends $pb.GeneratedMessage {
  factory HumidityResponse({
    $core.double? humidity,
    $fixnum.Int64? time,
  }) {
    final result = create();
    if (humidity != null) result.humidity = humidity;
    if (time != null) result.time = time;
    return result;
  }

  HumidityResponse._();

  factory HumidityResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HumidityResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HumidityResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'humidity', fieldType: $pb.PbFieldType.OF)
    ..aInt64(2, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HumidityResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HumidityResponse copyWith(void Function(HumidityResponse) updates) =>
      super.copyWith((message) => updates(message as HumidityResponse))
          as HumidityResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HumidityResponse create() => HumidityResponse._();
  @$core.override
  HumidityResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HumidityResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HumidityResponse>(create);
  static HumidityResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get humidity => $_getN(0);
  @$pb.TagNumber(1)
  set humidity($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHumidity() => $_has(0);
  @$pb.TagNumber(1)
  void clearHumidity() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get time => $_getI64(1);
  @$pb.TagNumber(2)
  set time($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);
}

class StopAutoCollectRequest extends $pb.GeneratedMessage {
  factory StopAutoCollectRequest({
    $core.String? sensor,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    return result;
  }

  StopAutoCollectRequest._();

  factory StopAutoCollectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StopAutoCollectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StopAutoCollectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopAutoCollectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopAutoCollectRequest copyWith(
          void Function(StopAutoCollectRequest) updates) =>
      super.copyWith((message) => updates(message as StopAutoCollectRequest))
          as StopAutoCollectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopAutoCollectRequest create() => StopAutoCollectRequest._();
  @$core.override
  StopAutoCollectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StopAutoCollectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StopAutoCollectRequest>(create);
  static StopAutoCollectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensor => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);
}

class AutoCollectRequest extends $pb.GeneratedMessage {
  factory AutoCollectRequest({
    $core.String? sensor,
    $fixnum.Int64? period,
    $fixnum.Int64? duration,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    if (period != null) result.period = period;
    if (duration != null) result.duration = duration;
    return result;
  }

  AutoCollectRequest._();

  factory AutoCollectRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AutoCollectRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutoCollectRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensor')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'period', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'duration', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoCollectRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoCollectRequest copyWith(void Function(AutoCollectRequest) updates) =>
      super.copyWith((message) => updates(message as AutoCollectRequest))
          as AutoCollectRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoCollectRequest create() => AutoCollectRequest._();
  @$core.override
  AutoCollectRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AutoCollectRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutoCollectRequest>(create);
  static AutoCollectRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensor => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get period => $_getI64(1);
  @$pb.TagNumber(2)
  set period($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriod() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriod() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get duration => $_getI64(2);
  @$pb.TagNumber(3)
  set duration($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDuration() => $_has(2);
  @$pb.TagNumber(3)
  void clearDuration() => $_clearField(3);
}

class AutoCollectResponse extends $pb.GeneratedMessage {
  factory AutoCollectResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  AutoCollectResponse._();

  factory AutoCollectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AutoCollectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AutoCollectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoCollectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AutoCollectResponse copyWith(void Function(AutoCollectResponse) updates) =>
      super.copyWith((message) => updates(message as AutoCollectResponse))
          as AutoCollectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AutoCollectResponse create() => AutoCollectResponse._();
  @$core.override
  AutoCollectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AutoCollectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AutoCollectResponse>(create);
  static AutoCollectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class StopAutoCollectResponse extends $pb.GeneratedMessage {
  factory StopAutoCollectResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  StopAutoCollectResponse._();

  factory StopAutoCollectResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StopAutoCollectResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StopAutoCollectResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'iot404.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopAutoCollectResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopAutoCollectResponse copyWith(
          void Function(StopAutoCollectResponse) updates) =>
      super.copyWith((message) => updates(message as StopAutoCollectResponse))
          as StopAutoCollectResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopAutoCollectResponse create() => StopAutoCollectResponse._();
  @$core.override
  StopAutoCollectResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StopAutoCollectResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StopAutoCollectResponse>(create);
  static StopAutoCollectResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
