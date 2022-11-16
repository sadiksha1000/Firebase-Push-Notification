import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:push_notifier/weather_details.dart';

class MainScreen extends StatelessWidget {
  final WeatherDetails? args;
  const MainScreen({
    Key? key,
    this.args,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Latitude ${args!.latitude!}",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  " Longitude ${args!.longitude!}",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Address ${args!.address!}",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  "Country ${args!.country!}",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Max Temperature ${args!.maxTemp!}",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  "Min Temperature ${args!.minTemp!}",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
