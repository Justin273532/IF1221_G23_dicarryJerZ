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