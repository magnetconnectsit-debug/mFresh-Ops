import 'package:flutter/foundation.dart';

class AppConstants {
  // region Private Constructor
  AppConstants._();
  // endregion

  // region Base URL
  static const String defaultBaseUrl = 'https://opsapitest.magnetconnects.com/public/api';
  static const String devBaseUrl = 'https://opsapitest.magnetconnects.com/public/api';
  static String baseUrl = defaultBaseUrl;
  static const bool isDevBuild = kDebugMode;

  static const String userImageBaseUrl =
      "https://d2o48lx73aoryr.cloudfront.net/users/";
  // endregion

  // region Web URLs

  // endregion

  // region API Timeouts
  static const int connectionTimeout = 100000;
  static const int receiveTimeout = 100000;
  // endregion

  // region API Endpoints
  static const String login = '/login';
  static const String profile = '/profile';
  static const String logout = '/logout';
  static const String passwordUpdate = '/password-update';
  static const String profileUpdate = '/profile-update';
  static const String allAssignee = '/all-assignee';
  
  // Support Tickets
  static const String supportUnits = '/support-units';
  static const String supportCategory = '/support-category';
  static const String supportProjects = '/support-projects';
  static const String supportSubcategories = '/support-subcategories';
  static const String createSupportTicket = '/create-support-ticket';
  static const String viewSupportTicket = '/view-support-ticket';
  static const String editSupportTicket = '/edit-support-ticket';
  static const String updateSupportTicket = '/update-support-ticket';
  static const String allSupportTickets = '/all-supporttickets';
  // endregion

  // region Hive Keys
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';
  // endregion
}







