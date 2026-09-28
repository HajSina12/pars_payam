import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final Function(String message, bool isMe) onMessageReceived;
  final Function(String userName, String endpointId) onDeviceFound;

  BluetoothService({
    required this.onMessageReceived,
    required this.onDeviceFound,
  });

  // درخواست مجوزهای دسترسی بلوتوث و مکان
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // شروع انتشار حضور و جستجوی کاربران نزدیک
  Future<void> startDiscoveryAndAdvertise(String myName) async {
    try {
      // ۱. آماده‌سازی برای شناسایی توسط دیگران
      await Nearby().startAdvertising(
        myName,
        strategy,
        onConnectionInitiated: (id, info) => _acceptConnection(id),
        onConnectionResult: (id, status) {},
        onDisconnected: (id) {},
      );

      // ۲. جستجو برای یافتن دیگران
      await Nearby().startDiscovery(
        myName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          onDeviceFound(name, id);
        },
        onEndpointLost: (id) {},
      );
    } catch (e) {
      print("خطا در سرویس بلوتوث: $e");
    }
  }

  void _acceptConnection(String endpointId) {
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (id, payload) {
        if (payload.type == PayloadType.BYTES) {
          String text = String.fromCharCodes(payload.bytes!);
          onMessageReceived(text, false);
        }
      },
    );
  }

  // اتصال به کاربر انتخابی
  void connectToDevice(String myName, String endpointId) {
    Nearby().requestConnection(
      myName,
      endpointId,
      onConnectionInitiated: (id, info) => _acceptConnection(id),
      onConnectionResult: (id, status) {},
      onDisconnected: (id) {},
    );
  }

  // ارسال پیام متنی
  void sendMessage(String endpointId, String text) {
    Nearby().sendBytesPayload(
      endpointId,
      Uint8List.fromList(text.codeUnits),
    );
    onMessageReceived(text, true);
  }
}