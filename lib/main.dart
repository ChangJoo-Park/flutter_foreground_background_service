// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate';
import 'dart:io' show Platform; //at the top

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:foreground_service/foreground_service.dart';

import 'package:flutter/widgets.dart';

void printMessage(String msg) => print('[${DateTime.now()}] $msg');

void printPeriodic() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function=$printPeriodic");
}

void printOneShot() => printMessage("One shot!");

Future<void> main() async {
  final int periodicID = 0;
  final int oneShotID = 1;

  // Start the AlarmManager service.
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  printMessage("main run");
  runApp(const Center(
      child:
          Text('See device log for output', textDirection: TextDirection.ltr)));
  if (Platform.isAndroid) {
    await AndroidAlarmManager.periodic(
        const Duration(seconds: 5), periodicID, printPeriodic,
        wakeup: true);
    await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5), oneShotID, printOneShot);
    startFGS();
  }
}

//use an async method so we can await
void startFGS() async {
  await ForegroundService.setServiceIntervalSeconds(5);

  //necessity of editMode is dubious (see function comments)
  await ForegroundService.notification.startEditMode();

  await ForegroundService.notification
      .setTitle("Example Title: ${DateTime.now()}");
  await ForegroundService.notification
      .setText("Example Text: ${DateTime.now()}");

  await ForegroundService.notification.finishEditMode();

  await ForegroundService.startForegroundService(foregroundServiceFunction);
  await ForegroundService.getWakeLock();
}

void foregroundServiceFunction() {
  debugPrint("The current time is: ${DateTime.now()}");
}
