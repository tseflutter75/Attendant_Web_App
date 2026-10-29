// import 'package:flutter/material.dart';

// class DoctorCardBook extends StatelessWidget {
//   final String imageUrl;
//   final String name;
//   final List<String> degrees;
//   final String speciality;
//   // final String experience;
//   // final String workingPlace;
//   // final String fee;
//   final VoidCallback onTap;

//   const DoctorCardBook({
//     super.key,
//     required this.imageUrl,
//     required this.name,
//     required this.degrees,
//     required this.speciality,
//     // required this.experience,
//     // required this.workingPlace,
//     // required this.fee,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       color: const Color(0xFFFCFDFF),
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: const BorderSide(color: Colors.white, width: 2.5),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top Section
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.asset(
//                     imageUrl,
//                     height: 70,
//                     width: 70,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // Details (Name, Degree, etc)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       Text(
//                         speciality,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 5),

//                       Wrap(
//                         spacing: 6,
//                         runSpacing: 6,
//                         children: degrees
//                             .map(
//                               (d) => Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 6,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade100,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   d,
//                                   style: const TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),

//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
