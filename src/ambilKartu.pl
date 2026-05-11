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