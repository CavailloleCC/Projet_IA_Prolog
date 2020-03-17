%mettre les personnages dans des scénarios et garder les rôles et appartenances dans ce fichier
%création de personnages : personnage(X,Y,role = {killer K, cible C, rien R},appartenance = {joueur J, ordinateur O, nul N})

:-dynamic personnage/5.

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


case(X,Y):- integer(X),integer(Y),X >= 1, X =< 4, Y >= 1, Y =< 4.
etatCase(case(X,Y),LP):- findall(personnage(P,X,Y,R,A), personnage(P,X,Y,R,A), LP). %Récupération de la liste des personnages dans la case(X,Y)

deplacer(P,X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).

%ligne test : deplacer(personnage(P,_,_,R,A),X,Y):- case(X,Y), retract(personnage(P,_,_,R,A)), assert(personnage(P,X,Y,R,A)).

%Personnages voisins : P a pour voisin...
voisinGauche(P,LP):-personnage(P,X,Y,_,_),X>=2,X1 is X-1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinDroit(P,LP):-personnage(P,X,Y,_,_),X=<4,X1 is X+1,findall(personnage(P1,X1,Y,R1,A1),personnage(P1,X1,Y,R1,A1),LP).
voisinHaut(P,LP):-personnage(P,X,Y,_,_),Y>=2,Y1 is Y-1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).
voisinBas(P,LP):-personnage(P,X,Y,_,_),Y=<4,Y1 is Y+1,findall(personnage(P1,X,Y1,R1,A1),personnage(P1,X,Y1,R1,A1),LP).

%Personnages susceptibles de tuer P : P1 peut tuer P2 ? ou P1 peut tuer ...
    %tuer par couteau
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),personnage(P2,X,Y,_,_). 
    
    %tuer par sniper
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),caseSniper(X,Y), personnage(P2,X,_,_,_),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),caseSniper(X,Y), personnage(P2,_,Y,_,_),etatCase(case(X,Y),L),length(L,1).
    
    %tuer par pistolet
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinGauche(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinDroit(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinHaut(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1). 
    peutTuer(P1,P2):-personnage(P1,X,Y,_,_),voisinBas(P1,LP),member(personnage(P2,_,_,_,_),LP),etatCase(case(X,Y),L),length(L,1).

%Récupération de la liste des suspects qui peuvent tuer P. LS = liste suspects
estSuspect(LS,P):-peutTuer(P1,P),findall(personnage(P1,X,Y,R,A), personnage(P,X,Y,R,A), LS).

%P1 tue P si il existe au moins 2 autres suspects que P1 (pour pas se faire démasquer)
%tuer(P1,P):- estSuspect(LP,P),length(LP,N),N>=2.

%attention : quand on fait estSuspect OU peutTuer parfois ça revient plusieurs fois : car exemple, p13 peut tuer p5 avec un sniper MAIS AUSSI avec le pistolet (or quand avec le prédicat tuer, on veut compter les nombres de suspects, il ne faudrait pas que ce soit les memes)
%Pour mieux comprendre mon commentaire précédent, tester sur prolog ceci : "estSuspect(LP,p5)" il y a plusieurs fois le 13 donc il serait peut-être compter 2 fois dans les suspects!!!!
