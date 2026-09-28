import 'package:flutter/material.dart';
import 'bluetooth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late BluetoothService _btService;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final Map<String, String> _nearbyDevices = {}; // endpointId: name
  String? _connectedEndpointId;

  @override
  void initState() {
    super.initState();
    _btService = BluetoothService(
      onMessageReceived: (text, isMe) {
        setState(() {
          _messages.add({'text': text, 'isMe': isMe});
        });
      },
      onDeviceFound: (name, id) {
        setState(() {
          _nearbyDevices[id] = name;
        });
      },
    );
    _initBluetooth();
  }

  void _initBluetooth() async {
    bool granted = await _btService.requestPermissions();
    if (granted) {
      _btService.startDiscoveryAndAdvertise("کاربر پارس پیام");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پارس پیام (آفلاین)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_searching),
            onPressed: _showDevicesDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? const Color(0xFF2B5278) : const Color(0xFF182533),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color(0xFF17212B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'پیام خود را بنویسید...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF64B5F6)),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty && _connectedEndpointId != null) {
                      _btService.sendMessage(_connectedEndpointId!, _messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF242F3D),
        title: const Text('دستگاه‌های نزدیک'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: _nearbyDevices.entries.map((entry) {
              return ListTile(
                title: Text(entry.value),
                onTap: () {
                  _btService.connectToDevice("کاربر پارس پیام", entry.key);
                  setState(() => _connectedEndpointId = entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}