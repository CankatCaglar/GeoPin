#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TÜM eksik çevirileri ekle - Tarihi Yerler ve diğer kategoriler
"""

# TÜM kategorilerdeki eksik çeviriler
all_translations = {
    # Tarihi Yerler - Historical Monuments
    'q_buckingham_palace': 'Buckingham Sarayı nerede?',
    'q_the_white_house': 'Beyaz Saray nerede?',
    'q_the_kremlin': 'Kremlin nerede?',
    'q_forbidden_city': 'Yasak Şehir nerede?',
    'q_alhambra': 'Elhamra Sarayı nerede?',
    'q_mont_saint-michel': 'Mont Saint-Michel nerede?',
    'q_neuschwanstein': 'Neuschwanstein Kalesi nerede?',
    'q_edinburgh_castle': 'Edinburgh Kalesi nerede?',
    'q_prague_castle': 'Prag Kalesi nerede?',
    'q_schönbrunn_palace': 'Schönbrunn Sarayı nerede?',
    'q_topkapi_palace': 'Topkapı Sarayı nerede?',
    'q_potala_palace': 'Potala Sarayı nerede?',
    'q_winter_palace': 'Kış Sarayı nerede?',
    'q_palace_of_westminster': 'Westminster Sarayı nerede?',
    'q_royal_palace_of_madrid': 'Madrid Kraliyet Sarayı nerede?',
    'q_doge\'s_palace': 'Doge Sarayı nerede?',
    'q_blenheim_palace': 'Blenheim Sarayı nerede?',
    'q_chateau_de_chambord': 'Chambord Şatosu nerede?',
    'q_castel_sant\'angelo': 'Castel Sant\'Angelo nerede?',
    'q_alcazar_of_seville': 'Sevilla Alcazar\'ı nerede?',
    
    # Daha fazla tarihi yer
    'q_the_parthenon': 'Parthenon nerede?',
    'q_the_pantheon': 'Pantheon nerede?',
    'q_hagia_sophia': 'Ayasofya nerede?',
    'q_blue_mosque': 'Mavi Cami (Sultan Ahmet Camii) nerede?',
    'q_westminster_abbey': 'Westminster Manastırı nerede?',
    'q_sagrada_familia': 'La Sagrada Familia nerede?',
    'q_duomo_di_milano': 'Milano Katedrali nerede?',
    'q_cologne_cathedral': 'Köln Katedrali nerede?',
    'q_st_peter\'s_basilica': 'Aziz Petrus Bazilikası nerede?',
    'q_sistine_chapel': 'Sistine Şapeli nerede?',
    'q_arc_de_triomphe': 'Zafer Takı nerede?',
    'q_brandenburg_gate': 'Brandenburg Kapısı nerede?',
    'q_trevi_fountain': 'Trevi Çeşmesi nerede?',
    'q_spanish_steps': 'İspanyol Merdivenleri nerede?',
    'q_piazza_san_marco': 'San Marco Meydanı nerede?',
    'q_red_square': 'Kızıl Meydan nerede?',
    'q_tiananmen_square': 'Tiananmen Meydanı nerede?',
    'q_times_square': 'Times Meydanı nerede?',
    'q_trafalgar_square': 'Trafalgar Meydanı nerede?',
    'q_piccadilly_circus': 'Piccadilly Circus nerede?',
    
    # Stadyumlar
    'q_camp_nou': 'Camp Nou nerede?',
    'q_wembley': 'Wembley Stadyumu nerede?',
    'q_santiago_bernabeu': 'Santiago Bernabéu nerede?',
    'q_old_trafford': 'Old Trafford nerede?',
    'q_allianz_arena': 'Allianz Arena nerede?',
    'q_san_siro': 'San Siro nerede?',
    'q_maracana': 'Maracanã nerede?',
    'q_la_bombonera': 'La Bombonera nerede?',
    'q_anfield': 'Anfield nerede?',
    'q_signal_iduna_park': 'Signal Iduna Park nerede?',
    'q_azteca': 'Azteca Stadyumu nerede?',
    'q_atatürk_olympic_stadium': 'Atatürk Olimpiyat Stadyumu nerede?',
    
    # Havalimanları
    'q_heathrow': 'Heathrow Havalimanı nerede?',
    'q_jfk': 'JFK Havalimanı nerede?',
    'q_dubai_international': 'Dubai Uluslararası Havalimanı nerede?',
    'q_charles_de_gaulle': 'Charles de Gaulle Havalimanı nerede?',
    'q_frankfurt_airport': 'Frankfurt Havalimanı nerede?',
    'q_schiphol': 'Amsterdam Schiphol Havalimanı nerede?',
    'q_changi': 'Singapur Changi Havalimanı nerede?',
    'q_hong_kong_international': 'Hong Kong Uluslararası Havalimanı nerede?',
    'q_lax': 'Los Angeles Uluslararası Havalimanı nerede?',
    'q_haneda': 'Tokyo Haneda Havalimanı nerede?',
    'q_istanbul_airport': 'İstanbul Havalimanı nerede?',
    'q_barajas': 'Madrid Barajas Havalimanı nerede?',
    
    # Mutfak
    'q_bangkok_pad_thai': 'Bangkok, Pad Thai\'nin evi nerede?',
    'q_beijing_peking_duck': 'Pekin, Pekin Ördeğinin evi nerede?',
    'q_barcelona_tapas': 'Barselona, tapasın evi nerede?',
    'q_naples_pizza': 'Napoli, pizzanın evi nerede?',
    'q_lyon_french_cuisine': 'Lyon, Fransız mutfağının esi nerede?',
    'q_tokyo_sushi': 'Tokyo, sushinin esi nerede?',
    'q_mumbai_curry': 'Mumbai, körinin esi nerede?',
    'q_istanbul_kebab': 'İstanbul, kebabın esi nerede?',
    'q_mexico_city_tacos': 'Mexico City, tacoların esi nerede?',
    'q_vienna_schnitzel': 'Viyana, şnitselin esi nerede?',
}

# app_localizations.dart'ı oku
with open('lib/app_localizations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Türkçe çevirileri ekle
insert_pos = content.find("  // NOT: Kalan 400+ soru için fallback mekanizması çalışacak")
if insert_pos > 0:
    # Yeni çevirileri oluştur
    new_translations = "\n  // Tarihi Yerler, Stadyumlar, Havalimanları, Mutfak\n"
    for key, value in sorted(all_translations.items()):
        new_translations += f"  '{key}': '{value}',\n"
    new_translations += "  \n"
    
    # Ekle
    new_content = content[:insert_pos] + new_translations + content[insert_pos:]
    
    # Kaydet
    with open('lib/app_localizations.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"✅ {len(all_translations)} Türkçe çeviri eklendi!")
    print("\nEklenen kategoriler:")
    print("- Tarihi Yerler (saraylar, kaleler, anıtlar)")
    print("- Stadyumlar")
    print("- Havalimanları")
    print("- Mutfak")
else:
    print("❌ Ekleme noktası bulunamadı!")
