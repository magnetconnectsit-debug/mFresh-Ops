# Task Scheduler Module Documentation

> **Status:** Active / Living Specification  
> **Package:** `packages/apps/mfresh_ops`  
> **Module Path:** `lib/modules/tasks/`  
> **Documentation Location:** `documentation/task_scheduler/TASK_SCHEDULER.md`  
> **Last Updated:** October 2026  
> **Maintainer:** Banamali Nayak

---

## 1. Overview & Scope

The **Task Scheduler** module is the workforce execution, job scheduling, and operational accountability engine of the `mfresh_ops` application. It bridges supervisors/administrators who assign recurring or ad-hoc tasks with field personnel, store managers, and technicians who execute them on-site.

### Core Capabilities
* **Daily Operational View (`/daily-tasks`)**: Default operational landing view for non-admin field personnel. Groups daily tasks into Overdue, Today, and Tomorrow/Upcoming with real-time countdown tickers.
* **All Tasks Overview (`/all-tasks`)**: Tabular management console with multi-criteria server filters, global sorting, paginated browsing, and Excel/PDF report exports.
* **Monthly Breakdown (`/daily-task-filter`)**: Hierarchical calendar-style view breaking down jobs by Month $\rightarrow$ Week $\rightarrow$ Day with aggregate status tallies.
* **Creation & Recurrence Wizard (`/create-task`)**: Two-step guided creation/editing flow supporting one-time schedules or advanced recurring jobs (daily, weekly, day-of-month, ordinal weekday, yearly).
* **Proof & Approval Lifecycle**: Interactive modal for attaching camera/gallery photos, submitting field comments, and supervisor sign-off (Approve / Reject).
* **Granular Scope Control**: Supports modifying or deleting either a single task instance (`level 0`) or an entire recurring series (`level 1`).

---

## 2. Directory Structure & File Map

```
packages/apps/mfresh_ops/
├── documentation/
│   └── task_scheduler/
│       └── TASK_SCHEDULER.md                     # [This File] Master module documentation
├── lib/
│   ├── data/
│   │   ├── models/tasks/
│   │   │   └── task_models.dart                  # Core models: TaskItem, TaskProject, TaskGroup, TaskListResponse, DailyTaskResponse, TaskDetailResponse
│   │   └── repositories/
│   │       └── task_repository.dart              # TaskRepository handling 14 network endpoints
│   └── modules/tasks/
│       ├── controllers/
│       │   ├── tasks_controller.dart             # Master controller: Daily tasks, table view, create/edit, submit/approve, delete
│       │   └── daily_task_filter_controller.dart # Dedicated controller for Month-wise hierarchical view
│       └── views/
│           ├── all_tasks_screen.dart             # All Tasks tabular screen
│           ├── daily_tasks_screen.dart           # Daily Tasks primary view
│           ├── daily_task_filter_screen.dart     # Month-by-month accordion screen
│           ├── create_task_screen.dart           # 2-step create & edit wizard (recurring tasks)
│           ├── edit_task_screen.dart             # Dedicated edit screen for one-time tasks (recurring_task: "0")
│           ├── task_review_screen.dart           # Standalone review screen (bypassed by dialog in current UI)
│           └── widgets/
│               ├── daily_task_card.dart          # Interactive card with countdowns, badges, and action triggers
│               ├── appointment_recurrence_dialog.dart # Recurrence engine modal (Daily, Weekly, Monthly, Yearly)
│               ├── task_submission_dialog.dart   # Proof upload, comment submission & supervisor review modal
│               ├── delete_task_dialog.dart       # Prompt for deleting instance vs. entire series
│               ├── all_tasks_table.dart          # Custom paginated data table for All Tasks
│               ├── all_tasks_action_buttons.dart # Action bar: Create Task, Export (Excel/PDF), Page Size
│               ├── task_filter_card.dart         # Project, Unit, Group, Assignee filter card
│               ├── daily_task_filter_bar.dart    # Filter controls for Month-wise screen
│               ├── daily_task_filter_card.dart   # Card component for Month-wise screen
│               ├── task_tabs.dart                # Active vs. Completed segmented tab widget
│               └── task_stat_item.dart           # Counter stat chip widget
```

---

## 3. Role-Based Access Control (RBAC) & Permissions

All permissions are loaded on login into `AuthRepository.rxUserPermissions`.

| Permission Key | Affected Component / File | UI Impact When Granted | UI Impact When Missing |
|---|---|---|---|
| `Task_Sheduler_Pannel` *(Backend spelling)* | `common_sidebar.dart`<br/>`home_grid_controller.dart` | "Task Scheduler" drawer expandable section and "Daily Task" home grid card are visible. | Entire Task Scheduler section and home card are completely hidden. |
| `Daily_Task` | `common_sidebar.dart`<br/>`home_grid_controller.dart` | Shows "Daily Task" drawer sub-item; enables Home Card routing to `/daily-tasks`. | "Daily Task" item hidden from sidebar. |
| `All_Task` | `common_sidebar.dart`<br/>`home_grid_controller.dart` | Shows "All Task" drawer sub-item; shows "All" shortcut pill on Home Card. | Hidden from drawer and Home Card. |
| `daily_task_by_month` | `common_sidebar.dart`<br/>`home_grid_controller.dart` | Shows "Daily Task By Month" drawer sub-item; shows "Month" shortcut pill on Home Card. | Hidden from drawer and Home Card. |
| `header_task_btn` | `common_shortcut_header.dart` | Renders purple `Tasks` quick-launch pill in the top app bar across all screens. | Header shortcut button is hidden. |
| `create_new_task` | `daily_tasks_screen.dart`<br/>`all_tasks_action_buttons.dart`<br/>`home_grid_controller.dart` | Renders "Create Task" button in app bar, table header, and Home "Add" shortcut. | "Create Task" buttons are hidden. |
| `Task_Edit` | `daily_task_card.dart`<br/>`all_tasks_table.dart` | Shows blue pencil icon on cards; clicking Task ID navigates to Edit screen. | Edit icon hidden; clicking Task ID does not navigate. |
| `Task_Delete` | `daily_task_card.dart` | Shows trash delete icon on active cards. | Trash icon is hidden. |
| `export_task` | `all_tasks_action_buttons.dart` | Displays Export button with Excel (.xlsx) and PDF (.pdf) options. | Export button is completely hidden. |
| `Daily_Task_Filter` | `task_filter_card.dart` | Renders the top multi-select Filter Card container. | Returns `SizedBox.shrink()`, removing filter bar entirely. |
| `Daily_Task_Project_Filter` | `task_filter_card.dart` | Project multi-select dropdown is visible. | Project dropdown hidden. |
| `Daily_Task_Unit_Filter` | `task_filter_card.dart` | Unit (Store) multi-select dropdown is visible. | Unit dropdown hidden. |
| `Daily_Task_Group_Filter` | `task_filter_card.dart` | Security Group multi-select dropdown is visible. | Group dropdown hidden. |
| `Daily_Task_Assignee_Filter` | `task_filter_card.dart` | Assignee multi-select dropdown is visible. | Assignee dropdown hidden. |

---

## 4. Navigation & Role-Based Entry Routing

* **Cold Boot & Login Routing (`splash_controller.dart` / `login_controller.dart`)**:
  * **Admin (`role == '1'`)** $\rightarrow$ Lands on `AppRoutes.home`.
  * **Field Staff & Operators (`role != '1'`)** $\rightarrow$ **Lands directly on `AppRoutes.dailyTasks`** as the application root.
* **Top App Bar Shortcut (`common_shortcut_header.dart`)**:
  * If user has `header_task_btn`, clicking `Tasks` launches `AppRoutes.dailyTasks` from any screen in the app.
* **Edit Navigation Routing (`TasksController.editTaskDetails`)**:
  * When clicking Edit on any task card, table row, or status fallback:
    * If `recurring_task == "0"` (or non-recurring): **Navigates to `AppRoutes.editTask` (`/edit-task`)** displaying the dedicated single-page edit form.
    * If `recurring_task == "1"`: Navigates to `AppRoutes.createTask` (`/create-task`) in recurring edit mode.

---

## 5. UI Rendering & Business Logic

### 5.1 Daily Tasks Screen (`/daily-tasks`)

#### Tab Filtering Logic
* **Active Tab (0)**:
  * Excludes tasks with status `completed` or `approved`.
  * If a task is in `review` or `under_review`, it is **only shown if the current logged-in user is the approver** (`task.approverId == user.id`).
  * Displays active, due, overdue, upcoming, and rejected tasks.
* **Completed Tab (1)**:
  * Displays tasks with status `completed` or `approved`.
  * If a task is in `review` or `under_review`, it is **shown to the submitter** (`task.approverId != user.id`) so field personnel can see their submitted task awaiting review.

#### Temporal Grouping
Tasks are automatically sorted and rendered under three chronological section headers:
1. **Overdue Tasks**: Scheduled date is before today (`< today`). Styled with warning icon and red header (`#E25C5C`).
2. **Today's Tasks**: Scheduled date matches today (`== today`). Separated by dashed dividers, styled with calendar icon and primary blue header.
3. **Tomorrow – Upcoming Tasks**: Scheduled date is after today (`> today`). Styled with future calendar icon (`#0D6EFD`).

#### Detailed vs. Compact List View
* **Compact View (`controller.isListView == true`)**: 1-line item with icon (red sync for recurring, dark person for one-time), truncated title, and status pill. Tapping expands individual cards via `controller.expandedTaskId`.
* **Detailed View (`controller.isListView == false`)**: Full card showing title, description, time slot, frequency badge, assignee/group badge, action icons, and status badge with live timer.

#### Real-time Overdue / Upcoming Countdown
* `tasks_controller.dart` runs a global 1-second timer (`Timer.periodic`) updating `currentTime.value`.
* Cards listening via `Obx` dynamically render:
  * Overdue: `"Overdue by {Xh Ym}"`
  * Upcoming: `"Starts in {Xh Ym}"`

---

### 5.2 Status Badges & Lifecycle Transitions

```
                    ┌──────────────┐
                    │ Task Created │
                    └──────┬───────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
        [ Upcoming ]                 [ Active ]
   ("Starts in {time}")                  │
             │                           │
             └─────────────┬─────────────┘
                           ▼
                 [ Due / Pending ]
                           │
             ┌─────────────┴─────────────┐
             ▼ (Deadline passed)         ▼ (Staff submits proof)
        [ Overdue ]                 ┌─────────┴─────────┐
    ("Overdue by {time}")           │ Approval Required?│
             │                      └────┬─────────┬────┘
             │                           │ No      │ Yes
             │ Staff Submits             ▼         ▼
             └──────────────────────> [Completed] [ Under Review ]
                                                       │
                                            ┌──────────┴──────────┐
                                            ▼ Reject              ▼ Approve
                                       [ Rejected ]          [ Approved ]
                                       (Can Resubmit)        (Final State)
```

#### Status Badge Tapping Logic (`task.canStatusBtnClicked`):
1. **Permission Check**: If `task.canStatusBtnClicked != true`, clicks are blocked with a toast: *"You do not have permission to perform this action."*
2. **Review State (`review` / `under_review`)**:
   * If logged-in user is `approverId`: Opens `TaskSubmissionDialog` in interactive review mode (Approve / Reject buttons enabled, Approver comments enabled).
   * Else: Opens `TaskSubmissionDialog` in read-only mode.
3. **Execution State (`due` / `overdue` / `pending` / `rejected`)**:
   * Opens `TaskSubmissionDialog` in execution mode (Staff comments enabled, photo picker enabled, Update / Submit buttons enabled).
4. **Finished State (`completed` / `approved`)**:
   * Opens `TaskSubmissionDialog` in read-only mode.
5. **Fallback**:
   * If user has `Task_Edit` permission: Opens task in Edit Wizard.

---

### 5.3 Task Submission & Review Dialog (`TaskSubmissionDialog`)

* **Attachments Carousel**:
  * Renders server photos (`/uploads/taskuploads/`) and locally picked images (`XFile`).
  * Tapping any thumbnail launches an `InteractiveViewer` full-screen image carousel with zoom/pan and page controls.
  * In non-read-only mode, allows deleting local picks and launching the device camera directly via `pickImage(ImageSource.camera)`.
* **Field Proof Validation**:
  * If `task.photoRequired == '1'`, submission is blocked if `attachments.isEmpty`.
  * Staff comments are required on submission.
  * Approver comments are required before approving or rejecting.

---

### 5.4 Create & Edit Wizard (`CreateTaskScreen`)

* **Top Mode Switcher**: `One-Time` vs `Recurring` utilizing `AppCommonConnectedTabBar` positioned as the top header of a unified bordered card container (`border: Border.all(color: Color(0xFFCBD5E1))`, `borderRadius: BorderRadius.circular(10.r)`). The active tab connects seamlessly to the content below, with the container border enclosing the step indicator, inputs, and action buttons on a modern canvas (`Color(0xFFF8FAFC)`). The card tightly wraps its content (`mainAxisSize: MainAxisSize.min`) terminating cleanly beneath the action buttons with outer page scrolling handled by `SingleChildScrollView`. Disabled in Read-Only view.
* **Step 1: Task Details**:
  * Title and Description inputs.
  * *One-Time Mode*: Start Date, End Date, Start Time, End Time. Auto-advances to date/time pickers if validation fails.
  * *Recurring Mode*: Recurrence summary card with a button launching `AppointmentRecurrenceDialog`.
* **Step 2: Assignee & Rules**:
  * *Security Group*: Selecting a group triggers `onGroupForCreateChanged(group)` to dynamically re-fetch/filter assignees for that specific group.
  * *Assignee*: Single-select user dropdown.
  * *Store (Unit) & Project*: Cascading selection. Focus automatically shifts to the next unselected dropdown.
  * *Photo Required Switch*: Toggles photo requirement on submission.
  * *Approval Required Switch*: If toggled `true`, dynamically reveals `Approver Name / Team` dropdown.
* **Update Level Selection (Recurring Task Edit Mode Only)**:
  * When `recurring_task == "0"` (one-time task), `Update Level` is omitted from the UI and automatically submitted as `"0"` in the payload.
  * When `recurring_task == "1"` (recurring series), both `"This Task Only" (0)` and `"Entire Task Series" (1)` are always available for selection (the previous `can_update_this_task_only` restriction is removed).

---

### 5.5 Recurrence Engine (`AppointmentRecurrenceDialog`)

Handles complex multi-mode recurrence patterns:
* **Frequencies**: `day`, `week`, `month`, `year`.
* **Day**: Repeats every $N$ days.
* **Week**: Repeats every $N$ weeks on selected weekdays (e.g. `Mon,Wed,Fri`).
* **Month**:
  * Mode `day`: Repeats on day $D$ of every $M$ months (e.g. Day 15).
  * Mode `the`: Repeats on the $O$ ordinal weekday of every $M$ months (e.g. `Second,Tue`).
* **Year**:
  * Mode `on`: Repeats on month $M$ and day $D$ every $Y$ years (e.g. `Oct 13`).
  * Mode `the`: Repeats on the $O$ ordinal weekday of month $M$ every $Y$ years (e.g. `3rd Monday of October`).
* **End Criteria**: End by specific calendar date OR terminate after $N$ occurrences.

---

### 5.6 All Tasks Table (`AllTasksScreen` & `AllTasksTableWidget`)

* **Columns**: `Task ID`, `Project`, `Task`, `Created On`, `Created By`, `Task Type`, `Assignee`, `Started From`, `Completed By`, `Status`, `Approver Name`.
* **Interactions**:
  * Tapping `Task ID`: Opens submission dialog if completed/approved, or opens Edit wizard if user has `Task_Edit`.
  * Tapping any other cell: Toggles multiline row expansion (`_expandedRows`) for text wrapping.
* **Client-Side Sorting**: Clicking any column header toggles ascending/descending/unsorted state.
* **Pagination**: Dropdown sets page size: 10, 20, 50, 100, 500, 1000 items per page.

---

### 5.7 Monthly Breakdown View (`DailyTaskFilterScreen`)

* **Header Summary**: Top counters for Completed (green), Active (amber), and Overdue (red).
* **Sliding Segmented Control**: Smooth animated transition between `Active (count)` and `Completed (count)`.
* **Hierarchical Accordion Structure**:
  * **Month Block**: Collapsible accordion displaying month name and total count. Defaults to open for current month.
  * **Week Block**: Collapsible accordion nested within each month.
  * **Task List**: Task cards displaying schedule dates, assignee, status badges, and action buttons.

---

### 5.8 Dedicated Edit Task Screen & Recurring Choice Dialog (`/edit-task` & `EditRecurringTaskChoiceDialog`)

When a user initiates an edit:
* **For Recurring Tasks (`recurring_task == "1"` / `isRecurring == true`)**:
  * Displays **`EditRecurringTaskChoiceDialog`** modal asking *"What do you want to edit?"*:
    * **`This Task Only`**: Navigates to `/edit-task` configured for this specific occurrence (`update_level: "0"`).
    * **`Entire Task Series`**: Navigates to the same unified `/edit-task` page in a single-column layout configured for the entire series (`update_level: "1"`), avoiding the legacy 2-step `/create-task` wizard.
* **For One-Time Tasks (`recurring_task == "0"`)**:
  * Navigates directly to `/edit-task` with `update_level: "0"`.

#### Screen Structure (`EditTaskScreen`):
The edit page operates in a unified, single-column scrollable layout (`maxWidth: 700px`). The top `One-Time` vs `Recurring` tab bar is omitted because the edit scope (`update_level: "0"` for occurrence vs `"1"` for series) is already established upon entry:

1. **Task Details**:
   * `Task Title`: Required text input (`AppCommonTextField`).
   * `Description`: Multiline text input (`AppCommonTextField`).
   * Horizontal divider with `16.h` vertical padding.

2. **Recurrence & Scheduling**:
   * **When Entire Task Series is selected (`update_level: "1"`)**:
     * **Recurrence Pattern**:
       * Pill selector: `Daily`, `Weekly`, `Monthly`, `Yearly`.
       * *Daily*: `Every [ 1 ] day(s)` with `[ ] Every weekday` checkbox.
       * *Weekly*: `Recur every [ 1 ] week(s) on:` with day pill toggles (`Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`, `Sun`).
       * *Monthly*: `Day [ D ] of every [ M ] month(s)` or `The [ Ordinal ] [ Weekday ] of every [ M ] month(s)`.
       * *Yearly*: `Recur every [ Y ] year(s)` with `On [ Month ] [ D ]` or `The [ Ordinal ] [ Weekday ] of [ Month ]`.
     * Horizontal divider with `16.h` vertical padding.
     * **Each Recurrence**:
       * Row 1: `Start Date` and `End Date` date pickers (`DD-MMM-YYYY`, e.g. `30-Sep-2026`).
       * Row 2: `Start Time` and `End Time` time pickers (`hh:mm a`, e.g. `4:00 PM`, `4:30 PM`).
     * Horizontal divider with `16.h` vertical padding.
     * **Range of Recurrence (Series)**:
       * Row 1: `Start` date picker (`30-Sep-2026`).
       * Row 2: `End by [ End Date ]` radio vs `End after [ Occurrence count ]` radio.
   * **When Single Occurrence / One-Time Task is selected (`update_level: "0"`)**:
     * Header: **`This Occurrence - Date & Time`** (or **`Date & Time`** for one-time tasks).
     * Row 1: `Start Date` and `End Date` date pickers (`DD-MMM-YYYY`, e.g. `30-Sep-2026`).
     * Row 2: `Start Time` and `End Time` time pickers (`hh:mm a`, e.g. `4:00 PM`, `4:30 PM`).
   * Horizontal divider with `16.h` vertical padding.

3. **Assignee & Settings**:
   * Row 1: `Security Group` and `Assignee` searchable dropdowns. Selecting a security group dynamically filters assignees.
   * Row 2: `Store (Unit)` and `Project` searchable dropdowns.
   * Row 3: `Photo Required` (switch toggle) and `Approval Required` (switch toggle).
   * Conditional Row 4: `Approver Name/ Team` dropdown (rendered when `Approval Required` is enabled).

4. **Action Buttons**:
   * Centered row containing:
     * `Cancel`: Outlined button (`height: 32.h`, `width: 90.w`).
     * `Update Task`: Primary brand orange button (`height: 32.h`, `width: 120.w`), submitting `POST /api/update-task` with `update_level: "1"` (for series) or `update_level: "0"` (for occurrence).

---

## 6. API Specifications, cURL Commands & Data Contracts

All endpoints are hosted under the API base URL configured in `AppConfig.baseUrl` (e.g. `https://dev-api.mfresh.in/api/`).

### Global Request Headers

#### Standard JSON Endpoints
```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <AUTH_TOKEN>
```

#### Multipart File Upload Endpoints (`task-submit`, `save-task`, `approve-task`, `reject-task`)
```http
Accept: application/json
Content-Type: multipart/form-data
Authorization: Bearer <AUTH_TOKEN>
```

---

### 6.1 Meta Dropdown APIs

#### A. Fetch Project List (`POST /api/task-project-list`)
Fetches all operational projects for assignment and filtering dropdowns across all task views.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-project-list" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{}'
```

* **Request Body:** `{}` (empty JSON object).

* **Example Success Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "projectid": 1,
      "projectname": "mFresh Operations"
    },
    {
      "projectid": 2,
      "projectname": "Distribution Center Central"
    },
    {
      "projectid": 3,
      "projectname": "Cold Chain Logistics"
    }
  ]
}
```

---

#### B. Fetch Security Group List (`GET /api/task-group-list`)
Fetches security and role groups for team-level assignment, filtering, and role-based access.

* **cURL:**
```bash
curl -X GET "https://dev-api.mfresh.in/api/task-group-list" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>"
```

* **Query Parameters:** None.

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "type": "SuperAdmin",
      "RoleNm": "HQ Leadership",
      "Role_val": "1",
      "rolefor": "0",
      "created_at": "2026-01-01 00:00:00",
      "updated_at": "2026-01-01 00:00:00"
    },
    {
      "id": 3,
      "type": "Operations",
      "RoleNm": "Store Managers",
      "Role_val": "1",
      "rolefor": "0",
      "created_at": "2026-01-01 00:00:00",
      "updated_at": "2026-01-01 00:00:00"
    },
    {
      "id": 4,
      "type": "Field Staff",
      "RoleNm": "Technicians",
      "Role_val": "2",
      "rolefor": "0",
      "created_at": "2026-01-01 00:00:00",
      "updated_at": "2026-01-01 00:00:00"
    }
  ]
}
```

---

#### C. Fetch Stores / Units (`POST /api/support-units`)
Fetches operational store units, outlets, and hubs for unit-level scoping and task allocation.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/support-units" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{}'
```

* **Request Body:** `{}` (empty JSON object).

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "data": [
    {
      "id": 10,
      "QRCodeID": "UNIT-10",
      "unit_name": "Koramangala Store #10"
    },
    {
      "id": 11,
      "QRCodeID": "UNIT-11",
      "unit_name": "Indiranagar Hub #11"
    },
    {
      "id": 12,
      "QRCodeID": "UNIT-12",
      "unit_name": "Whitefield Fulfillment Center #12"
    }
  ]
}
```

---

#### D. Fetch Assignees (`POST /api/all-assignee`)
Fetches eligible assignee personnel. Can optionally be filtered by Security Group ID (`group_id`).

* **cURL (All Assignees Unfiltered):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/all-assignee" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{}'
```

* **cURL (Filtered by Security Group ID):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/all-assignee" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "group_id": "3"
  }'
```

* **Request Parameters:**
  * `group_id` *(string, optional)*: Security group ID to retrieve members belonging strictly to that group.

* **Example Success Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    {
      "id": 5,
      "name": "Rahul Sharma"
    },
    {
      "id": 7,
      "name": "Priya Nair"
    },
    {
      "id": 14,
      "name": "Vikram Patel"
    }
  ]
}
```

---

### 6.2 Task Listing & Browsing APIs

#### A. Fetch Daily Tasks (`POST /api/daily-tasks`)
Default operational landing screen endpoint. Retrieves task instances partitioned into Today, Tomorrow/Upcoming, and Overdue, alongside counter stats for top badge chips.

* **cURL (Unfiltered / Default):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/daily-tasks" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "project_id": [],
    "unit_id": "",
    "assignee_id": [],
    "s_groupID": []
  }'
```

* **cURL (With Multi-Select Filters Applied):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/daily-tasks" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "project_id": [1, 2],
    "unit_id": [10, 11],
    "assignee_id": [5],
    "s_groupID": [3]
  }'
```

* **Request Body Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `project_id` | `List<int>` | Yes | Array of selected Project IDs. Empty `[]` for all projects. |
| `unit_id` | `List<int> \| String` | Yes | Array of selected Store Unit IDs. If empty, client sends empty string `""`. |
| `assignee_id` | `List<int>` | Yes | Array of selected Assignee User IDs. Empty `[]` for all users. |
| `s_groupID` | `List<int>` | Yes | Array of selected Security Group IDs. Empty `[]` for all groups. |

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "counts": {
    "active": 6,
    "upcoming": 2,
    "completed": 14,
    "overdue": 1
  },
  "tasks": [
    {
      "id": 101,
      "task_id": 101,
      "task_instance_id": 502,
      "task_code": "TSK-0101",
      "title": "Chiller Morning Temperature Audit",
      "desp": "Log temperature at 10 AM and upload display photo.",
      "project_id": "1",
      "project": "mFresh Operations",
      "unit_id": "10",
      "s_groupId": "3",
      "group_names": "Store Managers",
      "assign_to": "5",
      "assignee_name": "Rahul Sharma",
      "approver_id": "2",
      "approver_name": "Amit Verma",
      "created_by": "1",
      "createdby_name": "Supervisor Admin",
      "completed_by_name": null,
      "frequency": "day",
      "repeat_interval": "1",
      "photo_required": "1",
      "approval_required": "1",
      "status": "pending",
      "backend_day_status": "active",
      "canStatusbtnClicked": true,
      "shedule_date_time": "15-Oct-2026 10:00 AM",
      "start_time": "10:00 AM",
      "end_time": "10:30 AM",
      "start_date": "2026-10-15",
      "end_date": "2026-10-15",
      "picture": null,
      "ucomment": null,
      "approver_comment": null,
      "created_at": "2026-10-01T08:00:00Z",
      "updated_at": "2026-10-01T08:00:00Z"
    },
    {
      "id": 102,
      "task_id": 102,
      "task_instance_id": 503,
      "task_code": "TSK-0102",
      "title": "Display Rack Sanitization",
      "desp": "Sanitize fresh produce display tables with food-grade sanitizing solution.",
      "project_id": "1",
      "project": "mFresh Operations",
      "unit_id": "10",
      "s_groupId": "4",
      "group_names": "Technicians",
      "assign_to": "7",
      "assignee_name": "Priya Nair",
      "approver_id": "2",
      "approver_name": "Amit Verma",
      "created_by": "1",
      "createdby_name": "Supervisor Admin",
      "completed_by_name": "Priya Nair",
      "frequency": "week",
      "repeat_interval": "1",
      "selected_days": "Mon,Wed,Fri",
      "photo_required": "1",
      "approval_required": "1",
      "status": "review",
      "backend_day_status": "active",
      "canStatusbtnClicked": true,
      "shedule_date_time": "15-Oct-2026 11:00 AM",
      "start_time": "11:00 AM",
      "end_time": "11:45 AM",
      "picture": "[\"rack_sanitized_20261015.jpg\"]",
      "ucomment": "All 6 display racks sanitized with 200ppm quat solution.",
      "approver_comment": null,
      "created_at": "2026-10-01T08:00:00Z",
      "updated_at": "2026-10-15T11:40:00Z"
    }
  ]
}
```

---

#### B. Fetch All Tasks Index with Pagination (`POST /api/task-index`)
Data management console endpoint powering the `/all-tasks` screen and data table.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-index" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "page": 1,
    "per_page": 20,
    "projects": [1],
    "units": [10],
    "assignees": [5],
    "groups": [3]
  }'
```

* **Request Body Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `page` | `int` | Yes | Target 1-indexed page number (default `1`). |
| `per_page` | `int` | Yes | Items per page (e.g. `10, 20, 50, 100, 500, 1000`). |
| `projects` | `List<int>` | Yes | Array of Project IDs. Empty `[]` for all. |
| `units` | `List<int>` | Yes | Array of Unit IDs. Empty `[]` for all. |
| `assignees` | `List<int>` | Yes | Array of Assignee IDs. Empty `[]` for all. |
| `groups` | `List<int>` | Yes | Array of Security Group IDs. Empty `[]` for all. |

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "current_page": 1,
  "last_page": 5,
  "per_page": 20,
  "total_records": 95,
  "data": [
    {
      "id": 101,
      "task_id": 101,
      "task_instance_id": 502,
      "task_code": "TSK-0101",
      "title": "Chiller Morning Temperature Audit",
      "task_type": "Operational",
      "project": "mFresh Operations",
      "assignee_name": "Rahul Sharma",
      "approver_name": "Amit Verma",
      "createdby_name": "Supervisor Admin",
      "completed_by_name": null,
      "status": "pending",
      "shedule_date_time": "15-Oct-2026 10:00 AM",
      "created_at": "2026-10-01T08:00:00Z"
    },
    {
      "id": 98,
      "task_id": 98,
      "task_instance_id": 490,
      "task_code": "TSK-0098",
      "title": "Weekly Emergency Lighting Battery Test",
      "task_type": "Safety",
      "project": "mFresh Operations",
      "assignee_name": "Vikram Patel",
      "approver_name": "Amit Verma",
      "createdby_name": "Supervisor Admin",
      "completed_by_name": "Vikram Patel",
      "status": "approved",
      "shedule_date_time": "14-Oct-2026 04:00 PM",
      "created_at": "2026-10-01T08:00:00Z"
    }
  ]
}
```

---

#### C. Fetch Month-Wise Hierarchical Tasks (`POST /api/DailyTaskFilterApi`)
Powers the `/daily-task-filter` calendar-style breakdown, returning structured hierarchical data (Month $\rightarrow$ Week $\rightarrow$ Tasks) alongside server summary counts and filter options.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/DailyTaskFilterApi" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "tab": "active",
    "filter_year": 2026,
    "from_month": 10,
    "to_month": 10,
    "units": [10],
    "groups": [3],
    "assignees": [5],
    "projects": [1]
  }'
```

* **Request Body Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `tab` | `string` | Yes | Active tab: `"active"` or `"completed"`. |
| `filter_year` | `int` | Optional | Calendar year (e.g. `2026`). Default determined by server if null. |
| `from_month` | `int` | Optional | Start month integer (`1` to `12`). |
| `to_month` | `int` | Optional | End month integer (`1` to `12`). |
| `units` | `List<int>` | Yes | Array of Unit IDs. |
| `groups` | `List<int>` | Yes | Array of Group IDs. |
| `assignees` | `List<int>` | Yes | Array of Assignee IDs. |
| `projects` | `List<int>` | Yes | Array of Project IDs. |

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "data": {
    "summary": {
      "active_count": 8,
      "upcoming_count": 4,
      "completed_count": 22,
      "overdue_count": 1,
      "total_count": 35
    },
    "tabs": {
      "active": { "count": 13 },
      "completed": { "count": 22 }
    },
    "selected_filters": {
      "filter_year": 2026,
      "from_month": 10,
      "to_month": 10,
      "months": [10]
    },
    "server_date_time": "2026-10-15 12:00:00",
    "task_data": [
      {
        "month_key": "2026_10",
        "month_label": "October 2026",
        "is_current_month": true,
        "default_open": true,
        "count": 35,
        "weeks": [
          {
            "week_no": 1,
            "week_label": "Week 1 (Oct 1 - Oct 7)",
            "count": 10,
            "tasks": [
              {
                "id": 101,
                "task_id": 101,
                "task_instance_id": 502,
                "task_code": "TSK-0101",
                "title": "Chiller Morning Temperature Audit",
                "status": "pending",
                "schedule_date": "2026-10-02",
                "start_time": "10:00 AM",
                "end_time": "10:30 AM",
                "assignee_name": "Rahul Sharma",
                "canStatusbtnClicked": true
              }
            ]
          },
          {
            "week_no": 2,
            "week_label": "Week 2 (Oct 8 - Oct 14)",
            "count": 15,
            "tasks": [
              {
                "id": 98,
                "task_id": 98,
                "task_instance_id": 490,
                "task_code": "TSK-0098",
                "title": "Weekly Emergency Lighting Battery Test",
                "status": "approved",
                "schedule_date": "2026-10-14",
                "start_time": "04:00 PM",
                "end_time": "04:30 PM",
                "assignee_name": "Vikram Patel",
                "canStatusbtnClicked": false
              }
            ]
          }
        ]
      }
    ],
    "filter_options": {
      "months": [
        { "id": 10, "name": "October" },
        { "id": 11, "name": "November" },
        { "id": 12, "name": "December" }
      ],
      "units": [
        { "id": 10, "qrcodeId": "UNIT-10", "unit_name": "Koramangala Store #10" }
      ],
      "groups": [
        { "id": 3, "RoleNm": "Store Managers", "type": "Operations" }
      ],
      "assignees": [
        { "id": 5, "name": "Rahul Sharma" }
      ],
      "projects": [
        { "id": 1, "project": "mFresh Operations" }
      ]
    }
  }
}
```

---

#### D. Fetch User Saved Filter Preferences (`GET /api/User_task_filter`)
Retrieves the logged-in user's previously persisted multi-select filter choices to automatically restore their filter state on screen open.

* **cURL:**
```bash
curl -X GET "https://dev-api.mfresh.in/api/User_task_filter" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>"
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "data": {
    "project_id": "1,2",
    "unit_id": "10,11",
    "assignee_id": "5",
    "s_groupID": "3"
  }
}
```

---

### 6.3 Task Creation & Recurrence Engine (`POST /api/task-create`)

The `task-create` endpoint creates single ad-hoc tasks or series templates with recurring generation rules.

#### Master Parameter Dictionary (`POST /api/task-create`)

| Parameter | Type | Required | Default | Description / Accepted Values |
|---|---|---|---|---|
| `task_title` | `string` | **Yes** | — | Name / headline of the task. |
| `description` | `string` | **Yes** | — | Detailed operational guidelines or execution steps. |
| `project` | `string` | **Yes** | — | Target project ID passed as String (e.g. `"1"`). |
| `store` | `string` | **Yes** | — | Target Store / Unit ID passed as String (e.g. `"10"`). |
| `allgroup` | `string` | **Yes** | — | Target Security Group ID passed as String (e.g. `"3"`). |
| `assignee` | `string` | **Yes** | — | Target Assignee User ID passed as String (e.g. `"5"`). |
| `start_date` | `string` | **Yes** | — | Start date formatted as `YYYY-MM-DD` (e.g. `"2026-10-15"`). |
| `end_date` | `string \| null` | Conditional | `null` | End date `YYYY-MM-DD`. Required for recurrence or date-bounded one-time. |
| `start_time` | `string` | **Yes** | — | Start time in 12-hour format with AM/PM (e.g. `"10:00 AM"`). |
| `end_time` | `string` | **Yes** | — | End time in 12-hour format with AM/PM (e.g. `"11:30 AM"`). |
| `photo_required` | `string` | **Yes** | `"off"` | **String literal**: `"on"` or `"off"` (requires proof upload on completion). |
| `approval_required` | `string` | **Yes** | `"off"` | **String literal**: `"on"` or `"off"` (routes task into supervisor review). |
| `approver` | `string \| null` | Conditional | `null` | Approver User ID (string) if `approval_required == "on"`. |
| `recurring_task` | `string` | **Yes** | `"0"` | `"0"` for one-time task; `"1"` for recurring schedule. |
| `frequency` | `string \| null` | Conditional | `null` | Frequency unit when `recurring_task == "1"`: `"day"`, `"week"`, `"month"`, `"year"`. |
| `repeat_interval` | `int \| null` | Conditional | `null` | Repeat interval step (e.g. `1` for every day, `2` for every 2 weeks). |
| `selected_days` | `string \| null` | Conditional | `null` | Weekly: `"Mon,Wed,Fri"`. Monthly Ordinal: `"Second,Tue"`. |
| `month_days` | `string \| null` | Conditional | `null` | Monthly Day Mode: Day of month string (e.g. `"15"`). |
| `year_days` | `string \| null` | Optional | `null` | Yearly day index placeholder. |
| `yearlyPattern` | `string \| null` | Conditional | `null` | Yearly mode: `"on"` (specific date) or `"the"` (ordinal weekday). |
| `yearly_month` | `string \| null` | Conditional | `null` | 3-letter month for `"on"` pattern (e.g. `"Oct"`). |
| `yearly_day` | `string \| null` | Conditional | `null` | Day of month string for `"on"` pattern (e.g. `"15"`). |
| `yearly_week` | `string \| null` | Conditional | `null` | Ordinal word for `"the"` pattern (e.g. `"First"`, `"Second"`, `"Third"`, `"Fourth"`, `"Last"`). |
| `yearly_dayName` | `string \| null` | Conditional | `null` | 3-letter weekday for `"the"` pattern (e.g. `"Mon"`, `"Tue"`, `"Sun"`). |
| `yearly_month2` | `string \| null` | Conditional | `null` | 3-letter month for `"the"` pattern (e.g. `"Oct"`). |
| `occurrences` | `int \| null` | Optional | `null` | Optional max iteration count before terminating recurrence. |

---

#### A. Create One-Time Task
Schedule an ad-hoc, non-repeating operational job.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Deep Clean Evaporator Coils",
    "description": "Scrub condenser coils and disinfect condensate drainage trays in Walk-in Chiller 1.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2026-10-15",
    "start_time": "10:00 AM",
    "end_time": "11:30 AM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "0",
    "frequency": null,
    "repeat_interval": null,
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task created successfully",
  "task_id": 105
}
```

---

#### B. Create Recurring Daily Task
Schedule a task that repeats every $N$ days (e.g. daily morning temperature audit).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Daily Morning Chiller Temperature Check",
    "description": "Log digital thermostat temperature and inspect seal integrity.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2026-12-31",
    "start_time": "09:00 AM",
    "end_time": "09:30 AM",
    "photo_required": "on",
    "approval_required": "off",
    "approver": null,
    "recurring_task": "1",
    "frequency": "day",
    "repeat_interval": 1,
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Recurring task created successfully",
  "task_id": 106
}
```

---

#### C. Create Recurring Weekly Task (e.g. Mon, Wed, Fri)
Schedule a task that repeats on specific weekdays every $N$ weeks.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Tri-Weekly Biological Waste Manifest Log",
    "description": "Weigh biological waste containers and enter manifest receipt numbers.",
    "project": "1",
    "store": "10",
    "allgroup": "4",
    "assignee": "7",
    "start_date": "2026-10-15",
    "end_date": "2026-12-31",
    "start_time": "02:00 PM",
    "end_time": "03:00 PM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "1",
    "frequency": "week",
    "repeat_interval": 1,
    "selected_days": "Mon,Wed,Fri",
    "month_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Weekly recurring task created successfully",
  "task_id": 107
}
```

---

#### D. Create Recurring Monthly Task — Mode 1: Day of Month
Schedule a task that triggers on a specific calendar day of every month (e.g. Day 15).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Monthly Fire Extinguisher Pressure & Tag Inspection",
    "description": "Inspect all CO2 and dry chemical extinguishers. Record pressure gauge readings.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2027-10-15",
    "start_time": "11:00 AM",
    "end_time": "12:00 PM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "1",
    "frequency": "month",
    "repeat_interval": 1,
    "month_days": "15",
    "selected_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Monthly task created successfully",
  "task_id": 108
}
```

---

#### E. Create Recurring Monthly Task — Mode 2: Ordinal Weekday
Schedule a task that triggers on an ordinal weekday every month (e.g. Second Tuesday of every month).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Monthly Pest Control Service Escort & Audit",
    "description": "Escort certified vendor across kitchen and store warehouse. Sign vendor service slip.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2027-10-15",
    "start_time": "03:00 PM",
    "end_time": "04:30 PM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "1",
    "frequency": "month",
    "repeat_interval": 1,
    "month_days": null,
    "selected_days": "Second,Tue",
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Monthly ordinal task created successfully",
  "task_id": 109
}
```

---

#### F. Create Recurring Yearly Task — Mode 1: Specific Date
Schedule an annual task occurring on a fixed date (e.g. October 15 every year).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Annual Cold Room Calibration & FSSAI Re-certification",
    "description": "Vendor certification of all digital temperature loggers and chiller pressure valves.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2030-10-15",
    "start_time": "10:00 AM",
    "end_time": "01:00 PM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "1",
    "frequency": "year",
    "repeat_interval": 1,
    "yearlyPattern": "on",
    "yearly_month": "Oct",
    "yearly_day": "15",
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Yearly task created successfully",
  "task_id": 110
}
```

---

#### G. Create Recurring Yearly Task — Mode 2: Ordinal Weekday
Schedule an annual task occurring on an ordinal weekday in a specific month (e.g. 3rd Monday of October every year).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-create" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_title": "Annual Fire Safety Drill & Evacuation Simulation",
    "description": "Conduct annual store evacuation exercise and sound alarm system test.",
    "project": "1",
    "store": "10",
    "allgroup": "3",
    "assignee": "5",
    "start_date": "2026-10-15",
    "end_date": "2030-10-15",
    "start_time": "08:00 AM",
    "end_time": "09:30 AM",
    "photo_required": "on",
    "approval_required": "on",
    "approver": "2",
    "recurring_task": "1",
    "frequency": "year",
    "repeat_interval": 1,
    "yearlyPattern": "the",
    "yearly_week": "Third",
    "yearly_dayName": "Mon",
    "yearly_month2": "Oct",
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearly_month": null,
    "yearly_day": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Yearly ordinal task created successfully",
  "task_id": 111
}
```

---

### 6.4 Task Lifecycle: Details, Updates & Deletion

#### A. Fetch Task Details for Edit / Review (`POST /api/edit-task`)
Fetches comprehensive metadata for an individual task and its target instance.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/edit-task" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_id": "101",
    "instance_id": "502"
  }'
```

* **Request Parameters:**
  * `task_id` *(string)*: Parent task definition ID.
  * `instance_id` *(string)*: Individual execution occurrence ID.

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task details fetched successfully",
  "data": {
    "id": 101,
    "task_id": 101,
    "task_instance_id": 502,
    "title": "Chiller Morning Temperature Audit",
    "desp": "Log temperature at 10 AM and upload display photo.",
    "project_id": "1",
    "unit_id": "10",
    "s_groupId": "3",
    "assign_to": "5",
    "approver_id": "2",
    "start_date": "2026-10-15",
    "end_date": "2026-10-15",
    "start_time": "10:00 AM",
    "end_time": "10:30 AM",
    "photo_required": "1",
    "approval_required": "1",
    "recurring_task": "1",
    "frequency": "day",
    "repeat_interval": "1",
    "selected_days": null,
    "month_days": null,
    "status": "pending",
    "ucomment": "Completed temperature reading: 4.2 deg C",
    "approver_comment": null,
    "picture": "[\"chiller_temp_20261015.jpg\"]"
  }
}
```

---

#### B. Update Single Task Instance (`POST /api/update-task` with `update_level: "0"`)
Modifies schedule, assignee, or parameters of **this specific instance only**, leaving the rest of the recurring series untouched.

> [!NOTE]
> Unlike `task-create`, the `update-task` endpoint requires numeric types: integers for IDs (`project`, `store`, `allgroup`, `assignee`, `approver`) and integers `1`/`0` for booleans (`photo_required`, `approval_required`).

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/update-task" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_id": 101,
    "instance_id": 502,
    "update_level": "0",
    "task_title": "Chiller Morning Temperature Audit - Extended Defrost Check",
    "description": "Log temperature and inspect evaporator frost build-up on unit coils.",
    "project": 1,
    "store": 10,
    "allgroup": 3,
    "assignee": 5,
    "start_date": "2026-10-15",
    "end_date": "2026-10-15",
    "start_time": "10:00 AM",
    "end_time": "10:45 AM",
    "photo_required": 1,
    "approval_required": 1,
    "approver": 2,
    "recurring_task": "0",
    "frequency": null,
    "repeat_interval": null,
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task updated successfully"
}
```

---

#### C. Update Entire Recurring Task Series (`POST /api/update-task` with `update_level: "1"`)
Applies changes globally to all current and future occurrences of the recurring schedule.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/update-task" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_id": 101,
    "instance_id": 502,
    "update_level": "1",
    "task_title": "Daily Morning Chiller Temperature & Door Gasket Audit",
    "description": "Inspect door gaskets and log digital thermostat reading.",
    "project": 1,
    "store": 10,
    "allgroup": 3,
    "assignee": 5,
    "start_date": "2026-10-15",
    "end_date": "2027-03-31",
    "start_time": "08:30 AM",
    "end_time": "09:00 AM",
    "photo_required": 1,
    "approval_required": 1,
    "approver": 2,
    "recurring_task": "1",
    "frequency": "day",
    "repeat_interval": 1,
    "selected_days": null,
    "month_days": null,
    "year_days": null,
    "yearlyPattern": null,
    "yearly_month": null,
    "yearly_day": null,
    "yearly_week": null,
    "yearly_dayName": null,
    "yearly_month2": null,
    "occurrences": null
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task series updated successfully"
}
```

---

#### D. Delete Task Instance Only (`POST /api/delete-Task` with `delete_level: "0"`)
Deletes this specific instance while preserving the ongoing recurrence series.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/delete-Task" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_id": 101,
    "instance_id": 502,
    "delete_level": "0"
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task deleted successfully"
}
```

---

#### E. Delete Entire Recurring Task Series (`POST /api/delete-Task` with `delete_level: "1"`)
Deletes the parent template and cancels all subsequent future occurrences.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/delete-Task" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -d '{
    "task_id": 101,
    "instance_id": 502,
    "delete_level": "1"
  }'
```

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Entire task series deleted successfully"
}
```

---

### 6.5 Task Proof Submission, Draft & Approval APIs (Multipart)

All four endpoints below consume `multipart/form-data`. In cURL, fields are supplied using `-F`.

#### A. Submit Task Execution (`POST /api/task-submit`)
Called by field personnel upon completing the task. Transitions status to `review` (if approval is required) or `completed`.

* **cURL (Single Photo):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-submit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -F "task_instance_id=502" \
  -F "comment=Temperature reading logged at 4.1 deg C. All evaporator coils cleaned and sanitized." \
  -F "folder_path=uploads/taskuploads" \
  -F "taskimages[]=@/Users/user/Pictures/chiller_display.jpg"
```

* **cURL (Multiple Photos):**
```bash
curl -X POST "https://dev-api.mfresh.in/api/task-submit" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -F "task_instance_id=502" \
  -F "comment=Completed thorough audit. Attached display reading and coil condition photos." \
  -F "folder_path=uploads/taskuploads" \
  -F "taskimages[]=@/Users/user/Pictures/chiller_display.jpg" \
  -F "taskimages[]=@/Users/user/Pictures/coil_condition.jpg"
```

* **Multipart Form Fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `task_instance_id` | Text | **Yes** | Target task instance ID (e.g. `"502"`). |
| `comment` | Text | **Yes** | Staff completion notes and findings. |
| `folder_path` | Text | **Yes** | Destination upload folder: `"uploads/taskuploads"`. |
| `taskimages[]` | File Binary | Conditional | Binary image files. Mandatory if `task.photoRequired == "1"`. |

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task submitted successfully"
}
```

---

#### B. Save Task Draft (`POST /api/save-task`)
Saves intermediate execution progress (comments and photos) without triggering status transition into `review` or `completed`.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/save-task" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -F "task_instance_id=502" \
  -F "comment=Defrosting initiated. Awaiting temperature stabilization before final logging." \
  -F "folder_path=uploads/taskuploads" \
  -F "taskimages[]=@/Users/user/Pictures/defrost_in_progress.jpg"
```

* **Multipart Form Fields:**
  * `task_instance_id`: Target instance ID (string).
  * `comment`: Intermediate note.
  * `folder_path`: `"uploads/taskuploads"`.
  * `taskimages[]`: Optional image files.

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task updated successfully"
}
```

---

#### C. Supervisor Approve Task (`POST /api/approve-task`)
The designated approver signs off on submitted work. Transitions task status to `approved` / `completed`.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/approve-task" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -F "task_instance_id=502" \
  -F "comment=Verified. Thermostat display reading is compliant and coil sanitization confirmed." \
  -F "folder_path=uploads/taskuploads"
```

* **Multipart Form Fields:**
  * `task_instance_id`: Target instance ID (string).
  * `comment`: Approver verification note (required).
  * `folder_path`: `"uploads/taskuploads"`.

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task approved successfully"
}
```

---

#### D. Supervisor Reject Task (`POST /api/reject-task`)
The approver rejects the submission. Transitions task status to `rejected`, allowing field staff to review the rejection feedback, retake photos, and resubmit.

* **cURL:**
```bash
curl -X POST "https://dev-api.mfresh.in/api/reject-task" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <AUTH_TOKEN>" \
  -F "task_instance_id=502" \
  -F "comment=Digital display in attached photo is blurry and illegible. Please retake photo clearly." \
  -F "folder_path=uploads/taskuploads"
```

* **Multipart Form Fields:**
  * `task_instance_id`: Target instance ID (string).
  * `comment`: Detailed rejection reason and required remediation steps (required).
  * `folder_path`: `"uploads/taskuploads"`.

* **Example Success Response (200 OK):**
```json
{
  "status": true,
  "message": "Task rejected successfully"
}
```

---

### 6.6 Client-Side Export Specifications (Excel & PDF)

The All Tasks screen supports exporting currently loaded or filtered data. Export generation occurs **entirely client-side** without dedicated export backend endpoints:

* **Export Trigger**: `AllTasksActionButtonsWidget` checks `userPermissions.contains('export_task')`.
* **Execution**: `TasksController.exportTasks({bool isPdf = false})`
* **Column Mapping**:
  1. `Task ID` $\rightarrow$ `task.id`
  2. `Project` $\rightarrow$ `task.project`
  3. `Task` $\rightarrow$ `task.title`
  4. `Created On` $\rightarrow$ `task.createdAt`
  5. `Created By` $\rightarrow$ `task.createdByName`
  6. `Task Type` $\rightarrow$ `task.taskType`
  7. `Assignee` $\rightarrow$ `task.assigneeName`
  8. `Started From` $\rightarrow$ `task.scheduleDateTime`
  9. `Completed By` $\rightarrow$ `task.completedByName`
  10. `Status` $\rightarrow$ `task.status`
  11. `Approver Name` $\rightarrow$ `task.approverName`
* **Utility Libraries**: Uses `AppExportUtils.exportToExcel` (via `excel` package) and `AppExportUtils.exportToPdf` (via `pdf` package) from `packages/shared/core`.

---

### 6.7 Comprehensive Payload Discrepancy & Type Matrix

| Field | `task-create` Endpoint Expectation | `update-task` Endpoint Expectation | `daily-tasks` / Model Parsing | Mobile Client Strategy |
|---|---|---|---|---|
| `photo_required` | String: `"on"` or `"off"` | Integer: `1` or `0` | String `"1"` or `"0"` | Formatter converts boolean to `"on"/"off"` in create, and `1`/`0` in update. |
| `approval_required` | String: `"on"` or `"off"` | Integer: `1` or `0` | String `"1"` or `"0"` | Formatter converts boolean to `"on"/"off"` in create, and `1`/`0` in update. |
| `project` | String (e.g. `"1"`) | Integer (e.g. `1`) | String `prj_id` or `project_id` | Passed as string in create; passed as int in update. |
| `store` / `unit_id` | String (`store: "10"`) | Integer (`store: 10`) | String `unitID` or `unit_id` | Passed as string in create; passed as int in update. |
| `allgroup` / `s_groupId` | String (`allgroup: "3"`) | Integer (`allgroup: 3`) | String `s_groupId` | Passed as string in create; passed as int in update. |
| `assignee` / `assign_to` | String (`assignee: "5"`) | Integer (`assignee: 5`) | String `assign_to` | Passed as string in create; passed as int in update. |
| `approver` / `approver_id` | String (`approver: "2"`) | Integer (`approver: 2`) | String `approver_id` | Passed as string in create; passed as int in update. |
| `recurring_task` | String: `"1"` or `"0"` | String: `"1"` or `"0"` | String or int | Passed as string `"1"` or `"0"`. |
| `delete_level` / `update_level` | N/A | String: `"0"` or `"1"` | N/A | Passed as explicit string literal: `"0"` (single instance) or `"1"` (entire series). |
| `task_id` | N/A | Integer or String | Integer | Passed as `task.id`. |
| `instance_id` | N/A | Integer or String | Integer | Passed as `task.taskInstanceId`. |

---

### 6.8 Standard Error Responses

#### A. 422 Unprocessable Entity (Validation Failure)
Returned when required fields are missing, invalid date ranges are provided, or mandatory image proof is omitted.

```json
{
  "status": false,
  "message": "The given data was invalid.",
  "errors": {
    "task_title": [
      "The task title field is required."
    ],
    "comment": [
      "The comment field is required."
    ],
    "taskimages": [
      "Photo attachment is mandatory when photo requirement is enabled."
    ]
  }
}
```

#### B. 401 Unauthorized (Expired or Missing Token)
Returned when the `Authorization: Bearer <AUTH_TOKEN>` header is missing, malformed, or expired.

```json
{
  "status": false,
  "message": "Unauthenticated."
}
```

#### C. 403 Forbidden (Permission Denied)
Returned when the logged-in user lacks necessary operational permission (e.g. attempting to approve a task without approver assignment or attempting to delete without `Task_Delete`).

```json
{
  "status": false,
  "message": "You do not have permission to perform this action."
}
```

---

## 7. Known Issues & Audit Findings

1. **`daily_task_filter_bar.dart`**: The "Create Task" button does not check `create_new_task` permission.
2. **`daily_task_filter_card.dart`**: The Edit and Delete icons do not check `Task_Edit` or `Task_Delete` permissions, nor do they check if the task is already completed/approved.
3. **`task_review_screen.dart`**: Orphaned view with dummy callbacks. The app currently uses `TaskSubmissionDialog` popup everywhere.
4. **Pagination in `AllTasksScreen`**: Currently calls `getTasks(perPage: 10000)` and sorts/slices on client. Server-side pagination should be evaluated as datasets scale.
5. **Periodic Timer Overhead**: 1-second global timer updates every card simultaneously. Can be optimized with localized ticker widgets.

