godsHand :-
    get_current_player(Player),
    sudah_aksi_utama(Player), !,
    nl,
    write('Aksi utama pada giliran ini sudah dilakukan.'), nl,
    fail.
godsHand :-
    get_current_player(Player),
    pending_draw_two(Player), !,
    nl,
    write('Anda sedang terkena efek draw_two. Command valid hanya ambilKartu.'), nl,
    fail.
godsHand :-
    get_current_player(Player),
    pending_wild_draw_four(Player, _, _, _), !,
    nl,
    write('Anda sedang terkena efek wild_draw_four. Command valid hanya ambilKartu atau tantang.'), nl,
    fail.
godsHand :-
    pemain_dengan_kartu_lebih_satu(Eligible),
    tidak_kosong(Eligible), !,
    random(1, 101, Peluang),
    (   Peluang =< 20 ->
        jalankan_gods_hand(Eligible)
    ;   get_current_player(Player),
        nl,
        write('Tuhan belum berkehendak.'), nl,
        tandai_aksi_utama(Player),
        advance_turn
    ).
godsHand :-
    nl,
    write('God''s Hand tidak dijalankan karena seluruh pemain hanya memiliki satu kartu.'), nl.

pemain_dengan_kartu_lebih_satu(Eligible) :-
    player_names(Names),
    pemain_dengan_kartu_lebih_satu(Names, Eligible).

pemain_dengan_kartu_lebih_satu([], []).
pemain_dengan_kartu_lebih_satu([Name|Rest], [Name|EligibleRest]) :-
    count_cards(Name, Count),
    Count > 1, !,
    pemain_dengan_kartu_lebih_satu(Rest, EligibleRest).
pemain_dengan_kartu_lebih_satu([_|Rest], EligibleRest) :-
    pemain_dengan_kartu_lebih_satu(Rest, EligibleRest).

tidak_kosong([_|_]).

jalankan_gods_hand(Eligible) :-
    random_choice(Eligible, Pemilik),
    get_current_hand(Pemilik, Hand),
    panjang(Hand, JumlahKartu),
    BatasAtas is JumlahKartu + 1,
    random(1, BatasAtas, Index),
    remove_nth(Index, Hand, Card, HandBaruPemilik),
    player_names(Names),
    daftar_pemain_lain(Names, Pemilik, PenerimaList),
    random_choice(PenerimaList, Penerima),
    set_current_hand(Pemilik, HandBaruPemilik),
    hapus_kartu_tersembunyi(Pemilik, Card),
    add_card_to_hand(Penerima, Card),
    bersihkan_uni_pemain(Pemilik),
    bersihkan_uni_pemain(Penerima),
    get_current_player(Player),
    tandai_aksi_utama(Player),
    nl,
    write('Tuhan telah berkehendak.'), nl,
    write('Kartu '), print_card(Card),
    write(' milik '), write(Pemilik),
    write(' berpindah ke tangan '), write(Penerima), write('!'), nl,
    putar_giliran_ke_pemain(Penerima),
    nl,
    write('Giliran '), write(Penerima), write('.'), nl.

daftar_pemain_lain([], _, []).
daftar_pemain_lain([Player|Rest], Player, Result) :- !,
    daftar_pemain_lain(Rest, Player, Result).
daftar_pemain_lain([Name|Rest], Player, [Name|Result]) :-
    daftar_pemain_lain(Rest, Player, Result).

putar_giliran_ke_pemain(Player) :-
    turn_order(Order),
    putar_list_ke_pemain(Player, Order, NewOrder),
    retractall(turn_order(_)),
    assertz(turn_order(NewOrder)),
    set_current_player(Player),
    hapus_aksi_utama(Player),
    naikkan_nomor_giliran.

putar_list_ke_pemain(Player, [Player|Rest], [Player|Rest]) :- !.
putar_list_ke_pemain(Player, [First|Rest], Result) :-
    appendd(Rest, [First], Rotated),
    putar_list_ke_pemain(Player, Rotated, Result).

simpan_aksi_terakhir(Card, Player, Efek) :-
    nomor_giliran(N), !,
    retractall(kartu_aksi_terakhir(_, _, _, _)),
    assertz(kartu_aksi_terakhir(Card, Player, N, Efek)).
simpan_aksi_terakhir(Card, Player, Efek) :-
    retractall(kartu_aksi_terakhir(_, _, _, _)),
    assertz(kartu_aksi_terakhir(Card, Player, 1, Efek)).

efek_mimic(Player, TopBefore, ColorBefore) :-
    nl,
    write('Menelusuri riwayat permainan.'), nl,
    kartu_aksi_terakhir(Card, PemainAksi, GiliranAksi, Efek), !,
    nomor_giliran(GiliranSekarang),
    Jarak is GiliranSekarang - GiliranAksi,
    write('Kartu aksi terakhir yang dimainkan: '), print_card(Card),
    write(' (oleh '), write(PemainAksi), write(', '), write(Jarak), write(' giliran lalu)'), nl,
    write('Kartu mimic menyalin efek '), write(Efek), write('!'), nl,
    pilih_warna_mimic,
    simpan_aksi_terakhir(kartu(hitam, mimic), Player, Efek),
    jalankan_efek_mimic(Efek, Player, TopBefore, ColorBefore).
efek_mimic(Player, _, _) :-
    write('Belum pernah ada kartu aksi sebelumnya.'), nl,
    write('Kartu mimic berlaku seperti wild.'), nl,
    pilih_warna_mimic,
    simpan_aksi_terakhir(kartu(hitam, mimic), Player, wild),
    bersihkan_pending,
    advance_turn.


pilih_warna_mimic :-
    choose_color_for_wild(Color),
    set_active_color(Color),
    write('Warna aktif sekarang: '), write(Color), write('.'), nl.

jalankan_efek_mimic(skip, _, _, _) :-
    bersihkan_pending,
    lewati_pemain.
jalankan_efek_mimic(reverse, _, _, _) :-
    bersihkan_pending,
    balik_arah_permainan,
    direction(Dir),
    write('Arah permainan berubah menjadi '), write(Dir), write('.'), nl,
    advance_turn.
jalankan_efek_mimic(draw_two, _, _, _) :-
    bersihkan_pending,
    pemain_berikutnya(Target),
    assertz(pending_draw_two(Target)),
    nl,
    write(Target), write(' harus mengambil 2 kartu dan kehilangan giliran.'), nl,
    advance_turn.
jalankan_efek_mimic(wild_draw_four, Player, TopBefore, ColorBefore) :-
    bersihkan_pending,
    pemain_berikutnya(Target),
    assertz(pending_wild_draw_four(Target, Player, TopBefore, ColorBefore)),
    nl,
    write(Target), write(' dapat memilih ambilKartu atau tantang.'), nl,
    advance_turn.
jalankan_efek_mimic(wild, _, _, _) :-
    bersihkan_pending,
    advance_turn.
jalankan_efek_mimic(_, _, _, _) :-
    bersihkan_pending,
    advance_turn.
