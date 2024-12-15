
import 'package:ems/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Management System',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _domainController.text = existingJournal['domain'];
      _locationController.text = existingJournal['location'];
      _phoneNumberController.text = existingJournal['phoneNumber'];
      _emailController.text = existingJournal['email'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTextField(_titleController, 'Employee Name', Icons.person),
              const SizedBox(height: 10),
              _buildTextField(_domainController, 'Domain', Icons.work),
              const SizedBox(height: 10),
              _buildTextField(_locationController, 'Location', Icons.location_on),
              const SizedBox(height: 10),
              _buildTextField(_phoneNumberController, 'Phone Number', Icons.phone),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  } else {
                    await _updateItem(id);
                  }
                  _clearTextFields();
                  Navigator.of(context).pop();
                },
                icon: Icon(id == null ? Icons.add : Icons.update),
                label: Text(id == null ? 'Create New' : 'Update'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.orange[50],
      ),
    );
  }

  void _clearTextFields() {
    _titleController.clear();
    _domainController.clear();
    _locationController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text,
      _domainController.text,
      _locationController.text,
      _phoneNumberController.text,
      _emailController.text,
    );
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
      id,
      _titleController.text,
      _domainController.text,
      _locationController.text,
      _phoneNumberController.text,
      _emailController.text,
    );
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted an employee!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Action for search button
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Action for account button
            },
          ),
        ],
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.orange[50],
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
            elevation: 2,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _journals[index]['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'ID: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_journals[index]['id']}'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Domain: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_journals[index]['domain']}'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Location: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_journals[index]['location']}'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Phone: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_journals[index]['phoneNumber']}'),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Email: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${_journals[index]['email']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showForm(_journals[index]['id']),
                      ),
                      IconButton(
                        iconSize: 20,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(_journals[index]['id']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
