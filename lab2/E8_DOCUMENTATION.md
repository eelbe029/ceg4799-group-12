# E8 — Propriétés vérifiables et corpus légué

## Hypothèses violées, écrites comme propriétés explicites

Voir `ada/src/properties.ads` pour les trois propriétés formalisées
en Ada (fonctions booléennes réutilisables comme préconditions),
prêtes à devenir des contrats SPARK aux laboratoires 3-5 :

1. **Domaine de longueur admissible** (`Length_In_Domain`) —
   l'hypothèse implicite de stack.c ("l'entrée tient dans buffer[12]")
   devient une précondition vérifiable : `Input_Length <= 12`.
2. **Borne d'index** (`Index_In_Bounds`) — tout accès au tampon doit
   cibler un indice dans `1 .. 12`.
3. **Invariant du tampon** (`Buffer_Invariant`) — après toute copie,
   le nombre d'octets écrits ne doit jamais dépasser la capacité
   déclarée du tampon.

Ces propriétés sont démontrées en pratique dans `ada/src/safe_bof.adb`,
qui rejoue l'entrée malveillante de E3/E5 et lève `Constraint_Error`
plutôt que de corrompre la mémoire (voir E7).

## Corpus d'entrées mémoire dangereuses (8 entrées, dossier `corpus/`)

| # | Fichier | Taille | Catégorie | Propriété violée |
|---|---------|--------|-----------|-------------------|
| 1 | 01_overflow_local_setuid.bin | 517 o | Débordement (E3/T3) | Domaine de longueur + intégrité adresse de retour |
| 2 | 02_overflow_remote_server.bin | 517 o | Débordement distant (E9/T8) | Idem #1, via réseau |
| 3 | 03_retlibc_local_setuid.bin | 300 o | Return-to-libc (E5/T5) | Intégrité adresse de retour (contournement pile non-exécutable) |
| 4 | 04_boundary_exact_safe.bin | 12 o | Cas limite sûr | Limite non stricte du domaine de longueur |
| 5 | 05_boundary_plus1_overflow.bin | 13 o | Débordement minimal | Violation d'un seul octet du domaine de longueur |
| 6 | 06_empty_input.bin | 0 o | Cas limite (borne basse) | Borne d'index en entrée dégénérée |
| 7 | 07_overflow_max_e3_pattern.bin | 517 o | Débordement maximal | Magnitude maximale du domaine de longueur |
| 8 | 08_partial_retaddr_corruption.bin | 18 o | Corruption partielle | Invariant du tampon à un état intermédiaire |

Description complète de chaque entrée : voir `corpus/README_INDEX.txt`.

Ce corpus est légué au projet final (laboratoire 5) : il sera rejoué
par le banc d'essai du moniteur et les propriétés ci-dessus seront
réécrites en contrats SPARK vérifiables au laboratoire 3.
