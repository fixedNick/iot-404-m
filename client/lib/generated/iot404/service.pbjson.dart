// This is a generated file - do not edit.
//
// Generated from service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sensorTypeDescriptor instead')
const SensorType$json = {
  '1': 'SensorType',
  '2': [
    {'1': 'SENSOR_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SENSOR_TYPE_TEMPERATURE', '2': 1},
    {'1': 'SENSOR_TYPE_HUMIDITY', '2': 2},
    {'1': 'SENSOR_TYPE_WIND', '2': 3},
  ],
};

/// Descriptor for `SensorType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sensorTypeDescriptor = $convert.base64Decode(
    'CgpTZW5zb3JUeXBlEhsKF1NFTlNPUl9UWVBFX1VOU1BFQ0lGSUVEEAASGwoXU0VOU09SX1RZUE'
    'VfVEVNUEVSQVRVUkUQARIYChRTRU5TT1JfVFlQRV9IVU1JRElUWRACEhQKEFNFTlNPUl9UWVBF'
    'X1dJTkQQAw==');

@$core.Deprecated('Use periodTypeDescriptor instead')
const PeriodType$json = {
  '1': 'PeriodType',
  '2': [
    {'1': 'PERIOD_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'PERIOD_TYPE_DAY', '2': 1},
    {'1': 'PERIOD_TYPE_WEEK', '2': 2},
    {'1': 'PERIOD_TYPE_MONTH', '2': 3},
  ],
};

/// Descriptor for `PeriodType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List periodTypeDescriptor = $convert.base64Decode(
    'CgpQZXJpb2RUeXBlEhsKF1BFUklPRF9UWVBFX1VOU1BFQ0lGSUVEEAASEwoPUEVSSU9EX1RZUE'
    'VfREFZEAESFAoQUEVSSU9EX1RZUEVfV0VFSxACEhUKEVBFUklPRF9UWVBFX01PTlRIEAM=');

@$core.Deprecated('Use getSensorStatusRequestDescriptor instead')
const GetSensorStatusRequest$json = {
  '1': 'GetSensorStatusRequest',
  '2': [
    {'1': 'sensor', '3': 1, '4': 1, '5': 9, '10': 'sensor'},
  ],
};

/// Descriptor for `GetSensorStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorStatusRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRTZW5zb3JTdGF0dXNSZXF1ZXN0EhYKBnNlbnNvchgBIAEoCVIGc2Vuc29y');

@$core.Deprecated('Use getSensorStatusResponseDescriptor instead')
const GetSensorStatusResponse$json = {
  '1': 'GetSensorStatusResponse',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
  ],
};

/// Descriptor for `GetSensorStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorStatusResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRTZW5zb3JTdGF0dXNSZXNwb25zZRIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVk');

@$core.Deprecated('Use windSpeedRequestDescriptor instead')
const WindSpeedRequest$json = {
  '1': 'WindSpeedRequest',
};

/// Descriptor for `WindSpeedRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List windSpeedRequestDescriptor =
    $convert.base64Decode('ChBXaW5kU3BlZWRSZXF1ZXN0');

@$core.Deprecated('Use temperatureRequestDescriptor instead')
const TemperatureRequest$json = {
  '1': 'TemperatureRequest',
};

/// Descriptor for `TemperatureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temperatureRequestDescriptor =
    $convert.base64Decode('ChJUZW1wZXJhdHVyZVJlcXVlc3Q=');

@$core.Deprecated('Use humidityRequestDescriptor instead')
const HumidityRequest$json = {
  '1': 'HumidityRequest',
};

/// Descriptor for `HumidityRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List humidityRequestDescriptor =
    $convert.base64Decode('Cg9IdW1pZGl0eVJlcXVlc3Q=');

@$core.Deprecated('Use windSpeedResponseDescriptor instead')
const WindSpeedResponse$json = {
  '1': 'WindSpeedResponse',
  '2': [
    {'1': 'voltage', '3': 1, '4': 1, '5': 2, '10': 'voltage'},
    {'1': 'speed', '3': 2, '4': 1, '5': 2, '10': 'speed'},
    {'1': 'time', '3': 3, '4': 1, '5': 3, '10': 'time'},
  ],
};

/// Descriptor for `WindSpeedResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List windSpeedResponseDescriptor = $convert.base64Decode(
    'ChFXaW5kU3BlZWRSZXNwb25zZRIYCgd2b2x0YWdlGAEgASgCUgd2b2x0YWdlEhQKBXNwZWVkGA'
    'IgASgCUgVzcGVlZBISCgR0aW1lGAMgASgDUgR0aW1l');

@$core.Deprecated('Use temperatureResponseDescriptor instead')
const TemperatureResponse$json = {
  '1': 'TemperatureResponse',
  '2': [
    {'1': 'temperature', '3': 1, '4': 1, '5': 2, '10': 'temperature'},
    {'1': 'time', '3': 2, '4': 1, '5': 3, '10': 'time'},
  ],
};

/// Descriptor for `TemperatureResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temperatureResponseDescriptor = $convert.base64Decode(
    'ChNUZW1wZXJhdHVyZVJlc3BvbnNlEiAKC3RlbXBlcmF0dXJlGAEgASgCUgt0ZW1wZXJhdHVyZR'
    'ISCgR0aW1lGAIgASgDUgR0aW1l');

@$core.Deprecated('Use humidityResponseDescriptor instead')
const HumidityResponse$json = {
  '1': 'HumidityResponse',
  '2': [
    {'1': 'humidity', '3': 1, '4': 1, '5': 2, '10': 'humidity'},
    {'1': 'time', '3': 2, '4': 1, '5': 3, '10': 'time'},
  ],
};

/// Descriptor for `HumidityResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List humidityResponseDescriptor = $convert.base64Decode(
    'ChBIdW1pZGl0eVJlc3BvbnNlEhoKCGh1bWlkaXR5GAEgASgCUghodW1pZGl0eRISCgR0aW1lGA'
    'IgASgDUgR0aW1l');

@$core.Deprecated('Use stopAutoCollectRequestDescriptor instead')
const StopAutoCollectRequest$json = {
  '1': 'StopAutoCollectRequest',
  '2': [
    {'1': 'sensor', '3': 1, '4': 1, '5': 9, '10': 'sensor'},
  ],
};

/// Descriptor for `StopAutoCollectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopAutoCollectRequestDescriptor =
    $convert.base64Decode(
        'ChZTdG9wQXV0b0NvbGxlY3RSZXF1ZXN0EhYKBnNlbnNvchgBIAEoCVIGc2Vuc29y');

@$core.Deprecated('Use autoCollectRequestDescriptor instead')
const AutoCollectRequest$json = {
  '1': 'AutoCollectRequest',
  '2': [
    {'1': 'sensor', '3': 1, '4': 1, '5': 9, '10': 'sensor'},
    {'1': 'period', '3': 2, '4': 1, '5': 4, '10': 'period'},
    {'1': 'duration', '3': 3, '4': 1, '5': 4, '10': 'duration'},
  ],
};

/// Descriptor for `AutoCollectRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List autoCollectRequestDescriptor = $convert.base64Decode(
    'ChJBdXRvQ29sbGVjdFJlcXVlc3QSFgoGc2Vuc29yGAEgASgJUgZzZW5zb3ISFgoGcGVyaW9kGA'
    'IgASgEUgZwZXJpb2QSGgoIZHVyYXRpb24YAyABKARSCGR1cmF0aW9u');

@$core.Deprecated('Use autoCollectResponseDescriptor instead')
const AutoCollectResponse$json = {
  '1': 'AutoCollectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `AutoCollectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List autoCollectResponseDescriptor =
    $convert.base64Decode(
        'ChNBdXRvQ29sbGVjdFJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3M=');

@$core.Deprecated('Use stopAutoCollectResponseDescriptor instead')
const StopAutoCollectResponse$json = {
  '1': 'StopAutoCollectResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `StopAutoCollectResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopAutoCollectResponseDescriptor =
    $convert.base64Decode(
        'ChdTdG9wQXV0b0NvbGxlY3RSZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use getSensorStatsRequestDescriptor instead')
const GetSensorStatsRequest$json = {
  '1': 'GetSensorStatsRequest',
  '2': [
    {
      '1': 'sensor',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.iot404.v1.SensorType',
      '10': 'sensor'
    },
    {
      '1': 'period',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.iot404.v1.PeriodType',
      '10': 'period'
    },
    {'1': 'period_offset', '3': 3, '4': 1, '5': 5, '10': 'periodOffset'},
  ],
};

/// Descriptor for `GetSensorStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorStatsRequestDescriptor = $convert.base64Decode(
    'ChVHZXRTZW5zb3JTdGF0c1JlcXVlc3QSLQoGc2Vuc29yGAEgASgOMhUuaW90NDA0LnYxLlNlbn'
    'NvclR5cGVSBnNlbnNvchItCgZwZXJpb2QYAiABKA4yFS5pb3Q0MDQudjEuUGVyaW9kVHlwZVIG'
    'cGVyaW9kEiMKDXBlcmlvZF9vZmZzZXQYAyABKAVSDHBlcmlvZE9mZnNldA==');

@$core.Deprecated('Use dayDataPointDescriptor instead')
const DayDataPoint$json = {
  '1': 'DayDataPoint',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
};

/// Descriptor for `DayDataPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dayDataPointDescriptor = $convert.base64Decode(
    'CgxEYXlEYXRhUG9pbnQSOAoJdGltZXN0YW1wGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIJdGltZXN0YW1wEhQKBXZhbHVlGAIgASgBUgV2YWx1ZQ==');

@$core.Deprecated('Use aggregatedDataPointDescriptor instead')
const AggregatedDataPoint$json = {
  '1': 'AggregatedDataPoint',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'date'
    },
    {'1': 'min', '3': 2, '4': 1, '5': 1, '10': 'min'},
    {'1': 'max', '3': 3, '4': 1, '5': 1, '10': 'max'},
    {'1': 'avg', '3': 4, '4': 1, '5': 1, '10': 'avg'},
  ],
};

/// Descriptor for `AggregatedDataPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aggregatedDataPointDescriptor = $convert.base64Decode(
    'ChNBZ2dyZWdhdGVkRGF0YVBvaW50Ei4KBGRhdGUYASABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUgRkYXRlEhAKA21pbhgCIAEoAVIDbWluEhAKA21heBgDIAEoAVIDbWF4EhAKA2F2'
    'ZxgEIAEoAVIDYXZn');

@$core.Deprecated('Use getSensorStatsResponseDescriptor instead')
const GetSensorStatsResponse$json = {
  '1': 'GetSensorStatsResponse',
  '2': [
    {
      '1': 'day_data',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.iot404.v1.DayDataPoint',
      '10': 'dayData'
    },
    {
      '1': 'aggregated_data',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.iot404.v1.AggregatedDataPoint',
      '10': 'aggregatedData'
    },
  ],
};

/// Descriptor for `GetSensorStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorStatsResponseDescriptor = $convert.base64Decode(
    'ChZHZXRTZW5zb3JTdGF0c1Jlc3BvbnNlEjIKCGRheV9kYXRhGAEgAygLMhcuaW90NDA0LnYxLk'
    'RheURhdGFQb2ludFIHZGF5RGF0YRJHCg9hZ2dyZWdhdGVkX2RhdGEYAiADKAsyHi5pb3Q0MDQu'
    'djEuQWdncmVnYXRlZERhdGFQb2ludFIOYWdncmVnYXRlZERhdGE=');
