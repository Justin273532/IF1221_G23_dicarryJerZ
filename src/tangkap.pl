tangkap(_) :-
    get_current_player(Pemanggil),
    sudah_aksi_utama(Pemanggil), !,
    nl,
    write('Aksi utama pada giliran ini sudah dilakukan.'), nl,
    fail.
tangkap(_) :-
    get_current_player(Pemanggil),
    pending_draw_two(Pemanggil), !,
    nl,
    write('Anda sedang terkena efek draw_two. Command valid hanya ambilKartu.'), nl,
    fail.
tangkap(_) :-
    get_current_player(Pemanggil),
    pending_wild_draw_four(Pemanggil, _, _, _), !,
    nl,
    write('Anda sedang terkena efek wild_draw_four. Command valid hanya ambilKartu atau tantang.'), nl,
    fail.
tangkap(NamaPemain) :-
    get_current_player(Pemanggil),
    ada_kartu_tersembunyi(NamaPemain), !,
    nl,
    write('Terdapat kartu yang disembunyikan oleh '), write(NamaPemain), write('.'), nl,
    write('Perintah tangkap tidak valid. '), write(Pemanggil), write(' mendapatkan 1 kartu penalti.'), nl,
    ambil_banyak_kartu(Pemanggil, 1, _),
    tandai_aksi_utama(Pemanggil),
    advance_turn.
tangkap(NamaPemain) :-
    get_current_player(Pemanggil),
    pemain_bisa_ditangkap(NamaPemain), !,
    ambil_banyak_kartu(NamaPemain, 2, _),
    bersihkan_uni_pemain(NamaPemain),
    nl,
    write(NamaPemain), write(' tertangkap tidak menyerukan UNI.'), nl,
    write(NamaPemain), write(' mendapatkan 2 kartu penalti.'), nl,
    tandai_aksi_utama(Pemanggil),
    advance_turn.
tangkap(NamaPemain) :-
    get_current_player(Pemanggil),
    nl,
    write('Tangkapan terhadap '), write(NamaPemain), write(' tidak valid.'), nl,
    write(Pemanggil), write(' mendapatkan 1 kartu penalti.'), nl,
    ambil_banyak_kartu(Pemanggil, 1, _),
    tandai_aksi_utama(Pemanggil),
    advance_turn.

pemain_bisa_ditangkap(Player) :-
    pelanggar_uni(Player),
    tidak_ada_kartu_tersembunyi(Player),
    count_cards_terlihat(Player, 1), !.