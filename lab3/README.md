# Laboratoire 3 - Du C vulnerable au SPARK prouve

CEG 4799 / CSI 4539 - Automne 2026 - Groupe 12

## Structure

| Chemin | Contenu |
|---|---|
| `validator/validator.gpr` | Projet GPR (E1) |
| `validator/src/input_validator.ads` | Specification SPARK : sous-types, predicat, contrats (E1-E3) |
| `validator/src/input_validator.adb` | Corps SPARK du validateur (E1-E2) |
| `validator/tests/test_validator.adb` | Harnais d'essai, hors SPARK (`SPARK_Mode => Off`) |
| `traces/` | Sorties de gprbuild, GNATprove et du harnais |

Le dossier `validator/` est le validateur legue au projet final.

## Commandes (a partir de `lab3/validator`)

```bash
gprbuild -P validator.gpr -cargs -gnata
gnatprove -P validator.gpr --mode=flow --report=all
./bin/test_validator
```

## Code SPARK et code non-SPARK

- SPARK (`SPARK_Mode => On`) : paquet `Input_Validator`, specification et corps.
- Hors SPARK (`SPARK_Mode => Off`) : procedure `Test_Validator` (affichage avec
  `Ada.Text_IO`, gestion d'exceptions). Elle n'utilise le validateur que par
  l'interface du paquet.

## Hypotheses de validation ecrites comme contrats (E3)

| Hypothese | Contrat |
|---|---|
| Longueur bornee | `subtype Length_Type is Natural range 0 .. Max_Length` |
| Borne d'index | `subtype Buffer_Index is Positive range 1 .. Max_Length` |
| Tampon de taille fixe | `subtype Buffer_String is String (Buffer_Index)` |
| Jeu de caracteres admissible | `subtype Allowed_Char ... with Static_Predicate` |
| Forme de l'entree brute | `Pre => Input'First = 1 and then Input'Last <= Max_Raw_Length` |
| Entree invalide rejetee, entree acceptee dans le tampon | `Post` de `Validate` |
| Flux de donnees | `Global => null`, `Depends => (Buffer => Input, Length => Input, Status => Input)` |
