%mettre les personnages dans des scénarios et garder les rôles et appartenances dans ce fichier
%création de personnages : personnage(X,Y,role = {killer K, cible C, rien R},appartenance = {joueur J, ordinateur O, nul N})

:-dynamic personnage/5.
:-dynamic suspects/1.
:-dynamic scoreJoueur/1.
:-dynamic scoreOrdi/1.
:-dynamic gagnant/1.
:-dynamic tour/1.

personnage(p1,1,1,r,n).
personnage(p2,1,2,r,n).
personnage(p3,1,3,k,o).
personnage(p4,2,4,c,j).
personnage(p5,3,1,r,n).
personnage(p6,2,3,c,j).
personnage(p7,2,1,r,n).
personnage(p8,4,3,r,n).
personnage(p9,3,2,c,j).
personnage(p10,2,1,k,j).
personnage(p11,1,3,c,o).
personnage(p12,3,4,r,n).
personnage(p13,4,1,r,n).
personnage(p14,3,1,c,o).
personnage(p15,1,1,c,o).
personnage(p16,2,1,r,n).

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
%Personnage aléatoire
personnageAleatoire(P):-listPersonnages(LP),random_member(P,LP).

%Position aléatoire
positionAleatoire(X,Y):-random_member(X,[1,2,3,4]),random_member(Y,[1,2,3,4]).

%Liste des personnages appartenant au joueur
personnagesJoueur(LP):-findall(personnage(P,X,Y,R,j),personnage(P,X,Y,R,j),LP).

%Liste des personnages appartenant au joueur virtuel (ordinateur)
personnagesOrdinateur(LP):-findall(personnage(P,X,Y,R,o),personnage(P,X,Y,R,o),LP).

case(X,Y):- integer(X),integer(Y),X >= 1, X =< 4, Y >= 1, Y =< 4.
etatCase(case(X,Y),LP):- findall(personnage(P,X,Y,R,A), personnage(P,X,Y,R,A), LP). %Récupération de la liste des personnages dans la case(X,Y)

%%Déplacer un personnage
deplacer(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).

%Déplacer un personnage au hasard
deplacerOrdi(P):-listPersonnages(LP),random_member(personnage(P,_,_,_,_),LP),random_member(X,[1,2,3,4]),,random_member(Y,[1,2,3,4]),deplacer(P,X,Y).
deplacerOrdi(P):-listPersonnages(LP),random_member(personnage(P,X,_,_,_),LP),L is [1,2,3,4], delete(L1,X,L2),random_member(X1,L1),,random_member(Y,[1,2,3,4]),deplacer(P,X1,Y).


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
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,R,A),peutTuer(P1,P2),retract(personnage(P2,_,_,R,A)),R=c,A=j,scoreJoueur(S),S1 is S+1,retract(scoreJoueur(S)),assert(scoreJoueur(S1)).
tuer(P1,P2):-personnage(P1,_,_,k,j),personnage(P2,_,_,R,A),peutTuer(P1,P2),retract(personnage(P2,_,_,R,A)),R=k,A=o,scoreJoueur(S),S1 is S+3,retract(scoreJoueur(S)),assert(scoreJoueur(S1)),retract(gagnant(null)),assert(gagnant(joueur)).
tuer(P1,P2):-personnage(P1,_,_,R,j),personnage(P2,_,_,_,_),R\=k,write('Veuillez utiliser votre killer pour tuer.').


%Stratégie ordinateur : P1 tue P2 si il existe au moins 1 autre suspect que P1 (pour pas se faire démasquer)
tuerOrdi(P1,P2):-personnage(P1,_,_,k,o),personnage(P2,_,_,_,A),A\=o,peutTuer(P1,P2),estSuspect(LS,P2),length(LS,N),N>=1,retract(personnage(P2,_,_,_,A)),scoreOrdi(S),S1 is S+3, retract(scoreOrdi(S)), assert(scoreOrdi(S1)),retract(gagnant(null)),assert(gagnant(ordi)).

%Mise à jour de la liste des suspects : au premier meurtre tous les suspects dans la liste puis suspects en commun avec les meurtres précédents
modifierSuspects(P):-listSuspect(LS,P),suspects([]),retract(suspects([])),assert(suspects(LS)).
modifierSuspects(P):-listSuspect(LS,P),suspects(L),length(L,N),N>=1,intersection(L,LS,LF),retract(suspects(L)),assert(suspects(LF)).

%Tueur adverse trouvé
tueurAdverse(P):-suspects(L),length(L,1),member(P,L).

%Vérifier si la partie est terminée
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('La partie est terminée.Vous avez gagné !').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('La partie est terminée.L adversaire a gagné !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ>SO,write('La partie est terminée.Vous avez gagné !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ<SO,write('La partie est terminée.L adversaire a gagné !').
verifierFin:-gagnant(joueur),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('La partie est terminée.Vous êtes à égalité !').
verifierFin:-gagnant(ordi),scoreJoueur(SJ),scoreOrdi(SO),SJ=SO,write('La partie est terminée.Vous êtes à égalité !').

%Changement de tour
changerTour:-tour(joueur),retract(tour(joueur)),assert(tour(ordi)).
changerTour:-tour(ordi),retract(tour(ordi)),assert(tour(joueur)).



%Prédicat test
modifierScore(scoreOrdi(X)):-retract(scoreOrdi(X)),Y is X+3,assert(scoreOrdi(Y)).

%Affichages

clear:-write('\e[2J]').

afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), write(case(X,Y)), write(' : '), write(LP).
