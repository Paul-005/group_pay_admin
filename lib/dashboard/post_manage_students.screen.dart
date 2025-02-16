import 'package:flutter/material.dart';

class StudentSelectionScreen extends StatefulWidget {
  @override
  _StudentSelectionScreenState createState() => _StudentSelectionScreenState();
}

class _StudentSelectionScreenState extends State<StudentSelectionScreen> {
  bool _applyToAll = false;
  bool _selectAll = false;
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final Set<String> _selectedStudents = {};

  // Sample student data
  final List<Map<String, dynamic>> _students = List.generate(
    20,
    (index) => {
      'id': 'S${index + 1}',
      'name': 'Student ${index + 1}',
      'department': index % 2 == 0 ? 'Computer Science' : 'Electronics',
      'year': '${(index % 4) + 1}',
    },
  );

  List<Map<String, dynamic>> get filteredStudents {
    return _students.where((student) {
      final searchMatch = student['name']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      if (_selectedFilter == 'All') return searchMatch;
      return searchMatch && student['department'] == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Student Selection',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Manual Selection Section
            Card(
              margin: EdgeInsets.fromLTRB(16, 5, 16, 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Student Distrubution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${_selectedStudents.length} selected',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Select All Option
                    if (!_applyToAll)
                      CheckboxListTile(
                        value: _selectAll,
                        onChanged: (value) {
                          setState(() {
                            _selectAll = value ?? false;
                            if (_selectAll) {
                              _selectedStudents.addAll(filteredStudents
                                  .map((s) => s['id'].toString()));
                            } else {
                              _selectedStudents.clear();
                            }
                          });
                        },
                        title: Text(
                          'Select All Students',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        activeColor: Colors.deepPurple,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    SizedBox(height: 16),
                    // Students List
                    if (!_applyToAll) ...[
                      ...filteredStudents.map((student) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Card(
                              elevation: 0,
                              color: Colors.grey[100],
                              child: CheckboxListTile(
                                value: _selectedStudents
                                    .contains(student['id'].toString()),
                                onChanged: (value) {
                                  setState(() {
                                    if (value ?? false) {
                                      _selectedStudents
                                          .add(student['id'].toString());
                                    } else {
                                      _selectedStudents
                                          .remove(student['id'].toString());
                                    }
                                    _selectAll = filteredStudents.every((s) =>
                                        _selectedStudents
                                            .contains(s['id'].toString()));
                                  });
                                },
                                title: Text(
                                  student['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                subtitle: Text(
                                  '${student['department']} - Year ${student['year']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                activeColor: Colors.deepPurple,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          )),
                    ] else
                      Center(
                        child: Text(
                          'Manual selection disabled when applying to all students',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              height: 56,
              margin: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // Handle next action
                  if (_applyToAll || _selectedStudents.isNotEmpty) {
                    // Navigate to next screen or process selection
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Create Post',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
