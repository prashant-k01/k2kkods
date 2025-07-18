  import 'package:flutter/material.dart';
import 'package:k2k/utils/sreen_util.dart';

Widget buildShimmerCard() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtil.spacingLarge,
        vertical: ScreenUtil.spacingMedium,
      ),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtil.borderRadiusLarge),
        ),
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: ScreenUtil.textSizeLarge + 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
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
                          color: Colors.grey[300],
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
                          color: Colors.grey[300],
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
                            color: Colors.grey[300],
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
    );
  }
