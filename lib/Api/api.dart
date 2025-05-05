class Api {
  // static String baseUrl = "https://fbm-be.vercel.app/api/";
  static String baseUrl = "http://13.203.35.52:5000/api/";
  static String createBlog = "${baseUrl}blog/createblog";

  static String getAllBlog = "${baseUrl}blog/getallblogs";
  static String deleteBlog = "${baseUrl}blog/deleteblog";
  // Users
  static String createUser = "${baseUrl}auth/create-user";
  static String getAllUser = "${baseUrl}auth/getallusers";
  static String deleteUser = "${baseUrl}auth/delete-user";
  static String getAllRequest = "${baseUrl}auth/getAllRequest";

  // messages
  static String getAllMessages = "${baseUrl}message/get-all-messages";
  static String reply = "${baseUrl}message/reply";
  // Plan
  static String createPlan = "${baseUrl}invest/create-plan";
  static String getAllPlan = "${baseUrl}invest/getallplans";
  static String deletePlan = "${baseUrl}invest/delete-plan";
  static String updatePlan = "${baseUrl}invest/update-plan";
  static String assignPlan = "${baseUrl}invest/assign-plan";
  static String getPendingReturnUser = "${baseUrl}invest/pending-payouts";
  static String markAsPaid = "${baseUrl}invest/return-paid";
  static String count = "${baseUrl}invest/counts";
  static String allPaymentHistory = "${baseUrl}invest/all-payment-history";
}
