import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/doctor_list_screen.dart';
import 'package:attendantwebapp/features/Appointment%20List/presentation/screens/appointment_list_screen.dart';
import 'package:attendantwebapp/features/Doctor%20List/presentations/screens/patient_list_screen.dart';
import 'package:attendantwebapp/features/Queue/queue_list_screen.dart';
import 'package:flutter/material.dart';

class BottomNavControllerScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavControllerScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavControllerScreen> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavControllerScreen> {
  late int selected;

  final List<Widget> _pages = [
    DoctorListScreen(),
    AppointmentListScreen(),
    QueueListScreen(),
    PatientListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[selected],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Color(0xFFE5ECFC)),

        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Color(0xFFFCFDFF),

            indicatorColor: const Color.fromARGB(255, 193, 217, 255),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Color(0xFF458CF6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
              }
              return const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              );
            }),
          ),

          child: NavigationBar(
            selectedIndex: selected,
            elevation: 10,

            onDestinationSelected: (value) {
              setState(() => selected = value);
            },

            destinations: [
              NavigationDestination(
                icon: Image.asset(
                  "assets/images/appointment.png",
                  height: 26,
                  width: 26,
                ),
                label: "Doctor",
              ),

              NavigationDestination(
                icon: Image.asset(
                  "assets/images/booked.png",
                  height: 22,
                  width: 22,
                ),
                label: "Appointment",
              ),

              NavigationDestination(
                icon: Image.asset(
                  "assets/images/queue.png",
                  height: 22,
                  width: 22,
                ),
                label: "Queue",
              ),
              NavigationDestination(
                icon: Image.asset(
                  "assets/images/worklist.png",
                  height: 22,
                  width: 22,
                ),
                label: "Patient",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
