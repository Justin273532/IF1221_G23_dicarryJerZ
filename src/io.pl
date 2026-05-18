ask_player_count(NumPlayers) :-
    repeat,
    write('Masukkan jumlah pemain: '),
    read_term(user_input, Term, []),
    (   valid_player_count(Term)
    ->  NumPlayers = Term,
        !
    ;   nl,
        write('Mohon masukkan angka antara 2 - 4.'), nl,
        fail
    ).

gather_nama(NumPlayers, Names) :-
    gather_nama(1, NumPlayers, [], RevNames),
    reversee(RevNames, Names).

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
    read_term(user_input, Candidate, []),
    (   Candidate = '' ->
        write('Nama tidak boleh kosong. Masukkan nama lain: '),
        baca_nama_loop(Acc, Name);
        name_exists(Candidate, Acc) -> write('Nama sudah digunakan. Masukkan nama lain: '),
        baca_nama_loop(Acc, Name);
        Name = Candidate
    ).

print_card(kartu(Color, Num)) :-
    numeric_value(Num),
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

choose_color_for_wild(Color) :-
    repeat,
    write('Pilih warna aktif baru (merah/kuning/hijau/biru): '),
    read_term(user_input, Term, []),
    (   Term = merah -> Color = merah, !;
        Term = kuning -> Color = kuning, !;
        Term = hijau -> Color = hijau, !;
        Term = biru -> Color = biru, !;
        nl,
        write('Warna tidak valid.'), nl,
        fail
    ).

lihatCommand :-
    nl,
    write('Aksi utama yang tersedia:'), nl,
    write('1. mainkanKartu(NomorUrut)'), nl,
    write('2. ambilKartu'), nl, nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

lihatKartu :-
    get_current_player(Player),
    get_current_hand(Player, Hand),
    nl,
    write('Berikut kartu yang anda miliki.'), nl,
    print_numbered_cards(Hand, 1).

print_numbered_cards([], _).
print_numbered_cards([Card|Rest], N) :-
    write(N), write('. '),
    print_card(Card), nl, nl,
    N1 is N + 1,
    print_numbered_cards(Rest, N1).

cekInfo :-
    get_top_card(TopCard),
    player_names(Names),
    nl,
    write('Kartu discard top: '),
    print_card(TopCard), nl,
    write('Urutan pemain: '),
    print_name_list(Names), nl, nl,
    print_player_info(Names, 1).

print_player_info([], _).
print_player_info([Name|Rest], N) :-
    count_cards(Name, Count),
    write('Nama pemain '), write(N), write(': '), write(Name), nl,
    write('Jumlah kartu : '), write(Count), nl, nl,
    N1 is N + 1,
    print_player_info(Rest, N1).
