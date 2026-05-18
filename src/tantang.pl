tantang :-
    get_current_player(Challenger),
    pending_wild_draw_four(Challenger, Previous, TopBefore, ColorBefore), !,
    nl,
    write('Tantangan dilakukan!'), nl,
    write('Memeriksa kartu '), write(Previous), write('...'), nl,
    get_current_hand(Previous, PrevHand),
    (   ada_kartu_cocok_wild_draw_four(PrevHand, TopBefore, ColorBefore) ->
        ambil_banyak_kartu(Previous, 4, Cards),
        write('Tantangan berhasil. '), write(Previous), write(' mendapatkan 4 kartu acak: '),
        print_card_list(Cards), write('.'), nl
    ;   ambil_banyak_kartu(Challenger, 6, Cards),
        write('Tantangan gagal. '), write(Challenger), write(' mendapatkan 6 kartu acak: '),
        print_card_list(Cards), write('.'), nl
    ),
    bersihkan_pending,
    tandai_aksi_utama(Challenger),
    advance_turn.
tantang :-
    nl,
    write('Tidak ada kartu wild_draw_four yang dapat ditantang saat ini.'), nl,
    fail.
