card_points(kartu(_, Num), Num) :- numeric_value(Num), !.
card_points(kartu(_, skip), 10).
card_points(kartu(_, reverse), 10).
card_points(kartu(_, draw_two), 10).
card_points(kartu(_, wild), 20).
card_points(kartu(_, wild_draw_four), 20).

kartu_cocok_umum(kartu(hitam, wild), kartu(hitam, wild), _) :- !, fail.
kartu_cocok_umum(kartu(hitam, wild), _, _).
kartu_cocok_umum(kartu(hitam, wild_draw_four), kartu(hitam, wild_draw_four), _) :- !, fail.
kartu_cocok_umum(kartu(hitam, wild_draw_four), _, _).
kartu_cocok_umum(kartu(Color, _), _, ActiveColor) :-
    normal_color(Color),
    Color = ActiveColor, !.
kartu_cocok_umum(kartu(_, Num), kartu(_, TopNum), _) :-
    numeric_value(Num),
    numeric_value(TopNum),
    Num = TopNum, !.
kartu_cocok_umum(kartu(Color, skip), kartu(_, skip), _) :- normal_color(Color), !.
kartu_cocok_umum(kartu(Color, reverse), kartu(_, reverse), _) :- normal_color(Color), !.
kartu_cocok_umum(kartu(Color, draw_two), kartu(_, draw_two), _) :- normal_color(Color).

kartu_cocok_wild_draw_four(kartu(Color, _), _, ActiveColor) :-
    normal_color(Color),
    Color = ActiveColor, !.
kartu_cocok_wild_draw_four(kartu(_, Num), kartu(_, TopNum), _) :-
    numeric_value(Num),
    numeric_value(TopNum),
    Num = TopNum.

ada_kartu_cocok_wild_draw_four([Card|_], TopCard, ActiveColor) :-
    kartu_cocok_wild_draw_four(Card, TopCard, ActiveColor), !.
ada_kartu_cocok_wild_draw_four([_|Rest], TopCard, ActiveColor) :-
    ada_kartu_cocok_wild_draw_four(Rest, TopCard, ActiveColor).

tidak_ada_kartu_cocok_wild_draw_four(Hand, TopCard, ActiveColor) :-
    ada_kartu_cocok_wild_draw_four(Hand, TopCard, ActiveColor), !, fail.
tidak_ada_kartu_cocok_wild_draw_four(_, _, _).

boleh_main_sekarang :-
    pending_draw_two(_), !, fail.
boleh_main_sekarang :-
    pending_wild_draw_four(_, _, _, _), !, fail.
boleh_main_sekarang.

kartu_valid_dimainkan(Player, Index, Card, NewHand) :-
    boleh_main_sekarang,
    get_current_hand(Player, Hand),
    remove_nth(Index, Hand, Card, NewHand),
    get_top_card(TopCard),
    get_active_color(ActiveColor),
    kartu_valid_dengan_kondisi(Card, NewHand, TopCard, ActiveColor).

kartu_valid_dengan_kondisi(kartu(hitam, wild), _, kartu(hitam, wild), _) :- !, fail.
kartu_valid_dengan_kondisi(kartu(hitam, wild), _, _, _) :- !.
kartu_valid_dengan_kondisi(kartu(hitam, wild_draw_four), _, kartu(hitam, wild_draw_four), _) :- !, fail.
kartu_valid_dengan_kondisi(kartu(hitam, wild_draw_four), _, _, _) :- !.
kartu_valid_dengan_kondisi(kartu(_, draw_two), _, kartu(_, draw_two), _) :- !, fail.
kartu_valid_dengan_kondisi(Card, _, TopCard, ActiveColor) :-
    bukan_hitam(Card),
    kartu_cocok_umum(Card, TopCard, ActiveColor).

playable_card(kartu(_, draw_two)) :-
    get_top_card(kartu(_, draw_two)), !, fail.
playable_card(Card) :-
    get_top_card(TopCard),
    get_active_color(ActiveColor),
    kartu_cocok_umum(Card, TopCard, ActiveColor).

mainkan_kartu_terpilih(Player, Card, NewHand, Mode) :-
    get_top_card(TopBefore),
    get_active_color(ColorBefore),
    set_current_hand(Player, NewHand),
    set_top_card(Card),
    warna_setelah_main(Card, ColorBefore),
    nl,
    write(Player), write(' memainkan kartu: '),
    print_card(Card), write('.'), nl,
    status_uni_setelah_main(Player, NewHand, Mode),
    tandai_aksi_utama(Player),
    efek_kartu(Card, Player, NewHand, TopBefore, ColorBefore).

warna_setelah_main(kartu(hitam, wild), _) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl, !.
warna_setelah_main(kartu(hitam, wild_draw_four), _) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl, !.
warna_setelah_main(kartu(Color, _), _) :-
    set_active_color(Color).

status_uni_setelah_main(Player, Hand, uni) :-
    panjang(Hand, 1), !,
    retractall(pelanggar_uni(Player)),
    retractall(status_uni(Player)),
    assertz(status_uni(Player)),
    write(Player), write(' menyerukan UNI!'), nl.
status_uni_setelah_main(Player, Hand, biasa) :-
    panjang(Hand, 1), !,
    retractall(status_uni(Player)),
    retractall(pelanggar_uni(Player)),
    assertz(pelanggar_uni(Player)).
status_uni_setelah_main(Player, _, _) :-
    bersihkan_uni_pemain(Player).

efek_kartu(_, Player, _, _, _) :-
    count_cards(Player, 0), !,
    bersihkan_pending,
    endGame.
efek_kartu(kartu(_, skip), _, _, _, _) :-
    bersihkan_pending,
    lewati_pemain.
efek_kartu(kartu(_, reverse), _, _, _, _) :-
    bersihkan_pending,
    balik_arah_permainan,
    direction(Dir),
    write('Arah permainan berubah menjadi '), write(Dir), write('.'), nl,
    advance_turn.
efek_kartu(kartu(_, draw_two), _, _, _, _) :-
    bersihkan_pending,
    pemain_berikutnya(Target),
    assertz(pending_draw_two(Target)),
    nl,
    write(Target), write(' harus mengambil 2 kartu dan kehilangan giliran.'), nl,
    advance_turn.
efek_kartu(kartu(hitam, wild_draw_four), Player, _, TopBefore, ColorBefore) :-
    bersihkan_pending,
    pemain_berikutnya(Target),
    assertz(pending_wild_draw_four(Target, Player, TopBefore, ColorBefore)),
    nl,
    write(Target), write(' dapat memilih ambilKartu atau tantang.'), nl,
    advance_turn.
efek_kartu(_, _, _, _, _) :-
    bersihkan_pending,
    advance_turn.

