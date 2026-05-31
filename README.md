# Dungeon Echoes

**Dungeon Echoes** to dwuwymiarowa gra akcji tworzona w Godot Engine. Gracz walczy z kolejnymi falami przeciwnikow, zbiera monety, kupuje ulepszenia w sklepie i rozwija zestaw broni, probujac przetrwac jak najdluzej.

Projekt powstal jako gra zaliczeniowa i laczy elementy platformowki, arenowego survivalu oraz prostego roguelite'owego progresu.

## Spis tresci

- [Opis gry](#opis-gry)
- [Najwazniejsze funkcje](#najwazniejsze-funkcje)
- [Sterowanie](#sterowanie)
- [Wymagania](#wymagania)
- [Uruchomienie projektu](#uruchomienie-projektu)
- [Eksport gry](#eksport-gry)
- [Struktura projektu](#struktura-projektu)
- [Status projektu](#status-projektu)
- [Autorzy i zasoby](#autorzy-i-zasoby)

## Opis gry

W grze sterujesz bohaterem poruszajacym sie po mrocznej arenie. Twoim zadaniem jest odpieranie coraz trudniejszych fal przeciwnikow. Pokonani wrogowie moga zostawiac monety, ktore pozwalaja kupowac nowe bronie oraz ulepszenia statystyk w sklepie.

Rozgrywka opiera sie na szybkim ruchu, dashu, zmianie broni i utrzymywaniu combosa. Im sprawniej eliminujesz przeciwnikow, tym wieksze premie do obrazen i szybkosci mozesz uzyskac.

## Najwazniejsze funkcje

- System fal przeciwnikow z rosnacym poziomem trudnosci.
- Kilka typow przeciwnikow, m.in. slime, skeleton, blob enemy, cacodemon oraz boss.
- Bohater z ruchem, skokiem, dashem, stanami animacji i reakcja na niski poziom zdrowia.
- System broni:
  - fireball,
  - electric weapon,
  - self guiding missile,
  - gravity grenade.
- Sklep z losowanymi przedmiotami i ulepszeniami.
- System monet oraz zapisu postepu gracza.
- Combo z progami `FLOW`, `HOT STREAK`, `RAMPAGE` i `OVERDRIVE`.
- Menu glowne z opcja nowej gry, kontynuacji oraz ustawieniami glosnosci.
- Menu pauzy z mozliwoscia zapisania gry przed wyjsciem.
- Krotki tutorial wprowadzajacy w podstawowe sterowanie.
- Efekty dzwiekowe, muzyka, czasteczki, kamera shake i wizualne efekty trafien.

## Sterowanie

| Akcja | Klawisz / przycisk |
| --- | --- |
| Ruch w lewo | `A` |
| Ruch w prawo | `D` |
| Skok | `Spacja` |
| Dash | `Shift` |
| Atak | `E` lub lewy przycisk myszy |
| Interakcja | `F` |
| Bron 1 | `1` |
| Bron 2 | `2` |
| Bron 3 | `3` |
| Bron 4 | `4` |
| Pauza | `Esc` |

## Wymagania

- Godot Engine `4.6` lub nowszy zgodny z projektem.
- System Windows, Linux lub macOS do uruchomienia w edytorze Godot.
- Do eksportu na Windows wymagane sa standardowe szablony eksportu Godot.

Projekt ma przygotowany preset eksportu dla **Windows Desktop**.

## Uruchomienie projektu

1. Sklonuj repozytorium:

   ```bash
   git clone <adres-repozytorium>
   ```

2. Otworz Godot Engine.

3. Wybierz opcje importu projektu i wskaz plik:

   ```text
   project.godot
   ```

4. Po zaimportowaniu projektu uruchom scene startowa przyciskiem **Play**.

Glowna scena projektu jest ustawiona w konfiguracji Godota, wiec gra powinna wystartowac od menu glownego.

## Eksport gry

W projekcie znajduje sie preset eksportu:

- nazwa: `Dungeon Echoes`
- platforma: `Windows Desktop`
- format: `x86_64`
- PCK osadzony w pliku wykonywalnym

Aby wyeksportowac gre:

1. Otworz projekt w Godot.
2. Przejdz do **Project > Export**.
3. Wybierz preset `Dungeon Echoes`.
4. Ustaw docelowa lokalizacje pliku `.exe`.
5. Kliknij **Export Project**.

## Struktura projektu

```text
.
+-- project.godot
+-- export_presets.cfg
+-- wave_manager.gd
+-- scenes
|   +-- main_menu
|   +-- main_map
|   +-- shop_map
|   +-- tutorial
|   +-- test_map
|   +-- entities
|       +-- main_character
|       +-- enemies
|       +-- collectables
|       +-- universal
+-- tools
```

Najwazniejsze katalogi:

- `scenes/main_menu` - menu glowne, przyciski, ustawienia audio i przejscia scen.
- `scenes/main_map` - glowna mapa, pauza, platformy, zarzadzanie arena.
- `scenes/shop_map` - sklep, przedmioty, ulepszenia i zakup broni.
- `scenes/entities/main_character` - postac gracza, HUD, dane gracza, ruch i system broni.
- `scenes/entities/enemies` - przeciwnicy oraz ich stany zachowania.
- `scenes/entities/collectables` - monety, przedmioty do zbierania i dropy zdrowia.
- `scenes/entities/universal` - wspolne elementy, np. paski zdrowia, eksplozje i efekty.
- `scenes/tutorial` - prosty tutorial sterowania.

## Status projektu

Projekt jest grywalnym prototypem / projektem zaliczeniowym. Zawiera podstawowa petle rozgrywki:

1. start z menu glownego,
2. walka na mapie,
3. zbieranie monet,
4. zakupy w sklepie,
5. zapis i kontynuacja postepu.

Mozliwe kierunki dalszego rozwoju:

- dopracowanie balansu fal przeciwnikow,
- dodanie wiekszej liczby map,
- rozbudowanie walk bossow,
- dodanie ekranu ustawien sterowania,
- uporzadkowanie licencji zasobow audio i grafik,
- przygotowanie buildow do pobrania w GitHub Releases.

## Autorzy i zasoby

Projekt zostal przygotowany jako praca zaliczeniowa w Godot Engine.

Repozytorium zawiera pliki graficzne, dzwiekowe, fonty oraz muzyke uzywane w projekcie. Przed publiczna dystrybucja gry poza kontekstem edukacyjnym warto zweryfikowac licencje wszystkich zasobow zewnetrznych.

## Licencja

Brak okreslonej licencji w repozytorium. Domyslnie oznacza to, ze prawa do kodu i zasobow pozostaja przy autorach projektu.
