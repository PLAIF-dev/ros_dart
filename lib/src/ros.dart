part of '../ros_dart.dart';

/// [RosRequest] 를 보내고 받는 것을 관리하는 class
abstract interface class Ros {
  /// 실제 구현을 factory constructor 로만 접근가능하도록 강제함
  /// 더욱 설명적이기 때문
  factory Ros.implement() = RosImpl._;

  /// ROSBridge 와 연결하기 위한 method
  /// [Uri] 를 변수로 넣을 때는 다음과 같은 양식을 따르는 것을 추천
  /// ```dart
  /// Uri.parse('ws://~:9090')
  /// ```
  Future<void> connect(Uri uri);

  /// [RosRequest] 를 보내 응답을 받는 메소드
  Stream<Map<String, dynamic>> send(RosRequest request);

  ///
  FutureOr<void> disconnect();
}

/// [Ros] 실제 구현. [WebSocket] 을 이용함
class RosImpl implements Ros {
  RosImpl._();

  /// Websocket 관리 객체
  /// Dependency Injection 으로 테스트 가능하게 처리하고 싶었으나
  /// 비동기로 객체를 만드는 방법 밖에 없고, 구조가 복잡해지기 때문에 하지 못했음
  WebSocket? _socket;

  @override
  Future<void> connect(Uri uri) async {
    try {
      _socket = await WebSocket.connect(uri.toString());
    } on SocketException {
      rethrow;
    }
  }

  @override
  FutureOr<void> disconnect() {
    _socket?.close();
  }

  @override
  Stream<Map<String, dynamic>> send(RosRequest request) {
    // 즉, 연결을 하지 않았다는 의미
    if (_socket == null) {
      throw const NoRosConnectionException();
    }

    // 요청 전송
    _socket!.add(request.toJson());

    // response 를 기다릴 필요가 없다면, 이후에 있는 StreamController, StreamSubscription
    // 등을 instance 화 할 필요 없기 때문에 처리
    if (!request.hasResponse) {
      return const Stream.empty();
    }

    // stream 을 쉽게 처리할 수 있도록 도와줌
    final controller = StreamController<Map<String, dynamic>>();
    late StreamSubscription<dynamic> subscription;
    subscription = _socket!.listen(
      (raw) => _onData(raw, request, controller),
      onDone: () {
        subscription.cancel();
        controller.close();
      },
      onError: () {
        subscription.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  void _onData(dynamic raw, RosRequest request, StreamController controller) {
    final deserializedData =
        json.decode(raw.toString()) as Map<String, dynamic>;

    // Stream 에 들어온 역직렬화한 응답이 유효한 응답이 아니라면 무시
    if (!request.didGetValidResponse(deserializedData)) {
      return;
    }

    // 유효한 응답으로 내보내기
    controller.add(deserializedData);
  }
}
