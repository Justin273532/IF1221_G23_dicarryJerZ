:- dynamic(game_started/0,
           player_names/1,
           turn_order/1,
           current_player/1,
           player_hand/2,
           draw_pile/1,
           discard_top/1,
           active_color/1,
           direction/1,
           status_uni/1,
           pelanggar_uni/1,
           pending_draw_two/1,
           pending_wild_draw_four/4,
           aksi_utama_selesai/1,
           kartu_tersembunyi/2,
           kartu_aksi_terakhir/4,
           nomor_giliran/1).

:- include('util.pl').
:- include('io.pl').
:- include('bonus.pl').
:- include('actionCard.pl').
:- include('tantang.pl').
:- include('tangkap.pl').
:- include('gameSystem.pl').
