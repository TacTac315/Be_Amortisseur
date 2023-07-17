% ####################Partie 1##########################################
%Constantes
Ms= 1120/4;
Mu=45;
Ks = 20000;
Kt=150000;
Cs=1000;
Ct=0.0;
 %Représentation d'état
 A=[0 1 0 -1
    -Ks/Ms -Cs/Ms 0 Cs/Ms
    0 0 0 1
    Ks/Mu Cs/Mu -Kt/Mu -(Cs+Ct)/Mu];

B=[0
   1/Ms
   0
   -1/Mu];

Cst=[0 1 0 0];
Cut=[0 0 0 1];

D=0;
E=[0
   0
   -1
   Ct/Mu];

%Fonction de transfert
%%Caisse Zs/Zr
Sys_Caisse = ss(A,E,Cst,D);
Tf_Caisse = tf(Sys_Caisse);

%%Roue Zu/Zr
Sys_Roue=ss(A,E,Cut,D);
Tf_Roue=tf(Sys_Roue);   


%Echellons
stepplot(0.08*Tf_Caisse);
hold on
stepplot(0.08*Tf_Roue);
legend('Caisse', 'Roue');
title('Réponse à un échellon 0.08m en BO');
xlabel('Temps');
ylabel('Amplitude (m)');
grid;
% #########################Mise en place de la commande LQR###############
%Faible déplacement de la roue par rapport à la caisse
    %->Variable x1
%Confort des passages : vitesse absolue de la roue par rapport à la caisse
    %->Variable x2
%Tenue de route : La roue doit rester en contact avec le sol
    %->Variable x3
%Aucun critère sur x4
Q=[4*10^8 0 0 0;
    0 10^6 0 0;
    0 0 225*10^10 0
    0 0 0 0];
R=1;
[G,K,lambda]=lqr(A,B,Q,R,0);

Abf=A-B*G; %Matrice du retour d'état en BF

%Ft de la caisse : 
Sys_Caisse_LQR=ss(Abf,E,Cst,D);
Sys_Roue_LQR=ss(Abf,E,Cut,D);

%Commande
C=-G;
Sys_Commande=ss(Abf,E,C,D);

%Echellons pour la Caisse
figure
stepplot(0.08*Sys_Caisse_LQR);
hold on
stepplot(0.08*Tf_Caisse);
legend('Caisse LQR','Caisse BO');
title('Réponse à un échellon 0.08m, avec Q donné');
grid;

%Echellon pour la Commande
figure
stepplot(0.08*Sys_Commande)
legend('Commande');
title('Réponse à un échellon 0.08m, LQR, Q donné');
grid;
%###############En modifiant Q#####################################
%####Ferme->Faible déplacement de la roue par rapport à la caisse
Q_ferme=[50*4*10^8 0 0 0;
    0 10^6 0 0;
    0 0 225*10^10 0
    0 0 0 0];
R=1;
[G_ferme,K,lambda_2]=lqr(A,B,Q_ferme,R,0);

Abf_ferme=A-B*G_ferme; %Matrice du retour d'état en BF

%Ft de la caisse : 
Sys_Caisse_LQR_ferme=ss(Abf_ferme,E,Cst,D);
Sys_Roue_LQR_ferme=ss(Abf_ferme,E,Cut,D);

%Commande
C=-G;
Sys_Commande_ferme=ss(Abf_ferme,E,C,D);

%Echellons pour la Caisse
% figure
% hold on
% stepplot(0.08*Sys_Caisse_LQR);
% stepplot(0.08*Sys_Caisse_LQR_ferme);
% legend('Caisse Q origine','Caisse Q ferme');
% title('Réponse à un échellon 0.08m, Q ferme');
% xlabel('Temps (ms)');
% grid;

%####Ajout de confort et diminution de x3
Q_tuned=[10*4*10^8 0 0 0;
    0 120*10^6 0 0;
    0 0 0.7*225*10^10 0
    0 0 0 0];
R=1;
[G_tuned,K,lambda_3]=lqr(A,B,Q_tuned,R,0);

Abf_tuned=A-B*G_tuned; %Matrice du retour d'état en BF

%Ft de la caisse : 
Sys_Caisse_LQR_tuned=ss(Abf_tuned,E,Cst,D);
Sys_Roue_LQR_tuned=ss(Abf_tuned,E,Cut,D);

%Commande
C=-G;
Sys_Commande_ferme=ss(Abf_tuned,E,C,D);

%Echellons pour la Caisse
figure
hold on
stepplot(0.08*Sys_Caisse_LQR);
stepplot(0.08*Sys_Caisse_LQR_ferme);
stepplot(0.08*Sys_Caisse_LQR_tuned);
legend('Caisse Q origine','Caisse Q ferme', 'Caisse Q optimal');
title('Réponse à un échellon 0.08m, comparaison');
xlabel('Temps');
ylabel('Amplitude (m)');
grid;

%Echellons pour la roue
figure
hold on
stepplot(0.08*Sys_Roue_LQR);
stepplot(0.08*Sys_Roue_LQR_ferme);
stepplot(0.08*Sys_Roue_LQR_tuned);
legend('Roue Q origine','Roue Q ferme', 'Roue Q optimal');
title('Réponse à un échellon 0.08m, comparaison');
xlabel('Temps');
ylabel('Amplitude (m)');
grid;

%#########################Comparaison origine LQR optimal ###############

figure 
hold on
stepplot(0.08*Sys_Caisse_LQR_tuned);
stepplot(0.08*Sys_Roue_LQR_tuned);
stepplot(0.08*Tf_Caisse);
stepplot(0.08*Tf_Roue);
legend('Caisse LQR','Roue LQR','Caisse BO','Roue BO');
title('Echellon 0.08m en BO et avec LQR optimal');
xlabel('Temps');
ylabel('Amplitude (m)');
% ########################Placement de pôles ############################
%Nous récupérons les TF de roue et caisse obtenue via LQR
p=[-11.4248+59.9577i,-11.4248-59.9577i,-500+0i,-200+0i];
Kpp=place(Sys_Caisse.A,Sys_Caisse.B,p);
Ap=A-B*Kpp;
Sys_Caisse_PP=ss(Ap,E,Cst,D);
figure 
hold on
stepplot(0.08*Sys_Caisse_PP);
stepplot(0.08*Sys_Caisse);
legend('Caisse placement de poles','Caisse BO');
title('Echellon 0.08m en BO et avec placement de pôles');
xlabel('Temps');
ylabel('Amplitude (m)');
