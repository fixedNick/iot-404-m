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
