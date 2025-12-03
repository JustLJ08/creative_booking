import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import '../models/booking.dart';
import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<Booking>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _futureBookings = ApiService.fetchMyBookings();
    });
  }

  // Helper to format date nicely
  String _formatDateTime(String dateStr, String timeStr) {
    try {
      final DateTime dateTime = DateTime.parse("$dateStr $timeStr");
      return DateFormat('MMM d, y • h:mm a').format(dateTime);
    } catch (e) {
      return "$dateStr at $timeStr";
    }
  }

  // Helper for status colors
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Placeholder for sending receipt logic
  void _handleSendReceipt(int bookingId) {
    // Logic to pick image and upload would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload Receipt feature coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Consistent background
      appBar: AppBar(
        title: Text(
          "My Bookings",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF111827),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadBookings();
        },
        child: FutureBuilder<List<Booking>>(
          future: _futureBookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text("Error loading bookings", style: GoogleFonts.plusJakartaSans()),
                    TextButton(onPressed: _loadBookings, child: const Text("Retry"))
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 64, color: Colors.indigo[200]),
                    const SizedBox(height: 16),
                    Text(
                      "No bookings yet",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18, 
                        color: Colors.indigo[900],
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Your upcoming appointments will appear here.", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final booking = snapshot.data![index];
                return _buildBookingCard(booking);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.status ?? 'pending');
    final isPending = (booking.status ?? 'pending').toLowerCase() == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (booking.status ?? 'Pending').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  "#${booking.id}",
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Creative Details
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(
                    (booking.creativeName?.isNotEmpty ?? false) 
                        ? booking.creativeName![0].toUpperCase() 
                        : "?",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.creativeName ?? "Unknown Creative",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        booking.creativeRole ?? "Professional",
                        style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1),
            ),

            // Date & Time
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: Colors.indigo[400]),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(booking.date, booking.time),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),

            // --- ADDED: Display Booking Message/Requirements ---
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "MESSAGE",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (booking.requirements.isNotEmpty) 
                        ? booking.requirements 
                        : "No message provided",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // ----------------------------------------------------

            // ACTION BUTTON: Send Receipt (Only for Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleSendReceipt(booking.id ?? 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Indigo color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: Text(
                    "Send Half Payment Receipt",
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}