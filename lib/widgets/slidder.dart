// ignore_for_file: prefer_const_constructors
/*
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

Widget alertInfoBox(int dataMax, int dataMin, dynamic data){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: SfSliderTheme(
      data: SfSliderThemeData(
        thumbRadius: 14,
      ),
      child: SfSlider(
        max: dataMax,
        min: dataMin,
        value: data,
        interval: 1,
        stepDuration: SliderStepDuration(hours: 24),
        //dateFormat: DateFormat.y(),
        dateIntervalType: DateIntervalType.days,
        enableTooltip: true,
        showDividers : true,

        /*
        thumbIcon: Container(
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white
            ),
            textAlign: TextAlign.center,
          )
        ),
        */

        /*
        tooltipTextFormatterCallback: (dynamic actualLabel, String formattedText) {
          return DateFormat.Md().format(actualLabel);
        },
        */
  
        onChanged: (dynamic values) {
          setState(() {
            data = values;
            print('$data');
          });
        },
        
      )
    ),
  );
}
*/