unit U_ConfigBanco;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TConfigBanco = class

  private
    FDataBase: String;
    FServer: String;
    FPortBd: String;
    FUsuario: String;
    FSenha: String;
    FDLLConexao: String;
    FDriveID: String;
    FPortApi: String;

    procedure ValidarConfig;

  public
    property DataBase: String read FDataBase write FDataBase;
    property Server: String read FServer write FServer;
    property PortBd: String read FPortBd write FPortBd;
    property Usuario: String read FUsuario write FUsuario;
    property Senha: String read FSenha write FSenha;
    property DLLConexao: String read FDLLConexao write FDLLConexao;
    property DriveID: String read FDriveID write FDriveID;

    class function GetInstance: TConfigBanco;
    class function NewInstance: TObject; override;
    destructor Destroy; override;
    procedure PreparaConfigBanco;


end;

var
  ConfigBanco : TConfigBanco;

implementation

{ TConfigBanco }

uses System.IniFiles,
     Winapi.Windows,
     Vcl.Forms;


destructor TConfigBanco.Destroy;
begin

  inherited;
end;

class function TConfigBanco.GetInstance: TConfigBanco;
begin
  Result := TConfigBanco.Create;
end;

class function TConfigBanco.NewInstance: TObject;
begin
  if not(Assigned(ConfigBanco)) then
    ConfigBanco := TConfigBanco(inherited NewInstance);

  Result := ConfigBanco;
end;

procedure TConfigBanco.PreparaConfigBanco;
var
  vArquivoConfigIni : String;
  vArquivoIni       : TIniFile;
begin
  vArquivoConfigIni   := System.SysUtils.GetCurrentDir + '\softgranXML.ini';

  if NOT FileExists(vArquivoConfigIni) then
  begin
    Application.MessageBox(Pchar('Arquivo de inicialização não encontrado: '+vArquivoConfigIni),
                                                        'Iniciando Sistema', MB_ICONERROR);
    Application.Terminate;
  end;

  vArquivoIni  := TIniFile.Create(vArquivoConfigIni);
  try
    FDriveID     := vArquivoIni.ReadString('conexaoBanco', 'DriverID','FB');
    FServer      := vArquivoIni.ReadString('conexaoBanco', 'Server','localhost');
    FDataBase    := vArquivoIni.ReadString('conexaoBanco', 'Database','');
    FPortBd      := vArquivoIni.ReadString('conexaoBanco', 'PortBd','3050');
    FUsuario     := vArquivoIni.ReadString('conexaoBanco', 'User','SYSDBA');
    FSenha       := vArquivoIni.ReadString('conexaoBanco', 'Password','');
    FDLLConexao  := vArquivoIni.ReadString('conexaoBanco', 'DLL_Conexao','');

    ValidarConfig;

  finally
    vArquivoIni.Free;
  end;

end;

procedure TConfigBanco.ValidarConfig;
var
  vMensagem : String;
begin
  vMensagem := '';

  if FDataBase.Trim.IsEmpty then
    vMensagem := 'Banco de Dados não informado'
  else
  if FServer.Trim.IsEmpty then
    vMensagem := 'Servidor não informado'
  else
  if FPortBd.Trim.IsEmpty then
    vMensagem := 'Porta do Banco de Dados não informada'
  else
  if FUsuario.Trim.IsEmpty then
    vMensagem := 'Usuario do banco de dados não informado'
  else
  if FSenha.Trim.IsEmpty then
    vMensagem := 'Senha do banco de dados não informada'
  else
  if FDLLConexao.Trim.IsEmpty then
    vMensagem := 'DLL de conexão nao informada'
  else
  if not FileExists(FDLLConexao) then
    vMensagem := 'Arquivo DLL de conexão não existe'
  else
  if FDriveID.Trim.IsEmpty then
    vMensagem := 'Drive do banco de dados não informado';

  if not vMensagem.IsEmpty then
  begin
    Application.MessageBox(Pchar(vMensagem),'Iniciando Sistema', MB_ICONERROR);
    Application.Terminate;
  end;

end;

initialization

finalization
  if Assigned(ConfigBanco) then
    ConfigBanco.Free;

end.

