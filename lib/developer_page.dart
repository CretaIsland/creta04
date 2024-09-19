import 'package:creta04/data_io/enterprise_manager.dart';
import 'package:creta_studio_model/model/book_model.dart';
import 'package:creta_studio_model/model/page_model.dart';
import 'package:creta_studio_model/model/frame_model.dart';
import 'package:creta_studio_model/model/contents_model.dart';
import 'package:creta_studio_model/model/link_model.dart';
import 'package:creta_studio_model/model/depot_model.dart';
import 'package:creta_user_io/data_io/team_manager.dart';
import 'package:creta_user_io/data_io/user_property_manager.dart';
import 'package:creta_user_model/model/user_property_model.dart';
import 'package:creta_user_model/model/team_model.dart';
import 'package:flutter/material.dart';
import 'package:hycop/hycop.dart';

import 'design_system/component/snippet.dart';
import 'model/channel_model.dart';
import 'model/comment_model.dart';
import 'model/connected_user_model.dart';
import 'model/enterprise_model.dart';
import 'model/favorites_model.dart';
import 'model/filter_model.dart';
import 'model/host_model.dart';
import 'model/playlist_model.dart';
import 'model/scrshot_model.dart';
import 'model/subscription_model.dart';
import 'model/template_model.dart';
import 'model/watch_history_model.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Developer mode'),
          ),
          floatingActionButton: Snippet.CretaDial(context),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Developer mode'),
              TextButton(
                child: const Text('Generate Create Table Script'),
                onPressed: () async {
                  // // book family
                  BookModel book = BookModel('');
                  _createTable(book);
                  _createTable(book, tableName: "creta_book_published");
                  _createTable(PageModel('', book));
                  _createTable(PageModel('', book), tableName: "creta_page_published");
                  _createTable(FrameModel('', book.mid));
                  _createTable(FrameModel('', book.mid), tableName: "creta_frame_published");
                  _createTable(ContentsModel('', book.mid));
                  _createTable(ContentsModel('', book.mid), tableName: "creta_contents_published");
                  _createTable(LinkModel('', book.mid));
                  _createTable(LinkModel('', book.mid), tableName: "creta_link_published");
                  _createTable(DepotModel('', ''));
                  // user family
                  _createTable(UserPropertyModel(''), tableName: "creta_user_property");
                  _createTable(TeamModel(''));
                  // comunitory faimily
                  _createTable(ChannelModel(''));
                  _createTable(CommentModel(''));
                  _createTable(ConnectedUserModel(bookMid: '', name: '', email: '', imageUrl: ''));
                  _createTable(EnterpriseModel(''));
                  _createTable(FavoritesModel(''));
                  _createTable(FilterModel(''));
                  _createTable(HostModel(''));
                  _createTable(PlaylistModel(''));
                  _createTable(ScrshotModel(''));
                  _createTable(SubscriptionModel(''));
                  _createTable(TemplateModel(''));
                  _createTable(WatchHistoryModel(''));
                },
              ),
              TextButton(
                child: const Text('Generate Creta Enterprise, Team, User'),
                onPressed: () async {
                  // // book family
                  // EnterpriseModel orphan = await EnterpriseManager().createEnterprise(
                  //   name: 'orphan',
                  //   description: 'orphan admin',
                  //   enterpriseUrl: '',
                  //   adminEmail: 'cretacreates@gmail.com',
                  //   mediaApiUrl: "https://letscreta.com:444",
                  // );
                  // EnterpriseManager().createToDB(orphan);

                  EnterpriseModel enterpriseModel = await EnterpriseManager().createEnterprise(
                    name: 'creta',
                    description: 'super admin',
                    enterpriseUrl: '',
                    mediaApiUrl: "https://letscreta.com:444",
                    adminEmail: 'cretacreates@gmail.com',
                  );
                  EnterpriseManager().createToDB(enterpriseModel);

                  TeamModel cretaTeam = TeamModel(enterpriseModel.mid);
                  cretaTeam.name = 'notloginuserid Team';
                  cretaTeam.enterprise = 'creta';
                  cretaTeam.owner = 'notloginuserid@sqisoft.com';
                  cretaTeam.teamMembers = ['notloginuserid@sqisoft.com'];
                  TeamManager().createTeam(cretaTeam);

                  UserPropertyModel cretaUser = UserPropertyModel(cretaTeam.mid);
                  cretaUser.nickname = 'notloginuser';
                  cretaUser.enterprise = 'creta';
                  cretaUser.email = 'notloginuserid@sqisoft.com';
                  cretaUser.teams = [cretaTeam.mid];
                  UserPropertyManager().createUserProperty(
                    createModel: cretaUser,
                    verified: true,
                    agreeUsingMarketing: true,
                  );
                },
              ),

              // hycop_delta table 도 생성해야함.
              // creta_host 는 리얼타임으로 잡아주어야 함.

              const Text("creta_user_property table 의 notloginuserid@sqisoft.com 데이터의"),
              const Text("parentMid 에, "),
              const Text("hycop_users table 의 notloginuserid@sqisoft.com 데이터의"),
              const Text("userId 값을 넣으시오"),
              const Text("creta_user_property table 의 cretacreates@gmail.com 데이터의"),
              const Text("parentMid 에, "),
              const Text("hycop_users table 의 cretacreates@gmail.com 데이터의"),
              const Text("userId 값을 넣으시오"),

              TextButton(
                  child: const Text('remove delta'),
                  onPressed: () async {
                    _removeDelta();
                  }),
            ],
          ))),
    );
  }
}

Future<void> _createTable(AbsExModel model, {String? tableName}) async {
  String script = model.generateCreateTableScript(tableName);
  //saveLogToFile(script, "book_create_table.sql");
  //print('Generate Collection Json : $script');
  String result = '0';
  try {
    result =
        await HycopFactory.function!.execute2(functionId: "executeSQL", params: {"sql": script});
  } catch (e) {
    logger.severe('executeSQL test failed $e');
  }
  logger.info(result);
}

Future<void> _removeDelta() async {
  String result = '0';
  try {
    result = await HycopFactory.function!.execute2(functionId: "removeDelta");
  } catch (e) {
    logger.severe('removeDelta test failed $e');
  }
  logger.info(result);
}
