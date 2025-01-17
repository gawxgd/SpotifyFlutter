# spotify_flutter

# Dokumentacja Projektu

## 📄 Opis Projektu
Gra online multiplayer, w której gracze zgadują, jakiej muzyki słuchają ich znajomi. Użytkownicy logują się za pomocą swojego konta Spotify, przekazując tokeny dostępu do Spotify API. Aplikacja pobiera ich statystyki muzyczne, które następnie można przeglądać. Użytkownicy mają możliwość zarządzania ustawieniami aplikacji i edytowania swojego profilu.  

Grę można rozpocząć na dwa sposoby:  
1. **Dołączenie do istniejącej gry**: Wystarczy wpisać kod PIN pokoju.  
2. **Stworzenie nowej gry**: Proces obejmuje:  
   - Ustalenie zasad (np. czas na jedno pytanie i liczba rund).  
   - Otwarcie widoku lobby gry, z którego można zaprosić innych graczy, generując kod QR lub udostępniając specjalny link (Deep Link).  

Podczas rozgrywki gracze łączą się między sobą peer-to-peer za pomocą technologii WebRTC.  

Każdy uczestnik widzi ten sam ekran, na którym wyświetlana jest piosenka oraz siatka użytkowników. Zadaniem graczy jest wskazanie osoby, która według nich słucha tej piosenki. Po upływie czasu lub wcześniejszym jego zakończeniu przez hosta, prezentowane są odpowiedzi graczy. Następnie host może przejść do kolejnego pytania, a system wyświetla aktualny ranking (leaderboard).  

Gra trwa aż do wyczerpania ustalonej liczby rund, po czym gracze widzą ekran końcowy z podsumowaniem wyników.

---

### Funkcjonalności:
- **Przeglądanie statystyk**: Analiza preferencji muzycznych użytkownika.  
- **Rozgrywka**:  
  - Tworzenie lub dołączanie do gry przy użyciu kodu PIN.  
  - Ustalanie zasad (liczba rund, czas na odpowiedź).  
  - Wyświetlanie rankingów po każdej rundzie i widoku końca gry.  
- **Połączenia peer-to-peer**: Gracze łączą się przy użyciu WebRTC.  

---

## 🔗 Integracje
Projekt wykorzystuje następujące zewnętrzne integracje:  
- **Spotify API**: Pobieranie statystyk muzycznych użytkowników.  
- **Firebase**: Obsługa mechanizmu rozpoznawania graczy po identyfikatorze pokoju (Room ID).  
- **Deep Links**: Dołączanie do gry za pomocą kodów QR lub linków.  
- **WebRTC**: Obsługa połączeń peer-to-peer między graczami.  
- **Wibracje**: Powiadomienia wibracyjne w kluczowych momentach gry.  

---

## 👤 Konto testowe 
Dowolny użytkownik spotify zarejstrowany w Spotify Developer Dashbord

---

# 🔗 Schemat kolekcji Firestore: **Rooms**

Kolekcja **Rooms** przechowuje dane dotyczące pokoi gry. Każdy dokument w tej kolekcji zawiera informacje potrzebne do zarządzania grą oraz nawiązywania połączeń peer-to-peer.

## 📂 Struktura dokumentów:
### Pola:
- **pin** *(string)*  
  - Unikalny kod PIN pokoju gry, który gracze podają, aby dołączyć do rozgrywki.  
  - **Przykład**: `"12345"`

- **hostPeerId** *(string)*  
  - Identyfikator peer-to-peer hosta, wykorzystywany do komunikacji między graczami za pomocą technologii WebRTC.  
  - **Przykład**: `"host_abc123"`
---

## 🛠️ Przykładowy dokument:
```json
{
  "pin": "12345",
  "hostPeerId": "host_abc123",
}
```

# 🌐 Firebase Hosting dla `assetlinks.json`

Aplikacja wykorzystuje Firebase Hosting do hostowania pliku **`assetlinks.json`**, który jest niezbędny do obsługi linków głębokich (deep links) na urządzeniach mobilnych.  

Plik **`assetlinks.json`** pozwala aplikacji na asocjację z domeną, co umożliwia otwieranie linków w aplikacji zamiast w przeglądarce. Jest to kluczowe dla poprawnego działania deep linków na platformach takich jak Android.

---

## 📄 Zawartość pliku `assetlinks.json`:
```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.spotify_flutter",
      "sha256_cert_fingerprints": [
        "12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF"
      ]
    }
  }
]
```


