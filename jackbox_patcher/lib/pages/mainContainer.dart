
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:jackbox_patcher/components/dialogs/leaveApplicationDialog.dart';
import 'package:jackbox_patcher/services/api/api_service.dart';
import 'package:jackbox_patcher/services/device/device.dart';
import 'package:jackbox_patcher/services/downloader/downloader_service.dart';
import 'package:jackbox_patcher/services/translations/translationsHelper.dart';
import 'package:jackbox_patcher/services/user/initialLoad.dart';
import 'package:jackbox_patcher/services/user/userdata.dart';
import 'package:jackbox_patcher/services/windowManager/windowsManagerService.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

import '../components/notificationsCaroussel.dart';
import '../services/discord/DiscordService.dart';

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> with WindowListener {
  bool isFirstTimeOpening = true;
  bool _loaded = false;

  double calculatePadding() {
    if (MediaQuery.of(context).size.width > 1000) {
      return (MediaQuery.of(context).size.width - 880) / 2;
    } else {
      return 60;
    }
  }

  @override
  void initState() {
    windowManager.addListener(this);
    _load(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TranslationsHelper().appLocalizations = AppLocalizations.of(context);
    return NavigationView(
        content: Stack(
      children: [
        Image.asset("assets/images/background_pattern.png",
            scale: 1.5,
            repeat: ImageRepeat.repeat,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(1, 32, 32, 32).withOpacity(0.98),
        ),
        Column(children: [
          const Spacer(),
          _buildUpper(),
          _buildLower(),
          const Spacer(),
        ]),
      ],
    ));
  }

  Widget _buildUpper() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _buildTitle(),
      const SizedBox(
        height: 30,
      ),
      _loaded
          ? _buildMenu()
          : LottieBuilder.asset("assets/lotties/QuiplashOutput.json",
              width: 200, height: 200),
      const SizedBox(
        height: 30,
      ),
    ]);
  }

  Widget _buildMenu() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: calculatePadding()),
        child: Column(children: [
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                  style: ButtonStyle(
                      backgroundColor: ButtonState.all(Colors.green),
                      shape: ButtonState.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)))),
                  onPressed: () async {
                    await Navigator.pushNamed(context, "/searchMenu");
                    DiscordService().launchMenuPresence();
                  },
                  child: SizedBox(
                      width: 300,
                      height: 20,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FluentIcons.play, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                                AppLocalizations.of(context)!
                                    .launch_search_game,
                                style: const TextStyle(color: Colors.white))
                          ])))),
          const SizedBox(height: 10),
          !DeviceService.isWeb()
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: ButtonState.all(Colors.blue),
                          shape: ButtonState.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)))),
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/patch");
                        DiscordService().launchMenuPresence();
                      },
                      child: SizedBox(
                          width: 300,
                          height: 20,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FluentIcons.download,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.patch_a_game,
                                    style: const TextStyle(color: Colors.white))
                              ]))))
              : const SizedBox(height: 0),
          const SizedBox(height: 30),
          !DeviceService.isWeb()
              ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: ButtonState.all(Colors.grey),
                          shape: ButtonState.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)))),
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/settings",
                            arguments: UserData().packs);
                        DiscordService().launchMenuPresence();
                        if (APIService().cachedSelectedServer != null) {
                          _loaded = false;
                          setState(() {});
                          _load(false);
                        }
                      },
                      child: SizedBox(
                          width: 300,
                          height: 20,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(FluentIcons.settings,
                                    color: Colors.white),
                                const SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.settings,
                                    style: const TextStyle(color: Colors.white))
                              ]))))
              : const SizedBox(height: 0)
        ]));
  }

  Widget _buildConnectedServer() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(AppLocalizations.of(context)!
          .connected_to_server(APIService().cachedSelectedServer!.name)),
      const SizedBox(width: 10),
      GestureDetector(
        child: Text(AppLocalizations.of(context)!.connected_to_server_change,
            style: const TextStyle(decoration: TextDecoration.underline)),
        onTap: () async {
          UserData().setSelectedServer(null);
          UserData().packs = [];
          APIService().resetCache();
        },
      )
    ]);
  }

  Widget _buildTitle() {
    return Column(children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: _loaded
              ? Image.network(
                  APIService()
                      .assetLink(APIService().cachedSelectedServer!.image),
                  height: 100)
              : Image.asset(
                  "assets/logo.png",
                  height: 100,
                )),
      Text(
          _loaded
              ? APIService().cachedSelectedServer!.name
              : AppLocalizations.of(context)!.jackbox_utility,
          style: FluentTheme.of(context).typography.titleLarge)
    ]);
  }

  Widget _buildLower() {
    return _loaded
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotificationCaroussel(
              news: APIService().cachedNews,
            ),
          )
        : Container();
  }

  void _load(bool automaticallyChooseBestServer) async {
    await InitialLoad.init(context,isFirstTimeOpening, automaticallyChooseBestServer);
      isFirstTimeOpening = false;
    setState(() {
      _loaded = true;
    });
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      bool shouldClose = DownloaderService.isDownloading
          ? await (showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return const LeaveApplicationDialog();
                  })) ==
              true
          : true;

      await WindowManagerService.saveCurrentScreenSize();
      if (shouldClose) {
        windowManager.destroy();
      }
    }
  }
}
