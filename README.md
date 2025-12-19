
# AnyVenue - Platform Booking Lapangan Olahraga Digital

### Nama-nama Anggota Kelompok
- Alya Nabilla Khamil (2406358094)
- Fakhri Husaini Romza (2406436972)
- Keisha Vania Laurent (2406437331)
- Naufal Fadli Rabbani (2406350785)
- Sahila Khairatul Athia (2406495716)

## 📱 Deskripsi Aplikasi

Platform website "**AnyVenue**" dirancang untuk memudahkan pengguna dalam mencari dan memesan *venue* olahraga, serta menghubungkan komunitas melalui fitur **Event**. Fokus utama aplikasi ini adalah efisiensi pencarian lokasi, transparansi ketersediaan slot waktu, kemudahan reservasi, dan publikasi kegiatan olahraga. Pengguna dapat memilih *venue* sesuai jenis olahraga, melakukan *booking*, serta melihat dan mendaftar pada berbagai *event* olahraga yang tersedia.

### Kebermanfaatan
- **Untuk User (Pencari Venue & Penggiat Olahraga)**:
    - Menyediakan pengalaman reservasi yang **praktis, informatif, dan efisien**.
    - Memberikan akses ke komunitas olahraga melalui fitur **Event**, di mana pengguna dapat menemukan dan mengikuti kegiatan olahraga menarik di sekitar mereka untuk memperluas jaringan sosial.

- **Untuk Venue Partner (Pemilik Venue)**:
    - Menyediakan **platform promosi digital** yang luas untuk *venue* mereka.
    - Mempermudah **manajemen jadwal/booking** secara digital.
    - Fitur **Event** memungkinkan pemilik untuk menyelenggarakan turnamen atau kegiatan komunitas guna meningkatkan eksposur dan mendatangkan lebih banyak pengunjung ke *venue*.

## 🧩 Daftar Modul
1. **Autentikasi (Login/Register/Logout)**:
   - Memungkinkan pengguna untuk membuat akun baru, melakukan *login*, serta *logout* dengan aman. Modul ini juga mengatur hak akses agar fitur tertentu hanya dapat diakses sesuai *role*.
   
2. **Landing Page**:
   - Landing page berfungsi sebagai halaman utama yang menampilkan gambaran umum dari seluruh fitur yang tersedia dalam aplikasi. Pada bagian awal halaman, terdapat section perkenalan yang menjelaskan secara singkat tujuan dan konsep utama dari website ini. Setelah itu, pengguna dapat menemukan beberapa section overview yang menampilkan ringkasan dari fitur-fitur utama aplikasi, antara lain:
      - *Booking Venue/ Tambah Venue (untuk Owner):* menampilkan deskripsi singkat tentang fitur booking venue bagi pengguna atau dapat menambahkan venue baru bagi role owner.
      - *Event :* menampilkan ringkasan fitur untuk melihat daftar event yang sedang berlangsung bagi pengguna atau menambahkan event baru bagi owner.
      - *Review Lapangan:* menampilkan cuplikan fitur bagi pengguna untuk memberikan ulasan terhadap lapangan yang telah digunakan.

      Setiap section dilengkapi dengan tombol navigasi yang akan mengarahkan pengguna langsung ke halaman fitur terkait, sehingga landing page berfungsi sebagai pusat orientasi sekaligus pintu masuk ke seluruh modul utama dalam aplikasi.

3. **Venue** (Keisha Vania Laurent):
   - *Venue* memiliki hubungan dengan modul *Review* dan *Booking*, di mana satu venue dapat memiliki banyak review dan banyak booking. Modul ini juga menyediakan halaman untuk menampilkan daftar semua venue serta halaman detail setiap venue. Selain itu, tersedia fitur CRUD yang dapat diakses oleh `Owner` untuk pengelolaan data venue.

4. **Booking** (Fakhri Husaini Romza):
   - Menampilkan halaman untuk melakukan *booking* kepada venue yang dipilih. Memiliki `User` yang bisa melakukan *booking* sebuah `Venue`, field `created_at` untuk tanggal *booking*.

5. **Account** (Alya Nabilla Khamil):
   - Berfungsi untuk mengelola data dan aktivitas pengguna dalam sistem, yang terdiri dari dua jenis peran utama, yaitu `User` (pengguna biasa) dan `Owner` (pemilik venue). Halaman profil pengguna yang menampilkan informasi aktivitas masing-masing peran. Integrasi dengan modul `Venue` dan `Event` untuk menampilkan data terkait. Berikut detail halaman profil sesuai *role*:
        - User (Pengguna Biasa): Dapat melihat daftar *venue* yang sudah di-*booking*, dapat melihat *review* yang telah dibuat terhadap venue.
        - Owner (Pemilik Venue): Dapat melihat daftar *venue* dan detail *venue* yang dimilikinya.

6. **Review** (Sahila Khairatul Athia):
   - Memungkinkan `User` untuk berbagi pengalaman mereka terhadap suatu `Venue` melalui sistem `Review` yang interaktif. `User` dapat melakukan operasi CRUD (*Create*, *Read*, *Update*, *Delete*) terhadap `Review` untuk `Venue` tertentu dengan komentar/ulasan serta *rating* (1-5 bintang). Terdapat juga fitur filtering untuk melihat "All Reviews" atau "My Reviews" secara dinamis.
     
7. **Event** (Naufal Fadli Rabbani):
   -  Modul `Event` merupakan suatu fitur dimana `Owner` dapat menyelengarakan event dan membuka pendaftaran bagi `User` yang mau berpartisipasi. `User` dapat melakukan pendaftaran pada event yang diselenggrakan oleh `Owner`.

## 🧑‍💻 Peran Pengguna (Actors)

1. **User (Penyewa Venue)**
    - Melihat daftar *venue* & melakukan *booking*.
    - Melihat daftar *event* & mengikuti *event*.
    - Memberikan *rating* dan *review*.
    - Mengelola profil pribadi.

2. **Owner (Pemilik Venue)**
    - Menambahkan dan mengelola data *venue*.
    - Menambahkan dan mengelola *event*.
    - Melihat daftar *booking* masuk.
    - Mengelola profil pribadi.

## 🌐 Alur Pengintegrasian dengan Web Service
Aplikasi mobile ini terhubung dengan layanan web (Django Framework) yang telah dikembangkan sebelumnya. Pertukaran data dilakukan menggunakan protokol HTTP dengan format JSON. Berikut adalah alur integrasinya:

1. **Request** (Permintaan Data): Aplikasi mobile mengirimkan HTTP Request (GET, POST, DELETE) ke endpoint URL yang tersedia pada Web Service (misalnya: untuk login, mengambil daftar venue, atau mengirim data booking).

    - URL Web Service: https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/

2. **Processing** (Pemrosesan di Server): Web service (Django) menerima *request*, memproses logika bisnis (validasi data, query database), dan menyiapkan respon.

3. **Response** (Balikan Data): Web service mengirimkan kembali data yang diminta atau status operasi dalam format JSON.

    - Contoh: Mengembalikan list objek venue atau status "Success" setelah booking berhasil.

4. **Parsing & Display**: Aplikasi mobile menerima respon JSON, melakukan *parsing* (konversi data JSON menjadi objek Dart), dan memperbarui tampilan antarmuka (UI) sesuai dengan data yang diterima (misalnya: menampilkan list card venue di layar).

5. **Asynchronous Communication**: Seluruh proses *fetch* data dilakukan secara *asynchronous* agar antarmuka aplikasi tidak membeku (*freeze*) saat menunggu balikan data dari server.

## 🔗 Tautan Penting

- **Website Deployment:** [AnyVenue Web](https://keisha-vania-anyvenue.pbp.cs.ui.ac.id/)
- **Desain Figma:** [AnyVenue Mobile Design](https://www.figma.com/design/tM78JfgdxlbbkeU8Jos2Md/AnyVenue-Mobile?node-id=6004-3118&t=QhQJN9Pm6qrp00ZA-1)
- **Initial Dataset:** [AnyVenue Dataset](https://docs.google.com/spreadsheets/d/1-ULBMiPrgKrf5jqux1t8zMe6mDMGfZHzvRUlN7DwcL8/edit?usp=sharing)
- **Sumber Dataset:** [AYO - Super Sport Community App](https://ayo.co.id/venues)
