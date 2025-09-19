import 'package:flutter/material.dart';
import 'package:k2k/utils/sreen_util.dart';
import 'package:shimmer/shimmer.dart';

Widget ShimmerCard() {
  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: ScreenUtil.spacingLarge,
      vertical: ScreenUtil.spacingMedium,
    ),
    child: Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenUtil.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil.spacingLarge),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200, // light background
          highlightColor: Colors.grey.shade400, // darker wave
          direction: ShimmerDirection.ltr,
          period: const Duration(milliseconds: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: ScreenUtil.textSizeLarge + 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(
                          ScreenUtil.borderRadiusSmall,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtil.spacingLarge),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.only(left: ScreenUtil.spacingMedium),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            ScreenUtil.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ScreenUtil.spacingLarge),

              /// Body Rows
              ...List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtil.spacingMedium),
                  child: Row(
                    children: [
                      Container(
                        width: ScreenUtil.iconSizeSmall,
                        height: ScreenUtil.iconSizeSmall,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(
                            ScreenUtil.borderRadiusSmall,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil.spacingMedium),
                      Expanded(
                        child: Container(
                          height: ScreenUtil.textSizeMedium,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                              ScreenUtil.borderRadiusSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
