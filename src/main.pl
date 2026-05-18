:- dynamic(game_started/0,
           player_names/1,
           turn_order/1,
           current_player/1,
           player_hand/2,
           draw_pile/1,
           discard_top/1,
           active_color/1,
           direction/1).

:- include('io.pl').
:- include('gameSystem.pl').
