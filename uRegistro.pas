unit uRegistro;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Hash;

type
  TfrmRegistro = class(TForm)
    ScaledLayout1: TScaledLayout;
    VertScrollBox1: TVertScrollBox;
    GPL_datos: TGridPanelLayout;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    tlb_nombre: TLabel;
    tlb_apellido1: TLabel;
    tlb_apellido2: TLabel;
    TE_nombre: TEdit;
    TE_apellido1: TEdit;
    TE_apellido2: TEdit;
    GPL_contacto: TGridPanelLayout;
    Layout4: TLayout;
    tlb_email: TLabel;
    TE_email: TEdit;
    Layout5: TLayout;
    tlb_telefono: TLabel;
    TE_telefono: TEdit;
    GPL_conexion: TGridPanelLayout;
    Layout7: TLayout;
    tlb_usuario: TLabel;
    TE_usuario: TEdit;
    Layout8: TLayout;
    tlb_contasena: TLabel;
    TE_contrasena: TEdit;
    GPL_botones: TGridPanelLayout;
    tbtn_registrar: TButton;
    FDCon_academia: TFDConnection;
    FDQ_verificarUsuario: TFDQuery;
    FDQ_insertarUsuario: TFDQuery;
    FDQ_verificarEmail: TFDQuery;
    FDQuery1: TFDQuery;
    procedure TE_nombreExit(Sender: TObject);
    procedure TE_apellido1Exit(Sender: TObject);
    procedure TE_apellido2Exit(Sender: TObject);
    procedure tbtn_registrarClick(Sender: TObject);
  private
    { Private declarations }
      procedure GenerarNombreUsuario;
  public
    { Public declarations }
  end;

var
  frmRegistro: TfrmRegistro;

implementation



{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.Surface.fmx MSWINDOWS}
{$R *.iPad.fmx IOS}
{$R *.XLgXhdpiTb.fmx ANDROID}
{$R *.SSW3.fmx ANDROID}
{$R *.GGlass.fmx ANDROID}

  procedure TfrmRegistro.generarNombreUsuario;
  var
    nombre,apellido1,apellido2,usuario,baseUsuario  :string;
    contador: Integer;
    existe: Boolean;
  begin
    nombre := TE_nombre.Text.Trim;
    apellido1 := TE_apellido1.Text.Trim;
    apellido2 := TE_apellido2.Text.Trim;

    if (Length(nombre) >= 1) and (Length(apellido1) >= 3) and (Length(apellido2) >= 3) then
      begin
        baseUsuario  := LowerCase(Copy(nombre, 1, 1) +
                             Copy(apellido1, 1, 3) +
                             Copy(apellido2, 1, 3));
        usuario := baseUsuario;
        contador := 0;


        repeat
          FDQ_verificarUsuario.Close;
          FDQ_verificarUsuario.ParamByName('usuario').AsString := usuario;
          FDQ_verificarUsuario.Open;

          existe := FDQ_verificarUsuario.Fields[0].AsInteger > 0;

          if existe then
            begin
              Inc(contador);
              // Eliminamos última letra y agregamos número
              usuario := Copy(baseUsuario, 1, Length(baseUsuario) - 1) + IntToStr(contador);
            end;

        until not existe;


        TE_usuario.Text := usuario;
      end
    else
      TE_usuario.Text := ''; // Vaciar si falta información
  end;

  procedure TfrmRegistro.tbtn_registrarClick(Sender: TObject);
  var
    nombre, apellido1, apellido2, telefono, email, usuario, pass: string;
    emailExiste: Boolean;
  begin
      // Obtener valores de los TEdit
    nombre     := TE_nombre.Text.Trim;
    apellido1  := TE_apellido1.Text.Trim;
    apellido2  := TE_apellido2.Text.Trim;
    telefono   := TE_telefono.Text.Trim;
    email      := TE_email.Text.Trim;
    usuario    := TE_usuario.Text.Trim;
    pass       := THashSHA2.GetHashString(TE_contrasena.Text);

      // Validar que los campos obligatorios no estén vacíos
    if (nombre = '') or (apellido1 = '') or (email = '') or
       (usuario = '') or (pass = '') then
      begin
        ShowMessage('Por favor, rellena todos los campos obligatorios.');
        Exit;
      end;

      // Verificar si el email ya existe
    FDQ_verificarEmail.Close;
    FDQ_verificarEmail.ParamByName('email').AsString := email;
    FDQ_verificarEmail.Open;
    emailExiste := FDQ_verificarEmail.Fields[0].AsInteger > 0;

    if emailExiste then
    begin
      ShowMessage('Este email ya está registrado. Usa otro.');
      Exit;
    end;

    // Insertar el nuevo usuario
    try
      FDQ_insertarUsuario.Close;
      FDQ_insertarUsuario.ParamByName('nombre').AsString     := nombre;
      FDQ_insertarUsuario.ParamByName('apellido1').AsString  := apellido1;
      FDQ_insertarUsuario.ParamByName('apellido2').AsString  := apellido2;
      FDQ_insertarUsuario.ParamByName('telefono').AsString   := telefono;
      FDQ_insertarUsuario.ParamByName('email').AsString      := email;
      FDQ_insertarUsuario.ParamByName('usuario').AsString    := usuario;
      FDQ_insertarUsuario.ParamByName('pass').AsString       := pass;

      FDQ_insertarUsuario.ExecSQL;

      ShowMessage('Usuario registrado correctamente');
    except
      on E: Exception do
        ShowMessage('Error al registrar usuario: ' + E.Message);
    end;

  end;

  procedure TfrmRegistro.TE_apellido1Exit(Sender: TObject);
  begin
    GenerarNombreUsuario;
  end;

  procedure TfrmRegistro.TE_apellido2Exit(Sender: TObject);
  begin
    GenerarNombreUsuario;
  end;

  procedure TfrmRegistro.TE_nombreExit(Sender: TObject);
  begin
    GenerarNombreUsuario;
  end;

end.
