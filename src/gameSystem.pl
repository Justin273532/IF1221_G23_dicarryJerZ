startGame :-
    reset_game_state,
    randomize,
    ask_player_count(NumPlayers),
    gather_nama(NumPlayers, Names),
    shuffle_list(Names, ShuffledNames),
    build_deck(Deck0),
    shuffle_list(Deck0, ShuffledDeck),
    deal_init_hands(ShuffledNames, ShuffledDeck, DeckAfterDeal, PlayerHands),
    choose_init_discard(DeckAfterDeal, DiscardCard, RemainingDeck),
    assertz(game_started),
    assertz(player_names(ShuffledNames)),
    assertz(turn_order(ShuffledNames)),
    ShuffledNames = [FirstPlayer|_],
    assertz(current_player(FirstPlayer)),
    assertz(draw_pile(RemainingDeck)),
    assertz(discard_top(DiscardCard)),
    discard_color(DiscardCard, TopColor),
    assertz(active_color(TopColor)),
    assertz(direction(kanan)),
    assertz(nomor_giliran(1)),
    store_player_hands(PlayerHands),
    nl,
    write('Urutan pemain: '), print_name_list(ShuffledNames), nl,
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
    write('Kartu discard top: '), print_card(DiscardCard), nl,
    write('Giliran '), write(FirstPlayer), write('.'), nl.

store_player_hands([]).
store_player_hands([Name-Hand|Rest]) :-
    assertz(player_hand(Name, Hand)),
    store_player_hands(Rest).

reset_game_state :-
    retractall(game_started),
    retractall(player_names(_)),
    retractall(turn_order(_)),
    retractall(current_player(_)),
    retractall(player_hand(_, _)),
    retractall(draw_pile(_)),
    retractall(discard_top(_)),
    retractall(active_color(_)),
    retractall(direction(_)),
    retractall(status_uni(_)),
    retractall(pelanggar_uni(_)),
    retractall(pending_draw_two(_)),
    retractall(pending_wild_draw_four(_, _, _, _)),
    retractall(aksi_utama_selesai(_)),
    retractall(kartu_tersembunyi(_, _)),
    retractall(kartu_aksi_terakhir(_, _, _, _)),
    retractall(nomor_giliran(_)).

get_current_player(Player) :- current_player(Player), !.
get_current_hand(Player, Hand) :- player_hand(Player, Hand), !.

set_current_hand(Player, Hand) :-
    retractall(player_hand(Player, _)),
    assertz(player_hand(Player, Hand)).

get_top_card(Card) :- discard_top(Card), !.
set_top_card(Card) :-
    retractall(discard_top(_)),
    assertz(discard_top(Card)).

get_active_color(Color) :- active_color(Color), !.
set_active_color(Color) :-
    retractall(active_color(_)),
    assertz(active_color(Color)).

set_current_player(Player) :-
    retractall(current_player(_)),
    assertz(current_player(Player)).

bersihkan_pending :-
    retractall(pending_draw_two(_)),
    retractall(pending_wild_draw_four(_, _, _, _)).

bersihkan_uni_pemain(Player) :-
    retractall(status_uni(Player)),
    retractall(pelanggar_uni(Player)).

hapus_aksi_utama(Player) :-
    retractall(aksi_utama_selesai(Player)).

tandai_aksi_utama(Player) :-
    retractall(aksi_utama_selesai(Player)),
    assertz(aksi_utama_selesai(Player)).

sudah_aksi_utama(Player) :-
    aksi_utama_selesai(Player), !.

advance_turn :-
    naikkan_nomor_giliran,
    maju_satu_giliran(Next),
    hapus_aksi_utama(Next),
    nl,
    write('Giliran '), write(Next), write('.'), nl.

advance_turn_silent(Next) :-
    naikkan_nomor_giliran,
    maju_satu_giliran(Next),
    hapus_aksi_utama(Next).

naikkan_nomor_giliran :-
    retract(nomor_giliran(N)), !,
    N1 is N + 1,
    assertz(nomor_giliran(N1)).
naikkan_nomor_giliran :-
    assertz(nomor_giliran(1)).

maju_satu_giliran(Next) :-
    turn_order([Current, Next|Rest]),
    retractall(turn_order(_)),
    appendd([Next|Rest], [Current], NewOrder),
    assertz(turn_order(NewOrder)),
    set_current_player(Next),
    !.
maju_satu_giliran(Current) :-
    turn_order([Current]),
    set_current_player(Current).

pemain_berikutnya(Next) :-
    turn_order([_, Next|_]), !.
pemain_berikutnya(Player) :-
    current_player(Player).

balik_arah_permainan :-
    direction(kanan), !,
    retractall(direction(_)),
    assertz(direction(kiri)),
    turn_order([Current|Rest]),
    reversee(Rest, RevRest),
    retractall(turn_order(_)),
    assertz(turn_order([Current|RevRest])).
balik_arah_permainan :-
    retractall(direction(_)),
    assertz(direction(kanan)),
    turn_order([Current|Rest]),
    reversee(Rest, RevRest),
    retractall(turn_order(_)),
    assertz(turn_order([Current|RevRest])).

lewati_pemain :-
    advance_turn_silent(Skipped),
    nl,
    write(Skipped), write(' kehilangan giliran.'), nl,
    advance_turn.

player_index(Player, Index) :-
    player_names(Names),
    player_index_in_list(Player, Names, 1, Index).

player_index_in_list(Player, [Player|_], Index, Index) :- !.
player_index_in_list(Player, [_|Rest], Cur, Index) :-
    Next is Cur + 1,
    player_index_in_list(Player, Rest, Next, Index).

count_cards(Player, Count) :-
    player_hand(Player, Hand),
    panjang(Hand, Count).

build_deck(Deck) :-
    colors(Colors),
    numbers(Nums),
    build_kartu_angka(Colors, Nums, NumberCards),
    build_kartu_aksi(Colors, [skip, reverse, draw_two], ActionCards),
    build_kartu_repeat(4, kartu(hitam, wild), WildCards),
    build_kartu_repeat(4, kartu(hitam, wild_draw_four), WildDrawFourCards),
    build_kartu_repeat(4, kartu(hitam, mimic), MimicCards),
    appendd(NumberCards, ActionCards, Temp1),
    appendd(Temp1, WildCards, Temp2),
    appendd(Temp2, WildDrawFourCards, Temp3),
    appendd(Temp3, MimicCards, Deck).

colors([merah, kuning, hijau, biru]).
numbers([0,1,2,3,4,5,6,7,8,9]).

build_kartu_angka([], _, []).
build_kartu_angka([Color|RestColors], Numbers, Cards) :-
    build_kartu_angka_for_color(Color, Numbers, Cards1),
    build_kartu_angka(RestColors, Numbers, Cards2),
    appendd(Cards1, Cards2, Cards).

build_kartu_angka_for_color(_, [], []).
build_kartu_angka_for_color(Color, [N|Rest], [kartu(Color, N)|Cards]) :-
    build_kartu_angka_for_color(Color, Rest, Cards).

build_kartu_aksi([], _, []).
build_kartu_aksi([Color|RestColors], Types, Cards) :-
    build_kartu_aksi_for_color(Color, Types, Cards1),
    build_kartu_aksi(RestColors, Types, Cards2),
    appendd(Cards1, Cards2, Cards).

build_kartu_aksi_for_color(_, [], []).
build_kartu_aksi_for_color(Color, [Type|Rest], [kartu(Color, Type)|Cards]) :-
    build_kartu_aksi_for_color(Color, Rest, Cards).

build_kartu_repeat(0, _, []) :- !.
build_kartu_repeat(N, Card, [Card|Rest]) :-
    N > 0,
    N1 is N - 1,
    build_kartu_repeat(N1, Card, Rest).

deal_init_hands([], Deck, Deck, []).
deal_init_hands([Player|RestPlayers], Deck0, DeckFinal, [Player-Hand|RestHands]) :-
    take_n_cards(7, Deck0, Hand, Deck1),
    deal_init_hands(RestPlayers, Deck1, DeckFinal, RestHands).

take_n_cards(0, Deck, [], Deck) :- !.
take_n_cards(N, [Card|Rest], [Card|Taken], Remaining) :-
    N > 0,
    N1 is N - 1,
    take_n_cards(N1, Rest, Taken, Remaining).

choose_init_discard(Deck0, Card, Remaining) :-
    collect_kartu_numerik(Deck0, NumericCards),
    non_empty_list(NumericCards),
    random_choice(NumericCards, Card),
    remove_first(Card, Deck0, Remaining),
    !.
choose_init_discard([Card|Remaining], Card, Remaining).

collect_kartu_numerik([], []).
collect_kartu_numerik([kartu(Color, Num)|Rest], [kartu(Color, Num)|Cards]) :-
    numeric_value(Num),
    collect_kartu_numerik(Rest, Cards), !.
collect_kartu_numerik([_|Rest], Cards) :-
    collect_kartu_numerik(Rest, Cards).

random_choice([X], X) :- !.
random_choice(List, Choice) :-
    panjang(List, Len),
    Hi is Len + 1,
    random(1, Hi, Index),
    nth_element(Index, List, Choice).

shuffle_list(List, Shuffled) :-
    shuffle_list_acc(List, [], Shuffled).

shuffle_list_acc([], Acc, Acc).
shuffle_list_acc([X], Acc, [X|Acc]) :- !.
shuffle_list_acc(List, Acc, Shuffled) :-
    panjang(List, Len),
    Hi is Len + 1,
    random(1, Hi, Index),
    remove_nth(Index, List, Elem, Rest),
    shuffle_list_acc(Rest, [Elem|Acc], Shuffled).

replace_hand_after_play(Player, Index, PlayedCard, NewHand) :-
    get_current_hand(Player, OldHand),
    remove_nth(Index, OldHand, PlayedCard, NewHand).

add_card_to_hand(Player, Card) :-
    get_current_hand(Player, OldHand),
    appendd(OldHand, [Card], NewHand),
    set_current_hand(Player, NewHand),
    count_cards(Player, Count),
    (Count = 1 -> true ; bersihkan_uni_pemain(Player)).

ambil_satu_kartu(Card) :-
    retract(draw_pile([Card|Rest])),
    assertz(draw_pile(Rest)).

draw_from_pile(Card) :-
    ambil_satu_kartu(Card).

ambil_banyak_kartu(Player, 0, []) :-
    Player = Player, !.
ambil_banyak_kartu(Player, N, [Card|Rest]) :-
    N > 0,
    ambil_satu_kartu(Card),
    add_card_to_hand(Player, Card),
    N1 is N - 1,
    ambil_banyak_kartu(Player, N1, Rest).

draw_n_cards(0, Acc, Acc) :- !.
draw_n_cards(N, Acc0, Acc) :-
    N > 0,
    draw_from_pile(Card),
    N1 is N - 1,
    draw_n_cards(N1, [Card|Acc0], Acc).

discard_color(kartu(Color, _), Color).

mainkanKartu(Index) :-
    Index > 0,
    get_current_player(Player),
    sudah_aksi_utama(Player), !,
    nl,
    write('Aksi utama pada giliran ini sudah dilakukan.'), nl,
    fail.
mainkanKartu(Index) :-
    Index > 0,
    get_current_player(Player),
    get_current_hand(Player, Hand),
    (   nth_element(Index, Hand, Card) ->
        (   kartu_valid_dimainkan(Player, Index, Card, NewHand) ->
            mainkan_kartu_terpilih(Player, Card, NewHand, biasa)
        ;   nl,
            write('Kartu tersebut tidak valid untuk dimainkan saat ini.'), nl,
            fail
        )
    ;   nl,
        write('Nomor urut kartu '), write(Index), write(' tidak valid.'), nl,
        fail
    ).
mainkanKartu(_) :-
    nl,
    write('Nomor urut kartu harus berupa bilangan bulat positif.'), nl,
    fail.

uni(Index) :-
    Index > 0,
    get_current_player(Player),
    sudah_aksi_utama(Player), !,
    nl,
    write('Aksi utama pada giliran ini sudah dilakukan.'), nl,
    fail.
uni(Index) :-
    Index > 0,
    get_current_player(Player),
    get_current_hand(Player, Hand),
    panjang(Hand, Count),
    (   Count = 2,
        nth_element(Index, Hand, Card),
        kartu_valid_dimainkan(Player, Index, Card, NewHand) ->
            mainkan_kartu_terpilih(Player, Card, NewHand, uni)
    ;   nl,
        write('Perintah UNI tidak valid.'), nl,
        write(Player), write(' mendapatkan 1 kartu penalti.'), nl,
        ambil_banyak_kartu(Player, 1, _),
        tandai_aksi_utama(Player),
        advance_turn
    ).
uni(_) :-
    nl,
    write('Nomor urut kartu harus berupa bilangan bulat positif.'), nl,
    fail.

ambilKartu :-
    get_current_player(Player),
    sudah_aksi_utama(Player), !,
    nl,
    write('Aksi utama pada giliran ini sudah dilakukan.'), nl,
    fail.
ambilKartu :-
    get_current_player(Player),
    pending_draw_two(Player), !,
    ambil_banyak_kartu(Player, 2, Cards),
    nl,
    write(Player), write(' mendapatkan kartu: '), print_card_list(Cards), write('.'), nl,
    bersihkan_pending,
    tandai_aksi_utama(Player),
    advance_turn.
ambilKartu :-
    get_current_player(Player),
    pending_wild_draw_four(Player, _, _, _), !,
    ambil_banyak_kartu(Player, 4, Cards),
    nl,
    write(Player), write(' mendapatkan kartu: '), print_card_list(Cards), write('.'), nl,
    bersihkan_pending,
    tandai_aksi_utama(Player),
    advance_turn.
ambilKartu :-
    get_current_player(Player),
    draw_pile([_|_]), !,
    ambil_banyak_kartu(Player, 1, [Card]),
    nl,
    write(Player), write(' mendapatkan kartu: '), print_card(Card), write('.'), nl,
    tandai_aksi_utama(Player),
    advance_turn.
ambilKartu :-
    nl,
    write('Draw pile kosong. Tidak bisa mengambil kartu.'), nl,
    fail.

endGame :-
    pemain_habis_kartu(Winner), !,
    nl,
    write('Permainan selesai! '), write(Winner), write(' menghabiskan semua kartunya!'), nl, nl,
    write('Berikut perhitungan poin sisa kartu.'), nl,
    player_names(Names),
    buat_daftar_nilai(Names, 1, Scores),
    print_perhitungan_poin(Scores), nl,
    urutkan_nilai(Scores, Sorted),
    write('Urutan pemenang:'), nl,
    print_ranking(Sorted, 1), nl,
    Sorted = [score(Juara, _, _, _)|_],
    write('Selamat, '), write(Juara), write(' menjadi pemenang!'), nl,
    reset_game_state.
endGame :-
    nl,
    write('Permainan belum selesai.'), nl.

pemain_habis_kartu(Player) :-
    player_hand(Player, []), !.
pemain_habis_kartu(Player) :-
    player_names(Names),
    pemain_habis_kartu_dalam_list(Names, Player).

pemain_habis_kartu_dalam_list([Name|_], Name) :-
    player_hand(Name, []), !.
pemain_habis_kartu_dalam_list([_|Rest], Player) :-
    pemain_habis_kartu_dalam_list(Rest, Player).

buat_daftar_nilai([], _, []).
buat_daftar_nilai([Name|Rest], Urutan, [score(Name, Points, JumlahKartu, Urutan)|Scores]) :-
    player_hand(Name, Hand),
    jumlah_poin_kartu(Hand, Points),
    panjang(Hand, JumlahKartu),
    Next is Urutan + 1,
    buat_daftar_nilai(Rest, Next, Scores).

print_perhitungan_poin([]).
print_perhitungan_poin([score(Name, Points, _, _)|Rest]) :-
    player_hand(Name, Hand),
    write(Name), write(': '),
    print_rincian_kartu(Hand, Points), nl,
    print_perhitungan_poin(Rest).

print_rincian_kartu([], _) :-
    write('kartu habis = 0 poin'), !.
print_rincian_kartu(Hand, Points) :-
    print_card_list(Hand),
    write(' = '), write(Points), write(' poin').

lebih_baik(score(_, P1, _, _), score(_, P2, _, _)) :-
    P1 < P2, !.
lebih_baik(score(_, P, C1, _), score(_, P, C2, _)) :-
    C1 < C2, !.
lebih_baik(score(_, P, C, O1), score(_, P, C, O2)) :-
    O1 < O2.

urutkan_nilai([], []).
urutkan_nilai([X|Xs], Sorted) :-
    urutkan_nilai(Xs, SortedXs),
    sisip_nilai(X, SortedXs, Sorted).

sisip_nilai(X, [], [X]).
sisip_nilai(X, [Y|Ys], [X,Y|Ys]) :-
    lebih_baik(X, Y), !.
sisip_nilai(X, [Y|Ys], [Y|Rest]) :-
    sisip_nilai(X, Ys, Rest).

print_ranking([], _).
print_ranking([score(Name, Points, _, _)|Rest], N) :-
    write(N), write('. '), write(Name), write(' ('), write(Points), write(' poin)'), nl,
    N1 is N + 1,
    print_ranking(Rest, N1).