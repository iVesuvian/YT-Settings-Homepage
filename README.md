# YTSettingsButton 🎛️

Tweak per **YouTube iOS** che aggiunge un'icona ⚙️ **Impostazioni** nella navigation bar della homepage.

> **Nessun jailbreak richiesto** — il tweak viene iniettato direttamente nell'IPA tramite GitHub Actions e installato con TrollStore, Sideloadly o AltStore.

---

## 📂 Struttura del progetto

```
YTSettingsButton/
├── Tweak.x                          ← Codice tweak (Logos / Objective-C)
├── Makefile                         ← Configurazione Theos
├── control                          ← Metadati pacchetto
├── README.md
└── .github/
    └── workflows/
        └── build.yml                ← Pipeline CI/CD completa
```

---

## ⚙️ Come funziona la pipeline

```
GitHub Actions (macOS)
│
├── 1. Checkout sorgenti
├── 2. Installa Theos + iOS SDK
├── 3. Compila Tweak.x → YTSettingsButton.dylib
├── 4. Scarica IPA di YouTube (da Release o Secret)
├── 5. Estrae il .app bundle
├── 6. Copia la dylib in .app/Frameworks/
├── 7. Inietta il load command (insert_dylib / optool)
├── 8. Rimuove la firma originale
├── 9. Ricrea lo .ipa patchato
└── 10. Pubblica su GitHub Releases
```

---

## 🚀 Setup

### Prerequisito: ottenere l'IPA di YouTube

Hai bisogno di un IPA **decryptato** di YouTube (il file originale dell'App Store è cifrato).

Modi per ottenerlo:
- **[AppDB.to](https://appdb.to)** — scarica direttamente IPA decryptati
- **[Decrypt.day](https://decrypt.day)** — archivio per versione
- iPhone jailbroken con **Sideloadly** — esporta l'IPA decryptato

### Metodo A — IPA tramite GitHub Release (consigliato)

1. Vai su **Releases → Create a new release**, tag: `ipa-source`
2. Allega il file `YouTube_XX.X.X.ipa` come asset e pubblica
3. Avvia la pipeline: **Actions → Build & Inject YTSettingsButton → Run workflow**

### Metodo B — IPA tramite Secret (link diretto)

1. Ottieni un link diretto al file `.ipa` pubblicamente accessibile
2. **Settings → Secrets → Actions → New secret**: nome `IPA_URL`, valore = link
3. La pipeline scaricherà automaticamente l'IPA

---

## 📲 Installazione dell'IPA patchato

Scarica l'IPA dalla sezione **Releases** o dalla tab **Actions → Artifacts**.

| Metodo | Requisiti | Note |
|---|---|---|
| **TrollStore** ⭐ | iOS 14–17 (A12+) | Permanente, nessun limite 7 giorni |
| **Sideloadly** | Qualsiasi iOS + PC/Mac | Ri-firma ogni 7 giorni |
| **AltStore / Feather** | Qualsiasi iOS + PC/Mac | Come Sideloadly |

---

## 🔨 Compilazione locale (opzionale)

```bash
export THEOS=/opt/theos
cd YTSettingsButton
make package FINALPACKAGE=1
```

Iniezione manuale:
```bash
unzip YouTube.ipa -d extracted
cp YTSettingsButton.dylib extracted/Payload/YouTube.app/Frameworks/
insert_dylib --strip-codesig --inplace \
  @executable_path/Frameworks/YTSettingsButton.dylib \
  extracted/Payload/YouTube.app/YouTube
cd extracted && zip -r ../YouTube_patched.ipa Payload/
```

---

## 📄 Licenza

MIT License
