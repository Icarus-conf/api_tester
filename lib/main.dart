import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ApiCheckerScreen(),
    );
  }
}

class ApiCheckerScreen extends StatefulWidget {
  const ApiCheckerScreen({super.key});

  @override
  _ApiCheckerScreenState createState() => _ApiCheckerScreenState();
}

class _ApiCheckerScreenState extends State<ApiCheckerScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _loading = false;
  String _message = '';
  int? _statusCode;

  // Method to check API validity
  Future<void> checkApiValidity() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      showToast("URL cannot be empty!", success: false);
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
      _statusCode = null;
    });

    try {
      // Send the request to the entered URL
      final response = await http.get(Uri.parse(url));

      setState(() {
        _statusCode = response.statusCode;
      });

      if (response.statusCode == 200) {
        // Check if CORS headers are present
        final corsHeaders = response.headers['access-control-allow-origin'];
        if (corsHeaders == null) {
          setState(() {
            _message =
                "Success, but CORS headers not found. API might block cross-origin requests.";
          });
          showToast("API Success, but CORS not allowed", success: false);
        } else {
          setState(() {
            _message =
                "Success! The API is valid and allows cross-origin requests.";
          });
          showToast("API Success (200) - OK with CORS", success: true);
        }
      } else {
        setState(() {
          _message =
              "Error: API returned status code ${response.statusCode} (${response.reasonPhrase}).";
        });
        showToast(
          "API Error: ${response.statusCode} - ${response.reasonPhrase}",
          success: false,
        );
      }
    } catch (e) {
      setState(() {
        _message = "Error: Invalid URL or the API is not reachable.";
      });
      showToast("Invalid URL or no response from API", success: false);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Helper method to show toast notifications
  void showToast(String message, {bool success = true}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: success ? Colors.green : Colors.red,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Checker')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter API URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF172a3a),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: checkApiValidity,
                        child: const Text(
                          'Check API',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              _statusCode != null
                  ? Text(
                      'HTTP Status Code: $_statusCode $_message',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    )
                  : Container(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
