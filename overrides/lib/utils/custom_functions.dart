import 'package:intl/intl.dart';
import '../models/lista_item.dart';
import '../models/share_item.dart';

class CustomFunctions {
  static DateTime? ustawRok1900(DateTime? inputDate) {
    if (inputDate == null) return null;
    return DateTime(1900, inputDate.month, inputDate.day);
  }

  static String obliczWiekOsoby(DateTime? dataUrodzenia, String languageCode) {
    if (dataUrodzenia == null || dataUrodzenia.year == 1900) {
      return '';
    }

    DateTime dzis = DateTime.now();
    int wiek = dzis.year - dataUrodzenia.year;

    if (dzis.month < dataUrodzenia.month ||
        (dzis.month == dataUrodzenia.month && dzis.day < dataUrodzenia.day)) {
      wiek--;
    }

    if (wiek < 1) return '';

    String lang = languageCode.toLowerCase();

    switch (lang) {
      case 'pl':
        String slowo;
        if (wiek == 1) {
          slowo = 'rok';
        } else {
          int ostatniaCyfra = wiek % 10;
          int dwieOstatnie = wiek % 100;
          if (ostatniaCyfra >= 2 &&
              ostatniaCyfra <= 4 &&
              (dwieOstatnie < 10 || dwieOstatnie > 20)) {
            slowo = 'lata';
          } else {
            slowo = 'lat';
          }
        }
        return '$wiek $slowo';

      case 'en':
        return '$wiek ${wiek == 1 ? 'year old' : 'years old'}';

      case 'de':
        return '$wiek ${wiek == 1 ? 'Jahr alt' : 'Jahre alt'}';

      case 'ru':
        String slowo;
        int n = wiek % 100;
        int n1 = n % 10;
        if (n > 10 && n < 20) {
          slowo = 'лет';
        } else if (n1 > 1 && n1 < 5) {
          slowo = 'года';
        } else if (n1 == 1) {
          slowo = 'год';
        } else {
          slowo = 'лет';
        }
        return '$wiek $slowo';

      default:
        return '$wiek';
    }
  }

  static List<ListaItem> sortujUrodziny(List<ListaItem> lista) {
    List<ListaItem> posortowanaLista = List.from(lista);
    DateTime dzis = DateTime.now();
    DateTime dzisTylkoData = DateTime(dzis.year, dzis.month, dzis.day);

    posortowanaLista.sort((a, b) {
      if (a.datazapisz == null || b.datazapisz == null) return 0;

      DateTime najblizszeA =
          DateTime(dzis.year, a.datazapisz!.month, a.datazapisz!.day);
      if (najblizszeA.isBefore(dzisTylkoData)) {
        najblizszeA =
            DateTime(dzis.year + 1, a.datazapisz!.month, a.datazapisz!.day);
      }

      DateTime najblizszeB =
          DateTime(dzis.year, b.datazapisz!.month, b.datazapisz!.day);
      if (najblizszeB.isBefore(dzisTylkoData)) {
        najblizszeB =
            DateTime(dzis.year + 1, b.datazapisz!.month, b.datazapisz!.day);
      }

      return najblizszeA.compareTo(najblizszeB);
    });

    return posortowanaLista;
  }

  static bool czyIstniejeDuplikatV3(
    List<ListaItem> lista,
    String noweImie,
    DateTime? nowaData,
    int indexEdycji,
  ) {
    if (nowaData == null) return false;

    final String czysteNoweImie = noweImie.trim().toLowerCase();
    if (czysteNoweImie.isEmpty) return false;

    for (int i = 0; i < lista.length; i++) {
      if (indexEdycji != -1 && i == indexEdycji) {
        continue;
      }

      final item = lista[i];
      final String imieZListy = item.tekst.trim().toLowerCase();
      final bool imieToSamo = imieZListy == czysteNoweImie;
      final bool dzienTenSam = item.datazapisz?.day == nowaData.day;
      final bool miesiacTenSam = item.datazapisz?.month == nowaData.month;

      if (imieToSamo && dzienTenSam && miesiacTenSam) {
        return true;
      }
    }

    return false;
  }

  static bool czyBliskoUrodziny(DateTime? dataUrodzin) {
    if (dataUrodzin == null) return false;

    final teraz = DateTime.now();
    final dzis = DateTime(teraz.year, teraz.month, teraz.day);
    final jutro = dzis.add(const Duration(days: 1));

    final urodzinyWTymRoku =
        DateTime(teraz.year, dataUrodzin.month, dataUrodzin.day);

    return urodzinyWTymRoku.isAtSameMomentAs(dzis) ||
        urodzinyWTymRoku.isAtSameMomentAs(jutro);
  }

  static bool czyToNajblizszaData(
    DateTime? dataWiersza,
    List<ListaItem>? listaUrodzin,
  ) {
    if (dataWiersza == null || listaUrodzin == null || listaUrodzin.isEmpty) {
      return false;
    }

    final teraz = DateTime.now();
    final dzis = DateTime(teraz.year, teraz.month, teraz.day);
    final jutro = dzis.add(const Duration(days: 1));

    bool czyJestJakisCzerwony = false;
    for (var item in listaUrodzin) {
      if (item.datazapisz == null) continue;
      final d =
          DateTime(teraz.year, item.datazapisz!.month, item.datazapisz!.day);
      if (d.isAtSameMomentAs(dzis) || d.isAtSameMomentAs(jutro)) {
        czyJestJakisCzerwony = true;
        break;
      }
    }

    if (czyJestJakisCzerwony) return false;

    List<ListaItem> posortowana = List.from(listaUrodzin);
    posortowana.sort((a, b) {
      if (a.datazapisz == null || b.datazapisz == null) return 0;
      int valA = a.datazapisz!.month * 100 + a.datazapisz!.day;
      int valB = b.datazapisz!.month * 100 + b.datazapisz!.day;
      return valA.compareTo(valB);
    });

    DateTime? najblizsza;
    int dDzis = dzis.month * 100 + dzis.day;

    for (var item in posortowana) {
      if (item.datazapisz == null) continue;
      int dItem = item.datazapisz!.month * 100 + item.datazapisz!.day;
      if (dItem > dDzis) {
        najblizsza = item.datazapisz;
        break;
      }
    }

    if (najblizsza == null && posortowana.isNotEmpty) {
      najblizsza = posortowana.first.datazapisz;
    }

    return dataWiersza.month == najblizsza?.month &&
        dataWiersza.day == najblizsza?.day;
  }

  /// Buduje czytelny tekst do udostępnienia – miesiąc słownie, bez wieku
  static String budujTekstDoWysylki(
    List<ListaDoUdostepnienia> listaShare,
    String wybranyJezyk,
  ) {
    final wybrane =
        listaShare.where((osoba) => osoba.czyprzekazac == true).toList();

    if (wybrane.isEmpty) {
      if (wybranyJezyk == 'pl') return "Nie zaznaczono żadnych osób.";
      if (wybranyJezyk == 'de') return "Keine Personen ausgewählt.";
      if (wybranyJezyk == 'ru') return "Никто не выбран.";
      return "No persons selected.";
    }

    String tekst = "";
    if (wybranyJezyk == 'pl') {
      tekst = "Lista urodzin:\n\n";
    } else if (wybranyJezyk == 'de') {
      tekst = "Geburtstagsliste:\n\n";
    } else if (wybranyJezyk == 'ru') {
      tekst = "Список дней рождения:\n\n";
    } else {
      tekst = "Birthday list:\n\n";
    }

    for (var osoba in wybrane) {
      if (osoba.przekazdate == null) continue;

      // Miesiąc SŁOWNIE (np. "12 stycznia", "15 marca", "22 sierpnia")
      String dataTekst =
          DateFormat("d MMMM", wybranyJezyk).format(osoba.przekazdate!);

      // Rok dopisujemy tylko jeśli był widoczny (nie 1900)
      if (osoba.przekazdate!.year > 1900) {
        dataTekst += " ${osoba.przekazdate!.year}";
      }

      tekst += "${osoba.przekazimie}: $dataTekst\n";
    }

    return tekst;
  }

  static List<ListaDoUdostepnienia> przepiszNaListeShare(
    List<ListaItem> listaWejsciowa,
  ) {
    return listaWejsciowa.map((osoba) {
      return ListaDoUdostepnienia(
        przekazimie: osoba.tekst,
        przekazdate: osoba.datazapisz,
        czyprzekazac: false,
      );
    }).toList();
  }
}
