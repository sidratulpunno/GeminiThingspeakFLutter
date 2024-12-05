import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:thingspeak/valueState.dart';

const apiKey =
    'AIzaSyDoE107-VUexohs5AvLoktkBAzLObP-nJ0'; // Replace with your actual API key

class GenerativeAIScreen extends StatefulWidget {
  @override
  _GenerativeAIScreenState createState() => _GenerativeAIScreenState();
}

class _GenerativeAIScreenState extends State<GenerativeAIScreen> {
  final cropTextController = TextEditingController();
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  @override
  void dispose() {
    cropTextController.dispose();
    super.dispose();
  }

  String _generatedText = ''; // To store the generated text
  bool _isLoading = false; // To show a loading indicator during API call

  // Function to generate text from the AI model
  Future<void> _generateText() async {
    setState(() {
      _isLoading = true;
    });

    final prompt =
        'I am farming ${cropTextController.text}, temperature is ${ValueState.value[0]} celsius and humidity is ${ValueState.value[1]} and soil moisture is ${ValueState.value[2]} and water level is ${ValueState.value[3]} and mqtt value is ${ValueState.value[4]} .I am from Bangladesh.Please give me some tips within 300 words like what should i do and what pesticide or fertilizer i should use point by point and don\'t give my data and disclaimer back.';
    final content = [Content.text(prompt)];

    try {
      final response = await _model.generateContent(content);
      setState(() {
        if (cropTextController.text.isEmpty) {
          _generatedText = 'Crop field cannot be empty';
        } else {
          _generatedText = response.text ?? 'No response from the model';
          print(_generatedText);
        }
      });
    } catch (e) {
      setState(() {
        _generatedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Farming Suggestions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get AI-based tips for your crops!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: cropTextController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                hintText: 'E.g., Tomato, Wheat',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purpleAccent),
                ),
                labelStyle: TextStyle(color: Colors.purple),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) return 'Crop name cannot be empty';
                return null;
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Get Suggestions',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: _generatedText.isEmpty
                    ? const Center(
                        child: Text(
                          'Press the button to get suggestions.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.deepPurple[50],
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _generatedText,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.deepPurple[900],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
