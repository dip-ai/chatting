import 'package:flutter/material.dart';

import '../ThirdPage/chat_page.dart';

class Contact {
  final String name;
  final String imagePath;
  final String lastMessage;

  Contact({
    required this.name,
    required this.imagePath,
    required this.lastMessage,
  });
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Contact> _contacts = [
    Contact(
      name: 'Steve Rogers',
      imagePath: 'assets/images/sr.jfif',
      lastMessage: 'I can do that all day',
    ),
    Contact(
      name: 'Tony Stark',
      imagePath: 'assets/images/ts.jfif',
      lastMessage:
          'It\'s not about how much we lost, it\'s about how much we have left',
    ),
    Contact(
      name: 'Peter Parker',
      imagePath: 'assets/images/pp.jfif',
      lastMessage: 'I\'ve lost Gwen. Umm.. She is my MJ',
    ),
    Contact(
      name: 'Bruce Wayne',
      imagePath: 'assets/images/bw.jpg',
      lastMessage: 'Men are brave',
    ),
    Contact(
      name: 'Arther fleck',
      imagePath: 'assets/images/af.jfif',
      lastMessage:
          'I used to think life was a tragedy, but now I realize it\'s a comedy!',
    ),
    Contact(
      name: 'Harry Potter',
      imagePath: 'assets/images/hp.jpg',
      lastMessage: 'I solemnly swear that I am up to no good',
    ),
    Contact(
      name: 'Thor',
      imagePath: 'assets/images/thor.jpg',
      lastMessage: 'I\'m still worthy',
    ),
    Contact(
      name: 'Clerk Kent',
      imagePath: 'assets/images/ck.jfif',
      lastMessage: 'There is a superhero in all of us',
    ),
    Contact(
      name: 'Arya Starck',
      imagePath: 'assets/images/as.jpg',
      lastMessage: 'Leave one wolf alive and the sheep are never safe',
    ),
    Contact(
      name: 'Cersei Lannister',
      imagePath: 'assets/images/cl.jfif',
      lastMessage:
          'What good is power if you cannot protect the ones you love?',
    ),
    Contact(
      name: 'Daenerys Targaryen',
      imagePath: 'assets/images/dt.jpg',
      lastMessage:
          'I\'m not going to stop the wheel, I\'m going to break the wheel',
    ),
    Contact(
      name: 'Jaime Lannister',
      imagePath: 'assets/images/jl.jfif',
      lastMessage:
          'As long as I\'m better than everyone else I suppose it doesn\'t matter',
    ),
    Contact(
      name: 'Tyrion Lannister',
      imagePath: 'assets/images/tl.jfif',
      lastMessage: '“Winter is coming. We know what’s coming with it',
    ),
  ];
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts.addAll(_contacts);
  }

  void _filterContacts(String query) {
    query = query.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateToChatScreen(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(contact: contact),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: const InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit_note_outlined),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        AssetImage(_filteredContacts[index].imagePath),
                  ),
                  title: Text(_filteredContacts[index].name),
                  subtitle: Text(
                    _filteredContacts[index].lastMessage,
                    maxLines: 1,
                  ),
                  onTap: () => _navigateToChatScreen(_filteredContacts[index]),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 14, right: 12),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: "",
              icon: ImageIcon(
                AssetImage("assets/images/globe.png"),
                color: Colors.black54,
              ),
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Icon(
                Icons.wechat_rounded,
                color: Color(0xFF5A1BF8),
                size: 30,
              ),
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Icon(
                Icons.phone,
                color: Colors.black54,
              ),
            ),
            BottomNavigationBarItem(
              label: "",
              icon: Icon(
                Icons.settings,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
            onPressed: () {}, child: const Icon(Icons.add)),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
