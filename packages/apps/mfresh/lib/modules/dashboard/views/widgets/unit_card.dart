import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UnitCard extends StatelessWidget {
  final String unitName;
  final String description;
  final String image;
  final String date;
  final VoidCallback onTap;

  const UnitCard({
    super.key,
    required this.unitName,
    required this.onTap,
    required this.description,
    required this.image,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    double fontSizeUnitNo = 16;
    double fontSizeDescription = 14;
    double fontSizeDate = 14;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/unit_card.jpeg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/unit_card.jpeg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, err, stack) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Unit No.: ",
                            style: TextStyle(
                              fontSize: fontSizeUnitNo,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: unitName,
                            style: TextStyle(
                              fontSize: fontSizeUnitNo + 1,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSizeDescription,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSizeDate,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
