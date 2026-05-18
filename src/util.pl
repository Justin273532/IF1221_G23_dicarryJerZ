appendd([], L, L).
appendd([H|T], L, [H|R]) :-
    appendd(T, L, R).

reversee(List, Reversed) :-
    reversee_acc(List, [], Reversed).
reversee_acc([], Acc, Acc).
reversee_acc([H|T], Acc, Reversed) :-
    reversee_acc(T, [H|Acc], Reversed).

panjang([], 0).
panjang([_|Rest], Count) :-
    panjang(Rest, Count0),
    Count is Count0 + 1.

list_length(List, Count) :-
    panjang(List, Count).

ambil_elemen(1, [X|_], X) :- !.
ambil_elemen(N, [_|Rest], X) :-
    N > 1,
    N1 is N - 1,
    ambil_elemen(N1, Rest, X).

nth_element(N, List, X) :-
    ambil_elemen(N, List, X).

hapus_ke(1, [X|Xs], X, Xs) :- !.
hapus_ke(N, [X|Xs], Elem, [X|Rest]) :-
    N > 1,
    N1 is N - 1,
    hapus_ke(N1, Xs, Elem, Rest).

remove_nth(N, List, Elem, Rest) :-
    hapus_ke(N, List, Elem, Rest).

hapus_pertama(X, [X|Rest], Rest) :- !.
hapus_pertama(X, [Y|Rest], [Y|Rest2]) :-
    hapus_pertama(X, Rest, Rest2).

remove_first(X, List, Rest) :-
    hapus_pertama(X, List, Rest).

anggota(X, [X|_]) :- !.
anggota(X, [_|Rest]) :-
    anggota(X, Rest).

bukan_anggota(X, List) :-
    anggota(X, List), !, fail.
bukan_anggota(_, _).

non_empty_list([_|_]).

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

normal_color(merah).
normal_color(kuning).
normal_color(hijau).
normal_color(biru).

warna_valid(merah).
warna_valid(kuning).
warna_valid(hijau).
warna_valid(biru).

kartu_aksi(skip).
kartu_aksi(reverse).
kartu_aksi(draw_two).

kartu_hitam(kartu(hitam, wild)).
kartu_hitam(kartu(hitam, wild_draw_four)).

bukan_hitam(kartu(Color, _)) :-
    normal_color(Color).

name_exists(Name, [Name|_]) :- !.
name_exists(Name, [_|Rest]) :-
    name_exists(Name, Rest).

last_element([X], X) :- !.
last_element([_|Rest], X) :-
    last_element(Rest, X).

hapus_terakhir([X], X, []) :- !.
hapus_terakhir([H|T], X, [H|R]) :-
    hapus_terakhir(T, X, R).

jumlah_poin_kartu([], 0).
jumlah_poin_kartu([Card|Rest], Total) :-
    card_points(Card, P),
    jumlah_poin_kartu(Rest, RestP),
    Total is P + RestP.