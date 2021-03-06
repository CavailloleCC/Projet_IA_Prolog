%mettre les personnages dans des scénarios et garder les rôles et appartenances dans ce fichier
%création de personnages : personnage(X,Y,role = {killer K, cible C, rien R},appartenance = {joueur J, ordinateur O, nul N})

:-dynamic personnage/5.
:-dynamic suspects/1.
:-dynamic scoreJoueur/1.
:-dynamic scoreOrdi/1.
:-dynamic gagnant/1.
:-dynamic tour/1.
:-dynamic caseSniper/3.

personnage(a,_,_,r,n).
personnage(b,_,_,r,n).
personnage(c,_,_,k,o).
personnage(d,_,_,c,j).
personnage(e,_,_,r,n).
personnage(f,_,_,c,j).
personnage(g,_,_,r,n).
personnage(h,_,_,r,n).
personnage(i,_,_,c,j).
personnage(j,_,_,k,j).
personnage(k,_,_,c,o).
personnage(l,_,_,r,n).
personnage(m,_,_,r,n).
personnage(n,_,_,c,o).
personnage(o,_,_,c,o).
personnage(p,_,_,r,n).

caseSniper(s1,_,_).
caseSniper(s2,_,_).
caseSniper(s3,_,_).

role(r).
role(k).
role(c).

appartenance(j).
appartenance(c).
appartenance(n).

suspects([]).

scoreOrdi(0).
scoreJoueur(0).

gagnant(null).

tour(joueur).

%Liste de tous les personnages du jeu
listPersonnages(LP):-findall(personnage(P,X,Y,R,O),personnage(P,X,Y,R,O),LP).

%Liste des personnages appartenant au joueur
personnagesJoueur(LP):-findall(personnage(P,X,Y,R,j),personnage(P,X,Y,R,j),LP).

%Liste des personnages appartenant au joueur virtuel (ordinateur)
personnagesOrdinateur(LP):-findall(personnage(P,X,Y,R,o),personnage(P,X,Y,R,o),LP).

%Liste des personnages dans la case(X,Y)
case(X,Y):- integer(X),integer(Y),X >= 1, X =< 4, Y >= 1, Y =< 4.
etatCase(case(X,Y),LP):- findall(personnage(P,X,Y,R,A), personnage(P,X,Y,R,A), LP).

%Changement de tour
changerTour:-tour(joueur),retract(tour(joueur)),assert(tour(ordi)).
changerTour:-tour(ordi),retract(tour(ordi)),assert(tour(joueur)).

%%Déplacer un personnage
deplacer(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).

%Initialisation des caseSniper aléatoire
initialiserSniper:-random_member(X1,[1,2,3,4]),random_member(Y1,[1,2,3,4]),retract(caseSniper(s1,_,_)),assert(caseSniper(s1,X1,Y1)),delete([1,2,3,4],X1,L),random_member(X2,L),random_member(Y2,[1,2,3,4]),retract(caseSniper(s2,_,_)),assert(caseSniper(s2,X2,Y2)),delete(L,X2,L1),random_member(X3,L1),random_member(Y3,[1,2,3,4]),retract(caseSniper(s3,_,_)),assert(caseSniper(s3,X3,Y3)).

%Initialisation du placement des personnages aléatoire
initialiserPlacement(P):-random_member(X,[1,2,3,4]),random_member(Y,[1,2,3,4]),deplacer(P,X,Y).
initialiserPlateau:-initialiserPlacement(a),initialiserPlacement(b),initialiserPlacement(c),initialiserPlacement(d),initialiserPlacement(e),initialiserPlacement(f),initialiserPlacement(g),initialiserPlacement(h),initialiserPlacement(i),initialiserPlacement(j),initialiserPlacement(k),initialiserPlacement(l),initialiserPlacement(m),initialiserPlacement(n),initialiserPlacement(o),initialiserPlacement(p),initialiserSniper.

%Deplacer un personnage par le joueur
deplacerPersonnage(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)),affichePlateau,verifierFin.

%Déplacer un personnage au hasard (on change obligatoirement le personnage de ligne)
deplacerOrdi(P):-listPersonnages(LP),random_member(personnage(P,X,_,_,_),LP), delete([1,2,3,4],X,L),random_member(X1,L),random_member(Y,[1,2,3,4]),deplacer(P,X1,Y).


%Personnages voisins : P a pour voisin les personnages de la liste LP
voisinHaut(P,LP):-personnage(P,X,Y,_,_),X>=2,X1 is X-1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinBas(P,LP):-personnage(P,X,Y,_,_),X=<4,X1 is X+1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinGauche(P,LP):-personnage(P,X,Y,_,_),Y>=2,Y1 is Y-1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).
voisinDroit(P,LP):-personnage(P,X,Y,_,_),Y=<4,Y1 is Y+1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).

%Personnages susceptibles de tuer P2 : P1 peut tuer P2
    %tuer par couteau
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),personnage(P2,X,Y,_,_).

    %tuer par sniper
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),caseSniper(_,X,Y), personnage(P2,X,_,_,_),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),caseSniper(_,X,Y), personnage(P2,_,Y,_,_),etatCase(case(X,Y),L),length(L,1).

    %tuer par pistolet
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinGauche(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinDroit(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinHaut(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinBas(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).

%Stratégie ordinateur : seuls les personnages appartenant pas au joueur virtuel peuvent être suspects
estSuspect(P1,P2):-personnage(P1,_,_,_,A),A\=o,peutTuer(P1,P2).

%Récupération de la liste des suspects qui peuvent tuer P. LS = liste suspects
listSuspect(LS,P):-setof(P1, estSuspect(P1,P), LS).

%%Tuer un personnage
%Stratégie joueur : P1 tue P2 s'il vérifie les contraintes définies dans peutTuer
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,c,j),peutTuer(P1,P2),modifierSuspects(P2),retract(personnage(P2,_,_,_,_)),scoreJoueur(S),S1 is S+1,retract(scoreJoueur(S)),assert(scoreJoueur(S1)),affichePlateau,verifierFin.
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,k,o),peutTuer(P1,P2),modifierSuspects(P2),retract(personnage(P2,_,_,_,_)),scoreJoueur(S),S1 is S+3,retract(scoreJoueur(S)),assert(scoreJoueur(S1)),retract(gagnant(null)),assert(gagnant(joueur)),affichePlateau,verifierFin.
tuer(P1,P2):-personnage(P1,_,_,R,j),personnage(P2,_,_,_,_),R\=k,write('Veuillez utiliser votre killer pour tuer.'),actionJoueur.
tuer(P1,P2):-personnage(P1,_,_,_,A),personnage(P2,_,_,_,_),A\=j,write('Veuillez utiliser votre killer pour tuer.'),actionJoueur.
tuer(P1,P2):-personnage(P1,_,_,_,j),personnage(P2,_,_,_,_),peutTuer(P1,P2),modifierSuspects(P2),retract(personnage(P2,_,_,_,_)),affichePlateau,verifierFin.
tuer(P1,P2):-personnage(P1,_,_,_,j),personnage(P2,_,_,_,_),write('Votre killer doit etre seul dans sa case pour pouvoir tuer par sniper ou par pistolet.').

%Stratégie ordinateur : P1 tue P2 si il existe au moins 1 autre suspect que P1 (pour pas se faire démasquer)
tuerOrdi(P1,P2):-personnage(P1,_,_,k,o),personnage(P2,_,_,_,A),A\=o,peutTuer(P1,P2),tueurAdverse(P2),listSuspect(LS,P2),length(LS,N),N>=1,retract(personnage(P2,_,_,_,A)),scoreOrdi(S),S1 is S+3, retract(scoreOrdi(S)), assert(scoreOrdi(S1)),retract(gagnant(null)),assert(gagnant(ordi)).

%Mise à jour de la liste des suspects : au premier meurtre tous les suspects dans la liste puis suspects en commun avec les meurtres précédents
modifierSuspects(P):-listSuspect(LS,P),suspects([]),retract(suspects([])),assert(suspects(LS)).
modifierSuspects(P):-listSuspect(LS,P),suspects(L),length(L,N),N>=1,intersection(L,LS,LF),retract(suspects(L)),assert(suspects(LF)).

%Determine si le tueur adverse P a été trouvé
tueurAdverse(P):-suspects(L),length(L,1),member(P,L).

%Action du joueur virtuel : tue si il a trouvé le tueur adverse et que son killer peut tuer
actionOrdi:-tuerOrdi(_,_),verifierFin.
actionOrdi:-deplacerOrdi(_),write('\n\nTour joueur virtuel : '),affichePlateau,verifierFin.

%Action du joueur : affichage des consignes pour action du joueur
actionJoueur:-write('\n\nA votre tour de jouer\nPour deplacer un personnage p sur la case (ligne,colonne) : deplacerPersonnage(p,ligne,colonne).\nPour tuer un personnage p2 avec votre killer p1 : tuer(p1,p2).').


%Vérifier si la partie est terminée (le killer d'un des joueurs a été tué)
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nVous avez gagne !\n\nPour quitter entrez "quitter."').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nL adversaire a gagne !\n\nPour quitter entrez "quitter.').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nVous avez gagne !\n\nPour quitter entrez "quitter."').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nL adversaire a gagne !\n\nPour quitter entrez "quitter.').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nVous etes a egalite !\n\nPour quitter entrez "quitter.').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('\nLa partie est terminee.\nVotre score : '),write(SJ),write('\nScore adversaire : '),write(SO),write('\nVous etes a egalite !\n\nPour quitter entrez "quitter.').
verifierFin:-tour(joueur),changerTour,actionOrdi.
verifierFin:-tour(ordi),changerTour,actionJoueur.


%Affichages

clear:-write('\e[2J]').

afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=0, write('                ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=1, nth0(0,LP,personnage(P0,_,_,_,_)), write(P0),write('               ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=2, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),write(P0),write(P1),write('              ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=3, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)), write(P0),write(P1),write(P2),write('             ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=4, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write('            ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=5, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write('           ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=6, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write('          ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=7, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write('         ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=8, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write('        ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=9, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write('       ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=10, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write('      ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=11, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write('     ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=12, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)),nth0(11,LP,personnage(P11,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write(P11),write('    ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=13, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)),nth0(11,LP,personnage(P11,_,_,_,_)),nth0(12,LP,personnage(P12,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write(P11),write(P12),write('   ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=14, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)),nth0(11,LP,personnage(P11,_,_,_,_)),nth0(12,LP,personnage(P12,_,_,_,_)),nth0(13,LP,personnage(P13,_,_,_,_)), write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write(P11),write(P12),write(P13),write('  ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=15, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)),nth0(11,LP,personnage(P11,_,_,_,_)),nth0(12,LP,personnage(P12,_,_,_,_)),nth0(13,LP,personnage(P13,_,_,_,_)),nth0(14,LP,personnage(P14,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write(P11),write(P12),write(P13),write(P14),write(' ').
afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), length(LP,N),N=16, nth0(0,LP,personnage(P0,_,_,_,_)),nth0(1,LP,personnage(P1,_,_,_,_)),nth0(2,LP,personnage(P2,_,_,_,_)),nth0(3,LP,personnage(P3,_,_,_,_)),nth0(4,LP,personnage(P4,_,_,_,_)),nth0(5,LP,personnage(P5,_,_,_,_)),nth0(6,LP,personnage(P6,_,_,_,_)),nth0(7,LP,personnage(P7,_,_,_,_)),nth0(8,LP,personnage(P8,_,_,_,_)),nth0(9,LP,personnage(P9,_,_,_,_)),nth0(10,LP,personnage(P10,_,_,_,_)),nth0(11,LP,personnage(P11,_,_,_,_)),nth0(12,LP,personnage(P12,_,_,_,_)),nth0(13,LP,personnage(P13,_,_,_,_)),nth0(14,LP,personnage(P14,_,_,_,_)),nth0(15,LP,personnage(P15,_,_,_,_)),write(P0),write(P1),write(P2),write(P3),write(P4),write(P5),write(P6),write(P7),write(P8),write(P9),write(P10),write(P11),write(P12),write(P13),write(P14),write(P15).

afficheLigne:-write('\n   ________________ ________________ ________________ ________________ \n').

afficheNumeroColonnes:-write('\n          1                2                3                4         ').

afficheLigne1:-afficheNumeroColonnes,afficheLigne,write('1 |'),afficheCase(case(1,1)),write('|'),afficheCase(case(1,2)),write('|'),afficheCase(case(1,3)),write('|'),afficheCase(case(1,4)),write('|').
afficheLigne2:-afficheLigne,write('2 |'),afficheCase(case(2,1)),write('|'),afficheCase(case(2,2)),write('|'),afficheCase(case(2,3)),write('|'),afficheCase(case(2,4)),write('|').
afficheLigne3:-afficheLigne,write('3 |'),afficheCase(case(3,1)),write('|'),afficheCase(case(3,2)),write('|'),afficheCase(case(3,3)),write('|'),afficheCase(case(3,4)),write('|').
afficheLigne4:-afficheLigne,write('4 |'),afficheCase(case(4,1)),write('|'),afficheCase(case(4,2)),write('|'),afficheCase(case(4,3)),write('|'),afficheCase(case(4,4)),write('|'),afficheLigne.

affichePersonnages:-personnage(PK,_,_,k,j),findall(personnage(PC,_,_,c,j),personnage(PC,_,_,c,j),LC),nth0(0,LC,personnage(P0,_,_,c,j)),nth0(1,LC,personnage(P1,_,_,c,j)),nth0(2,LC,personnage(P2,_,_,c,j)),caseSniper(s1,X1,Y1),caseSniper(s2,X2,Y2),caseSniper(s3,X3,Y3),write('\n\nLes cases Sniper sont : '),write(caseSniper(s1,X1,Y1)),write(', '),write(caseSniper(s2,X2,Y2)),write(', '),write(caseSniper(s3,X3,Y3)),write('\nVotre killer est : '),write(PK),write('\nVos cibles sont : '),write(P0),write(', '),write(P1),write(', '),write(P2).
affichePersonnages:-personnage(PK,_,_,k,j),findall(personnage(PC,_,_,c,j),personnage(PC,_,_,c,j),LC),nth0(0,LC,personnage(P0,_,_,c,j)),nth0(1,LC,personnage(P1,_,_,c,j)),caseSniper(s1,X1,Y1),caseSniper(s2,X2,Y2),caseSniper(s3,X3,Y3),write('\n\nLes cases Sniper sont : '),write(caseSniper(s1,X1,Y1)),write(', '),write(caseSniper(s2,X2,Y2)),write(', '),write(caseSniper(s3,X3,Y3)),write('\nVotre killer est : '),write(PK),write('\nVos cibles sont : '),write(P0),write(', '),write(P1).
affichePersonnages:-personnage(PK,_,_,k,j),findall(personnage(PC,_,_,c,j),personnage(PC,_,_,c,j),LC),nth0(0,LC,personnage(P0,_,_,c,j)),caseSniper(s1,X1,Y1),caseSniper(s2,X2,Y2),caseSniper(s3,X3,Y3),write('\n\nLes cases Sniper sont : '),write(caseSniper(s1,X1,Y1)),write(', '),write(caseSniper(s2,X2,Y2)),write(', '),write(caseSniper(s3,X3,Y3)),write('\nVotre killer est : '),write(PK),write('\nVos cibles sont : '),write(P0).
affichePersonnages:-personnage(PK,_,_,k,j),caseSniper(s1,X1,Y1),caseSniper(s2,X2,Y2),caseSniper(s3,X3,Y3),write('\n\nLes cases Sniper sont : '),write(caseSniper(s1,X1,Y1)),write(', '),write(caseSniper(s2,X2,Y2)),write(', '),write(caseSniper(s3,X3,Y3)),write('\nVotre killer est : '),write(PK).

afficheRegles:-write('\nRegles du jeu :\nA chaque tour vous pouvez, soit deplacer un des personnages du plateau sur une case de votre choix, soit tuer un personnage du plateau grace a votre killer.\nPour tuer un personnage vous avez trois possibilites :\n- tuer par couteau si votre killer se trouve dans la meme case que sa vistime\n- tuer par pistolet si votre killer est seul dans une case adjacente a celle de sa victime\n- tuer par sniper si votre killer est seul sur une case dite "sniper" et que sa victime est presente sur une des cases en ligne droite par rapport a la sienne\n\n').

commencer:-afficheRegles, initialiserPlateau,afficheLigne1,afficheLigne2,afficheLigne3,afficheLigne4, affichePersonnages,actionJoueur.

affichePlateau:-afficheLigne1,afficheLigne2,afficheLigne3,afficheLigne4,affichePersonnages.

quitter :- halt.
