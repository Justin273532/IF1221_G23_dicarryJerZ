saveGame :-
    game_started, !,
    write('Masukkan nama file penyimpanan: '),
    read_term(user_input, FileName, []),
    open(FileName, write, Stream),
    tulis_status_permainan(Stream),
    close(Stream),
    nl,
    write('Status permainan berhasil disimpan ke '), write(FileName), write('.'), nl.
saveGame :-
    nl,
    write('Tidak ada permainan yang sedang berjalan.'), nl,
    fail.

loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read_term(user_input, FileName, []),
    open(FileName, read, Stream),
    reset_game_state,
    baca_status_permainan(Stream),
    close(Stream),
    current_player(Player),
    assertz(game_started), !,
    nl,
    write('Status permainan berhasil dimuat dari '), write(FileName), write('.'), nl,
    write('Melanjutkan giliran '), write(Player), write('.'), nl.
loadGame :-
    nl,
    write('Gagal memuat permainan.'), nl,
    fail.


tulis_status_permainan(Stream) :-
    player_names(Names),
    turn_order(Order),
    current_player(Player),
    discard_top(TopCard),
    active_color(ActiveColor),
    direction(Direction),
    draw_pile(DrawPile),
    nomor_giliran(TurnNumber),
    tulis_term(Stream, daftar_pemain(Names)),
    tulis_term(Stream, urutan_pemain(Order)),
    tulis_term(Stream, giliran(Player)),
    tulis_term(Stream, discard_top(TopCard)),
    tulis_term(Stream, warna_aktif(ActiveColor)),
    tulis_term(Stream, arah_permainan(Direction)),
    tulis_term(Stream, draw_pile(DrawPile)),
    tulis_term(Stream, nomor_giliran(TurnNumber)),
    tulis_status_uni(Stream, Names),
    tulis_pelanggar_uni(Stream, Names),
    tulis_aksi_utama(Stream, Names),
    tulis_pending_draw_two(Stream, Names),
    tulis_pending_wild_draw_four(Stream),
    tulis_kartu_aksi_terakhir(Stream),
    tulis_kartu_tersembunyi(Stream, Names),
    tulis_semua_kartu_pemain(Stream, Names).

tulis_term(Stream, Term) :-
    write(Stream, Term),
    write(Stream, '.'),
    nl(Stream).

tulis_status_uni(Stream, Names) :-
    kumpulkan_status_uni(Names, List),
    tulis_term(Stream, status_uni(List)).

tulis_pelanggar_uni(Stream, Names) :-
    kumpulkan_pelanggar_uni(Names, List),
    tulis_term(Stream, pelanggar_uni(List)).

tulis_aksi_utama(Stream, Names) :-
    kumpulkan_aksi_utama(Names, List),
    tulis_term(Stream, aksi_utama_selesai(List)).

tulis_pending_draw_two(Stream, Names) :-
    kumpulkan_pending_draw_two(Names, List),
    tulis_term(Stream, pending_draw_two(List)).

tulis_pending_wild_draw_four(Stream) :-
    pending_wild_draw_four(Target, Previous, TopBefore, ColorBefore), !,
    tulis_term(Stream, pending_wild_draw_four(Target, Previous, TopBefore, ColorBefore)).
tulis_pending_wild_draw_four(Stream) :-
    tulis_term(Stream, pending_wild_draw_four_tidak_ada).

tulis_kartu_aksi_terakhir(Stream) :-
    kartu_aksi_terakhir(Card, Player, TurnNumber, Effect), !,
    tulis_term(Stream, kartu_aksi_terakhir(Card, Player, TurnNumber, Effect)).
tulis_kartu_aksi_terakhir(Stream) :-
    tulis_term(Stream, kartu_aksi_terakhir_tidak_ada).

tulis_kartu_tersembunyi(_, []).
tulis_kartu_tersembunyi(Stream, [Name|Rest]) :-
    kartu_tersembunyi(Name, Hidden), !,
    tulis_term(Stream, kartu_tersembunyi(Name, Hidden)),
    tulis_kartu_tersembunyi(Stream, Rest).
tulis_kartu_tersembunyi(Stream, [_|Rest]) :-
    tulis_kartu_tersembunyi(Stream, Rest).

tulis_semua_kartu_pemain(_, []).
tulis_semua_kartu_pemain(Stream, [Name|Rest]) :-
    player_hand(Name, Hand),
    tulis_term(Stream, kartu(Name, Hand)),
    tulis_semua_kartu_pemain(Stream, Rest).

kumpulkan_status_uni([], []).
kumpulkan_status_uni([Name|Rest], [Name|List]) :-
    status_uni(Name), !,
    kumpulkan_status_uni(Rest, List).
kumpulkan_status_uni([_|Rest], List) :-
    kumpulkan_status_uni(Rest, List).

kumpulkan_pelanggar_uni([], []).
kumpulkan_pelanggar_uni([Name|Rest], [Name|List]) :-
    pelanggar_uni(Name), !,
    kumpulkan_pelanggar_uni(Rest, List).
kumpulkan_pelanggar_uni([_|Rest], List) :-
    kumpulkan_pelanggar_uni(Rest, List).

kumpulkan_aksi_utama([], []).
kumpulkan_aksi_utama([Name|Rest], [Name|List]) :-
    aksi_utama_selesai(Name), !,
    kumpulkan_aksi_utama(Rest, List).
kumpulkan_aksi_utama([_|Rest], List) :-
    kumpulkan_aksi_utama(Rest, List).

kumpulkan_pending_draw_two([], []).
kumpulkan_pending_draw_two([Name|Rest], [Name|List]) :-
    pending_draw_two(Name), !,
    kumpulkan_pending_draw_two(Rest, List).
kumpulkan_pending_draw_two([_|Rest], List) :-
    kumpulkan_pending_draw_two(Rest, List).


baca_status_permainan(Stream) :-
    read_term(Stream, Term, []),
    proses_term_dari_file(Stream, Term).

proses_term_dari_file(_, end_of_file) :- !.
proses_term_dari_file(Stream, Term) :-
    pulihkan_term(Term),
    baca_status_permainan(Stream).

pulihkan_term(daftar_pemain(Names)) :-
    assertz(player_names(Names)), !.
pulihkan_term(urutan_pemain(Order)) :-
    assertz(turn_order(Order)), !.
pulihkan_term(giliran(Player)) :-
    assertz(current_player(Player)), !.
pulihkan_term(discard_top(Card)) :-
    assertz(discard_top(Card)), !.
pulihkan_term(warna_aktif(Color)) :-
    assertz(active_color(Color)), !.
pulihkan_term(arah_permainan(Direction)) :-
    assertz(direction(Direction)), !.
pulihkan_term(draw_pile(DrawPile)) :-
    assertz(draw_pile(DrawPile)), !.
pulihkan_term(nomor_giliran(TurnNumber)) :-
    assertz(nomor_giliran(TurnNumber)), !.
pulihkan_term(status_uni(List)) :-
    pulihkan_status_uni(List), !.
pulihkan_term(pelanggar_uni(List)) :-
    pulihkan_pelanggar_uni(List), !.
pulihkan_term(aksi_utama_selesai(List)) :-
    pulihkan_aksi_utama(List), !.
pulihkan_term(pending_draw_two(List)) :-
    pulihkan_pending_draw_two(List), !.
pulihkan_term(pending_wild_draw_four(Target, Previous, TopBefore, ColorBefore)) :-
    assertz(pending_wild_draw_four(Target, Previous, TopBefore, ColorBefore)), !.
pulihkan_term(pending_wild_draw_four_tidak_ada) :- !.
pulihkan_term(kartu_aksi_terakhir(Card, Player, TurnNumber, Effect)) :-
    assertz(kartu_aksi_terakhir(Card, Player, TurnNumber, Effect)), !.
pulihkan_term(kartu_aksi_terakhir_tidak_ada) :- !.
pulihkan_term(kartu_tersembunyi(Player, Hidden)) :-
    assertz(kartu_tersembunyi(Player, Hidden)), !.
pulihkan_term(kartu(Player, Hand)) :-
    assertz(player_hand(Player, Hand)), !.
pulihkan_term(_).

pulihkan_status_uni([]).
pulihkan_status_uni([Name|Rest]) :-
    assertz(status_uni(Name)),
    pulihkan_status_uni(Rest).

pulihkan_pelanggar_uni([]).
pulihkan_pelanggar_uni([Name|Rest]) :-
    assertz(pelanggar_uni(Name)),
    pulihkan_pelanggar_uni(Rest).

pulihkan_aksi_utama([]).
pulihkan_aksi_utama([Name|Rest]) :-
    assertz(aksi_utama_selesai(Name)),
    pulihkan_aksi_utama(Rest).

pulihkan_pending_draw_two([]).
pulihkan_pending_draw_two([Name|Rest]) :-
    assertz(pending_draw_two(Name)),
    pulihkan_pending_draw_two(Rest).