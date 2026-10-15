import 'package:flutter/material.dart';
import 'package:core/constants/app_colors.dart';
import 'package:core/utils/app_text_style.dart';
import 'package:core/widgets/app_image_view.dart';
import 'package:core/widgets/app_common_video_player.dart';

class TicketAttachmentPreview {
  static void show(BuildContext context, List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = initialIndex;
        final pageController = PageController(initialPage: initialIndex);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: AppColors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: urls.length,
                    onPageChanged: (index) {
                      setModalState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = urls[index];
                      final bool isItemVideo = url.toLowerCase().endsWith('.mp4') ||
                          url.toLowerCase().endsWith('.mov') ||
                          url.toLowerCase().endsWith('.avi') ||
                          url.toLowerCase().endsWith('.mkv');
                      if (isItemVideo) {
                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: AppCommonVideoPlayer(
                              videoUrl: url,
                              autoPlay: true,
                              looping: true,
                            ),
                          ),
                        );
                      } else {
                        return InteractiveViewer(
                          child: AppImageView(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            borderRadius: 12,
                          ),
                        );
                      }
                    },
                  ),
                  if (currentIndex > 0)
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        backgroundColor: AppColors.black.withValues(alpha: 0.54),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
                          onPressed: () {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  if (currentIndex < urls.length - 1)
                    Positioned(
                      right: 20,
                      child: CircleAvatar(
                        backgroundColor: AppColors.black.withValues(alpha: 0.54),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 18),
                          onPressed: () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: CircleAvatar(
                      backgroundColor: AppColors.black.withValues(alpha: 0.54),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${currentIndex + 1} / ${urls.length}",
                        style: AppTextStyle.style_12_500(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
