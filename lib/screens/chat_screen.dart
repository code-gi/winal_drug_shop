import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'medications_screen.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;
  File? _image;

  // Predefined responses for demo purposes
  final Map<String, String> _responseMap = {
    'hello': 'Hello! How can I help you today?',
    'hi': 'Hi there! How can the Winal Drug Shop team assist you?',
    'medicine': 'We offer a wide range of medicines for both humans and animals. What specific medicine are you looking for?',
    'prescription': 'You can upload a photo of your prescription using the + button, and our pharmacist will assist you.',
    'price': 'Prices vary based on the medication. Please let us know which product you\'re interested in.',
    'location': 'We are located at 123 Health Street. You can also get medications delivered to your location.',
    'delivery': 'Yes, we offer same-day delivery for orders placed before 2 PM.',
    'hours': 'We are open Monday to Saturday from 8 AM to 8 PM, and Sunday from 10 AM to 6 PM.',
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // Add welcome message
    Future.delayed(const Duration(milliseconds: 500), () {
      _addBotMessage("Hi there! How can I help you with your health needs today?");
    });
  }

  // Initialize speech to text functionality
  void _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _addUserMessage(message);
      _messageController.clear();
      
      // Generate response with delay
      Future.delayed(const Duration(milliseconds: 800), () {
        _generateResponse(message.toLowerCase());
      });
    }
  }
  
  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
  }
  
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
      ));
    });
  }

  void _generateResponse(String userText) {
    bool responded = false;
    
    _responseMap.forEach((key, value) {
      if (userText.contains(key)) {
        _addBotMessage(value);
        responded = true;
      }
    });
    
    if (!responded) {
      _addBotMessage("Thank you for your message. One of our pharmacists will respond shortly. Is there anything else I can help you with?");
    }
  }
  
  // Actual image picker implementation
  Future<void> _pickImage() async {
    try {
      // Request camera permission first
      var status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        return;
      }
      
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, // or ImageSource.gallery for choosing from gallery
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        
        // Add a message about the actual image
        _addUserMessage("[You shared an image: ${pickedFile.name}]");
        
        // Generate response
        Future.delayed(const Duration(milliseconds: 800), () {
          _addBotMessage("Thank you for sharing your prescription. Our pharmacist will review it and get back to you shortly. Would you like to schedule a pickup or delivery?");
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  // Actual voice recording implementation
  void _toggleVoiceRecording() async {
    // Check microphone permission
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
      return;
    }
    
    if (!_isRecording) {
      setState(() {
        _isRecording = true;
      });
      
      // Show recording in progress
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording... Speak now')),
      );
      
      if (_speechEnabled) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          partialResults: true,
          onSoundLevelChange: (level) {
            // You can use this to show a visual indicator of sound level
          },
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    } else {
      setState(() {
        _isRecording = false;
      });
      
      _speech.stop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording stopped')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Blue header section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and shop name
                  Row(
                    children: [
                      // Cow icon
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Winal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Drug Shop',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Welcome message
                  const Text(
                    'Welcome to Winal Drug shop, your entrusted health care partner; we are here to ensure human and animal health plus wellness needs are met with excellent care',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // How can we help you?
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Message input field with interactive buttons
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Send us a message',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                            ),
                            onSubmitted: (_) => _handleSendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Plus button for image upload - Now works with actual functionality
                        InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Mic button for voice recording - Now works with actual functionality
                        InkWell(
                          onTap: _toggleVoiceRecording,
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 20,
                            color: _isRecording ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Send button
                        InkWell(
                          onTap: _handleSendMessage,
                          child: const Icon(
                            Icons.send,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chat messages area
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("Start a conversation", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser 
                            ? Alignment.centerRight 
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Back button at the bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _speech.stop();
    super.dispose();
  }
}

// Simplified chat message class
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}