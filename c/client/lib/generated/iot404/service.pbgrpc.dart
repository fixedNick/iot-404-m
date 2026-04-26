// This is a generated file - do not edit.
//
// Generated from service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

import 'service.pb.dart' as $1;

export 'service.pb.dart';

@$pb.GrpcServiceName('iot404.ESP8266')
class ESP8266Client extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ESP8266Client(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.WindSpeedResponse> windspeed(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$windspeed, request, options: options);
  }

  // method descriptors

  static final _$windspeed = $grpc.ClientMethod<$0.Empty, $1.WindSpeedResponse>(
      '/iot404.ESP8266/windspeed',
      ($0.Empty value) => value.writeToBuffer(),
      $1.WindSpeedResponse.fromBuffer);
}

@$pb.GrpcServiceName('iot404.ESP8266')
abstract class ESP8266ServiceBase extends $grpc.Service {
  $core.String get $name => 'iot404.ESP8266';

  ESP8266ServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.WindSpeedResponse>(
        'windspeed',
        windspeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.WindSpeedResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.WindSpeedResponse> windspeed_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return windspeed($call, await $request);
  }

  $async.Future<$1.WindSpeedResponse> windspeed(
      $grpc.ServiceCall call, $0.Empty request);
}
