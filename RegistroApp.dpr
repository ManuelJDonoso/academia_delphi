program RegistroApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  uRegistro in 'uRegistro.pas' {frmRegistro};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmRegistro, frmRegistro);
  Application.Run;
end.
