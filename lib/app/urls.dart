class Urls {
  static const _baseUrl = "https://perp1.space/api";

  static const loginUrl = "$_baseUrl/login";

  // dorctor list and  appointment
  static const doctorListUrl = "$_baseUrl/doctors/login_user_assign_doctor";
  static const patientSearchUrl = "$_baseUrl/patient/search_patient";

  static chamberScheduleUrl(String id, String id2) =>
      "$_baseUrl/chamber/get_doctor_schedule_bu/$id/$id2";

  static const nextvisitUrl = "$_baseUrl/patient/next_visit";
  static const apointmentEntryUrl = "$_baseUrl/appointment/create";
  static const apointmentListUrl = "$_baseUrl/appointment";
  static const workingListUrl = "$_baseUrl/appointment/working";

  static const queueListUrl = "$_baseUrl/prescription/queue_data";

  // Patient
  static const patientEntryUrl = "$_baseUrl/patient/create";
  static const patientListUrl = "$_baseUrl/patient";
  static const categoryListUrl = "$_baseUrl/lookupvalue/multiplefilter/CAT";
  static patientEditUrl(String id) => "$_baseUrl/patient/update/$id";

  static arrivedButtonUrl(String id) => "$_baseUrl/appointment/status/$id";

  static vitalsinglepatientUrl(String id) =>
      "$_baseUrl/patient/patient_by_id/$id";

  static const voeMultifilterListUrl =
      "$_baseUrl/pr_lookup_value/multiplefilter/VOE";

  static const vitalEntryUrl = "$_baseUrl/prescription/create";

  static vitalEditAutoFieldDataUrl(String id) =>
      "$_baseUrl/prescription/get_oe_document/$id";

  static vitalEditUrl(String id) => "$_baseUrl/prescription/update/$id";

  static sentToDoctorQueueUrl(String id) =>
      "$_baseUrl/appointment/sent_to_doctor_queue/$id";

  static const newPatientToRegisterUrl =
      "$_baseUrl/patient/register_new_patient";

  static const emergencyWalkinUrl = "$_baseUrl/appointment/emergency_walkin";

  static bookappointmentViewUrl(String dID, String BUid, String date) =>
      "$_baseUrl/appointment/booked/$dID/$BUid/$date";
}
