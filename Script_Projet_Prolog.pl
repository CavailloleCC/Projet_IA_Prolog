%mettre les personnages dans des scénarios et garder les rôles et appartenances dans ce fichier
%création de personnages : personnage(X,Y,role = {killer K, cible C, rien R},appartenance = {joueur J, ordinateur O, nul N})

:-dynamic personnage/5.
:-dynamic suspects/1.
:-dynamic scoreJoueur/1.
:-dynamic scoreOrdi/1.
:-dynamic gagnant/1.
:-dynamic tour/1.

personnage(a,1,1,r,n).
personnage(b,1,2,r,n).
personnage(c,1,3,k,o).
personnage(d,2,4,c,j).
personnage(e,3,1,r,n).
personnage(f,2,3,c,j).
personnage(g,2,1,r,n).
personnage(h,4,3,r,n).
personnage(i,3,2,c,j).
personnage(j,2,1,k,j).
personnage(k,1,3,c,o).
personnage(l,3,4,r,n).
personnage(m,4,1,r,n).
personnage(n,3,1,c,o).
personnage(o,1,1,c,o).
personnage(p,2,1,r,n).

caseSniper(2,3).
caseSniper(1,2).
caseSniper(4,1).

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

%Deplacer un personnage par le joueur
deplacerPersonnage(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)),affichePlateau,verifierFin.

%Déplacer un personnage au hasard
deplacerOrdi(P):-listPersonnages(LP),random_member(personnage(P,_,_,_,_),LP),random_member(X,[1,2,3,4]),random_member(Y,[1,2,3,4]),deplacer(P,X,Y).
deplacerOrdi(P):-listPersonnages(LP),random_member(personnage(P,X,_,_,_),LP), delete([1,2,3,4],X,L),random_member(X1,L),random_member(Y,[1,2,3,4]),deplacer(P,X1,Y).


%Personnages voisins : P a pour voisin...
voisinHaut(P,LP):-personnage(P,X,Y,_,_),X>=2,X1 is X-1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinBas(P,LP):-personnage(P,X,Y,_,_),X=<4,X1 is X+1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinGauche(P,LP):-personnage(P,X,Y,_,_),Y>=2,Y1 is Y-1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).
voisinDroit(P,LP):-personnage(P,X,Y,_,_),Y=<4,Y1 is Y+1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).

%Personnages susceptibles de tuer P2 : P1 peut tuer P2
    %tuer par couteau
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),personnage(P2,X,Y,_,_).

    %tuer par sniper
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),caseSniper(X,Y), personnage(P2,X,_,_,_),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-P1 \= P2,personnage(P1,X,Y,_,_),caseSniper(X,Y), personnage(P2,_,Y,_,_),etatCase(case(X,Y),L),length(L,1).

    %tuer par pistolet
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinGauche(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinDroit(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinHaut(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinBas(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).

%Stratégie ordinateur : seuls les personnages appartenant pas au joueur virtuel peuvent être suspects
estSuspect(P1,P2):-A\=o,personnage(P1,_,_,_,A),peutTuer(P1,P2).

%Récupération de la liste des suspects qui peuvent tuer P. LS = liste suspects
listSuspect(LS,P):-setof(P1, estSuspect(P1,P), LS).

%%Tuer un personnage
%Stratégie joueur : tuer par un joueur
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,R,A),peutTuer(P1,P2),retract(personnage(P2,_,_,R,A)),R=c,A=j,scoreJoueur(S),S1 is S+1,retract(scoreJoueur(S)),assert(scoreJoueur(S1)),affichePlateau,verifierFin.
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,R,A),peutTuer(P1,P2),retract(personnage(P2,_,_,R,A)),R=k,A=o,scoreJoueur(S),S1 is S+3,retract(scoreJoueur(S)),assert(scoreJoueur(S1)),retract(gagnant(null)),assert(gagnant(joueur)),affichePlateau,verifierFin.
tuer(P1,P2):-personnage(P1,_,_,R,j),personnage(P2,_,_,_,_),R\=k,write('Veuillez utiliser votre killer pour tuer.'),actionJoueur.
tuer(P1,P2):-personnage(P1,_,_,_,A),personnage(P2,_,_,_,_),A\=j,write('Veuillez utiliser votre killer pour tuer.'),actionJoueur.

%Stratégie ordinateur : P1 tue P2 si il existe au moins 1 autre suspect que P1 (pour pas se faire démasquer)
tuerOrdi(P1,P2):-personnage(P1,_,_,k,o),personnage(P2,_,_,_,A),A\=o,peutTuer(P1,P2),tueurAdverse(P2),listSuspect(LS,P2),length(LS,N),N>=1,retract(personnage(P2,_,_,_,A)),scoreOrdi(S),S1 is S+3, retract(scoreOrdi(S)), assert(scoreOrdi(S1)),retract(gagnant(null)),assert(gagnant(ordi)).

%Mise à jour de la liste des suspects : au premier meurtre tous les suspects dans la liste puis suspects en commun avec les meurtres précédents
modifierSuspects(P):-listSuspect(LS,P),suspects([]),retract(suspects([])),assert(suspects(LS)).
modifierSuspects(P):-listSuspect(LS,P),suspects(L),length(L,N),N>=1,intersection(L,LS,LF),retract(suspects(L)),assert(suspects(LF)).

%Tueur adverse trouvé
tueurAdverse(P):-suspects(L),length(L,1),member(P,L).

%Action du joueur virtuel : tue si il a trouvé le tueur adverse et que son killer peut tuer
actionOrdi:-tuerOrdi(P1,P2),verifierFin.
actionOrdi:-deplacerOrdi(P),write('\n\nTour joueur virtuel : '),affichePlateau,verifierFin.

%Action du joueur : affichage des consignes pour action du joueur
actionJoueur:-write('\n\nA votre tour de jouer\nPour deplacer un personnage p sur la case (x,y) : deplacerPersonnage(p,x,y).\nPour tuer un personnage p2 avec votre killer p1 : tuer(p1,p2).').


%Vérifier si la partie est terminée
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('La partie est terminée.Vous avez gagné !').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('La partie est terminée.L adversaire a gagné !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('La partie est terminée.Vous avez gagné !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('La partie est terminée.L adversaire a gagné !').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('La partie est terminée.Vous êtes à égalité !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('La partie est terminée.Vous êtes à égalité !').
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

afficheLigne:-write('\n ________________ ________________ ________________ ________________ \n').

afficheLigne1:-afficheLigne,write('|'),afficheCase(case(1,1)),write('|'),afficheCase(case(1,2)),write('|'),afficheCase(case(1,3)),write('|'),afficheCase(case(1,4)),write('|').
afficheLigne2:-afficheLigne,write('|'),afficheCase(case(2,1)),write('|'),afficheCase(case(2,2)),write('|'),afficheCase(case(2,3)),write('|'),afficheCase(case(2,4)),write('|').
afficheLigne3:-afficheLigne,write('|'),afficheCase(case(3,1)),write('|'),afficheCase(case(3,2)),write('|'),afficheCase(case(3,3)),write('|'),afficheCase(case(3,4)),write('|').
afficheLigne4:-afficheLigne,write('|'),afficheCase(case(4,1)),write('|'),afficheCase(case(4,2)),write('|'),afficheCase(case(4,3)),write('|'),afficheCase(case(4,4)),write('|'),afficheLigne.

affichePersonnages:-personnage(PK,_,_,k,j),findall(personnage(PC,_,_,c,j),personnage(PC,_,_,c,j),LC),nth0(0,LC,personnage(P0,_,_,c,j)),nth0(1,LC,personnage(P1,_,_,c,j)),nth0(2,LC,personnage(P2,_,_,c,j)),write('\nVotre killer est : '),write(PK),write('\nVos cibles sont : '),write(P0),write(', '),write(P1),write(', '),write(P2).

afficheDebut:-afficheLigne1,afficheLigne2,afficheLigne3,afficheLigne4, affichePersonnages,actionJoueur.

affichePlateau:-afficheLigne1,afficheLigne2,afficheLigne3,afficheLigne4, affichePersonnages.
