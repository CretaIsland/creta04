    // hycop_multi_platform 에서 제외됨

// import 'package:flutter/material.dart';
// import 'package:hycop_multi_platform/hycop/webrtc/peers/peers_data.dart';
// // ignore: depend_on_referenced_packages
// import 'package:provider/provider.dart';

// import 'remote_stream.dart';

// class ListRemoteStreams extends StatelessWidget {
//   const ListRemoteStreams({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [ChangeNotifierProvider<PeersData>.value(value: peersDataHolder!)],
//       child: Consumer<PeersData>(
//         builder: (context, peersDataManager, child) {
//           return SizedBox(
//               width: 320,
//               height: 180,
//               child: peersDataManager.peers.isNotEmpty
//                   ? ListView.builder(
//                       itemCount: peersDataManager.peers.length,
//                       itemBuilder: (context, index) {
//                         String peerId = peersDataManager.peers.keys.elementAt(index);
//                         return RemoteStream(
//                             key: ValueKey(peerId),
//                             peer: peersDataManager.peers[peerId]!,
//                             screenHeight: 320,
//                             screenWidth: 180);
//                       })
//                   : const SizedBox.shrink());
//         },
//       ),
//     );
//   }
// }
