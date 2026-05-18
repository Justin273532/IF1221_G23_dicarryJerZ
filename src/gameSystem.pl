appendd([], L, L).
appendd([H|T], L, [H|R]) :-
    appendd(T, L, R).

reversee(List, Reversed) :-
    reversee_acc(List, [], Reversed).
reversee_acc([], Acc, Acc).
reversee_acc([H|T], Acc, Reversed) :-
    reversee_acc(T, [H|Acc], Reversed).

numeric_value(0).
numeric_value(1).
numeric_value(2).
numeric_value(3).
numeric_value(4).
numeric_value(5).
numeric_value(6).
numeric_value(7).
numeric_value(8).
numeric_value(9).

valid_player_count(2).
valid_player_count(3).
valid_player_count(4).

non_empty_list([_|_]).

normal_color(merah).
normal_color(kuning).
normal_color(hijau).
normal_color(biru).

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
    assertz(direction(right)),
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
    retractall(direction(_)).

get_current_player(Player) :-
    current_player(Player), !.

get_current_hand(Player, Hand) :-
    player_hand(Player, Hand), !.

set_current_hand(Player, Hand) :-
    retractall(player_hand(Player, _)),
    assertz(player_hand(Player, Hand)).

get_top_card(Card) :-
    discard_top(Card), !.

set_top_card(Card) :-
    retractall(discard_top(_)),
    assertz(discard_top(Card)).

get_active_color(Color) :-
    active_color(Color), !.

set_active_color(Color) :-
    retractall(active_color(_)),
    assertz(active_color(Color)).

advance_turn :-
    turn_order([Current, Next|Rest]),
    retractall(turn_order(_)),
    appendd([Next|Rest], [Current], NewOrder),
    assertz(turn_order(NewOrder)),
    retractall(current_player(_)),
    assertz(current_player(Next)),
    nl,
    write('Giliran '), write(Next), write('.'), nl.

player_index(Player, Index) :-
    player_names(Names),
    player_index_in_list(Player, Names, 1, Index).

player_index_in_list(Player, [Player|_], Index, Index) :- !.
player_index_in_list(Player, [_|Rest], Cur, Index) :-
    Next is Cur + 1,
    player_index_in_list(Player, Rest, Next, Index).

count_cards(Player, Count) :-
    player_hand(Player, Hand),
    list_length(Hand, Count).

list_length([], 0).
list_length([_|Rest], Count) :-
    list_length(Rest, Count0),
    Count is Count0 + 1.

name_exists(Name, [Name|_]) :- !.
name_exists(Name, [_|Rest]) :-
    name_exists(Name, Rest).

build_deck(Deck) :-
    colors(Colors),
    numbers(Nums),
    build_kartu_angka(Colors, Nums, NumberCards),
    build_kartu_aksi(Colors, [skip, reverse, draw_two], ActionCards),
    build_kartu_repeat(4, kartu(hitam, wild), WildCards),
    build_kartu_repeat(4, kartu(hitam, wild_draw_four), WildDrawFourCards),
    appendd(NumberCards, ActionCards, Temp1),
    appendd(Temp1, WildCards, Temp2),
    appendd(Temp2, WildDrawFourCards, Deck).

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

build_kartu_repeat(0, _, []).
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
    collect_kartu_numerik(Rest, Cards).
collect_kartu_numerik([_|Rest], Cards) :-
    collect_kartu_numerik(Rest, Cards).

random_choice([X], X) :- !.
random_choice(List, Choice) :-
    list_length(List, Len),
    Hi is Len + 1,
    random(1, Hi, Index),
    nth_element(Index, List, Choice).

nth_element(1, [X|_], X) :- !.
nth_element(N, [_|Rest], X) :-
    N > 1,
    N1 is N - 1,
    nth_element(N1, Rest, X).

remove_first(X, [X|Rest], Rest) :- !.
remove_first(X, [Y|Rest], [Y|Rest2]) :-
    remove_first(X, Rest, Rest2).

shuffle_list(List, Shuffled) :-
    shuffle_list_acc(List, [], Shuffled).

shuffle_list_acc([], Acc, Acc).
shuffle_list_acc([X], Acc, [X|Acc]) :- !.
shuffle_list_acc(List, Acc, Shuffled) :-
    list_length(List, Len),
    Hi is Len + 1,
    random(1, Hi, Index),
    remove_nth(Index, List, Elem, Rest),
    shuffle_list_acc(Rest, [Elem|Acc], Shuffled).

remove_nth(1, [X|Xs], X, Xs) :- !.
remove_nth(N, [X|Xs], Elem, [X|Rest]) :-
    N > 1,
    N1 is N - 1,
    remove_nth(N1, Xs, Elem, Rest).

playable_card(Card) :-
    get_top_card(TopCard),
    get_active_color(ActiveColor),
    playable_against_top(Card, TopCard, ActiveColor).

playable_against_top(kartu(hitam, wild), _, _).
playable_against_top(kartu(hitam, wild_draw_four), _, _).

playable_against_top(kartu(Color, _), kartu(hitam, wild), ActiveColor) :-
    Color = ActiveColor.
playable_against_top(kartu(Color, _), kartu(hitam, wild_draw_four), ActiveColor) :-
    Color = ActiveColor.

playable_against_top(kartu(Color, skip), kartu(_, skip), _) :-
    normal_color(Color).
playable_against_top(kartu(Color, reverse), kartu(_, reverse), _) :-
    normal_color(Color).
playable_against_top(kartu(Color, draw_two), kartu(_, draw_two), _) :-
    normal_color(Color).

playable_against_top(kartu(Color, _), kartu(TopColor, _), _) :-
    Color = TopColor,
    normal_color(Color).

playable_against_top(kartu(_, Num), kartu(_, TopNum), _) :-
    numeric_value(Num),
    numeric_value(TopNum),
    Num = TopNum.

replace_hand_after_play(Player, Index, PlayedCard, NewHand) :-
    get_current_hand(Player, OldHand),
    remove_nth(Index, OldHand, PlayedCard, NewHand).

add_card_to_hand(Player, Card) :-
    get_current_hand(Player, OldHand),
    appendd(OldHand, [Card], NewHand),
    set_current_hand(Player, NewHand).

draw_from_pile(Card) :-
    retract(draw_pile([Card|Rest])),
    assertz(draw_pile(Rest)).

draw_n_cards(0, Acc, Acc) :- !.
draw_n_cards(N, Acc0, Acc) :-
    N > 0,
    draw_from_pile(Card),
    N1 is N - 1,
    draw_n_cards(N1, [Card|Acc0], Acc).

discard_color(kartu(Color, _), Color).

discard_color(kartu(hitam, wild), hitam).
discard_color(kartu(hitam, wild_draw_four), hitam).

card_points(kartu(_, Num), Num) :-
    numeric_value(Num), !.
card_points(kartu(_, skip), 10).
card_points(kartu(_, reverse), 10).
card_points(kartu(_, draw_two), 10).
card_points(kartu(_, wild), 20).
card_points(kartu(_, wild_draw_four), 20).

mainkanKartu(Index) :-
    Index > 0,
    get_current_player(Player),
    get_current_hand(Player, Hand),
    (   nth_element(Index, Hand, Card) ->
        (   playable_card(Card) ->  replace_hand_after_play(Player, Index, Card, NewHand),
            set_current_hand(Player, NewHand),
            set_top_card(Card),
            discard_color(Card, Color0),
            set_active_color(Color0),
            nl,
            write(Player), write(' memainkan kartu: '),
            print_card(Card), nl,
            handle_wild_color_choice(Card),
            advance_turn;
            nl,
            write('Kartu tersebut tidak valid untuk dimainkan saat ini.'), nl,
            fail
        );
        nl,
        write('Nomor urut kartu '), write(Index), write(' tidak valid.'), nl,
        fail
    ).

mainkanKartu(_) :-
    nl,
    write('Nomor urut kartu harus berupa bilangan bulat positif.'), nl,
    fail.

handle_wild_color_choice(kartu(hitam, wild)) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl.
handle_wild_color_choice(kartu(hitam, wild_draw_four)) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl.
handle_wild_color_choice(_) :-
    true.

ambilKartu :-
    get_current_player(Player),
    (   draw_pile([Card|_]) ->  draw_from_pile(Card),
        add_card_to_hand(Player, Card),
        nl,
        write(Player), write(' mendapatkan kartu: '),
        print_card(Card),
        nl,
        advance_turn;
        nl,
        write('Draw pile kosong. Tidak bisa mengambil kartu.'), nl,
        fail
    ).
