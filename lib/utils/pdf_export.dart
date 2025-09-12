import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

/// Detect backend host dynamically
String getBackendHost() {
  if (Platform.isAndroid) {
    // Android Emulator special localhost
    return "10.0.2.2";
  } else if (Platform.isIOS) {
    // iOS Simulator can use localhost
    return "localhost";
  } else {
    // Fallback: your PC's local IP (replace with your actual IP if needed)
    return "192.168.1.100";
  }
}

/// Generate PDF for given date range (start == end for single date)
Future<void> generateAttendancePdf(DateTime startDate, DateTime endDate) async {
  final pdf = pw.Document();

  final host = getBackendHost();

  final url =
      "http://$host:3000/attendance/report?startDate=${startDate.toIso8601String().split('T').first}&endDate=${endDate.toIso8601String().split('T').first}";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode != 200) {
    throw Exception("Failed to load attendance data: ${response.statusCode}");
  }

  final List<dynamic> data = jsonDecode(response.body);

  // Build PDF page
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Attendance Report",
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              "From: ${startDate.toString().split(' ').first}   To: ${endDate.toString().split(' ').first}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ["Roll No", "Name", "Date", "Status"],
              data: data.map((row) {
                return [
                  row['roll_no'].toString(),
                  row['name'],
                  row['date'].toString(),
                  row['is_present'] == 1 || row['is_present'] == true
                      ? "Present"
                      : "Absent",
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  // Save PDF
  final dir = await getApplicationDocumentsDirectory();
  final file = File("${dir.path}/attendance_report.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open PDF
  await OpenFilex.open(file.path);
}

/// Export attendance for a date range
Future<void> exportAttendancePdf(BuildContext context) async {
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    helpText: "Select Date Range for Attendance",
  );

  if (picked != null) {
    await generateAttendancePdf(picked.start, picked.end);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF generated successfully!")),
    );
  }
}

/// Export attendance for a single date
Future<void> exportSingleDatePdf(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    helpText: "Select a date for attendance PDF",
  );

  if (picked != null) {
    await generateAttendancePdf(picked, picked); // same start & end
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF generated successfully!")),
    );
  }
}
