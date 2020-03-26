%mettre les personnages dans des scénarios et garder les rôles et appartenances dans ce fichier
%création de personnages : personnage(X,Y,role = {killer K, cible C, rien R},appartenance = {joueur J, ordinateur O, nul N})

:-dynamic personnage/5.
:-dynamic suspects/1.

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

%Liste des personnages appartenant au joueur
personnagesJoueur(LP):-findall(personnage(P,X,Y,R,j),personnage(P,X,Y,R,j),LP).

%Liste des personnages appartenant au joueur virtuel (ordinateur)
personnagesOrdinateur(LP):-findall(personnage(P,X,Y,R,o),personnage(P,X,Y,R,o),LP).

%Liste des personnages dans la case(X,Y)
case(X,Y):- integer(X),integer(Y),X >= 1, X =< 4, Y >= 1, Y =< 4.
etatCase(case(X,Y),LP):- findall(personnage(P,X,Y,R,A), personnage(P,X,Y,R,A), LP). 

%%Déplacer un personnage
deplacer(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).
%Déplacer un personnage appartenant à un joueur
deplacerJoueur(P,X,Y):-personnage(P,_,_,_,j),deplacer(P,X,Y).
%Déplacer un personnage appartenant à un joueur virtuel (ordinateur)
deplacerOrdinateur(P,X,Y):-personnage(P,_,_,_,o),deplacer(P,X,Y).

%ligne test : deplacer(personnage(P,_,_,R,A),X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).

%Personnages voisins : P a pour voisin...
voisinGauche(P,LP):-personnage(P,X,Y,_,_),X>=2,X1 is X-1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinDroit(P,LP):-personnage(P,X,Y,_,_),X=<4,X1 is X+1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinHaut(P,LP):-personnage(P,X,Y,_,_),Y>=2,Y1 is Y-1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).
voisinBas(P,LP):-personnage(P,X,Y,_,_),Y=<4,Y1 is Y+1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).

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
tuer(P1,P2):-personnage(P1,_,_,k,j),peutTuer(P1,P2),retract(personnage(P2,_,_,_,_)).

%Stratégie ordinateur : P1 tue P2 si il existe au moins 1 autre suspect que P1 (pour pas se faire démasquer)
tuerOrdi(P1,P2):-personnage(P1,_,_,k,o),personnage(P2,_,_,_,A),A\=o,peutTuer(P1,P2),estSuspect(LS,P2),length(LS,N),N>=1,retract(personnage(P2,_,_,_,A)).

%Mise à jour de la liste des suspects : au premier meurtre tous les suspects dans la liste puis suspects en commun avec les meurtres précédents
modifierSuspects(P):-listSuspect(LS,P),suspects([]),retract(suspects([])),assert(suspects(LS)).
modifierSuspects(P):-listSuspect(LS,P),suspects(L),length(L,N),N>=1,intersection(L,LS,LF),retract(suspects(L)),assert(suspects(LF)).

%Tueur adverse trouvé
tueurAdverse(P):-suspects(L),length(L,1),member(P,L).

%Affichages

clear:-write('\e[2J]').

afficheCase(case(X,Y)):-etatCase(case(X,Y),LP), write(case(X,Y)), write(' : '), write(LP).
