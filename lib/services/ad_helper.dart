import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // TODO: Replace these with your actual AdMob App ID and Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2196000838402173/4296537141';
    } else {
      // Returning test ID for non-android if you don't have one
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  // Second banner for other pages
  static String get bannerAdUnitId2 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2196000838402173/6168155460';
    } else {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2196000838402173/8118430334';
    } else {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }

  // Since you created 3 units (2 banners, 1 interstitial), 
  // we'll use interstitial for the "video" request until you create a Rewarded unit.
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2196000838402173/8602747116';
    } else {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
  }

  static void showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent:  (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (err) {
          print('InterstitialAd failed to load: $err');
        },
      ),
    );
  }

  static void showRewardedAd({required Function onUserEarnedReward}) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
          );
          ad.show(
            onUserEarnedReward: (ad, reward) {
              onUserEarnedReward();
            },
          );
        },
        onAdFailedToLoad: (err) {
          print('RewardedAd failed to load: $err');
          // Still allow the action if ad fails
          onUserEarnedReward();
        },
      ),
    );
  }
}
