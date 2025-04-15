import 'package:flutter/material.dart';

class FAQsScreen extends StatefulWidget {
  const FAQsScreen({Key? key}) : super(key: key);

  @override
  _FAQsScreenState createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredFaqs = [];

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Where are you located?',
      'answer': 'We are located in Nateete, Uganda, near the city center.'
    },
    {
      'question': 'May I know your working hours?',
      'answer': 'We are open from 8:00 AM to 8:00 PM, Monday through Saturday.'
    },
    {
      'question': 'How may I contact Winal drug shop?',
      'answer': 'You can contact us on 0701550075'
    },
    {
      'question': 'Which delivery options are available?',
      'answer':
          'We offer delivery through public taxis and buses, as well as private courier services.'
    },
    {
      'question':
          'Who is responsible for the damages to orders delivered through public means?',
      'answer':
          'We ensure secure packaging but are not liable for damages caused by third-party transportation.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs = _faqs.where((faq) {
        return faq['question']!.toLowerCase().contains(query) ||
            faq['answer']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'FAQs',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search.....",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFaqs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(_filteredFaqs[index]['question']!),
                            content: Text(_filteredFaqs[index]['answer']!),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 238, 239),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _filteredFaqs[index]['question']!,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
