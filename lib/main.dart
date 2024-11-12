// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

// ignore: avoid_web_libraries_in_flutter
//import 'dart:html';

import 'package:creta_common/common/creta_color.dart'; //import 'package:creta04/pages/studio/sample_data.dart';
import 'package:creta_common/common/creta_snippet.dart';
import 'package:creta_common/common/creta_vars.dart';
import 'package:creta_common/model/app_enums.dart';
import 'package:creta_user_model/model/user_property_model.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hycop_multi_platform/hycop.dart';
//import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logging/logging.dart';
import 'package:get/get.dart';
import 'package:creta_common/common/cross_common_job.dart';
import 'design_system/component/snippet.dart';
import 'pages/studio/studio_constant.dart';
import 'pages/studio/studio_getx_controller.dart';
//import 'pages/login_page.dart';
import 'pages/login/creta_account_manager.dart';
import 'routes.dart';

Level logLevelFromString(String level) {
  switch (level) {
    case 'all':
      return Level.ALL;
    case 'finest':
      return Level.FINEST;
    case 'finer':
      return Level.FINER;
    case 'fine':
      return Level.FINE;
    case 'config':
      return Level.CONFIG;
    case 'info':
      return Level.INFO;
    case 'warning':
      return Level.WARNING;
    case 'severe':
      return Level.SEVERE;
    case 'shout':
      return Level.SHOUT;
    case 'off':
      return Level.OFF;
    default:
      return Level.SEVERE;
  }
}

void main() async {
  const String isDeveloper = String.fromEnvironment('isDeveloper', defaultValue: 'false');
  CretaVars.instance.isDeveloper = (isDeveloper == 'true');
  //setPathUrlStrategy();  <-- 예전에는 이렇게 사용했음 그러나 지금은...
  usePathUrlStrategy(); // <-- 이렇게 사용함

  WidgetsFlutterBinding.ensureInitialized();
  setupLogger();
  const String level = String.fromEnvironment('logLevel', defaultValue: 'severe');
  Logger.root.level = logLevelFromString(level);

  const String serverType = String.fromEnvironment('serverType', defaultValue: 'firebase');
  HycopFactory.serverType = ServerType.fromString(serverType);
  await HycopFactory.initAll();

  if (CretaVars.instance.isDeveloper == false) {
    await CretaAccountManager.initUserProperty();
  }

  //SampleData.initSample();
  StudioConst.initLangMap();

  // test code
  //myConfig!.serverConfig!.storageConnInfo.bucketId =
  //    "${HycopUtils.genBucketId(AccountManager.currentLoginUser.email, AccountManager.currentLoginUser.userId)}/";

  runApp(const ProviderScope(child: MainRouteApp()));
  //runApp(MyApp());
}

class MainRouteApp extends ConsumerStatefulWidget {
  const MainRouteApp({super.key});
  // This widget is the root of your application.
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainRouteAppState();
}

class _MainRouteAppState extends ConsumerState<MainRouteApp> {
  Future<bool>? _langInited;

  Future<bool>? initLang() async {
    if (CretaVars.instance.isDeveloper == false) {
      UserPropertyModel? userModel =
          CretaAccountManager.userPropertyManagerHolder.userPropertyModel;
      if (userModel != null) {
        if (userModel.language == LanguageType.none) {
          userModel.language = LanguageType.korean;
        }
        await Snippet.setLang(language: userModel.language);
      }
    } else {
      await Snippet.setLang(language: LanguageType.korean);
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    CrossCommonJob ccj = CrossCommonJob();
    CretaVars.instance.isCanvaskit = ccj.isInUsingCanvaskit();

    saveManagerHolder = SaveManager();

    //Snippet.clearLang();
    _langInited = initLang();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData.light().copyWith(
      //useMaterial3: true,
      //primaryColor: CretaColor.primary,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: CretaColor.primary,
        onPrimary: CretaColor.text[100]!,
        secondary: CretaColor.secondary,
        onSecondary: CretaColor.text[100]!,
        error: CretaColor.stateCritical,
        onError: CretaColor.text,
        surface: Colors.white,
        onSurface: CretaColor.text,
      ),
      // sliderTheme: SliderThemeData(
      //   activeTickMarkColor: Colors.amber,
      //   showValueIndicator: ShowValueIndicator.never,
      // ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(CretaColor.primary),
      ),
      dividerColor: CretaColor.text[200],
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: CretaColor.text),
        contentTextStyle: TextStyle(color: CretaColor.text),
      ),
      dataTableTheme: DataTableThemeData(
        dividerThickness: 0.2,
        dataTextStyle: TextStyle(color: CretaColor.text),
        headingTextStyle: TextStyle(color: Colors.white),
        headingRowColor: WidgetStateProperty.all(CretaColor.primary),
        // decoration: BoxDecoration(
        //   border: Border.all(color: CretaColor.secondary),
        // ),
      ),
    );

    if (CretaVars.instance.isDeveloper == true) {
      return GetMaterialApp.router(
        title: 'Creta creates',
        initialBinding: InitBinding(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: MaterialScrollBehavior().copyWith(scrollbars: false),
        theme: theme,
        routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
          return routesLoggedOut;
        }),
        routeInformationParser: const RoutemasterParser(),
      );
    }

    return FutureBuilder<bool>(
        future: _langInited,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //error가 발생하게 될 경우 반환하게 되는 부분
            logger.severe("data fetch error(WaitDatum)");
            return Directionality(
                textDirection: TextDirection.ltr,
                child: const Center(child: Text('data fetch error(WaitDatum)')));
          }
          if (snapshot.hasData == false) {
            logger.finest("wait data ...(WaitData)");
            return Directionality(
              textDirection: TextDirection.ltr, // or TextDirection.rtl, as needed
              child: Center(
                child: CretaSnippet.showWaitSign(),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            logger.finest("founded ${snapshot.data!}");
            return GetMaterialApp.router(
              title: 'Creta creates',
              initialBinding: InitBinding(),
              debugShowCheckedModeBanner: false,
              scrollBehavior: MaterialScrollBehavior().copyWith(scrollbars: false),
              theme: theme,
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                return routesLoggedOut;
              }),
              routeInformationParser: const RoutemasterParser(),
            );
          }
          return const SizedBox.shrink();
        });
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    // Register the InitController class
    Get.put(StudioGetXController());
    //Get.put(FrameEventController());
  }
}

class MyTextTheme extends TextTheme {
  // Add your custom styles here
}



/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.text_increase),
            onTap: () {
              Routemaster.of(context).push(AppRoutes.databaseExample);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.smart_button),
            onTap: () {},
          ),
          SpeedDialChild(
            child: Icon(Icons.house),
            onTap: () {},
          ),
        ],
      ),
      // FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'not defined',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
*/
