// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/utils/app_color.dart';

class CustomProfileImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  CustomProfileImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return (image.startsWith("http"))
        ? CachedNetworkImage(
            imageUrl: image,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Image.asset(
                AppAsset.profilePlaceHolder,
                fit: BoxFit.cover,
              );
            },
            errorWidget: (context, url, error) {
              return Image.asset(
                AppAsset.profilePlaceHolder,
                fit: BoxFit.cover,
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: "${Api.baseUrl}$image",
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Image.asset(
                AppAsset.profilePlaceHolder,
                fit: BoxFit.cover,
              );
            },
            errorWidget: (context, url, error) {
              return Image.asset(
                AppAsset.profilePlaceHolder,
                fit: BoxFit.cover,
              );
            },
          );
  }
}

class CustomListenerProfileImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  CustomListenerProfileImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return (image.startsWith("http"))
        ? CachedNetworkImage(
            imageUrl: image,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Image.asset(
                AppAsset.listenerPlaceHolder,
                fit: BoxFit.cover,
              );
            },
            errorWidget: (context, url, error) {
              return Image.asset(
                AppAsset.listenerPlaceHolder,
                fit: BoxFit.cover,
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: "${Api.baseUrl}$image",
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Image.asset(
                AppAsset.listenerPlaceHolder,
                fit: BoxFit.cover,
              );
            },
            errorWidget: (context, url, error) {
              return Image.asset(
                AppAsset.listenerPlaceHolder,
                fit: BoxFit.cover,
              );
            },
          );
  }
}

class SendMessageImage extends StatelessWidget {
  final String image;
  BoxFit? fit;
  SendMessageImage({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return (image.startsWith("http"))
        ? CachedNetworkImage(
            imageUrl: image,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.lightGrey.withValues(alpha: 0.6),
                // padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Image.asset(
                  AppAsset.imagePlaceHolder,
                  height: 50,
                  color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                )),
              );
            },
            errorWidget: (context, url, error) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.lightGrey.withValues(alpha: 0.6),

                // padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Image.asset(
                  AppAsset.imagePlaceHolder,
                  height: 50,
                  color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                )),
              );
            },
          )
        : CachedNetworkImage(
            imageUrl: "${Api.baseUrl}$image",
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.lightGrey.withValues(alpha: 0.6),

                // padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Image.asset(
                  AppAsset.imagePlaceHolder,
                  height: 50,
                  color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                )),
              );
            },
            errorWidget: (context, url, error) {
              return Container(
                width: 200,
                height: 200,
                color: AppColors.lightGrey.withValues(alpha: 0.6),

                // padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Image.asset(
                  AppAsset.imagePlaceHolder,
                  height: 50,
                  color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                )),
              );
            },
          );
  }
}

class SendMessageImageFullScreen extends StatelessWidget {
  final String image;
  BoxFit? fit;
  SendMessageImageFullScreen({
    super.key,
    required this.image,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return (image.startsWith("http"))
        ? CachedNetworkImage(
            imageUrl: image,
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return SizedBox(
                width: Get.height,
                height: Get.width,
                // color: AppColors.lightGrey.withValues(alpha: 0.6),
                // padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Image.asset(
                  AppAsset.imagePlaceHolder,
                  height: 160,
                )),
              );
            },
            errorWidget: (context, url, error) {
              return Center(
                  child: Image.asset(
                AppAsset.imagePlaceHolder,
                height: 160,
              ));
            },
          )
        : CachedNetworkImage(
            imageUrl: "${Api.baseUrl}$image",
            fit: fit ?? BoxFit.cover,
            placeholder: (context, url) {
              return Center(
                  child: Image.asset(
                AppAsset.imagePlaceHolder,
                height: 160,
              ));
            },
            errorWidget: (context, url, error) {
              return Center(
                  child: Image.asset(
                AppAsset.imagePlaceHolder,
                height: 160,
              ));
            },
          );
  }
}
