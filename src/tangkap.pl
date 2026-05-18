tangkap(NamaPemain) :-
    get_current_player(Pemanggil),
    pemain_bisa_ditangkap(NamaPemain), !,
    ambil_banyak_kartu(NamaPemain, 2, _),
    bersihkan_uni_pemain(NamaPemain),
    nl,
    write(NamaPemain), write(' tertangkap tidak menyerukan UNI.'), nl,
    write(NamaPemain), write(' mendapatkan 2 kartu penalti.'), nl,
    write('Giliran '), write(Pemanggil), write('.'), nl.
tangkap(NamaPemain) :-
    get_current_player(Pemanggil),
    nl,
    write('Tangkapan terhadap '), write(NamaPemain), write(' tidak valid.'), nl,
    write(Pemanggil), write(' mendapatkan 1 kartu penalti.'), nl,
    ambil_banyak_kartu(Pemanggil, 1, _),
    write('Giliran '), write(Pemanggil), write('.'), nl.

pemain_bisa_ditangkap(Player) :-
    pelanggar_uni(Player),
    count_cards(Player, 1), !.