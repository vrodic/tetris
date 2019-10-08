program tetris;

uses
  Forms,
  main in 'main.pas' {frmTetris},
  scores in 'scores.pas' {frmScores},
  chskin in 'chskin.pas' {frmChooseSkin};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Tetris by Vedran Rodic';
  Application.CreateForm(TfrmTetris, frmTetris);
  Application.Run;
end.
