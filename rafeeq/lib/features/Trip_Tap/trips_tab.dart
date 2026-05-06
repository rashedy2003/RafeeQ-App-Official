import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'AllTrips/MyTripsScreen.dart';
import 'TripDetails/trip_details_screen.dart';
import 'trip_cubit.dart';
import 'trip_state.dart';
import 'TripRequestModel.dart';
import 'TripsRepository.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();

  List<DateTime?> _dates = [DateTime.now(), DateTime.now().add(const Duration(days: 3))];
  String _selectedCurrency = "EGP";
  String _selectedTolerance = "medium";
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357);
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripsCubit(TripsRepository()),
      child: BlocConsumer<TripsCubit, TripsState>(
        listener: (context, state) {
          if (state is CreateTripSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("RafeeQ: Expedition Planned Successfully!"),
                backgroundColor: Color(0xFFB08900),
              ),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(tripId: state.tripId),
              ),
            );
          } else if (state is CreateTripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Container(
            color: Colors.black.withOpacity(0.3),
            child: SafeArea( // ✅ حماية المحتوى من التداخل مع الـ Notch أو الـ Status Bar
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10), // مسافة علوية إضافية

                      // ✅ الزرار أصبح بداخل SafeArea ومع Container لزيادة الوضوح
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MyTripsScreen()),
                                );
                              },
                              icon: const Icon(Icons.history_edu_rounded, color: Color(0xFFF1E4C1)),
                              label: Text(
                                "MY JOURNEYS",
                                style: GoogleFonts.cinzel(
                                  color: const Color(0xFFF1E4C1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.5, end: 0),
                        ],
                      ),

                      const SizedBox(height: 30), // مسافة بين الزرار والعنوان الرئيسي
                      _buildGoldTitle("CREATE YOUR JOURNEY"),
                      const SizedBox(height: 25),

                      _buildTextField(_titleController, "Trip Name", Icons.fort_rounded),
                      const SizedBox(height: 15),
                      _buildTextField(_descController, "What's the plan?", Icons.description, maxLines: 2),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Activity Duration"),
                      _buildDateCard(),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildTimeTile("Starts at", _startTime, true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTimeTile("Ends at", _endTime, false)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Budget & Preferences"),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_budgetController, "Budget", Icons.payments, isNumber: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDropdown("Currency", ["EGP", "USD"], (v) => _selectedCurrency = v!)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown("Flexibility (Tolerance)", ["low", "medium", "high"], (v) => _selectedTolerance = v!),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Target Destination"),
                      _buildMapCard(),
                      const SizedBox(height: 40),

                      state is CreateTripLoading
                          ? const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFFF1E4C1)),
                            SizedBox(height: 10),
                            Text("RafeeQ is planning your trip...",
                                style: TextStyle(color: Color(0xFFF1E4C1), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                          : _buildSubmitButton(context),
                    ],
                  ).animate().slideY(begin: 0.1, end: 0, duration: 600.ms).fadeIn(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoldTitle(String text) => Center(
      child: Text(text,
          style: GoogleFonts.cinzel(color: const Color(0xFFF1E4C1), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)));

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title, style: const TextStyle(color: Color(0xFFF1E4C1), fontWeight: FontWeight.w600)));

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller, maxLines: maxLines, style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Color(0xFFF1E4C1), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFF1E4C1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1E4C1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white, width: 2)),
        filled: true, fillColor: Colors.black38,
      ),
      validator: (v) => v!.isEmpty ? "This field is required" : null,
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.black87, style: const TextStyle(color: Colors.white),
      value: label == "Currency" ? _selectedCurrency : _selectedTolerance,
      decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Color(0xFFF1E4C1)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1E4C1))),
          filled: true, fillColor: Colors.black38),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateCard() => Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
      child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(calendarType: CalendarDatePicker2Type.range, selectedDayHighlightColor: const Color(0xFFB08900)),
          value: _dates,
          onValueChanged: (dates) => setState(() => _dates = dates)));

  Widget _buildTimeTile(String label, TimeOfDay time, bool isStart) => InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) setState(() => isStart ? _startTime = t : _endTime = t);
      },
      child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1E4C1))),
          child: Column(children: [
            Text(label, style: const TextStyle(color: Color(0xFFF1E4C1), fontSize: 12)),
            const SizedBox(height: 5),
            Text(time.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ])));

  Widget _buildMapCard() => SizedBox(
      height: 250,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
              options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: 12,
                  onTap: (pos, latlng) => setState(() => _selectedLocation = latlng)),
              children: [
                TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", userAgentPackageName: 'com.helwan.rafeeq'),
                MarkerLayer(markers: [
                  Marker(
                      point: _selectedLocation,
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40)
                          .animate(onPlay: (c) => c.repeat())
                          .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1.seconds, curve: Curves.easeInOut))
                ])
              ])));

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
        width: double.infinity, height: 60,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1E4C1),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5),
            onPressed: () {
              if (_formKey.currentState!.validate() && _dates.length >= 2) {
                final trip = TripRequestModel(
                    title: _titleController.text,
                    description: _descController.text,
                    latitude: _selectedLocation.latitude,
                    longitude: _selectedLocation.longitude,
                    preferredSiteTypes: ["other"],
                    startDate: _dates[0]!.toIso8601String().split('T')[0],
                    endDate: _dates[1]!.toIso8601String().split('T')[0],
                    dailyStartTime: _formatTime(_startTime),
                    dailyEndTime: _formatTime(_endTime),
                    estimatedBudget: double.tryParse(_budgetController.text) ?? 0,
                    currency: _selectedCurrency,
                    tolerance: _selectedTolerance
                );
                context.read<TripsCubit>().createTrip(trip);
              } else if (_dates.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a date range")),
                );
              }
            },
            child: const Text("LAUNCH EXPEDITION",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5))));
  }
}