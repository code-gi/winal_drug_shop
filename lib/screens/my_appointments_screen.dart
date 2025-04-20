import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/farm_activity.dart';
import '../utils/auth_service.dart';
import 'dart:developer' as developer;

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  List<Appointment> _appointments = [];
  List<FarmActivity> _activities = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showUpcoming = true;
  late TabController _tabController;
  final Map<int, FarmActivity> _activityMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showUpcoming = _tabController.index == 0;
      });
    });
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get the color based on appointment status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF1976D2); // Primary blue instead of green
      case 'pending':
        return Colors.orange;
      case 'completed':
        return const Color(0xFF42A5F5); // Light blue
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Convert the appointment time string to a DateTime
  DateTime _parseDateTime(String date, String time) {
    // Parse the date and time strings
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    if (dateParts.length != 3 || timeParts.length != 2) {
      // Return current date if format is invalid
      return DateTime.now();
    }

    try {
      return DateTime(
        int.parse(dateParts[0]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[2]), // Day
        int.parse(timeParts[0]), // Hour
        int.parse(timeParts[1]), // Minute
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  // Filter appointments based on the tab selection
  List<Appointment> get _filteredAppointments {
    final now = DateTime.now();

    return _appointments.where((appointment) {
      final appointmentDateTime = _parseDateTime(
          appointment.appointmentDate, appointment.appointmentTime);
      final status = appointment.status.toLowerCase();
      final isPastOrPresent = appointmentDateTime.isBefore(now) ||
          appointmentDateTime.isAtSameMomentAs(now);
      final isCompletedOrCancelled =
          status == 'completed' || status == 'cancelled';

      if (_showUpcoming) {
        // Show in upcoming tab only if:
        // 1. The appointment is in the future AND
        // 2. The status is either pending or confirmed
        return !isPastOrPresent && !isCompletedOrCancelled;
      } else {
        // Show in past tab if:
        // 1. The appointment is in the past/present OR
        // 2. The status is completed or cancelled
        return isPastOrPresent || isCompletedOrCancelled;
      }
    }).toList();
  }

  Future<void> _fetchActivities() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final response = await http.get(
        Uri.parse('${authService.baseUrl}/api/farm-activities'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _activities =
              data.map((json) => FarmActivity.fromJson(json)).toList();

          // Create a map of activity ID to activity for quick lookup
          for (var activity in _activities) {
            _activityMap[activity.id] = activity;
          }
        });
      }
    } catch (e) {
      developer.log('Error fetching activities: $e');
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication required';
        });
        return;
      }

      // Fetch farm activities first
      await _fetchActivities();

      final response = await http.get(
        Uri.parse('${authService.baseUrl}/api/appointments/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _appointments =
              data.map((json) => Appointment.fromJson(json)).toList();
          _appointments.sort((a, b) {
            final aDate = _parseDateTime(a.appointmentDate, a.appointmentTime);
            final bDate = _parseDateTime(b.appointmentDate, b.appointmentTime);
            return aDate.compareTo(bDate);
          });
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please login again.';
        });
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load appointments';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
      developer.log('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: const Color.fromRGBO(0, 19, 34, 1),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Appointments',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/FARM VISITS.jpeg',
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black.withOpacity(0.4),
                    ),
                    Positioned(
                      bottom: 60.0,
                      left: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Farm Service Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _fetchAppointments,
                  tooltip: 'Refresh appointments',
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 0, 36, 41),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: Icon(Icons.calendar_today),
                    text: 'Upcoming',
                  ),
                  Tab(
                    icon: Icon(Icons.history),
                    text: 'Past',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 60, color: Colors.red),
                              SizedBox(height: 16),
                              Text(
                                _errorMessage,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchAppointments,
                                child: Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 19, 0, 49),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _showUpcoming
                                        ? Icons.event_busy
                                        : Icons.history,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _showUpcoming
                                        ? 'No upcoming appointments'
                                        : 'No past appointments',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/farm_activities'),
                                    child: Text(
                                      'Book a service now',
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 242, 251, 255),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchAppointments,
                              color: const Color.fromARGB(255, 0, 64, 92),
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                itemCount: _filteredAppointments.length,
                                itemBuilder: (context, index) {
                                  final appointment =
                                      _filteredAppointments[index];
                                  final activity =
                                      _activityMap[appointment.farmActivityId];

                                  // Format date and time
                                  final date = DateFormat('EEEE, MMMM d, yyyy')
                                      .format(DateTime.parse(
                                          appointment.appointmentDate));
                                  final time = DateFormat('h:mm a').format(
                                      DateFormat('HH:mm:ss')
                                          .parse(appointment.appointmentTime));

                                  return AppointmentCard(
                                    appointment: appointment,
                                    activity: activity,
                                    date: date,
                                    time: time,
                                    statusColor:
                                        _getStatusColor(appointment.status),
                                    onTap: () {
                                      // Show appointment details
                                      _showAppointmentDetails(
                                          appointment, activity);
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 64, 92),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/farm_activities');
        },
        tooltip: 'Book new appointment',
      ),
    );
  }

  void _showAppointmentDetails(
      Appointment appointment, FarmActivity? activity) {
    final date = DateFormat('EEEE, MMMM d, yyyy')
        .format(DateTime.parse(appointment.appointmentDate));
    final time = DateFormat('h:mm a')
        .format(DateFormat('HH:mm:ss').parse(appointment.appointmentTime));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(appointment.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(appointment.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '#${appointment.id}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              if (activity != null) ...[
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ] else ...[
                Text(
                  'Farm Activity #${appointment.farmActivityId}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              SizedBox(height: 24),
              _buildDetailItem(Icons.calendar_today, 'Date', date),
              _buildDetailItem(Icons.access_time, 'Time', time),
              _buildDetailItem(
                Icons.payment,
                'Payment Status',
                appointment.paymentStatus.toUpperCase(),
                valueColor: appointment.paymentStatus.toLowerCase() == 'paid'
                    ? Colors.green
                    : Colors.orange,
              ),
              _buildDetailItem(Icons.attach_money, 'Total Amount',
                  'UGX ${appointment.totalAmount.toStringAsFixed(0)}'),
              SizedBox(height: 32),
              if (appointment.status.toLowerCase() == 'pending' ||
                  appointment.status.toLowerCase() == 'confirmed')
                ElevatedButton(
                  onPressed: () {
                    // Cancel appointment logic
                    _showCancelConfirmation(appointment.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 90, 23, 19),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel Appointment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              SizedBox(height: 16),
              if (appointment.paymentStatus.toLowerCase() == 'unpaid' &&
                  (appointment.status.toLowerCase() == 'pending' ||
                      appointment.status.toLowerCase() == 'confirmed'))
                ElevatedButton(
                  onPressed: () {
                    // Navigate to payment screen
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'appointment': appointment.toJson(),
                        'activity': activity?.toJson(),
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 5, 102, 102),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Make Payment',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment?'),
        content: Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointmentId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication required')),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Cancelling appointment...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      // Call the API to cancel appointment
      final response = await http.post(
        Uri.parse(
            '${authService.baseUrl}/api/appointments/$appointmentId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment cancelled successfully')),
        );
        Navigator.pop(context); // Close the details modal
        _fetchAppointments(); // Refresh appointments
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}

// Custom animated appointment card widget
class AppointmentCard extends StatefulWidget {
  final Appointment appointment;
  final FarmActivity? activity;
  final String date;
  final String time;
  final Color statusColor;
  final VoidCallback onTap;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.activity,
    required this.date,
    required this.time,
    required this.statusColor,
    required this.onTap,
  }) : super(key: key);

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.statusColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.activity?.name ?? 'Farm Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: widget.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.appointment.status.toUpperCase(),
                              style: TextStyle(
                                color: widget.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.date,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            widget.time,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UGX ${widget.appointment.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                widget.appointment.paymentStatus
                                            .toLowerCase() ==
                                        'paid'
                                    ? Icons.check_circle
                                    : Icons.pending,
                                size: 16,
                                color: widget.appointment.paymentStatus
                                            .toLowerCase() ==
                                        'paid'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                widget.appointment.paymentStatus.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: widget.appointment.paymentStatus
                                              .toLowerCase() ==
                                          'paid'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bottom action bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Spacer(),
                      if (widget.appointment.status.toLowerCase() ==
                              'pending' ||
                          widget.appointment.status.toLowerCase() ==
                              'confirmed')
                        Text(
                          'ID: #${widget.appointment.id}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
