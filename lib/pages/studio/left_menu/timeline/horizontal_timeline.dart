import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

import 'package:creta_common/model/app_enums.dart';

class HorizontalTimeline extends StatefulWidget {
  final FrameType type;
  const HorizontalTimeline({super.key, required this.type});

  @override
  State<HorizontalTimeline> createState() => _HorizontalTimelineState();
}

class _HorizontalTimelineState extends State<HorizontalTimeline> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            Text(
              widget.type == FrameType.monthHorizTimeline
                  ? 'Months Timeline'
                  : widget.type == FrameType.appHorizTimeline
                      ? 'App timeline'
                      : 'Delivery timeline',
              style: GoogleFonts.sniglet(
                fontSize: 26,
                color: Colors.black,
              ),
            ),
            if (widget.type == FrameType.monthHorizTimeline)
              const Expanded(child: _TimelineMonths()),
            if (widget.type == FrameType.appHorizTimeline) const Expanded(child: _AppTimeline()),
            if (widget.type == FrameType.deliveryHorizTimeline)
              const Expanded(child: _DeliveryTimeline()),
          ],
        ),
      ),
    );
  }
}

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class _TimelineMonths extends StatefulWidget {
  const _TimelineMonths();

  @override
  _TimelineMonthsState createState() => _TimelineMonthsState();
}

class _TimelineMonthsState extends State<_TimelineMonths> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int currentMonth = DateTime.now().month;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo((currentMonth - 1) * 100.0);
    });

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxHeight: 80),
      decoration: BoxDecoration(
        color: const Color(0xFF35577D).withOpacity(0.5),
        border: Border.all(width: 1, color: const Color(0xFF35577D)),
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (BuildContext context, int index) {
          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.center,
            isFirst: index == 0,
            isLast: index == months.length - 1,
            beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.8)),
            indicatorStyle: IndicatorStyle(
              color: index == currentMonth - 1 ? Colors.purpleAccent : Colors.white,
              indicator: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: index == currentMonth - 1 ? const Color(0xFF35577D) : Colors.white,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  shape: BoxShape.circle,
                  color: index == currentMonth - 1 ? const Color(0xFF35577D) : Colors.white,
                ),
              ),
            ),
            endChild: Container(
              constraints: const BoxConstraints(minWidth: 10),
              child: Center(
                child: Text(
                  months[index],
                  style: GoogleFonts.sniglet(
                    fontSize: 18,
                    color: index == currentMonth - 1 ? const Color(0xFF35577D) : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class _MessageTimeline extends StatelessWidget {
//   const _MessageTimeline({Key? key, required this.message}) : super(key: key);

//   final String message;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Flexible(
//             child: Text(
//               message,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.sniglet(
//                 fontSize: 16,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

const deliverySteps = [
  'Take your phone',
  'Choose a restaurant',
  'Order the food',
  'Wait for timeline_samples',
  'Pay',
  'Eat and enjoy',
];

class _DeliveryTimeline extends StatefulWidget {
  const _DeliveryTimeline();

  @override
  _DeliveryTimelineState createState() => _DeliveryTimelineState();
}

class _DeliveryTimelineState extends State<_DeliveryTimeline> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const currentStep = 3;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(currentStep * 120.0);
    });
    LineStyle? afterLineStyle;

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxHeight: 210),
      color: const Color(0xFF5D6173),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        itemCount: deliverySteps.length,
        itemBuilder: (BuildContext context, int index) {
          final step = deliverySteps[index];
          var indicatorSize = 30.0;
          var beforeLineStyle = LineStyle(
            color: Colors.white.withOpacity(0.8),
          );

          _DeliveryStatus status;
          if (index < currentStep) {
            status = _DeliveryStatus.done;
          } else if (index > currentStep) {
            status = _DeliveryStatus.todo;
            indicatorSize = 20;
            beforeLineStyle = const LineStyle(color: Color(0xFF747888));
          } else {
            afterLineStyle = const LineStyle(color: Color(0xFF747888));
            status = _DeliveryStatus.doing;
          }

          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.6,
            isFirst: index == 0,
            isLast: index == deliverySteps.length - 1,
            beforeLineStyle: beforeLineStyle,
            afterLineStyle: afterLineStyle,
            indicatorStyle: IndicatorStyle(
              width: indicatorSize,
              height: indicatorSize,
              indicator: _IndicatorDelivery(status: status),
            ),
            startChild: _StartChildDelivery(index: index),
            endChild: _EndChildDelivery(
              text: step,
              current: index == currentStep,
            ),
          );
        },
      ),
    );
  }
}

enum _DeliveryStatus { done, doing, todo }

class _StartChildDelivery extends StatelessWidget {
  const _StartChildDelivery({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/timeline_samples/horizontal/$index.png', height: 64),
    );
  }
}

class _EndChildDelivery extends StatelessWidget {
  const _EndChildDelivery({
    required this.text,
    required this.current,
  });

  final String text;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sniglet(
                    fontSize: 16,
                    color: current ? const Color(0xFF2ACA8E) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorDelivery extends StatelessWidget {
  const _IndicatorDelivery({required this.status});

  final _DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DeliveryStatus.done:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Center(
            child: Icon(Icons.check, color: Color(0xFF5D6173)),
          ),
        );
      case _DeliveryStatus.doing:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF2ACA8E),
          ),
          child: const Center(
            child: SizedBox(
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      case _DeliveryStatus.todo:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF747888),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5D6173),
              ),
            ),
          ),
        );
    }
  }
}

const appSteps = [
  'Configure',
  'Code',
  'Test',
  'Deploy',
  'Scale',
];

class _AppTimeline extends StatelessWidget {
  const _AppTimeline();

  @override
  Widget build(BuildContext context) {
    const currentStep = 1;

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: const Color(0xFF9F92E2)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: appSteps.length,
        itemBuilder: (BuildContext context, int index) {
          var beforeLineStyle = const LineStyle(
            thickness: 20,
            color: Color(0xFFD4D4D4),
          );

          LineStyle? afterLineStyle;
          if (index <= currentStep) {
            beforeLineStyle = const LineStyle(
              thickness: 20,
              color: Color(0xFF9F92E2),
            );
          }

          if (index == currentStep) {
            afterLineStyle = const LineStyle(
              thickness: 20,
              color: Color(0xFFD4D4D4),
            );
          }

          final isFirst = index == 0;
          final isLast = index == appSteps.length - 1;
          var indicatorX = 0.5;
          if (isFirst) {
            indicatorX = 0.3;
          } else if (isLast) {
            indicatorX = 0.7;
          }

          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.8,
            isFirst: isFirst,
            isLast: isLast,
            beforeLineStyle: beforeLineStyle,
            afterLineStyle: afterLineStyle,
            hasIndicator: index <= currentStep || isLast,
            indicatorStyle: IndicatorStyle(
              width: 20,
              height: 20,
              indicatorXY: indicatorX,
              color: const Color(0xFFD4D4D4),
              indicator: index <= currentStep ? const _IndicatorApp() : null,
            ),
            startChild: Container(
              constraints: const BoxConstraints(minWidth: 120),
              margin: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/timeline_samples/app/$index.png', height: 40),
                  const SizedBox(width: 8),
                  Text(
                    appSteps[index],
                    style: GoogleFonts.sniglet(
                      fontSize: 14,
                      color:
                          index <= currentStep ? const Color(0xFF9F92E2) : const Color(0xFFD4D4D4),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IndicatorApp extends StatelessWidget {
  const _IndicatorApp();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF9F92E2),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
