import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherTimeline extends StatelessWidget {
  const WeatherTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDB84B1),
            Color(0xFF3A3E88),
          ],
        ),
      ),
      child: ListView(
        children: <Widget>[
          TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.3,
            isFirst: true,
            indicatorStyle: IndicatorStyle(
              width: 70,
              height: 70,
              indicator: _Sun(),
            ),
            beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
            endChild: _ContainerHeader(),
          ),
          _buildTimelineTile(
            indicator: const _IconIndicator(
              iconData: WeatherIcons.cloudy,
              size: 20,
            ),
            hour: '18:00',
            weather: 'Cloudy',
            temperature: '26°C',
            phrase: 'A beautiful afternoon to take a walk into the park.'
                " Don't forget to take your water.",
          ),
          _buildTimelineTile(
            indicator: const _IconIndicator(
              iconData: WeatherIcons.sunset,
              size: 20,
            ),
            hour: '20:00',
            weather: 'Sunset',
            temperature: '24°C',
            phrase: 'Enjoy the view, the sun will be back tomorrow.',
          ),
          _buildTimelineTile(
            indicator: const _IconIndicator(
              iconData: WeatherIcons.night_alt_rain_mix,
              size: 20,
            ),
            hour: '22:00',
            weather: 'Fall of rain',
            temperature: '18°C',
            phrase: 'Temperature is decreasing...',
          ),
          _buildTimelineTile(
            indicator: const _IconIndicator(
              iconData: WeatherIcons.snowflake_cold,
              size: 20,
            ),
            hour: '00:00',
            weather: 'Chilly',
            temperature: '16°C',
            phrase: "Have a good night, don't forget your blanket.",
            isLast: true,
          ),
        ],
      ),
    );
  }

  TimelineTile _buildTimelineTile({
    _IconIndicator? indicator,
    required String hour,
    required String weather,
    required String temperature,
    required String phrase,
    bool isLast = false,
  }) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.3,
      beforeLineStyle: LineStyle(color: Colors.white.withOpacity(0.7)),
      indicatorStyle: IndicatorStyle(
        indicatorXY: 0.3,
        drawGap: true,
        width: 30,
        height: 30,
        indicator: indicator,
      ),
      isLast: isLast,
      startChild: Center(
        child: Container(
          alignment: const Alignment(0.0, -0.50),
          child: Text(
            hour,
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              weather,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              temperature,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              phrase,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _IconIndicator extends StatelessWidget {
  const _IconIndicator({
    required this.iconData,
    required this.size,
  });

  final IconData iconData;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 30,
              width: 30,
              child: Icon(
                iconData,
                size: size,
                color: const Color(0xFF9E3773).withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContainerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Seoul',
              style: GoogleFonts.lato(
                fontSize: 24,
                color: const Color.fromARGB(255, 202, 32, 117),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'now - 17:30',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: const Color(0xFFF4A5CD),
              ),
            ),
            Text(
              'Sunny',
              style: GoogleFonts.lato(
                fontSize: 30,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Humidity 47%',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: const Color(0xFF4A448F).withOpacity(0.8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  '28°C',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: const Color(0xFF4A448F).withOpacity(0.8),
                    fontWeight: FontWeight.w800,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Sun extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 25,
            spreadRadius: 20,
          ),
        ],
        shape: BoxShape.circle,
        color: Colors.white,
      ),
    );
  }
}
