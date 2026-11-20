import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VOLTAJ: Aşırı Hız',
      home: AnaMenuEkrani(),
    ),
  );
}

enum KureTipi { altin, zaman, kalkan, mayin }

class AnaMenuEkrani extends StatefulWidget {
  const AnaMenuEkrani({super.key});

  @override
  State<AnaMenuEkrani> createState() => _AnaMenuEkraniState();
}

class _AnaMenuEkraniState extends State<AnaMenuEkrani> {
  int rekorSkor = 0;
  int toplamTur = 0;

  @override
  void initState() {
    super.initState();
    istatistikleriYukle();
  }

  Future<void> istatistikleriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rekorSkor = prefs.getInt('voltaj_rekor') ?? 0;
      toplamTur = prefs.getInt('voltaj_tur') ?? 0;
    });
  }

  Future<void> oyunuBaslat() async {
    final sonuc = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => OyunMotoruEkrani(mevcutRekor: rekorSkor),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final yeniTur = toplamTur + 1;
    await prefs.setInt('voltaj_tur', yeniTur);

    int yeniRekor = rekorSkor;
    if (sonuc != null && sonuc > rekorSkor) {
      yeniRekor = sonuc;
      await prefs.setInt('voltaj_rekor', yeniRekor);
    }

    setState(() {
      toplamTur = yeniTur;
      rekorSkor = yeniRekor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.12),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      size: 64,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'VOLTAJ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Text(
                    'AŞIRI HIZ MODU',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _BilgiKarti(
                    rekorSkor: rekorSkor,
                    toplamTur: toplamTur,
                  ),
                  const SizedBox(height: 20),
                  const _MekanikOzeti(),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: oyunuBaslat,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text(
                    'TURU BAŞLAT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BilgiKarti extends StatelessWidget {
  final int rekorSkor;
  final int toplamTur;
  const _BilgiKarti({required this.rekorSkor, required this.toplamTur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('REKOR', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '$rekorSkor',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(width: 1, height: 36, color: Colors.white12),
          Column(
            children: [
              const Text('TOPLAM TUR', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '$toplamTur',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MekanikOzeti extends StatelessWidget {
  const _MekanikOzeti();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          _Satir(renk: Colors.amber, metin: 'Altın Küre: Puan + Kombo Çarpanı'),
          SizedBox(height: 6),
          _Satir(renk: Colors.cyanAccent, metin: 'Buz Küresi: +3 Saniye Ek Süre'),
          SizedBox(height: 6),
          _Satir(renk: Colors.greenAccent, metin: 'Kalkan Küresi: İlk Mayın Hasarını Siler'),
          SizedBox(height: 6),
          _Satir(renk: Colors.redAccent, metin: 'Kırmızı Mayın: -25 Puan & Kombo Sıfır'),
        ],
      ),
    );
  }
}

class _Satir extends StatelessWidget {
  final Color renk;
  final String metin;
  const _Satir({required this.renk, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: renk),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            metin,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class OyunMotoruEkrani extends StatefulWidget {
  final int mevcutRekor;
  const OyunMotoruEkrani({super.key, required this.mevcutRekor});

  @override
  State<OyunMotoruEkrani> createState() => _OyunMotoruEkraniState();
}

class _OyunMotoruEkraniState extends State<OyunMotoruEkrani> {
  final Random rnd = Random();

  int skor = 0;
  int kombo = 0;
  int kalanSure = 25;
  bool kalkanVar = false;
  String sonOlay = 'Hazır! Hızlı başla';

  KureTipi aktifTip = KureTipi.altin;
  double posX = 0.5;
  double posY = 0.5;
  double yonX = 0.008;
  double yonY = 0.006;

  Timer? saniyeTimer;
  Timer? kureOmurTimer;
  Timer? hareketTimer;

  int get dalga => 1 + (skor ~/ 120);
  int get carpan => 1 + (kombo ~/ 4);

  @override
  void initState() {
    super.initState();
    yeniKureUret();

    saniyeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (kalanSure <= 1) {
        t.cancel();
        kureOmurTimer?.cancel();
        hareketTimer?.cancel();
        turSonuPenceresi();
      } else {
        setState(() => kalanSure--);
      }
    });

    hareketTimer = Timer.periodic(const Duration(milliseconds: 24), (_) {
      if (!mounted || dalga < 2) return;
      setState(() {
        final hizCarpani = min(2.4, 0.8 + (dalga * 0.22));
        posX += yonX * hizCarpani;
        posY += yonY * hizCarpani;

        if (posX < 0.14 || posX > 0.86) {
          yonX = -yonX;
          posX = posX.clamp(0.14, 0.86);
        }
        if (posY < 0.20 || posY > 0.84) {
          yonY = -yonY;
          posY = posY.clamp(0.20, 0.84);
        }
      });
    });
  }

  KureTipi tipSec() {
    final r = rnd.nextDouble();
    final mayinEsigi = min(0.38, 0.18 + (dalga * 0.03));
    if (r < mayinEsigi) return KureTipi.mayin;
    if (r < mayinEsigi + 0.14) return KureTipi.zaman;
    if (r < mayinEsigi + 0.24) return KureTipi.kalkan;
    return KureTipi.altin;
  }

  void yeniKureUret() {
    kureOmurTimer?.cancel();
    setState(() {
      aktifTip = tipSec();
      posX = 0.16 + rnd.nextDouble() * 0.68;
      posY = 0.22 + rnd.nextDouble() * 0.60;
      yonX = (rnd.nextBool() ? 1 : -1) * (0.005 + rnd.nextDouble() * 0.005);
      yonY = (rnd.nextBool() ? 1 : -1) * (0.005 + rnd.nextDouble() * 0.005);
    });

    final omurMs = max(580, 1300 - (dalga * 95));
    kureOmurTimer = Timer(Duration(milliseconds: omurMs), () {
      if (!mounted) return;
      if (aktifTip == KureTipi.altin) {
        setState(() {
          kombo = 0;
          sonOlay = 'Altın kaçtı! Kombo sıfırlandı';
        });
      }
      yeniKureUret();
    });
  }

  void kureyeDokun() {
    switch (aktifTip) {
      case KureTipi.altin:
        HapticFeedback.lightImpact();
        setState(() {
          kombo++;
          final puan = 15 * carpan;
          skor += puan;
          sonOlay = '+$puan Puan (x$carpan Kombo)';
        });
        break;
      case KureTipi.zaman:
        HapticFeedback.mediumImpact();
        setState(() {
          kalanSure += 3;
          skor += 10;
          sonOlay = '+3 Saniye Ek Süre!';
        });
        break;
      case KureTipi.kalkan:
        HapticFeedback.mediumImpact();
        setState(() {
          kalkanVar = true;
          skor += 15;
          sonOlay = 'Kalkan Aktif! Mayın koruması hazır';
        });
        break;
      case KureTipi.mayin:
        HapticFeedback.heavyImpact();
        setState(() {
          if (kalkanVar) {
            kalkanVar = false;
            sonOlay = 'Kalkan mayını emdi!';
          } else {
            kombo = 0;
            skor = max(0, skor - 25);
            sonOlay = 'Mayına bastın! -25 Puan';
          }
        });
        break;
    }
    yeniKureUret();
  }

  void turSonuPenceresi() {
    final yeniRekor = skor > widget.mevcutRekor;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: Text(
          yeniRekor ? 'YENİ REKOR KIRILDI!' : 'Tur Tamamlandı',
          style: TextStyle(
            color: yeniRekor ? Colors.amber : Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Skor: $skor\nUlaşılan Dalga: $dalga\nEn Yüksek Çarpan: x$carpan',
          style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, skor);
            },
            child: const Text('Ana Menü'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                skor = 0;
                kombo = 0;
                kalanSure = 25;
                kalkanVar = false;
                sonOlay = 'Yeni tur başladı!';
              });
              saniyeTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                if (!mounted) return;
                if (kalanSure <= 1) {
                  t.cancel();
                  kureOmurTimer?.cancel();
                  hareketTimer?.cancel();
                  turSonuPenceresi();
                } else {
                  setState(() => kalanSure--);
                }
              });
              yeniKureUret();
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  Color kureRengi() {
    switch (aktifTip) {
      case KureTipi.altin:
        return Colors.amber;
      case KureTipi.zaman:
        return Colors.cyanAccent;
      case KureTipi.kalkan:
        return Colors.greenAccent;
      case KureTipi.mayin:
        return Colors.redAccent;
    }
  }

  IconData kureIkonu() {
    switch (aktifTip) {
      case KureTipi.altin:
        return Icons.bolt;
      case KureTipi.zaman:
        return Icons.timer;
      case KureTipi.kalkan:
        return Icons.shield;
      case KureTipi.mayin:
        return Icons.dangerous;
    }
  }

  @override
  void dispose() {
    saniyeTimer?.cancel();
    kureOmurTimer?.cancel();
    hareketTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ekran = MediaQuery.of(context).size;
    final renk = kureRengi();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SKOR: $skor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'DALGA $dalga • x$carpan',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${kalanSure}s',
                        style: TextStyle(
                          color: kalanSure <= 5 ? Colors.redAccent : Colors.cyanAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sonOlay,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      if (kalkanVar)
                        const Row(
                          children: [
                            Icon(Icons.shield, color: Colors.greenAccent, size: 15),
                            SizedBox(width: 4),
                            Text(
                              'KALKAN AÇIK',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: ekran.width * posX - 42,
              top: ekran.height * posY - 42,
              child: GestureDetector(
                onTap: kureyeDokun,
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: renk,
                    boxShadow: [
                      BoxShadow(
                        color: renk.withOpacity(0.55),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(kureIkonu(), color: Colors.black, size: 38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
