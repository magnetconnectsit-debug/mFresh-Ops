// region Imports
// No third-party imports required for constant definitions
// endregion

// region AppPermissions
/// Centralized constants for all role-based permissions in the application.
/// Strictly restricted to the permissions provided by the backend API.
abstract class AppPermissions {
  // region Customer & User
  static const customerMemberRadio = 'customer_member_radio';
  static const scannerAccess = 'Scanner_access';
  static const userProfileFilter = 'User_Profile_Filter';
  static const cashCollectionAccess = 'cash_collection_access';
  static const usersPanel = 'Users_panel';
  static const userAdminDE = 'U_Admin_D_E';
  static const userAdminEdit = 'U_Admin_Edit';
  static const unitAdminColumn = 'unit_admin_column';
  // endregion

  // region Dashboard & Analytics
  static const dashboardPanel = 'Dashboard_Panel';
  static const dashboardCustomisation = 'Dashboard_Customisation';
  // endregion

  // region Collections & Deposits
  static const collectionsDepositsPanel = 'Collections_Deposits_Panel';
  static const collectionOldPanel = 'collection_old_panel';
  static const collectionPanel = 'collection_panel';
  static const normalAdminCollection = 'normal_admin_collection';
  static const depositPanel = 'deposit_panel';
  static const depositFilter = 'deposit_filter';
  static const depositTable = 'deposit_table';
  static const depositOnboarding = 'deposit_onboarding';
  static const editCashDeposit = 'Edit_CashDeposit';
  static const deleteCashDeposit = 'Delete_CashDeposit';
  static const depositTableAction = 'deposit_table_action';
  static const resendReceiptCustomer = 'resend_receipt_customer';
  static const receiptPrint = 'receipt_print';
  static const paymentGateway = 'payment_gateway';
  static const resetPrint = 'reset_print';
  // endregion

  // region Expenses & Reports
  static const expensesPannel = 'Expenses_Pannel';
  static const reportPannel = 'Report_Pannel';
  // endregion

  // region Membership & Referral
  static const membershipPanel = 'Membership_Panel';
  static const referralPanel = 'Referral_Panel';
  // endregion

  // region Master & Pages
  static const masterPanel = 'Master_panel';
  static const pagesPanel = 'Pages_panel';
  // endregion

  // region Scanner & QR
  static const scannerPanel = 'scanner_panel';
  static const qrGeneratePanel = 'QR_Generate_Panel';
  static const allQR = 'All_QR';
  static const createQRPage = 'Create_QR_Page';
  static const externalQr = 'external_qr';
  // endregion

  // region Inventory
  static const inventoryPanel = 'inventory_panel';
  static const measurementsPanel = 'measurements_panel';
  static const storeRoom = 'store_room';
  static const storeInventoryStock = 'store_inventory_stock';
  static const unitInventoryStock = 'unit_inventory_stock';
  static const addInventoryStock = 'add_inventory_stock';
  static const inventoryItem = 'inventory_item';
  static const sInvSDStoreFilter = 'S_Inv_S_D_Store_Filter';
  static const sInvMultiItemFilter = 'S_Inv_Multi_Item_Filter';
  static const sInvMultiStoreFilter = 'S_Inv_Multi_Store_Filter';
  static const sInvAllot = 'S_Inv_Allot';
  static const sInvConsume = 'S_Inv_Consume';
  static const uInvAllot = 'U_Inv_Allot';
  static const uInvConsume = 'U_Inv_Consume';
  static const uInvMultiItemFilter = 'U_Inv_Multi_Item_Filter';
  static const uInvMultiUnitFilter = 'U_Inv_Multi_Unit_Filter';
  static const sInvExport = 'S_Inv_export';
  static const uInvExport = 'U_Inv_export';
  static const consumptionExport = 'Consumption_export';
  static const allotmentReportExport = 'Allotment_Report_export';
  static const allotmentReverse = 'allotment_reverse';
  static const consumptionReverse = 'consumption_reverse';
  static const consumptionReport = 'consumption_report';
  static const allotmentsReport = 'allotments_report';
  static const backDateInventoryConsume = 'back_date_inventory_consume';
  static const invOrderPanel = 'Inv_Order_Panel';
  static const invOrderLogPanel = 'Inv_Order_Log_Panel';
  static const invUnitOrder = 'Inv_Unit_Order';
  static const invStoreOrder = 'Inv_Store_Order';
  static const unitAuditReport = 'unit_audit_report';
  static const auditItemRank = 'audit_item_rank';
  static const createAuditItemRank = 'create_audit_item_rank';
  static const editAuditItemRank = 'edit_audit_item_rank';
  // endregion

  // region Cleaning
  static const approveCleaningPicture = 'approve_cleaning_picture';
  static const reuploadCleaningPicture = 'reupload_cleaning_picture';
  static const addCleaningPicture = 'add_cleaning_picture';
  static const cleaningPictureFilter = 'cleaning_picture_filter';
  static const cleanningPicsPannel = 'cleanning_pics_pannel';
  static const dailyChecklistPanel = 'daily_checklist_panel';
  // endregion

  // region Support Tickets / Maintenance
  static const maintenancePanel = 'maintenance_panel';
  static const maintenanceTable = 'maintenance_table';
  static const addMaintenance = 'add_maintenance';
  static const maintenanceFilter = 'maintenance_filter';
  static const maintenanceLayout = 'maintenance_Layout';
  static const mSubCategory = 'm_sub_category';
  static const maintenanceCategory = 'maintenance_category';
  static const maintenanceUpdatePermission = 'maintenance_update_Permission';
  static const filterStateDistrictMaintenance = 'filter_state_district_maintenance';
  static const filterCategorySupportTicket = 'filter_category_support_ticket';
  static const filterUnitSuportTicket = 'filter_unit_suport_ticket';
  static const filterStatusSuportTicket = 'filter_status_suport_ticket';
  static const mProjects = 'M_Projects';
  static const supportTicketDashboard = 'Support_Ticket_Dashboard';
  static const allTicketPermission = 'all_ticket_permission';
  static const mTemplate = 'M_Template';
  // endregion

  // region Info Directory, Assets & Brands
  static const cDirectoryPanel = 'c_directory_panel';
  static const dirL1 = 'Dir_L1';
  static const dirL2 = 'Dir_L2';
  static const dirL3 = 'Dir_L3';
  static const assetPanel = 'Asset_Panel';
  static const accountSubscriptionPanel = 'Account_subscription_panel';
  static const accountDetails = 'account_details';
  static const assetsProductDetails = 'assets_product_details';
  static const brandDetails = 'brand_details';
  static const companyDetails = 'company_details';
  static const contactEdit = 'contact_edit';
  static const contactDelete = 'contact_delete';
  static const accountSubscriptionEdit = 'Account_subscription_Edit';
  static const accountSubscriptionDelete = 'Account_subscription_Delete';
  static const productAssetEdit = 'Product&Asset_Edit';
  static const productAssetDelete = 'Product&Asset_Delete';
  static const assetCategoryPanel = 'asset_category_panel';
  // endregion

  // region Task Scheduler
  static const taskSchedulerPanel = 'Task_Sheduler_Pannel';
  static const allTask = 'All_Task';
  static const dailyTask = 'Daily_Task';
  static const dailyTaskFilter = 'Daily_Task_Filter';
  static const dailyTaskProjectFilter = 'Daily_Task_Project_Filter';
  static const dailyTaskUnitFilter = 'Daily_Task_Unit_Filter';
  static const dailyTaskGroupFilter = 'Daily_Task_Group_Filter';
  static const dailyTaskAssigneeFilter = 'Daily_Task_Assignee_Filter';
  static const resetApplyBtn = 'Reset_apply_btn';
  static const createNewTask = 'create_new_task';
  static const taskEdit = 'Task_Edit';
  static const taskDelete = 'Task_Delete';
  static const exportTask = 'export_task';
  static const dailyTaskByMonth = 'daily_task_by_month';
  // endregion

  // region Roles & Responsibilities
  static const rolesResponsibilityPanel = 'roles_responsibility_panel';
  static const rolesMaster = 'roles_master';
  static const responsibilitiesMaster = 'responsibilities_master';
  static const viewResponsibilities = 'view_responsibilities';
  // endregion

  // region Payment Reminders
  static const paymentReminderPannel = 'payment_reminder_pannel';
  // endregion

  // region Attendance & Tracking
  static const trackingPanel = 'tracking_panel';
  static const attendanceLog = 'Attendance_Log';
  static const attendanceMapView = 'attendance_map_view';
  static const dutyPunch = 'duty_punch';
  static const backgroundService = 'background_service';
  static const staffTab = 'staff_tab';
  static const selfieAttendance = 'selfie_attendance';
  // endregion

  // region Global & Common Controls
  static const bulkEdit = 'bulk_edit';
  static const filterProject = 'filter_project';
  static const filterGlobal = 'filter_global';
  static const filterAssignee = 'filter_assignee';
  static const profileTicketCreate = 'profile_ticket_create';
  static const profileTaskCreate = 'profile_task_create';
  static const headerTicketBtn = 'header_ticket_btn';
  static const headerTaskBtn = 'header_task_btn';
  static const onlineOfflineToggle = 'online_offline_toggle';
  static const additionalPhoneNo = 'additional_phone_no';
  static const unitFilter = 'unit_filter';
  static const saveFilter = 'save_filter';
  // endregion

  // region Others
  static const feedbackPanel = 'feedback_panel';
  static const careerPanel = 'Career_panel';
  static const deviceMappingPanel = 'Device_mapping_panel';
  static const seoPanel = 'SEO_Panel';
  static const eventMenu = 'event_menu';
  static const allEventTicketMenu = 'all_event_ticket_menu';
  static const dynamicWebsiteMenu = 'dynamic_website_menu';
  static const workforceMenu = 'workforce_menu';
  static const eventPanel = 'event_panel';
  static const rentalPanel = 'rental_panel';
  static const rentalBooking = 'rental_booking';
  static const rentalCustomer = 'rental_customer';
  static const rentalServices = 'rental_services';
  // endregion

  // region Helper Methods
  /// Set of all valid permission keys provided by backend
  static const Set<String> all = {
    customerMemberRadio,
    scannerAccess,
    userProfileFilter,
    cashCollectionAccess,
    dashboardPanel,
    collectionsDepositsPanel,
    expensesPannel,
    reportPannel,
    membershipPanel,
    referralPanel,
    usersPanel,
    masterPanel,
    pagesPanel,
    scannerPanel,
    inventoryPanel,
    collectionOldPanel,
    collectionPanel,
    depositPanel,
    measurementsPanel,
    storeRoom,
    storeInventoryStock,
    unitInventoryStock,
    addInventoryStock,
    inventoryItem,
    depositFilter,
    depositTable,
    depositOnboarding,
    editCashDeposit,
    deleteCashDeposit,
    normalAdminCollection,
    approveCleaningPicture,
    reuploadCleaningPicture,
    addCleaningPicture,
    cleaningPictureFilter,
    cleanningPicsPannel,
    dailyChecklistPanel,
    maintenanceTable,
    addMaintenance,
    maintenanceFilter,
    maintenanceLayout,
    mSubCategory,
    maintenanceCategory,
    maintenancePanel,
    depositTableAction,
    maintenanceUpdatePermission,
    filterStateDistrictMaintenance,
    filterCategorySupportTicket,
    filterUnitSuportTicket,
    filterStatusSuportTicket,
    sInvSDStoreFilter,
    sInvMultiItemFilter,
    sInvMultiStoreFilter,
    sInvAllot,
    sInvConsume,
    uInvAllot,
    uInvConsume,
    uInvMultiItemFilter,
    uInvMultiUnitFilter,
    sInvExport,
    uInvExport,
    consumptionExport,
    allotmentReportExport,
    mProjects,
    cDirectoryPanel,
    feedbackPanel,
    dirL1,
    dirL2,
    dirL3,
    careerPanel,
    assetPanel,
    deviceMappingPanel,
    seoPanel,
    accountSubscriptionPanel,
    qrGeneratePanel,
    allQR,
    createQRPage,
    taskSchedulerPanel,
    allTask,
    dailyTask,
    dailyTaskFilter,
    dailyTaskProjectFilter,
    dailyTaskUnitFilter,
    dailyTaskGroupFilter,
    dailyTaskAssigneeFilter,
    resetApplyBtn,
    createNewTask,
    taskEdit,
    taskDelete,
    exportTask,
    supportTicketDashboard,
    bulkEdit,
    allotmentReverse,
    consumptionReverse,
    userAdminDE,
    userAdminEdit,
    filterProject,
    filterGlobal,
    filterAssignee,
    eventMenu,
    allEventTicketMenu,
    dynamicWebsiteMenu,
    workforceMenu,
    profileTicketCreate,
    profileTaskCreate,
    headerTicketBtn,
    headerTaskBtn,
    resendReceiptCustomer,
    onlineOfflineToggle,
    externalQr,
    additionalPhoneNo,
    receiptPrint,
    paymentGateway,
    resetPrint,
    unitFilter,
    accountDetails,
    assetsProductDetails,
    brandDetails,
    companyDetails,
    allTicketPermission,
    saveFilter,
    consumptionReport,
    allotmentsReport,
    backgroundService,
    dutyPunch,
    trackingPanel,
    contactEdit,
    contactDelete,
    attendanceMapView,
    accountSubscriptionEdit,
    accountSubscriptionDelete,
    productAssetEdit,
    productAssetDelete,
    dashboardCustomisation,
    attendanceLog,
    mTemplate,
    paymentReminderPannel,
    staffTab,
    eventPanel,
    backDateInventoryConsume,
    dailyTaskByMonth,
    invOrderPanel,
    invOrderLogPanel,
    invUnitOrder,
    invStoreOrder,
    rolesResponsibilityPanel,
    rolesMaster,
    responsibilitiesMaster,
    viewResponsibilities,
    unitAuditReport,
    auditItemRank,
    createAuditItemRank,
    editAuditItemRank,
    unitAdminColumn,
    assetCategoryPanel,
    rentalPanel,
    rentalBooking,
    rentalCustomer,
    rentalServices,
    selfieAttendance,
  };

  /// Returns true if the key is valid and exists in user permissions (case-insensitive)
  static bool has(Iterable<String> userPermissions, String permissionKey) {
    final lowerKey = permissionKey.toLowerCase();
    return userPermissions.any((p) => p.toLowerCase() == lowerKey);
  }
  // endregion
}
// endregion
