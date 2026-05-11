mainkanKartu(Index) :-
    integer(Index),
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

handle_wild_color_choice(card(hitam, wild)) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl.
handle_wild_color_choice(card(hitam, wild_draw_four)) :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif berubah menjadi '), write(Color), write('.'), nl.
handle_wild_color_choice(_) :-
    true.

choose_color_for_wild(Color) :-
    repeat,
    write('Pilih warna aktif baru (merah/kuning/hijau/biru): '),
    read_term(user_input, Term, []),
    term_to_name_atom(Term, Input),
    (   Input = merah -> Color = merah, !;
        Input = kuning -> Color = kuning, !; 
        Input = hijau -> Color = hijau, !; 
        Input = biru -> Color = biru, !; 
        nl,
        write('Warna tidak valid.'), nl,
        fail
    ).