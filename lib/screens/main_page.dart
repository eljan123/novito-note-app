import 'package:flutter/material.dart';
import 'notes_home_page.dart';
import 'todo_list_page.dart';
import 'folder_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  
  // List of pages to display
  final List<Widget> _pages = [
    const NotesHomePage(),
    const FolderPage(),
    const TodoListPage(),
  ];

  // Function to change the selected page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Close the drawer after selection
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // End Drawer menu (opens from right)
      endDrawer: Drawer(
        backgroundColor: const Color(0xFF212121),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Novito',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Your Student Companion',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note, color: Colors.orange),
              title: const Text(
                'All Notes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              selected: _selectedIndex == 0,
              selectedTileColor: Colors.black26,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.orange),
              title: const Text(
                'Folders',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              selected: _selectedIndex == 1,
              selectedTileColor: Colors.black26,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.check_box, color: Colors.orange),
              title: const Text(
                'To-Do List',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              selected: _selectedIndex == 2,
              selectedTileColor: Colors.black26,
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      // Display the selected page
      body: _pages[_selectedIndex],
    );
  }
} 
