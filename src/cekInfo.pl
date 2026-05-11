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