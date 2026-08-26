import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:services/services.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:mfresh_ops/modules/support_tickets/controllers/ticket_details_controller.dart';
import 'package:mfresh_ops/core/utils/app_media_compressor.dart';
import 'package:core/utils/app_common_toast_message.dart';
import 'ticket_attachment_preview.dart';

class TicketDetailsTimeline extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailsController controller;

  const TicketDetailsTimeline({
    super.key,
    required this.ticket,
    required this.controller,
  });

  String _getCreatorName(dynamic ticket) {
    if (ticket.userName != null && ticket.userName!.isNotEmpty) {
      return ticket.userName!;
    }
    
    final String? creatorIdStr = ticket.createdBy?.toString() ?? ticket.createdById?.toString();
    if (creatorIdStr == null || creatorIdStr.isEmpty) {
      return "-";
    }

    final matchedAssignee = controller.assignees.firstWhereOrNull(
      (a) => a.id.toString() == creatorIdStr,
    );
    if (matchedAssignee != null && matchedAssignee.name.isNotEmpty) {
      return matchedAssignee.name;
    }

    if (ticket.logs != null) {
      for (var log in ticket.logs) {
        if (log['user_id']?.toString() == creatorIdStr &&
            log['user_name'] != null &&
            log['user_name'].toString().isNotEmpty) {
          return log['user_name'].toString();
        }
      }
    }

    if (ticket.comments != null) {
      for (var c in ticket.comments) {
        if (c['user_id']?.toString() == creatorIdStr) {
          final String? name = c['commented_by'] ?? c['user_name'];
          if (name != null && name.isNotEmpty && name.toLowerCase() != 'user') {
            return name;
          }
        }
      }
    }

    return "-";
  }

  void _showCommentMediaSourceOptions(
    BuildContext context,
    TicketDetailsController controller,
  ) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                controller.captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Photo from Gallery'),
              onTap: () {
                Get.back();
                controller.pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record a Video'),
              onTap: () {
                Get.back();
                controller.recordVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose Video from Gallery'),
              onTap: () {
                Get.back();
                controller.pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Choose Document (PDF/XLS)'),
              onTap: () {
                Get.back();
                controller.pickDocument();
              },
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildCommentInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF29B6F6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "COMMENTS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryOrange,
                ),
              ),
              const Spacer(),
              Obx(
                () => GestureDetector(
                  onTap: () => controller.isInternal.toggle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        controller.isInternal.value
                            ? Icons.check_box_outlined
                            : Icons.crop_square_outlined,
                        color: AppColors.primaryOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Mark Internal",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Write your comment...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFEEEEEE),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 1,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.link,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showCommentMediaSourceOptions(
                            context,
                            controller,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryOrange,
                                  ),
                                )
                              : IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.send,
                                    color: AppColors.primaryOrange,
                                    size: 20,
                                  ),
                                  onPressed: () => controller.addComment(),
                                ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showCommentMediaSourceOptions(context, controller),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondaryOrange,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attachment,
                    color: AppColors.primaryOrange,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Upload Files",
                    style: TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => (controller.selectedImages.isNotEmpty ||
                    controller.selectedVideos.isNotEmpty ||
                    controller.selectedDocuments.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...controller.selectedImages.map(
                          (file) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(file.path),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      controller.selectedImages.remove(file),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...controller.selectedVideos.map(
                          (file) => Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      controller.selectedVideos.remove(file),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...controller.selectedDocuments.map(
                          (file) => Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.description,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      controller.selectedDocuments.remove(file),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _commentRow({required Widget child}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 12,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 16),
          child: child,
        ),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, dynamic c) {
    final int commentId = c['id'] ?? 0;
    final List images = c['ticket_images'] ?? [];
    final storage = Get.find<StorageService>();
    final user = storage.getUser();
    final bool isOwner = c['user_id']?.toString() == user?.id?.toString();

    final String commenterIdStr = c['user_id']?.toString() ?? '';
    String commenterName = c['commented_by'] ?? c['user_name'] ?? '';

    if (commenterName.isEmpty || commenterName.toLowerCase() == 'user') {
      if (commenterIdStr.isNotEmpty) {
        if (commenterIdStr == user?.id?.toString()) {
          commenterName = user?.name ?? '';
        } else {
          final assignee = controller.assignees.firstWhereOrNull(
            (a) => a.id.toString() == commenterIdStr,
          );
          if (assignee != null) {
            commenterName = assignee.name;
          } else if (ticket != null && ticket.createdById?.toString() == commenterIdStr) {
            commenterName = _getCreatorName(ticket);
          }
        }
      }
    }
    if (commenterName.isEmpty) {
      commenterName = 'User';
    }

    String activityText = c['action'] ?? "$commenterName updated";
    if (commenterName.toLowerCase() != 'user') {
      activityText = activityText.replaceAll(RegExp(r'\bUser\b', caseSensitive: false), commenterName);
    }
    final bool hasBookmark = activityText.toLowerCase().contains("accepted");

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 16,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF9),
            border: Border.all(
              color: const Color(0xFF29B6F6),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 90,
                          child: Text(
                            "ACTIVITY",
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            activityText,
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onPressed: () => controller.toggleEditComment(commentId),
                    ),
                ],
              ),
              if (c['comment'] != null &&
                  c['comment'].toString().trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        "COMMENTS",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: _buildCommentText(c['comment'].toString())),
                  ],
                ),
              ],
              if (images.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 90,
                      child: Text(
                        "ATTACHMENTS",
                        style: TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: images.map((img) {
                          final urlStr = img.toString();
                          final List<String> urls = images.map((e) => e.toString()).toList();
                          final isVideo =
                              urlStr.toLowerCase().endsWith('.mp4') ||
                              urlStr.toLowerCase().endsWith('.mov') ||
                              urlStr.toLowerCase().endsWith('.avi') ||
                              urlStr.toLowerCase().endsWith('.mkv');
                          if (isVideo) {
                            return InkWell(
                              onTap: () {
                                TicketAttachmentPreview.show(context, urls, urls.indexOf(urlStr));
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          }
                          return InkWell(
                            onTap: () =>
                                TicketAttachmentPreview.show(context, urls, urls.indexOf(urlStr)),
                            child: AppImageView(
                              imageUrl: urlStr,
                              width: 50,
                              height: 50,
                              borderRadius: 6,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Updated On: ${c['created_at'] != null ? DateFormat('dd-MM-yy, HH:mm').format(DateTime.parse(c['created_at'])) : ''}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasBookmark)
          const Positioned(
            left: 12,
            top: 0,
            child: Icon(Icons.bookmark, color: Color(0xFF29B6F6), size: 18),
          ),
      ],
    );
  }

  Widget _buildCommentText(String text) {
    if (!text.contains('@')) {
      return Text(text, style: const TextStyle(fontSize: 12, height: 1.3));
    }

    final List<TextSpan> spans = [];
    final words = text.split(' ');
    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.startsWith('@')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(children: spans, style: const TextStyle(height: 1.3)),
    );
  }

  Widget _buildCommentEditForm(TicketDetailsController controller, dynamic c) {
    final int commentId = c['id'] ?? 0;
    final String initialComment = c['comment'] ?? '';
    final List initialImages = c['ticket_images'] ?? [];
    final bool initialInternal = c['is_internal'] == "1";

    return StatefulBuilder(
      builder: (context, setState) {
        final TextEditingController editController = TextEditingController(
          text: initialComment,
        );
        List<File> newImages = [];
        List<File> newVideos = [];
        List<String> existingImages = List<String>.from(
          initialImages.map((e) => e.toString()),
        );
        bool isInternal = initialInternal;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF9),
            border: Border.all(color: const Color(0xFF29B6F6), width: 1.5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Edit Comment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Checkbox(
                    value: isInternal,
                    onChanged: (val) => setState(() => isInternal = val!),
                  ),
                  const Text('Internal', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  Obx(
                    () => controller.isLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryOrange,
                            ),
                          )
                        : InkWell(
                            onTap: () => controller.editComment(
                              commentId: commentId,
                              comment: editController.text,
                              newImages: newImages,
                              newVideos: newVideos,
                              internal: isInternal,
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => InkWell(
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.toggleEditComment(commentId),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),
              ),
              const SizedBox(height: 12),
              if (existingImages.isNotEmpty) ...[
                const Text(
                  'Current Images:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: existingImages
                      .map(
                        (url) => Stack(
                          children: [
                            AppImageView(
                              imageUrl: url,
                              width: 50,
                              height: 50,
                              borderRadius: 8,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => existingImages.remove(url)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (newImages.isNotEmpty) ...[
                const Text(
                  'New Images:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: newImages
                      .map(
                        (file) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                file,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => newImages.remove(file)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (newVideos.isNotEmpty) ...[
                const Text(
                  'New Videos:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: newVideos
                      .map(
                        (file) => Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => newVideos.remove(file)),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              InkWell(
                onTap: () async {
                  Get.bottomSheet(
                    Material(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take a Photo'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                              );
                              if (picked != null) {
                                setState(
                                  () => newImages.add(File(picked.path)),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose Photo from Gallery'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickMultiImage();
                              setState(
                                () => newImages.addAll(
                                  picked.map((e) => File(e.path)),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.videocam),
                            title: const Text('Record a Video'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickVideo(
                                source: ImageSource.camera,
                              );
                              if (picked != null) {
                                AppCommonToastMessage.show(
                                  message: 'Compressing video...',
                                  type: ToastType.info,
                                );
                                final compressed = await AppMediaCompressor.compressVideo(
                                  File(picked.path),
                                );
                                setState(() => newVideos.add(compressed));
                                AppCommonToastMessage.show(
                                  message: 'Video compressed successfully',
                                  type: ToastType.success,
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.video_library),
                            title: const Text('Choose Video from Gallery'),
                            onTap: () async {
                              Get.back();
                              final picked = await ImagePicker().pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                AppCommonToastMessage.show(
                                  message: 'Compressing video...',
                                  type: ToastType.info,
                                );
                                final compressed = await AppMediaCompressor.compressVideo(
                                  File(picked.path),
                                );
                                setState(() => newVideos.add(compressed));
                                AppCommonToastMessage.show(
                                  message: 'Video compressed successfully',
                                  type: ToastType.success,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attachment_rounded,
                      color: AppColors.primaryOrange,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Attach Files",
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTable(List logs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF29B6F6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: logs.map((log) {
          final int idx = logs.indexOf(log);
          return Column(
            children: [
              _historyRowTable(log),
              if (idx != logs.length - 1)
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _historyHeaderTable() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "User",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              "Action",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyRowTable(dynamic log) {
    String dateStr = log['created_at'] ?? "-";
    String datePart = "-";
    String timePart = "-";
    try {
      final dt = DateTime.parse(dateStr);
      datePart = DateFormat("dd-MM-yy").format(dt);
      timePart = DateFormat("HH:mm").format(dt);
    } catch (_) {
      datePart = dateStr;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datePart,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
                Text(
                  timePart,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              log['user_name'] ?? "-",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          Expanded(flex: 5, child: _buildActionSpanText(log)),
        ],
      ),
    );
  }

  Widget _buildActionSpanText(dynamic log) {
    final String action = log['action'] ?? '';
    final String field = log['field'] ?? '';
    final String oldVal = log['old_value'] ?? '';
    final String newVal = log['new_value'] ?? '';

    if (action.toLowerCase() == 'create' || action.toLowerCase() == 'created') {
      return const Text(
        "Created.",
        style: TextStyle(fontSize: 11, color: Colors.black87),
      );
    }

    String fieldName = field;
    if (field == 'subcat_id') fieldName = 'Sub Category';
    if (field == 'mcat_id') fieldName = 'Category';
    if (field == 'assigned_to') fieldName = 'Assignee';
    if (field == 'priority') fieldName = 'Priority';
    if (field == 'status') fieldName = 'Status';
    if (field == 'projectid') fieldName = 'Project';

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
          height: 1.2,
        ),
        children: [
          const TextSpan(text: "Change "),
          TextSpan(
            text: fieldName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (oldVal.isNotEmpty) ...[
            const TextSpan(text: " from "),
            TextSpan(
              text: oldVal,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
          const TextSpan(text: " to "),
          TextSpan(
            text: newVal,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comments = ticket.comments ?? [];
    final logs = ticket.logs ?? [];
    final bool hasHistory = logs.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildCommentInputArea(context),
        const SizedBox(height: 16),
        ...comments.asMap().entries.map((entry) {
          final dynamic c = entry.value;
          final int commentId = c['id'] ?? 0;

          return _commentRow(
            child: Obx(
              () => controller.editingCommentIds.contains(commentId)
                  ? _buildCommentEditForm(controller, c)
                  : _buildCommentItem(context, c),
            ),
          );
        }),
        if (hasHistory) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "History",
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _historyHeaderTable(),
              ],
            ),
          ),
          _buildHistoryTable(logs),
        ],
      ],
    );
  }
}
