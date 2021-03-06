﻿unit ecranPrincipal_UNIT;
interface

	uses 
		fonctionsGlobales_UNIT, 
		moduleGestionEcran_UNIT, 
		System.SysUtils, 
		initialisationVariables_UNIT, 
		sauvegarde_UNIT, 
		math;

	procedure ecranPrincipal(var game: TGame; var civ: TCivilisation; var combat: TCombat);
	{RÔLE : Cette procedure correspond à l'affichage de l'ecran principal, qui permet d'acceder aux autres fenetres
	* grace a l'input du joueur.}

implementation

  // Déclaration des variables de texte dédiées à l'unité
  var
    texteNom,
    texteNourriture,
    textePopulation,
    texteNourritureParTour,
    texteCroissance,
    texteTravailParTour
    : String;

  const
    CROISSANCE_FOODMAX      : Array[1..30] of Integer = (10, 50, 150, 350, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500,
                                                        500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500, 500);
    MAX_PTSRECRU            : Array[0..3] of Integer = (5, 20, 50, 100);
    // Bonus de construction
    BONUS_FERME_FOOD        : Integer = 5;
    BONUS_MINE_TRAVAIL      : Integer = 2;
    BONUS_CARRIERE_TRAVAIL  : Integer = 5;
    BONUS_CASERNE_PTSRECRU  : Integer = 0;
    // Probabilité d'évênements aléatoires
    PROBA_RESSOURCES_BONUS  : Integer = 60;
    PROBA_ATTAQUES_BARBARES : Integer = 100;
    PROBA_EPIDEMIE          : Integer = 500;
    // Bonus en cas d'évênements aléatoires: (min, max)
    NB_BONUS_RADIS          : Array[1..2] of Integer = (10,30);
    NB_BONUS_NOURRITURE     : Array[1..2] of Integer = (10,25);
    NB_BONUS_CANONS         : Array[1..2] of Integer = (1,3);
    // Bonus de recherche
    BONUS_EPEE_TRANCHANTE   : Real = 1.2;
    BONUS_ARTILLERIE        : Real = 1.2;
    BONUS_POTION_MAGIQUE    : Integer = 2;

  procedure gestionParc(game: TGame; civ: TCivilisation);
  {RÔLE : Amelioration de type Luxe. Cette procedure permet de gérer les zones protégées construites pour la faune de la Foret.}
  {PRINCIPE : On affiche le texte correspondant à la zone protégée avec les variables de bonheur. Cette procedure est simplement descriptive}
  begin
    effacerEcran;
    displayHeader(game, civ);

    ecrireAuCentre(6,'Zones protégées');
    ecrireAuCentre(7,'---------------');

    dessinerCadreXY(29,12,90,19, simple, White, Black);

    ecrireEnPositionXY(35,14,'Vos zones protégées rapportent ');
    couleurTexte(LightGreen);
    ecrireEnPositionXY(66,14,IntToStr(civ.lvlParc*2));
    couleurTexte(White);
    ecrireEnPositionXY(68,14,' points de bonheur !');
    ecrireAuCentre(16,'Augmentez le niveau de vos zones protégées');
    ecrireAuCentre(17,'afin de gagner des points de bonheur !');

    game.Input := -1;
    while game.Input <> 0 do
    begin
      demanderReponse(game);
    end;
  end;

  procedure ressourcesBonus(var game: TGame; var civ : TCivilisation ; var combat : TCombat);
  {RÔLE : Cette procedure a pour role la gestion de la survenue dans le jeu de l'evenement aleatoire "ressources bonus".}
  var
    aleatoire,
    bonus_deniers,
    bonus_canons,
    bonus_nourriture : integer;

	{PRINCIPE : on actualise l'image grace à un effacerEcran() puis on affecte des bonus aléatoire en mettant à jour les variables concernées
	* (radis, nourriture, canons...) et on en informe le joueur a travers l'affichage.}
	begin

     randomize;
     aleatoire := random(PROBA_RESSOURCES_BONUS);

     if aleatoire=0 then
     begin
        // Actualisation de l'image
        effacerEcran();
        displayHeader(game, civ);

        // Bonus aléatoires
        randomize;
        bonus_deniers := random(NB_BONUS_RADIS[2]-NB_BONUS_RADIS[1])+NB_BONUS_RADIS[1];
        randomize;
        bonus_nourriture := random(NB_BONUS_NOURRITURE[2]-NB_BONUS_NOURRITURE[1])+NB_BONUS_NOURRITURE[1];
        randomize;
        bonus_canons := random(NB_BONUS_CANONS[2]-NB_BONUS_CANONS[1])+NB_BONUS_CANONS[1];

        // Ajout des bonus aux variables
        civ.Food := civ.Food + bonus_nourriture;
        combat.CanonsDispo := combat.CanonsDispo + bonus_canons;
        civ.gold := civ.gold + bonus_deniers;

        // Affichage de l'écran
        couleurTexte(LightGreen);
        ecrireAuCentre(7,'EVENEMENT : Collecte !');
        couleurTexte(White);

        ecrireAuCentre(12, 'Vos soldats sont revenus de la ronde ! Ils ont ramené des ressources bonus!');

        ecrireEnPositionXY(50,14,'Nourriture : ');
        ecrireEnPositionXY(50,15,'Radis      : ');
        ecrireEnPositionXY(50,16,'Canons     : ');

        couleurTexte(LightGreen);
        ecrireEnPositionXY(63,14,'+');
        ecrireEnPositionXY(63,15,'+');
        ecrireEnPositionXY(63,16,'+');
        ecrireEnPositionXY(64,14,IntToStr(bonus_nourriture));
        ecrireEnPositionXY(64,15,IntToStr(bonus_deniers));
        ecrireEnPositionXY(64,16,IntToStr(bonus_canons));
        couleurTexte(White);

        ecrireEnPositionXY(50,27,'0 - Continuer');

        // Lecture de la réponse du joueur
        repeat
          dessinerCadreXY(95,26,105,28, simple, White, Black);
          deplacerCurseurXY(100,27);
          readln(game.Input);
        until game.Input = 0;
     end;

  end;

  procedure epidemie(var game: TGame; var civ : TCivilisation ; var combat : TCombat);
  {RÔLE : Cette procedure gere les evenements de type "epidemie". }
  var
    aleatoire: Integer;
  {PRINCIPE : on actualise l'image grace à un effacerEcran() puis on met a jour la variable qui comporte la quantité de soldats que l'on possède
  * en la divisant par deux.}
  begin
    randomize;
    aleatoire := random(PROBA_EPIDEMIE);

    if (aleatoire = 0) then
    begin
      effacerEcran;
      displayHeader(game, civ);

      couleurTexte(LightRed);
      ecrireAuCentre(7,'EVENEMENT : Epidemie !');
      couleurTexte(White);

      combat.SoldatsDispo := combat.SoldatsDispo div 2;

      ecrireAuCentre(12, 'Une épidémie est survenue sur la civlisation des Sylvains.');
      ecrireAuCentre(13, 'Vous perdez la moitié de vos soldats !');

      ecrireEnPositionXY(50,27,'0 - Continuer');

      // Lecture de la réponse du joueur
      repeat
        dessinerCadreXY(95,26,105,28, simple, White, Black);
        deplacerCurseurXY(100,27);
        readln(game.Input);
      until game.Input = 0;
    end;
  end;

  procedure attaquesBarbares(var game: TGame; var civ : TCivilisation ; var combat : TCombat);
  {RÔLE : cette procedure gère l'évènement de type "attaques barbares"}
  var
    aleatoire: Integer;
  {PRINCIPE : on oblige le joueur à lancer un combat après avoir décidé de l'évènement à travers un tirage au sort random.
  * on lance ensuite une attaque dans l'écran de gestion de combat vers lequel le joueur est automatiquement autorisé}
  begin

    attendre(10);
    randomize;
    aleatoire := random(PROBA_ATTAQUES_BARBARES);

    if aleatoire = 0 then
    begin

      effacerEcran;
      displayHeader(game, civ);

      couleurTexte(LightRed);
      ecrireAuCentre(7,'EVENEMENT : Combat !');
      couleurTexte(White);

      dessinerCadreXY(30,12,88,18, simple, White, Black);
      ecrireEnPositionXY(35,14,'Vous êtes attaqués par une civilisation barbare !');
      ecrireEnPositionXY(40,16,'Appuyez sur 0 pour lancer le combat.');

      repeat
        dessinerCadreXY(95,26,105,28, simple, White, Black);
        deplacerCurseurXY(100,27);
        readln(game.Input);
      until game.Input = 0;

      combat.Adversaire := 'Petit camp barbare';
      game.Screen := 'ecranDeCombat';


    end;


  end;

  procedure updateConstruction(var game: TGame; var civ: TCivilisation);
  {RÔLE : Cette procédure a pour role de gerer les effets de la fin de la construction d'un bâtiment.}
  {PRINCIPE : On incremente les niveaux à chaque fin de construction.}
  begin
    effacerEcran;
    displayHeader(game, civ);
    couleurTexte(LightGreen);
    ecrireAuCentre(16,'Vous avez terminé la construction en cours !');
    couleurTexte(White);
    ecrireAuCentre(25,'0 - Continuer');
    game.Input := -1;
    while game.Input <> 0 do
    begin
      demanderReponse(game);
    end;

    // Effets de la construction
      if civ.CurrentConstruction = 'Ferme' then
        begin
          civ.Food_Par_Tour := civ.Food_Par_Tour + BONUS_FERME_FOOD;
          civ.lvlFerme := civ.lvlFerme + 1 ;
        end
      else if civ.CurrentConstruction = 'Mine' then
        begin
          civ.Travail_Par_Tour := civ.Travail_Par_Tour + BONUS_MINE_TRAVAIL;
          civ.lvlMine := civ.lvlMine + 1 ;
        end
      else if civ.CurrentConstruction = 'Carriere' then
        begin
          civ.Travail_Par_Tour := civ.Travail_Par_Tour + BONUS_CARRIERE_TRAVAIL;
          civ.lvlCarriere := civ.lvlCarriere + 1 ;
        end
      else if civ.CurrentConstruction = 'Caserne' then
        begin
          civ.lvlCaserne := civ.lvlCaserne + 1 ;
          civ.PointsRecrutement := civ.PointsRecrutement + BONUS_CASERNE_PTSRECRU;
        end
      else if civ.CurrentConstruction = 'Bibliotheque' then
        begin
          civ.lvlBibliotheque := civ.lvlBibliotheque + 1;
        end
      else if civ.CurrentConstruction = 'Marché' then
        begin
          civ.lvlMarche := civ.lvlMarche + 1 ;
        end
      else if civ.CurrentConstruction = 'Parc' then
        begin
          civ.lvlParc := civ.lvlParc + 1;
          civ.bonheur := civ.bonheur + 4;
        end;

    // Réinitialisation
      civ.NbConstructions := civ.NbConstructions + 1;
      civ.Travail := 0;
      civ.CurrentConstruction := 'Aucun';
      civ.Construction_Texte := 'Pas de construction en cours' ;
      civ.Travail_Texte := '';
  end;

  procedure godMode(var civ: TCivilisation; var combat: TCombat);
  {RÔLE : cette procedure sert de 'cheat-code' pour tester les différentes fonctionnalités sans passer par le début du jeu - réservé aux codeurs}
  {PRINCIPE : on affecte aux variables principales des valeurs stratégiques}
  begin
    civ.Travail_Par_Tour := 100;
    civ.Food_Par_Tour := 100;
    combat.SoldatsDispo := 100;
    combat.CanonsDispo := 20;
  end;

  procedure sauvegarder(var game: TGame; var civ: TCivilisation; var combat: TCombat);
  {RÔLE : cette procédure a pour role de sauvegarder l'avancement des joueurs dans des fichiers binaires}
  {PRINCIPE : on appelle la procedure writeFile en passant en paramètre les record contenant les variables du joueurs}
  begin
    // Affichage
    ecrireAuCentre(20,'Sauvegarde en cours...');

    // Sauvegarde
    writeFile(game.Input, game, civ, combat);
    game.Screen := 'menuInitial';

    // Rafraichissement de l'écran
    effacerEcran();
    displayHeader(game, civ);

    // Affichage
    couleurTexte(LightGreen);
    ecrireAuCentre(16,'Sauvegarde effectuée !');
    couleurTexte(White);

    readln;
  end;

  procedure finDeTour_construction(var game: TGame; var civ: TCivilisation);
  {RÔLE : Cette procedure a pour role de gerer les fins de tour de la construction}
  {PRINCIPE : On met a jour la construction en disant par exemple qu'un nouveau batiment 
  * a ete construit grace a l'appel de procedure updateConstruction()}
  begin
    civ.Travail := civ.Travail + civ.Travail_Par_Tour;
    civ.texteTravail := 'Travail accumulé : '+IntToStr(civ.Travail)+'/'+IntToStr(civ.Travail_Max);

    // Si la construction est terminée, alors on la met a jour.
    if (civ.Travail >= civ.Travail_Max) then updateConstruction(game, civ);
  end;

  procedure finDeTour_croissance(var civ: TCivilisation);
  {RÔLE : Cette procédure a pour role de gérer les fins de tour concernant la croissance, c'est à dire, la création de nouveaux
  * villageois, de stocks de nourriture etc}
  {PRINCIPE : On augmente la nourriture en fonction de la production actuelle puis on calcule le nombre de tours que le joueur
  * doit attendre avant une nouvelle croissance de sa population}
  begin
    // Augmentation de la nourriture en fonction de la production actuelle
    civ.Food := civ.Food + civ.Food_Par_Tour;

    if (civ.Food_Par_Tour > 0) then
      begin
        // Cette formule calcule le nombre de tours que le joueur doit attendre
        // avant une nouvelle croissance de sa population.
        civ.Nb_Tours_Levelup := ceil(((civ.Food_Max - civ.Food)/civ.Food_Par_Tour));

        if civ.Food_Par_Tour > civ.Food_Max then civ.Nb_Tours_Levelup := 0;

        if (civ.Food >= civ.Food_Max) then
          begin
            //Croissance
            civ.Population := civ.Population + 1;
            civ.Travail_Par_Tour := civ.Travail_Par_Tour + 1;
            civ.Food_Par_Tour := civ.Food_Par_Tour - 1;
            civ.Food := 0;
            if civ.Population >= 4 then civ.bonheur := civ.bonheur - 1;

            // On modifie le prochain pallier de nourriture a atteindre en fonction de la population actuelle.
            civ.Food_Max := CROISSANCE_FOODMAX[civ.Population];

          end;
      end;

    if (civ.Food_Par_Tour > 0) then civ.Croissance_Texte := concat('Nb tours avant croissance : ', IntToStr(civ.Nb_Tours_Levelup))
    else civ.Croissance_Texte := 'Aucune croissance possible   ';
  end;

  procedure finDeTour_recherches(var game: TGame; var civ: TCivilisation; var combat: TCombat);
  {RÔLE : Cette procédure a pour role de gérer les fins de tour concernant la recherche de la bibliothèque}
  {PRINCIPE : Si le travail equivaut le prix en travail de l'étude entamée alors la recherche est terminée et on en informe le joueur
  * a travers un affichage en mettant a jour les variables concerncées (ex: epees, soldats.. etc)}
  begin
    civ.travailRecherche := civ.travailRecherche + civ.lvlBibliotheque;

    if civ.travailRecherche >= civ.Travail_Max_Recherche then
    begin
      effacerEcran;
      displayHeader(game, civ);
      couleurTexte(LightGreen);
      ecrireAuCentre(16,'Vous avez terminé votre recherche en cours !');
      couleurTexte(White);
      ecrireAuCentre(25,'0 - Continuer');
      game.Input := -1;
      while game.Input <> 0 do
      begin
        demanderReponse(game);
      end;

      if (civ.CurrentRecherche = 'Epée Tranchante') then
        begin
          combat.Bonus_Soldats := combat.Bonus_Soldats * BONUS_EPEE_TRANCHANTE;
        end
      else if (civ.CurrentRecherche = 'Artillerie') then
        begin
          combat.Bonus_Canons := combat.Bonus_Canons * BONUS_ARTILLERIE;
        end
      else if (civ.CurrentRecherche = 'Potion magique') then
        begin
          civ.Travail_Par_Tour := civ.Travail_Par_Tour + BONUS_POTION_MAGIQUE;
        end
      else if (civ.CurrentRecherche = 'Bac à Compost') then
        begin
          civ.Food_Par_Tour := civ.Food_Par_Tour + 2;
        end
      else if (civ.CurrentRecherche = 'Brocante Forestière') then
        begin
        end
      else if (civ.CurrentRecherche = 'Stratégie') then
        begin
          effacerEcran;
          displayHeader(game, civ);
          couleurTexte(LightGreen);
          ecrireAuCentre(15,'Félicitations ! Vos stratagèmes ont longuement étudié le campement fortifié des humains');
          ecrireAuCentre(16,'et ont découvert qu''il est nécessaire que vous possédiez un dragon pour lancer l''assaut.');
          ecrireAuCentre(17,'Peut-être y-a-t-il quelqu''un qui pourrait en vendre au marché? Bonne chance!');
          couleurTexte(White);
          game.Input := -1;
          while game.Input <> 0 do
          begin
            demanderReponse(game);
          end;
        end;

      civ.CurrentRecherche := 'Aucun';
      civ.travailRecherche := 0;
      civ.Travail_Max_Recherche := 0;
    end;
  end;

  procedure finDeTour(var game: TGame; var civ: TCivilisation; var combat: TCombat);
 {RÔLE : Cette procédure a pour role de gerer les fins de tours, en particulier ce qui concerne les constructions et la caserne. On lance la construction ou on dit qu'il 
 * n'y a pas de construction}
 {PRINCIPE : On incremente le nombre de tours de jeu, on met a jour les points de recrutement de la caserne.
 * Si une construction est en cours alors on incremente egalement le travail}
  begin
    game.NbTour := game.NbTour + 1;
    civ.ConstructionLancee_Texte := 'Construction lancée !';

    // Incrémentationd des ressources en radis
    civ.gold := civ.gold + civ.lvlMarche;

    // Evènements
    ressourcesBonus(game, civ, combat);
    epidemie(game, civ, combat);

    // Si une construction est en cours, alors on incrémente le travail
    if (civ.CurrentConstruction <> 'Aucun') then finDeTour_construction(game, civ);
    finDeTour_croissance(civ);
    //if civ.PointsRecrutement < MAX_PTSRECRU[civ.lvlCaserne] then civ.PointsRecrutement := civ.PointsRecrutement + 1;
    if civ.CurrentRecherche <> 'Aucun' then finDeTour_recherches(game, civ, combat);

    attaquesBarbares(game, civ, combat);


  end;

  procedure ouvrirEcran(ecran: String; var game: TGame; var civ: TCivilisation; var combat: TCombat);
  {RÔLE : Cette procedure a pour role l'affichage des écrans suivants l'écran actuel (ex: après l'écran "sciences" on doit rediriger le joueur vers 
  * l'écran "gestion sciences", etc...}
  {PRINCIPE : On teste simplement la valeur de l'écran actuel puis on affecte à game.Screen une autre variable string ce qui redirige le joueur
  * vers un autre ecran ,etc }
  begin
    if ecran='Sciences' then
      begin
        if civ.lvlBibliotheque > 0 then game.Screen := 'gestionSciences';
      end
    else if ecran='Marché' then
      begin
        if civ.lvlMarche > 0 then game.Screen := 'gestionMarche';
      end
    else if ecran='Quitter' then
      begin
        effacerEcran();
        displayHeader(game, civ);

        ecrireEnPositionXY(50,10,'1 - Sauvegarder dans Fichier 1');
        ecrireEnPositionXY(50,11,'2 - Sauvegarder dans Fichier 2');
        ecrireEnPositionXY(50,12,'3 - Sauvegarder dans Fichier 3');
        ecrireEnPositionXY(50,14,'9 - Ne pas sauvegarder');
        ecrireEnPositionXY(50,15,'0 - Ne pas quitter');

        // Affichage du cadre de réponse
        dessinerCadreXY(95,26,105,28, simple, White, Black);
        deplacerCurseurXY(100,27);
        readln(game.Input);

        case game.Input of
          1..3: sauvegarder(game, civ, combat);
          9: game.Screen := 'menuInitial';
          0: game.Screen := 'ecranPrincipal';
        end;

      end
    else if ecran='Combat' then
      begin
        combat.Recrutement_Texte := '';
        game.Screen := 'gestionDeCombat';
      end
    else if ecran='Parc' then
      begin
        if civ.lvlParc > 0 then gestionParc(game, civ);
      end

  end;

  procedure ecranPrincipal(var game: TGame; var civ: TCivilisation; var combat: TCombat);
  {RÔLE : Cette procedure correspond a l'affichage de l'ecran principal qui permet d'acceder aux autres fenetres grace a l'input du joueur}
  {PRINCIPE : On affiche les différents textes, on donne le choix au joueur entre differentes fenetres a afficher ensuite
  * puis on lit son input et on appelle les procedures d'affichage d'ecran en fonction de cet input}
  begin

    // Header
      displayHeader(game, civ);


    // Titre
      ecrireAuCentre(6,'Ecran de gestion de la civilisation') ;
      ecrireAuCentre(7,'---------------------------------------') ;
      ecrireEnPositionXY(4,9,'Liste des villes de la civilisation :');
      ecrireEnPositionXY(4,10,'-------------------------------------');


    // Affichage des propriétés de la civilisation

    // Texte
    texteNom                := 'Campement de : '+civ.NomHeros;
    texteNourriture         := 'Nourriture : '+IntToStr(civ.Food)+' / '+IntToStr(civ.Food_Max);
    texteTravailParTour     := 'Travail par tour : '+IntToStr(civ.Travail_Par_Tour);
    textePopulation         := 'Population : '+IntToStr(civ.Population);
    texteNourritureParTour  := 'Nourriture par tour : '+IntToStr(civ.Food_Par_Tour);

    if (civ.Food_Par_Tour > 0) then
      texteCroissance := 'Nb tours avant croissance : '+IntToStr(civ.Nb_Tours_Levelup)
    else
      texteCroissance := 'Aucune croissance possible.';

    if civ.CurrentConstruction = 'Aucun' then
      begin
        civ.texteConstruction := 'Pas de construction en cours';
        civ.texteTravail := '';
      end;

    // Affichage
    ecrireEnPositionXY(4,12,texteNom);
    ecrireEnPositionXY(40,12,texteNourriture);
    ecrireEnPositionXY(80,12,texteTravailParTour);
    ecrireEnPositionXY(4,13,textePopulation);
    ecrireEnPositionXY(40,13,texteNourritureParTour);
    ecrireEnPositionXY(80,13,civ.texteConstruction);
    ecrireEnPositionXY(40,14,texteCroissance);
    ecrireEnPositionXY(80,14,civ.texteTravail);


    // Options du jeu
    ecrireEnPositionXY (4,18,'1 - Accéder au campement') ;
    ecrireEnPositionXY (4,19,'2 - Gestion militaire et diplomatique') ;
    ecrireEnPositionXY (4,24,'6 - Voir la map');
    if civ.lvlBibliotheque  > 0 then ecrireEnPositionXY (4,20,'3 - Gestion des sciences et recherches') ;
    if civ.lvlMarche        > 0 then ecrireEnPositionXY (4,21,'4 - Accéder au marché') ;
    if civ.lvlParc          > 0 then ecrireEnPositionXY (4,22,'5 - Voir les zones protégées') ;
    ecrireEnPositionXY (4,26,'9 - Fin de tour');
    ecrireEnPositionXY (4,27,'0 - Quitter la partie');


    // Affichage du cadre de réponse
      dessinerCadreXY(95,26,105,28, simple, White, Black);
      deplacerCurseurXY(100,27);
      readln(game.Input);


    // Lecture de la réponse du joueur
      case game.Input of
        1: game.Screen := 'gestionCapitale';
        2: ouvrirEcran('Combat', game, civ, combat);
        3: ouvrirEcran('Sciences', game, civ, combat);
        4: ouvrirEcran('Marché', game, civ, combat);
        5: ouvrirEcran('Parc', game, civ, combat);
        6: afficherCarte(False, game, civ);
        9: finDeTour(game, civ, combat);
        666: godMode(civ, combat);
        0: ouvrirEcran('Quitter', game, civ, combat);
      end;

    effacerEcran();


  end;


end.
