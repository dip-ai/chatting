// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../main.dart';

// class BookingPage extends StatefulWidget {
//   const BookingPage({super.key});

//   @override
//   State<BookingPage> createState() => _BookingPageState();
// }

// class Room {
//   final String id;
//   final String number;

//   Room(this.id, this.number);
// }

// class Booking {
//   final String roomNumber;
//   final String roomName;
//   final DateTime bookingDate;

//   Booking({
//     required this.roomNumber,
//     required this.roomName,
//     required this.bookingDate,
//   });
// }

// class _BookingPageState extends State<BookingPage> {
//   DateTime selectedDate = DateTime.now();
//   Room? selectedRoom;
//   bool showDropdown = false;
//   bool showBookButton = false;
//   bool isRoomAvailable = false;
//   List<Room> rooms = [];
//   String availabilityText = '';
//   bool showBookingHistory = false; // State variable to track the visibility
//   List<Booking> pastBookings = []; // List to store past bookings
//   List<Booking> upcomingBookings = []; // List to store upcoming bookings
//   bool showPastBookings = true; // Toggle between past and upcoming bookings

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         showDropdown = true;
//         showBookButton = false;
//         availabilityText = '';
//       });
//       _fetchRoomNumbers();
//     }
//   }

//   Future<void> _fetchRoomNumbers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$apiKey/rooms/available-rooms'),
//       );
//       log(response.statusCode.toString());
//       if (response.statusCode == 200) {
//         List<dynamic> data = jsonDecode(response.body.toString());
//         setState(() {
//           rooms =
//               data.map((item) => Room(item['_id'], item['roomName'])).toList();
//           selectedRoom = null;
//         });
//         log("Fetched rooms: $rooms");
//       } else {
//         throw Exception('Failed to load room numbers');
//       }
//     } catch (e) {
//       log('Error fetching room numbers: $e');
//     }
//   }

//   Future<void> _checkRoomAvailability(Room room) async {
//     try {
//       final String bookingDate = selectedDate.toIso8601String().split('T')[0];
//       SharedPreferences prefs = await SharedPreferences.getInstance();

//       final response = await http.get(
//         Uri.parse(
//             '$apiKey/bookings/availability?roomId=${room.id}&date=$bookingDate'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': "Bearer ${prefs.getString("api_token")}"
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = jsonDecode(response.body);

//         final bool availability =
//             responseBody['availability'] as bool? ?? false;
//         log(response.body);
//         setState(() {
//           isRoomAvailable = availability;
//           availabilityText =
//               availability ? 'Room is available' : 'Room is not available';
//           showBookButton = availability;
//           selectedRoom = availability ? room : null;
//         });

//         log("ok");
//       } else {
//         throw Exception(
//             'Failed to check room availability. Statuscode= ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error checking room availability: $e');
//       setState(() {
//         isRoomAvailable = false;
//         availabilityText = 'Error checking availability';
//         showBookButton = false;
//       });
//     }
//   }

//   Future<void> _bookRoom() async {
//     if (selectedRoom != null && isRoomAvailable) {
//       try {
//         final String bookingDate = selectedDate.toIso8601String().split('T')[0];
//         SharedPreferences prefs = await SharedPreferences.getInstance();

//         final String? userId = prefs.getString("api_id");
//         final String? authToken = prefs.getString("api_token");

//         // Log the userId and token
//         log('Attempting to book room with userId=$userId and token=$authToken');

//         if (userId == null || authToken == null) {
//           throw Exception('User ID or token is null');
//         }

//         final response = await http.post(
//           Uri.parse("$apiKey/bookings/book-seat"),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': "Bearer $authToken"
//           },
//           body: jsonEncode({
//             "userId": userId,
//             "roomId": selectedRoom!.id,
//             "bookingDate": selectedDate.toIso8601String(),
//           }),
//         );

//         if (response.statusCode >= 200 && response.statusCode < 300) {
//           log('Room booked successfully');
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Room booked successfully')),
//           );
//         } else {
//           log('Failed to book room: ${response.statusCode}, ${response.body}');
//           throw Exception('Failed to book room. ${response.statusCode}');
//         }
//       } catch (e) {
//         log('Error booking room: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text(
//                   'Failed to book room. User has another booking on the same date')),
//         );
//       }
//     } else {
//       log('No room selected or room is not available');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('No room selected or room is not available')),
//       );
//     }
//   }

//   void _onRoomSelected(Room room) {
//     _checkRoomAvailability(room);
//   }

//   Future<void> _fetchBookingHistory() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? userId = prefs.getString("api_id");
//       final String? authToken = prefs.getString("api_token");
//       log(userId!);

//       if (userId == null || authToken == null) {
//         throw Exception('User ID or token is null. Please log in again.');
//       }

//       final response = await http.get(
//         Uri.parse('$apiKey/bookings/booking-details?userId=$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': "Bearer $authToken"
//         },
//       );

//       log('Response status: ${response.statusCode}');
//       log('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);

//         if (responseBody is Map) {
//           final List<dynamic> pastData =
//               await responseBody['pastBookings'] ?? [];
//           final List<dynamic> upcomingData =
//               await responseBody['upcomingBookings'] ?? [];

//           setState(() {
//             pastBookings = pastData.map<Booking>((item) {
//               return Booking(
//                 roomNumber: item['roomNumber'] ?? 'N/A',
//                 roomName: item['roomName'] ?? 'N/A',
//                 bookingDate: item['bookedDate'] != null
//                     ? DateTime.parse(item['bookedDate'])
//                     : DateTime.now(),
//               );
//             }).toList();

//             upcomingBookings = upcomingData.map<Booking>((item) {
//               return Booking(
//                 roomNumber: item['roomNumber'] ?? 'N/A',
//                 roomName: item['roomName'] ?? 'N/A',
//                 bookingDate: item['bookedDate'] != null
//                     ? DateTime.parse(item['bookedDate'])
//                     : DateTime.now(),
//               );
//             }).toList();
//           });
//         }
//       } else {
//         throw Exception(
//             'Failed to fetch booking history. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error fetching booking history: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching booking history: $e')),
//       );
//     }
//   }

//   void _toggleBookingHistory() {
//     setState(() {
//       showBookingHistory = !showBookingHistory;
//       if (showBookingHistory) {
//         _fetchBookingHistory(); // Fetch data when showing history
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Book Your Seat',
//           style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w800,
//               color: Color(0xff0E57A5)),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CustomPaint(
//               painter: TopShapePainter(),
//               child: Container(
//                 height: 100,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
// const Text(
//   'Pick Your Date',
//   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
// ),
// const SizedBox(height: 16),
// TextField(
//   readOnly: true,
//   decoration: InputDecoration(
//     hintText: '${selectedDate.toLocal()}'.split(' ')[0],
//     suffixIcon: IconButton(
//       icon: const Icon(Icons.calendar_today),
//       onPressed: () => _selectDate(context),
//     ),
//   ),
// ),
//                   if (showDropdown && rooms.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
// const Text(
//   "Select your room number",
//   style: TextStyle(
//       fontSize: 16, fontWeight: FontWeight.bold),
// ),
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8.0),
//                             border: Border.all(
//                               color: const Color.fromARGB(255, 4, 1, 1),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: DropdownButton<Room>(
//                             menuMaxHeight: 250,
//                             isExpanded: true,
//                             underline: Container(),
//                             value: selectedRoom,
//                             onChanged: (Room? newValue) {
//                               setState(() {
//                                 selectedRoom = newValue;
//                                 availabilityText = '';
//                               });
//                               _onRoomSelected(newValue!);
//                             },
//                             hint: const Text("Choose your room number"),
//                             items:
//                                 rooms.map<DropdownMenuItem<Room>>((Room room) {
//                               return DropdownMenuItem<Room>(
//                                 value: room,
//                                 child: Text(room.number),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     if (availabilityText.isNotEmpty) ...[
//                       const SizedBox(height: 16),
//                       Text(
//                         availabilityText,
//                         style: TextStyle(
//                             color: isRoomAvailable ? Colors.green : Colors.red),
//                       ),
//                       if (showBookButton) ...[
//                         const SizedBox(height: 16),
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xff0E57A5),
//                               padding: const EdgeInsets.all(16.0),
//                             ),
//                             onPressed: _bookRoom,
//                             child: const Text(
//                               'Book Room',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ],
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
// style: ElevatedButton.styleFrom(
//   backgroundColor: const Color(0xff0E57A5),
//   padding: const EdgeInsets.all(16.0),
// ),
//                       onPressed: _toggleBookingHistory,
//                       child: Text(
//                         showBookingHistory
//                             ? 'Hide Booking History'
//                             : 'Show Booking History',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
// if (showBookingHistory) ...[
//   const SizedBox(height: 16),
//   PaginatedDataTable(
//     columns: const [
//       DataColumn(label: Text('Room Number')),
//       DataColumn(label: Text('Room Name')),
//       DataColumn(label: Text('Booking Date')),
//     ],
//     source: BookingDataSource(
//       bookings:
//           showPastBookings ? pastBookings : upcomingBookings,
//     ),
//     header: const Text(
//       'Booking History',
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         fontSize: 30,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
//     rowsPerPage: 5,
//     showCheckboxColumn: false,
//     showFirstLastButtons: true,
//   ),
//   const SizedBox(
//       height: 16), // Space between table and button
//   Center(
//     child: ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xff0E57A5),
//         padding: const EdgeInsets.all(16.0),
//       ),
//       onPressed: () {
//         setState(() {
//           showPastBookings = !showPastBookings;
//         });
//       },
//       child: Text(
//         showPastBookings
//             ? 'Show Upcoming Bookings'
//             : 'Show Past Bookings',
// style: const TextStyle(
//     color: Colors.white,
//     fontSize: 15,
//     fontWeight: FontWeight.w500),
//       ),
//     ),
//   ),
// ],
// ],
// ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class BookingDataSource extends DataTableSource {
//   final List<Booking> bookings;

//   BookingDataSource({required this.bookings});

//   @override
//   DataRow? getRow(int index) {
//     if (index >= bookings.length) return null;
//     final booking = bookings[index];
//     return DataRow(
//       cells: [
//         DataCell(Text(booking.roomNumber)),
//         DataCell(Text(booking.roomName)),
//         DataCell(Text(
//           DateFormat.yMMMd().format(booking.bookingDate),
//         )),
//       ],
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => bookings.length;

//   @override
//   int get selectedRowCount => 0;

//   @override
//   void selectAll(bool? selected) {}
// }

// class TopShapePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint paint = Paint()
//       ..color = const Color(0xFF0E57A5)
//       ..style = PaintingStyle.fill;

//     final Path path = Path()
//       ..lineTo(0, size.height - 40)
//       ..quadraticBezierTo(
//         size.width / 4,
//         size.height,
//         size.width / 2,
//         size.height - 40,
//       )
//       ..quadraticBezierTo(
//         3 * size.width / 4,
//         size.height - 80,
//         size.width,
//         size.height - 40,
//       )
//       ..lineTo(size.width, 0)
//       ..close();

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class Room {
  final String id;
  final String number;

  Room(this.id, this.number);
}

class Booking {
  final String roomNumber;
  final String roomName;
  final DateTime bookingDate;

  Booking({
    required this.roomNumber,
    required this.roomName,
    required this.bookingDate,
  });
}

class _BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  Room? selectedRoom;
  bool showDropdown = false;
  bool showBookButton = false;
  bool isRoomAvailable = false;
  List<Room> rooms = [];
  String availabilityText = '';
  bool showBookingHistory = false; // State variable to track the visibility
  List<Booking> pastBookings = []; // List to store past bookings
  List<Booking> upcomingBookings = []; // List to store upcoming bookings
  bool showPastBookings = true; // Toggle between past and upcoming bookings
  int pastBookingsNumbers = 1;
  int upcomingBookingsNumbers = 1;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        showDropdown = true;
        showBookButton = false;
        availabilityText = '';
      });
      _fetchRoomNumbers();
    }
  }

  Future<void> _fetchRoomNumbers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiKey/rooms/available-rooms'),
      );
      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body.toString());
        setState(() {
          rooms =
              data.map((item) => Room(item['_id'], item['roomName'])).toList();
          selectedRoom = null;
        });
        log("Fetched rooms: $rooms");
      } else {
        throw Exception('Failed to load room numbers');
      }
    } catch (e) {
      log('Error fetching room numbers: $e');
    }
  }

  Future<void> _checkRoomAvailability(Room room) async {
    try {
      final String bookingDate = selectedDate.toIso8601String().split('T')[0];
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(
        Uri.parse(
            '$apiKey/bookings/availability?roomId=${room.id}&bookingDate=$bookingDate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${prefs.getString("api_token")}"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        final bool availability =
            responseBody['availability'] as bool? ?? false;
        final int totalCapacity = responseBody['totalCapacity'] as int? ?? 0;
        final int availableSeats = responseBody['availableSeats'] as int? ?? 0;

        log(response.body);
        setState(() {
          isRoomAvailable = availability;
          availabilityText = availability
              ? 'Room is available\nTotal Capacity: $totalCapacity\tAvailable Seats: $availableSeats'
              : 'Room is not available\nTotal Capacity: $totalCapacity\nAvailable Seats: $availableSeats';
          showBookButton = availability;
          selectedRoom = availability ? room : null;
        });

        log("ok");
      } else {
        throw Exception(
            'Failed to check room availability. Statuscode= ${response.statusCode}');
      }
    } catch (e) {
      log('Error checking room availability: $e');
      setState(() {
        isRoomAvailable = false;
        availabilityText = 'Error checking availability';
        showBookButton = false;
      });
    }
  }

  Future<void> _bookRoom() async {
    if (selectedRoom != null && isRoomAvailable) {
      try {
        final String bookingDate = selectedDate.toIso8601String().split('T')[0];
        SharedPreferences prefs = await SharedPreferences.getInstance();

        final String? userId = prefs.getString("api_id");
        final String? authToken = prefs.getString("api_token");

        // Log the userId and token
        log('Attempting to book room with userId=$userId and token=$authToken');

        if (userId == null || authToken == null) {
          throw Exception('User ID or token is null');
        }

        final response = await http.post(
          Uri.parse("$apiKey/bookings/book-seat"),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': "Bearer $authToken"
          },
          body: jsonEncode({
            "userId": userId,
            "roomId": selectedRoom!.id,
            "bookingDate": selectedDate.toIso8601String(),
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          log('Room booked successfully');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Room booked successfully')),
            );
          }
        } else {
          log('Failed to book room: ${response.statusCode}, ${response.body}');
          throw Exception('Failed to book room. ${response.statusCode}');
        }
      } catch (e) {
        log('Error booking room: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Failed to book room. User has another booking on the same date')),
          );
        }
      }
    } else {
      log('No room selected or room is not available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No room selected or room is not available')),
      );
    }
  }

  void _onRoomSelected(Room? room) {
    _checkRoomAvailability(room!);
  }

  Future<void> _fetchBookingHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("api_id");
      final String? authToken = prefs.getString("api_token");

      if (userId == null || authToken == null) {
        throw Exception('User ID or token is null. Please log in again.');
      }
      log(userId);
      log(authToken);

      final response = await http.get(
        Uri.parse('$apiKey/bookings/booking-details-mob'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer $authToken"
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody is Map) {
          final List<dynamic> pastData = responseBody['pastBookings'] ?? [];
          final List<dynamic> upcomingData =
              responseBody['upcomingBookings'] ?? [];

          setState(() {
            pastBookings = pastData.map<Booking>((item) {
              return Booking(
                roomNumber: item['roomNumber'] ?? 'N/A',
                roomName: item['roomName'] ?? 'N/A',
                bookingDate: item['bookedDate'] != null
                    ? DateTime.parse(item['bookedDate'])
                    : DateTime.now(),
              );
            }).toList();

            upcomingBookings = upcomingData.map<Booking>((item) {
              return Booking(
                roomNumber: item['roomNumber'] ?? 'N/A',
                roomName: item['roomName'] ?? 'N/A',
                bookingDate: item['bookedDate'] != null
                    ? DateTime.parse(item['bookedDate'])
                    : DateTime.now(),
              );
            }).toList();
          });
        }
      } else {
        throw Exception(
            'Failed to fetch booking history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching booking history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching booking history: $e')),
        );
      }
    }
  }

  void _toggleBookingHistory() {
    setState(() {
      showBookingHistory = !showBookingHistory;
      if (showBookingHistory) {
        _fetchBookingHistory(); // Fetch data when showing history
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0E57A5),
        // forceMaterialTransparency: true,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Book Your Seat',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xffffffff)),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomPaint(
              painter: TopShapePainter(),
              child: Container(
                height: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  const Text(
                    'Pick Your Date',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: '${selectedDate.toLocal()}'.split(' ')[0],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showDropdown && rooms.isNotEmpty) ...[
                    // const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select your room number",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: const Color.fromARGB(255, 4, 1, 1),
                              width: 1.5,
                            ),
                          ),
                          child: DropdownButton<Room>(
                            value: selectedRoom,
                            isExpanded: true,
                            underline: Container(),
                            menuMaxHeight: 300,
                            hint: const Text("Choose your room number"),
                            onChanged: _onRoomSelected,
                            items:
                                rooms.map<DropdownMenuItem<Room>>((Room room) {
                              return DropdownMenuItem<Room>(
                                value: room,
                                child: Text(room.number),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      availabilityText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isRoomAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showBookButton)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _bookRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0E57A5),
                          padding: const EdgeInsets.all(16.0),
                        ),
                        child: const Text(
                          'Book Seat',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0E57A5),
                        padding: const EdgeInsets.all(16.0),
                      ),
                      onPressed: _toggleBookingHistory,
                      child: Text(
                        showBookingHistory
                            ? 'Hide Booking History'
                            : 'Show Booking History',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  if (showBookingHistory) ...[
                    const SizedBox(height: 20),
                    // Toggle button between past and upcoming bookings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPastBookings = true;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              showPastBookings
                                  ? const Color(0xff0E57A5)
                                  : Colors.grey,
                            ),
                          ),
                          child: const Text(
                            'Past Bookings',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showPastBookings = false;
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              showPastBookings
                                  ? Colors.grey
                                  : const Color(0xff0E57A5),
                            ),
                          ),
                          child: const Text(
                            'Upcoming Bookings',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Display the table if there are bookings
                    if (showPastBookings
                        ? pastBookings.isNotEmpty
                        : upcomingBookings.isNotEmpty) ...[
                      PaginatedDataTable(
                        header: Text(
                          showPastBookings
                              ? 'Past Bookings'
                              : 'Upcoming Bookings',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                        columns: const [
                          DataColumn(label: Text('Room Number')),
                          DataColumn(label: Text('Room Name')),
                          DataColumn(label: Text('Booking Date')),
                        ],
                        source: BookingDataSource(
                          bookings: showPastBookings
                              ? pastBookings
                              : upcomingBookings,
                        ),
                        rowsPerPage: 5,
                        showFirstLastButtons: true,
                      ),
                    ] else
                      Center(
                        child: Text(showPastBookings
                            ? 'No past bookings available.'
                            : 'No upcoming bookings available.'),
                      ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDataSource extends DataTableSource {
  final List<Booking> bookings;

  BookingDataSource({required this.bookings});

  @override
  DataRow getRow(int index) {
    final booking = bookings[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(booking.roomNumber)),
        DataCell(Text(booking.roomName)),
        DataCell(Text(DateFormat('yyyy-MM-dd').format(booking.bookingDate))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bookings.length;

  @override
  int get selectedRowCount => 0;
}

class TopShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0E57A5)
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 4,
        size.height,
        size.width / 2,
        size.height - 40,
      )
      ..quadraticBezierTo(
        3 * size.width / 4,
        size.height - 80,
        size.width,
        size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
//"id":"66c83c8f066fa13da0ad44eb",
//"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRpcGFuamFuMDA3QGdtYWlsLmNvbSIsImlhdCI6MTcyNDM5ODczNn0.iw8P8H3MYhtngbxhOKYhdFPyWsg3ECC8taYfgec_HNo"