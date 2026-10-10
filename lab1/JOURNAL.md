# Journal d'equipe - CEG4799/CSI4539 Laboratoire 1

## Equipe
- El Hadj El Bechir (eelbe029)
- Souheib Al-ahdal

## Jalon J1 (exigences, roles, echeancier)
- Programme etudie : catall.c (SEED Environment Variable and Set-UID Program Lab), wrapper Set-UID root autour de /bin/cat.
- Repartition des roles :
  - El Hadj El Bechir : E1-E3 (controle d'acces Linux), E4-E5 (modele de privilege et surfaces d'entree), E6a (injection de commande).
  - Souheib Al-ahdal : E6b (detournement par variable d'environnement), E7 (invocation sure), E8 (abandon de privilege), E9 (proprietes et corpus).
- Echeancier : E1-E6a le 27 septembre, E6b-E9 le 28 septembre, demonstration le 29 septembre, rapport final le 2 octobre.
- Note : le jalon J1 aurait du etre valide le 22 septembre; il est documente ici le 28 septembre en raison d'un retard de l'equipe.

## Seance du 27 septembre (El Hadj El Bechir)
- Mise en place de la VM SEED Ubuntu 20.04.
- E1-E3 : utilisateurs/groupes/permissions, ACL, capacites POSIX.
- E4 : identification du modele de privilege de catall.c via getresuid().
- E5 : analyse des trois surfaces d'entree (entrees utilisateur, PATH/IFS, liaison dynamique).
- E6a : injection de commande reproduite (scripts/e6a_command_injection.sh, traces/T4_command_injection.txt).

## Seance du 28 septembre (Souheib Al-ahdal)
- E6b : tentative initiale avec IFS seule -> echec. Decouverte que /bin/sh (dash) abandonne
  automatiquement le privilege Set-UID des qu'il detecte real UID != effective UID; ce
  comportement casse aussi LD_PRELOAD (voir T6). Contournement standard SEED applique :
  remplacement temporaire de /bin/sh par zsh le temps de l'attaque, puis restauration
  immediate de dash. Detournement par PATH reussi avec privilege root confirme
  (scripts/e6b_env_injection.sh, traces/T5_environnement.txt).
- E7 : remplacement de system() par execve() avec chemin absolu et environnement
  reconstruit (PATH/IFS fixes, liste blanche). Trace T7 : les entrees E6a/E6b sont inertes.
- E8 : abandon definitif du privilege avec setresuid() avant toute autre operation;
  verification que la reelevation echoue (T8).
- E9 : hypotheses de securite ecrites comme assertions dans catall_fixed.c (P1-P4);
  corpus de 9 entrees dangereuses documentees et rejouees (corpus/, traces/E9_corpus_replay.txt).

## Decisions et desaccords
- Aucun desaccord majeur. Division du travail par moitie du laboratoire (E1-E6a / E6b-E9)
  en raison de contraintes d'horaire du 27 septembre (un membre hors de la ville).

## Outils d'IA generative
- Claude (Anthropic) utilise pour expliquer les concepts (privilege Set-UID, execve, IFS,
  comportement de dash) et pour aider a rediger/deboguer le code de E7-E9 et le corpus.
  Tout le code a ete revu, teste et peut etre explique par Souheib Al-ahdal et El Hadj El Bechir .
