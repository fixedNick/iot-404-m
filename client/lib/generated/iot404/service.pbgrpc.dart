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

import 'service.pb.dart' as $0;

export 'service.pb.dart';

@$pb.GrpcServiceName('iot404.v1.ESP8266Service')
class ESP8266ServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ESP8266ServiceClient(super.channel, {super.options, super.interceptors});

  /// -- getters
  $grpc.ResponseFuture<$0.WindSpeedResponse> windSpeed(
    $0.WindSpeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$windSpeed, request, options: options);
  }

  $grpc.ResponseFuture<$0.TemperatureResponse> temperature(
    $0.TemperatureRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$temperature, request, options: options);
  }

  $grpc.ResponseFuture<$0.HumidityResponse> humidity(
    $0.HumidityRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$humidity, request, options: options);
  }

  /// -- end getters
  $grpc.ResponseFuture<$0.AutoCollectResponse> autoCollect(
    $0.AutoCollectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$autoCollect, request, options: options);
  }

  $grpc.ResponseFuture<$0.StopAutoCollectResponse> stopAutoCollect(
    $0.StopAutoCollectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stopAutoCollect, request, options: options);
  }

  // method descriptors

  static final _$windSpeed =
      $grpc.ClientMethod<$0.WindSpeedRequest, $0.WindSpeedResponse>(
          '/iot404.v1.ESP8266Service/WindSpeed',
          ($0.WindSpeedRequest value) => value.writeToBuffer(),
          $0.WindSpeedResponse.fromBuffer);
  static final _$temperature =
      $grpc.ClientMethod<$0.TemperatureRequest, $0.TemperatureResponse>(
          '/iot404.v1.ESP8266Service/Temperature',
          ($0.TemperatureRequest value) => value.writeToBuffer(),
          $0.TemperatureResponse.fromBuffer);
  static final _$humidity =
      $grpc.ClientMethod<$0.HumidityRequest, $0.HumidityResponse>(
          '/iot404.v1.ESP8266Service/Humidity',
          ($0.HumidityRequest value) => value.writeToBuffer(),
          $0.HumidityResponse.fromBuffer);
  static final _$autoCollect =
      $grpc.ClientMethod<$0.AutoCollectRequest, $0.AutoCollectResponse>(
          '/iot404.v1.ESP8266Service/AutoCollect',
          ($0.AutoCollectRequest value) => value.writeToBuffer(),
          $0.AutoCollectResponse.fromBuffer);
  static final _$stopAutoCollect =
      $grpc.ClientMethod<$0.StopAutoCollectRequest, $0.StopAutoCollectResponse>(
          '/iot404.v1.ESP8266Service/StopAutoCollect',
          ($0.StopAutoCollectRequest value) => value.writeToBuffer(),
          $0.StopAutoCollectResponse.fromBuffer);
}

@$pb.GrpcServiceName('iot404.v1.ESP8266Service')
abstract class ESP8266ServiceBase extends $grpc.Service {
  $core.String get $name => 'iot404.v1.ESP8266Service';

  ESP8266ServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.WindSpeedRequest, $0.WindSpeedResponse>(
        'WindSpeed',
        windSpeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.WindSpeedRequest.fromBuffer(value),
        ($0.WindSpeedResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.TemperatureRequest, $0.TemperatureResponse>(
            'Temperature',
            temperature_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.TemperatureRequest.fromBuffer(value),
            ($0.TemperatureResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HumidityRequest, $0.HumidityResponse>(
        'Humidity',
        humidity_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HumidityRequest.fromBuffer(value),
        ($0.HumidityResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.AutoCollectRequest, $0.AutoCollectResponse>(
            'AutoCollect',
            autoCollect_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.AutoCollectRequest.fromBuffer(value),
            ($0.AutoCollectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StopAutoCollectRequest,
            $0.StopAutoCollectResponse>(
        'StopAutoCollect',
        stopAutoCollect_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.StopAutoCollectRequest.fromBuffer(value),
        ($0.StopAutoCollectResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.WindSpeedResponse> windSpeed_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WindSpeedRequest> $request) async {
    return windSpeed($call, await $request);
  }

  $async.Future<$0.WindSpeedResponse> windSpeed(
      $grpc.ServiceCall call, $0.WindSpeedRequest request);

  $async.Future<$0.TemperatureResponse> temperature_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TemperatureRequest> $request) async {
    return temperature($call, await $request);
  }

  $async.Future<$0.TemperatureResponse> temperature(
      $grpc.ServiceCall call, $0.TemperatureRequest request);

  $async.Future<$0.HumidityResponse> humidity_Pre($grpc.ServiceCall $call,
      $async.Future<$0.HumidityRequest> $request) async {
    return humidity($call, await $request);
  }

  $async.Future<$0.HumidityResponse> humidity(
      $grpc.ServiceCall call, $0.HumidityRequest request);

  $async.Future<$0.AutoCollectResponse> autoCollect_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AutoCollectRequest> $request) async {
    return autoCollect($call, await $request);
  }

  $async.Future<$0.AutoCollectResponse> autoCollect(
      $grpc.ServiceCall call, $0.AutoCollectRequest request);

  $async.Future<$0.StopAutoCollectResponse> stopAutoCollect_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StopAutoCollectRequest> $request) async {
    return stopAutoCollect($call, await $request);
  }

  $async.Future<$0.StopAutoCollectResponse> stopAutoCollect(
      $grpc.ServiceCall call, $0.StopAutoCollectRequest request);
}
