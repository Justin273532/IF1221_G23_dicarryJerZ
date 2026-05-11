:- dynamic(game_started/0,
           player_names/1,
           turn_order/1,
           current_player/1,
           player_hand/2,
           draw_pile/1,
           discard_top/1,
           active_color/1,
           direction/1).

:- include('mainkanKartu.pl').
:- include('ambilKartu.pl').
:- include('lihatCommand.pl').
:- include('lihatKartu.pl').
:- include('cekInfo.pl').

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
    append([Next|Rest], [Current], NewOrder),
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


ask_player_count(NumPlayers) :-
    repeat,
    write('Masukkan jumlah pemain: '),
    read_term(user_input, Term, []),
    (   integer(Term), Term >= 2, Term =< 4
    ->  NumPlayers = Term,
        !
    ;   nl,
        write('Mohon masukkan angka antara 2 - 4.'), nl,
        fail
    ).

gather_nama(NumPlayers, Names) :-
    gather_nama(1, NumPlayers, [], RevNames),
    reverse(RevNames, Names).

gather_nama(I, NumPlayers, Acc, Names) :-
    I =< NumPlayers,
    !,
    baca_nama(I, Acc, Name),
    I2 is I + 1,
    gather_nama(I2, NumPlayers, [Name|Acc], Names).
gather_nama(_, _, Acc, Acc).

baca_nama(I, Acc, Name) :-
    write('Masukkan nama pemain '), write(I), write(': '),
    baca_nama_loop(Acc, Name).

baca_nama_loop(Acc, Name) :-
    read_term(user_input, Term, []),
    term_to_atom(Term, Candidate),
    (   Candidate == '' ->
        write('Nama tidak boleh kosong. Masukkan nama lain: '),
        baca_nama_loop(Acc, Name);
        name_exists(Candidate, Acc) -> write('Nama sudah digunakan. Masukkan nama lain: '),
        baca_nama_loop(Acc, Name);
        Name = Candidate
    ).

term_to_atom(Term, Atom) :-
    (   atom(Term) -> Atom = Term;
        number(Term) -> number_codes(Term, Codes),
        atom_codes(Atom, Codes);
        codes_list(Term) -> atom_codes(Atom, Term);
        fail
    ).

codes_list([]).
codes_list([H|T]) :-
    integer(H),
    codes_list(T).

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
    append(NumberCards, ActionCards, Temp1),
    append(Temp1, WildCards, Temp2),
    append(Temp2, WildDrawFourCards, Deck).

colors([merah, kuning, hijau, biru]).
numbers([0,1,2,3,4,5,6,7,8,9]).

build_kartu_angka([], _, []).
build_kartu_angka([Color|RestColors], Numbers, Cards) :-
    build_kartu_angka_for_color(Color, Numbers, Cards1),
    build_kartu_angka(RestColors, Numbers, Cards2),
    append(Cards1, Cards2, Cards).

build_kartu_angka_for_color(_, [], []).
build_kartu_angka_for_color(Color, [N|Rest], [kartu(Color, N)|Cards]) :-
    build_kartu_angka_for_color(Color, Rest, Cards).

build_kartu_aksi([], _, []).
build_kartu_aksi([Color|RestColors], Types, Cards) :-
    build_kartu_aksi_for_color(Color, Types, Cards1),
    build_kartu_aksi(RestColors, Types, Cards2),
    append(Cards1, Cards2, Cards).

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
    NumericCards \= [],
    random_choice(NumericCards, Card),
    remove_first(Card, Deck0, Remaining),
    !.
choose_init_discard([Card|Remaining], Card, Remaining).

collect_kartu_numerik([], []).
collect_kartu_numerik([kartu(Color, Num)|Rest], [kartu(Color, Num)|Cards]) :-
    integer(Num),
    Num >= 0,
    Num =< 9,
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


print_card(kartu(Color, Num)) :-
    integer(Num),
    !,
    write(Color), write('-'), write(Num).
print_card(kartu(Color, Type)) :- write(Color), write('-'), write(Type).

print_card_list([]).
print_card_list([Card]) :- print_card(Card).
print_card_list([Card|Rest]) :-
    print_card(Card),
    write(' + '),
    print_card_list(Rest).

print_name_list([]).
print_name_list([Name]) :- write(Name).
print_name_list([Name|Rest]) :-
    write(Name),
    write(' - '),
    print_name_list(Rest).


playable_card(Card) :-
    get_top_card(TopCard),
    get_active_color(ActiveColor),
    playable_against_top(Card, TopCard, ActiveColor).

playable_against_top(kartu(hitam, wild), _, _).
playable_against_top(kartu(hitam, wild_draw_four), _, _).

playable_against_top(kartu(Color, _), kartu(hitam, wild), ActiveColor) :-
    Color == ActiveColor.
playable_against_top(kartu(Color, _), kartu(hitam, wild_draw_four), ActiveColor) :-
    Color == ActiveColor.

playable_against_top(kartu(Color, skip), kartu(_, skip), _) :-
    Color \== hitam.
playable_against_top(kartu(Color, reverse), kartu(_, reverse), _) :-
    Color \== hitam.
playable_against_top(kartu(Color, draw_two), kartu(_, draw_two), _) :-
    Color \== hitam.

playable_against_top(kartu(Color, _), kartu(TopColor, _), _) :-
    Color == TopColor,
    Color \== hitam.

playable_against_top(kartu(_, Num), kartu(_, TopNum), _) :-
    integer(Num),
    integer(TopNum),
    Num =:= TopNum.


replace_hand_after_play(Player, Index, PlayedCard, NewHand) :-
    get_current_hand(Player, OldHand),
    remove_nth(Index, OldHand, PlayedCard, NewHand).

add_card_to_hand(Player, Card) :-
    get_current_hand(Player, OldHand),
    append(OldHand, [Card], NewHand),
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
    integer(Num),
    Num >= 0,
    Num =< 9, !.
card_points(kartu(_, skip), 10).
card_points(kartu(_, reverse), 10).
card_points(kartu(_, draw_two), 10).
card_points(kartu(_, wild), 20).
card_points(kartu(_, wild_draw_four), 20).
