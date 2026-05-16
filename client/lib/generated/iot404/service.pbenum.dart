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

/// Типы сенсоров
class SensorType extends $pb.ProtobufEnum {
  static const SensorType SENSOR_TYPE_UNSPECIFIED =
      SensorType._(0, _omitEnumNames ? '' : 'SENSOR_TYPE_UNSPECIFIED');
  static const SensorType SENSOR_TYPE_TEMPERATURE =
      SensorType._(1, _omitEnumNames ? '' : 'SENSOR_TYPE_TEMPERATURE');
  static const SensorType SENSOR_TYPE_HUMIDITY =
      SensorType._(2, _omitEnumNames ? '' : 'SENSOR_TYPE_HUMIDITY');
  static const SensorType SENSOR_TYPE_WIND =
      SensorType._(3, _omitEnumNames ? '' : 'SENSOR_TYPE_WIND');

  static const $core.List<SensorType> values = <SensorType>[
    SENSOR_TYPE_UNSPECIFIED,
    SENSOR_TYPE_TEMPERATURE,
    SENSOR_TYPE_HUMIDITY,
    SENSOR_TYPE_WIND,
  ];

  static final $core.List<SensorType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SensorType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SensorType._(super.value, super.name);
}

/// Типы временных периодов
class PeriodType extends $pb.ProtobufEnum {
  static const PeriodType PERIOD_TYPE_UNSPECIFIED =
      PeriodType._(0, _omitEnumNames ? '' : 'PERIOD_TYPE_UNSPECIFIED');
  static const PeriodType PERIOD_TYPE_DAY =
      PeriodType._(1, _omitEnumNames ? '' : 'PERIOD_TYPE_DAY');
  static const PeriodType PERIOD_TYPE_WEEK =
      PeriodType._(2, _omitEnumNames ? '' : 'PERIOD_TYPE_WEEK');
  static const PeriodType PERIOD_TYPE_MONTH =
      PeriodType._(3, _omitEnumNames ? '' : 'PERIOD_TYPE_MONTH');

  static const $core.List<PeriodType> values = <PeriodType>[
    PERIOD_TYPE_UNSPECIFIED,
    PERIOD_TYPE_DAY,
    PERIOD_TYPE_WEEK,
    PERIOD_TYPE_MONTH,
  ];

  static final $core.List<PeriodType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PeriodType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PeriodType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
