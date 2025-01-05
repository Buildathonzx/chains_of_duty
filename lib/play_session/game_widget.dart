// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart' as flame;
import 'package:chains_of_duty_lib/gameplay/shooter_game.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../level_selection/levels.dart';

/// This widget defines the game UI itself, without things like the settings
/// button or the back button.
class MyGameWidget extends StatelessWidget {
  final flame.Game game;
  final Map<String, Widget Function(BuildContext, flame.Game)> overlayBuilderMap;

  const MyGameWidget({
    required this.game,
    required this.overlayBuilderMap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flame.GameWidget(
      game: game,
      overlayBuilderMap: overlayBuilderMap,
      // Remove fullscreen: true since Flame 1.x GameWidget doesn't support it
    );
  }
}
