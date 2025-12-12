#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TÜM eksik çevirileri ekle - Köprüler, Mutfak, Stadyumlar, Havalimanları
"""
import re

# TÜM soruları main.dart'dan çıkar
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

questions = re.findall(r"prompt:\s*['\"]([^'\"]+)['\"]", content)
print(f"Toplam {len(questions)} soru bulundu")

# app_localizations.dart'ı oku
with open('lib/app_localizations.dart', 'r', encoding='utf-8') as f:
    loc_content = f.read()

# Eksik çevirileri bul
missing_translations = {}
for prompt in questions:
    key = prompt.lower()
    key = key.replace('where is ', 'q_').replace('where are ', 'q_')
    key = key.replace('?', '').replace("'", '').replace('"', '')
    key = key.replace(' ', '_').replace(',', '').replace('(', '').replace(')', '')
    key = key.replace('.', '').replace('–', '').replace(''', '').replace(''', '')
    key = key.replace('__', '_').strip()
    
    if f"'{key}':" not in loc_content:
        # Basit Türkçe çeviri oluştur
        tr = prompt.replace('Where is ', '').replace('Where are ', '').replace('?', ' nerede?')
        missing_translations[key] = tr

print(f"Eksik çeviri: {len(missing_translations)}")

# Çevirileri app_localizations.dart'a ekle
insert_pos = loc_content.find("  // NOT: Kalan 400+ soru için fallback mekanizması çalışacak")
if insert_pos > 0:
    new_translations = "\n  // Otomatik eklenen eksik çeviriler\n"
    for key, value in sorted(missing_translations.items())[:100]:  # İlk 100 eksik çeviri
        new_translations += f"  '{key}': '{value}',\n"
    new_translations += "  \n"
    
    new_content = loc_content[:insert_pos] + new_translations + loc_content[insert_pos:]
    
    with open('lib/app_localizations.dart', 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"✅ {min(100, len(missing_translations))} çeviri eklendi!")
else:
    print("❌ Ekleme noktası bulunamadı!")
