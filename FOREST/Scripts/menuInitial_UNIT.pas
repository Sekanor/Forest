﻿unit menuInitial_UNIT;

interface

	uses
	  fonctionsGlobales_UNIT,
	  moduleGestionEcran_UNIT,
	  initialisationVariables_UNIT,
	  sauvegarde_UNIT,
	  System.SysUtils;

	procedure menuInitial(var game: TGame; var civ: TCivilisation; var combat: TCombat);
	{RÔLE ET PRINCIPE : Cette procédure correspond à l'affichage du menu initial grace aux différentes procedures d'affichage}

implementation

procedure afficherDragon(color, pos: Integer);
{RÔLE ET PRINCIPE : procedure esthetique permettant l'affichage du logo dragon ASCII grace a la procedure ecrireAuCentre()}
begin
  couleurTexte(color);

  ecrireAuCentre(pos-3,  ' ,,                                 ');
  ecrireAuCentre(pos-2,  '	  `""*$b..	                                  ');
  ecrireAuCentre(pos-1,  '		     ""*$o.	                                  ');
  ecrireAuCentre(pos,    '		         "$$o.	                                  ');
  ecrireAuCentre(pos+1 , '		          "*$$o.                                 ');
  ecrireAuCentre(pos+2 , '		             "$$$o.                           ');
  ecrireAuCentre(pos+3 , '		        "$$$$bo...      ..o:                                  ');
  ecrireAuCentre(pos+4 , '		          "$$$$$$$$booocS$$$    ..    ,.                      ');
  ecrireAuCentre(pos+5 , '		       ".    "*$$$$SP     V$o..o$$. .$$$b                     ');
  ecrireAuCentre(pos+6 , '		        "$$o. .$$$$$o. ...A$$$$$$$$$$$$$$b                  ');
  ecrireAuCentre(pos+7 , '		  ""bo.   "*$$$$$$$$$$$$$$$$$$$$P*$$$$$$$$:                   ');
  ecrireAuCentre(pos+8 , ' 	     "$$.    V$$$$$$$$$P"**""*"   VP  * "l                    ');
  ecrireAuCentre(pos+9 , '		       "$$$o.4$$$$$$$$X                                       ');
  ecrireAuCentre(pos+10, '		        "*$$$$$$$$$$$$$AoA$o..oooooo..           .b           ');
  ecrireAuCentre(pos+11, '		               .X$$$$$$$$$$$P""     ""*oo,,     ,$P           ');
  ecrireAuCentre(pos+12, '		              $$P""V$$$$$$$:    .        ""*****"             ');
  ecrireAuCentre(pos+13, '		            .*"    A$$$$$$$$o.4;      .                       ');
  ecrireAuCentre(pos+14, '		                 .oP""   "$$$$$$b.  .$;                       ');
  ecrireAuCentre(pos+15, '		                          A$$$$$$$$$$P                        ');
  ecrireAuCentre(pos+16, '		                          "  "$$$$$P"                         ');

end;

procedure afficherTitre(color, Xpos,Ypos: Integer);
{RÔLE ET PRINCIPE : procedure esthetique permettant l'affichage du titre grace a la procedure ecrireEnPositionXY}
begin
  couleurTexte(color);

  ecrireEnPositionXY(Xpos,Ypos  , '____ ____ ____ ____ ____ ___');
  ecrireEnPositionXY(Xpos,Ypos+1, '|___ |  | |__/ |___ [__   | ');
  ecrireEnPositionXY(Xpos,Ypos+2, '|    |__| |  \ |___ ___]  |');


end;

procedure afficherSousTitre(color, pos: Integer);
{RÔLE ET PRINCIPE : procedure esthetique permettant l'affichage du sous-titre grace a la procedure ecrireAuCentre()}
begin
  couleurTexte(color);

  ecrireAuCentre(pos  ,'	+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+     ');
  ecrireAuCentre(pos+1,'	| R A C E  A G A I N S T   T H E  C I V I L I Z A T I O N |     ');
  ecrireAuCentre(pos+2,'	+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+     ');
end;

procedure prochainDialogue();
{RÔLE ET PRINCIPE : procédure permettant la transition entre les dialogues a afficher : 
* on efface l'ecran actuel puis on attend avant d'afficher le suivant}
begin
  readln;
  effacerEcran;;
  sleep(1000);
end;

procedure choix_Nom(var civ : TCivilisation);
{RÔLE : permet l'affichage de la fenetre qui concerne le choix du nom du joueur}
{PRINCIPE : on lit l'entree au clavier du joueur. si l'entrée est vide, on affecte un nom par defaut, sinon, l'entrée rentrée devient le
* nouveau nom du héros par affectation}
var
  nom : string;
begin

  effacerEcran;

  ecrireEnPositionXY(20, 8, 'LES SYLVAINS : ');
  ecrireEnPositionXY(35, 8, 'Bien, mon maître. Comment devons-nous vous appeler?');

  dessinerCadreXY(47,15,72,17,simple,White,Black);
  deplacerCurseurXY(52,16);
  readln(civ.NomHeros);
  if (civ.NomHeros = '') then civ.NomHeros := 'Ryu''Than';
  effacerEcran();
end;

procedure nouveau(var game: TGame; var civ: TCivilisation; var combat: TCombat);
{PRINCIPE : correspond a l'affichage de la fenetre intro lorsqu'une nouvelle partie commence}
{RÔLE : on initialise les variables puis on efface l'ecran. on affiche successivements des fenetres de dialogue a travers des
* procedures d'affichage et des redirection vers les fenetres dialogue suivantes.}
begin
  // Réinitialisation des variables et actualisation de l'image
  initialisationVariables(game, civ, combat);
  effacerEcran();

  //ecran 1
  ecrireEnPositionXY(20, 8, 'LES SYLVAINS : ');
  ecrireEnPositionXY(35, 8, 'Bienvenue au maître Ruy''Than de la cité des Sylvains.');
  ecrireEnPositionXY(35, 9, 'Souhaitez-vous que l''on vous appelle par ce nom');
  ecrireEnPositionXY(35, 10, 'ou que l''on vous appelle autrement?');

  ecrireEnPositionXY(20, 20, '>   1. Appelez moi Ruy''Than.');
  ecrireEnPositionXY(20, 21, '>   2. Vous devez m''appeler autrement.');

  demanderReponse(game);
  if game.Input=2 then choix_Nom(civ);

  effacerEcran();

  ecrireEnPositionXY(20, 8, 'LES SYLVAINS : ');
  ecrireEnPositionXY(35, 8, 'Oh grand '+ civ.NomHeros +'. Ma troupe vient de revenir de la forêt sacrée. .');
  ecrireEnPositionXY(35, 9, 'Notre peuple des Sylvains, qui a vécu durant des siècles dans la forêt ');
  ecrireEnPositionXY(35, 10, 'pourrait bien voir sa fin prochainement... Lorsque nous sommes allés');
  ecrireEnPositionXY(35, 11,'à la chasse aux Arachnos ce matin, nous avons vu des campements armés ');
  ecrireEnPositionXY(35, 12, 'de la race des Humainsà seulement quelques mètres du territoire de la forêt.');
  ecrireEnPositionXY(35, 13, 'Ce peuple barbare avait trois petits campements au Nord-Est ainsi que');
  ecrireEnPositionXY(35, 14, 'un campement fortifié au Nord-Ouest. ');
  ecrireEnPositionXY(35, 16, 'Pas de doutes : Ils comptent abattre notre forét sacrée!');

  ecrireEnPositionXY(20, 22, '>   1. Montre moi la carte qui résume tout ça.');
  ecrireEnPositionXY(20, 23, '>   2. Pas d''inquiétude. Nous les détruirons avant qu''ils ne nous attaquent.');

  demanderReponse(game);

  effacerEcran();

  if game.Input=1 then afficherCarte(False, game, civ);

  effacerEcran();

  ecrireAuCentre(7, 'CONSIGNES RECAPITULATIVES : ');
  ecrireAuCentre(9, '*  *  *');

  ecrireEnPositionXY(25, 12, 'VOTRE NOM     :  '+civ.NomHeros);
  ecrireEnPositionXY(25, 14, 'VOTRE PEUPLE  :  Les Sylvains, ancienne race mystique de la Forêt Sacrée');
  ecrireEnPositionXY(25, 16, 'VOTRE MISSION :  Détruire les 4 campemnts humains pour protéger la forêt !');

  ecrireAuCentre(18, '*  *  *');

  ecrireAuCentre(20, 'Vous etes nommé Chef de Guerre pour mener ce projet à son bien !');

  ecrireAuCentre(22, ' BONNE CHANCE ! ');

  dessinerCadreXY(35,26,85,28, simple, White, Black);
  ecrireAuCentre(27,'Appuyez sur Entrée pour continuer.');
  readln;

  // On efface l'écran
  effacerEcran();

  // Début du jeu
  game.Screen := 'ecranPrincipal';


end;

procedure charger(var game: TGame; var civ: TCivilisation; var combat: TCombat);
{RÔLE : ecran correpondant au chargement d'une partie entamée}
{PRINCIPE : on récupère l'entrée au clavier du joueur. Si celui ci veut charger une partie entamée, on la charge a travers la procedure readFile()}
var
  nbFile: Integer;
  info: TInfo;
begin
  // On actualise l'écran
  effacerEcran();
  afficherDragon   (White,4);
  afficherTitre    (White,70,1);
  afficherSousTitre(White,21);

  // On extrait les informations concernant les noms de fichier
  readInfo(info);

  ecrireEnPositionXY(50,24,'1 - '+info.filename1);
  ecrireEnPositionXY(50,25,'2 - '+info.filename2);
  ecrireEnPositionXY(50,26,'3 - '+info.filename3);
  ecrireEnPositionXY(50,28,'0 - Ne pas charger');

  // Affichage du cadre de réponse
  dessinerCadreXY(95,26,105,28, simple, White, Black);
  deplacerCurseurXY(100,27);
  readln(game.Input);

  if (game.Input >= 1) and (game.Input <= 3) then
    begin
      nbFile := game.Input;
      readFile(nbFile, game, civ, combat);
      game.Screen := 'ecranPrincipal';
    end;

end;

procedure quitter(var game: TGame);
{RÔLE ET PRINCIPE : permet de quitter la partie en cours en mettant simplement le booleen game.Run à FAUX}
begin
  game.Run := False;
end;

procedure menuInitial(var game: TGame; var civ: TCivilisation; var combat: TCombat);
{RÔLE ET PRINCIPE : Cette procédure correspond à l'affichage du menu initial grace aux différentes procedures d'affichage}
begin

    // Ancien display
    afficherDragon   (White,4);
    afficherTitre    (White,70,1);
    afficherSousTitre(White,21);

  // Affichage du cadre de réponse
  dessinerCadreXY(35,26,85,28, simple, White, Black);
  ecrireAuCentre(27,'Appuyez sur Entrée pour continuer.');
  readln;

  // On efface l'écran
  effacerEcran();

  afficherDragon   (White,4);
  afficherTitre    (White,70,1);
  afficherSousTitre(White,21);

  ecrireEnPositionXY(50,25,'1 - Nouvelle partie');
  ecrireEnPositionXY(50,26,'2 - Charger une partie');
  ecrireEnPositionXY(50,27,'3 - Quitter');

  // Affichage du cadre de réponse
  dessinerCadreXY(95,26,105,28, simple, White, Black);
  deplacerCurseurXY(100,27);
  readln(game.Input);

  // Lecture de la réponse du joueur
  case game.Input of
    1: nouveau(game, civ, combat);
    2: charger(game, civ, combat);
    3: quitter(game);
    else beep();
  end;

  effacerEcran();

end;



end.
