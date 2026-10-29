import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final List<String> degrees;
  final String speciality;
  final String workingPlace;
  final VoidCallback onTap;
  final VoidCallback ontapForEmergecy;
  final VoidCallback ontapForWalkIn;
  // final VoidCallback PatientPageTap;

  const DoctorCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.degrees,
    required this.speciality,
    // navigator pass
    required this.workingPlace,
    required this.onTap,
    required this.ontapForEmergecy,
    required this.ontapForWalkIn,
    // required this.PatientPageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: const Color(0xFFFCFDFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 80,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 80,
                        width: 70,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Details (Name, Degree, etc)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        speciality,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: degrees
                            .map(
                              (d) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      Text(
                        workingPlace,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Bottom Section: Fee + Button
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child:
                // Appointment Button
                Row(
                  children: [
                    // Book
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF0B3E6B)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Book",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF0B3E6B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Emergency
                    Expanded(
                      flex: 3,
                      child: InkWell(
                        onTap: ontapForEmergecy,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF0B3E6B)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Emergency",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF0B3E6B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Walk In
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: ontapForWalkIn,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFF0B3E6B)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "Walk In",
                              maxLines: 1,
                              style: TextStyle(
                                color: Color(0xFF0B3E6B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Patient
                    // Expanded(
                    //   flex: 2,
                    //   child: InkWell(
                    //     onTap: PatientPageTap,
                    //     borderRadius: BorderRadius.circular(4),
                    //     child: Container(
                    //       height: 40,
                    //       alignment: Alignment.center,
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         border: Border.all(color: const Color(0xFF0B3E6B)),
                    //         borderRadius: BorderRadius.circular(4),
                    //       ),
                    //       child: const FittedBox(
                    //         fit: BoxFit.scaleDown,
                    //         child: Text(
                    //           "Patient",
                    //           maxLines: 1,
                    //           style: TextStyle(
                    //             color: Color(0xFF0B3E6B),
                    //             fontSize: 12,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
