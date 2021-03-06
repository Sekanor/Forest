program CIVILISATION_Minimal;
{R�LE : Ce programme a pour r�le d'appeler la procedure Main qui d�termine quelle sera la fen�tre affich�e}

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  menuInitial_UNIT              in 'Scripts\menuInitial_UNIT.pas',
  ecranPrincipal_UNIT           in 'Scripts\ecranPrincipal_UNIT.pas',
  ecranDeCombat_UNIT            in 'Scripts\ecranDeCombat_UNIT.pas',
  gestionCapitale_UNIT          in 'Scripts\gestionCapitale_UNIT.pas',
  gestionDeCombat_UNIT          in 'Scripts\gestionDeCombat_UNIT.pas',
  fonctionsGlobales_UNIT        in 'Scripts\fonctionsGlobales_UNIT.pas',
  moduleGestionEcran_UNIT       in 'Scripts\moduleGestionEcran_UNIT.pas',
  initialisationVariables_UNIT  in 'Scripts\initialisationVariables_UNIT.pas';

procedure Main();
{R�LE : Cette proc�dure d�termine quel sera le prochain menu � �tre affich�.
* Elle a pour r�le de faire fonctionner le jeu entier.}
var
  game  : TGame;
  civ   : TCivilisation;
  combat: TCombat;
{PRINCIPE : Gr�ce � une alternative, on d�termine quel sera le prochain menu � �tre affich�.
* Par exemple, si la variable game.Screen vaut 'menuItinital' alors on appelle la sous proc�dure menuInitial
* qui affichera le menu initial et ainsi de suite.}
begin

  initialisationVariables(game, civ, combat);
  couleurTexte(White);

  repeat
  { Boucle principale du jeu.
    La variable game.Screen peut �tre �dit�e dans toutes les unit�s du programme.
    C'est cette variable qui d�termine quel sera le prochain menu � �tre affich�.
    Simplement ex�cuter les proc�dures a partir des autres proc�dures est une autre solution.}

    if      game.Screen = 'menuInitial'     then menuInitial(game)
    else if game.Screen = 'ecranPrincipal'  then ecranPrincipal(game, civ)
    else if game.Screen = 'ecranDeCombat'   then ecranDeCombat(game, civ, combat)
    else if game.Screen = 'gestionCapitale' then gestionCapitale(game, civ, combat)
    else if game.Screen = 'gestionDeCombat' then gestionDeCombat(game, civ, combat);
  until (game.Run = False);

end;

{PRINCIPE : on appelle simplement la proc�dure Main}
begin

  Main();

end.
