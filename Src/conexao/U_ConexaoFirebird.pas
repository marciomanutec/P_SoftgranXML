unit U_ConexaoFirebird;

interface

uses
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.FB,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt;


type
  TConexaoFirebird = class
  private
    FConnection       : TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;

  public
    function ConexaoFirebird: TFDConnection;
    constructor Create;
    Destructor  Destroy; override;

  end;


implementation

{ TConexaoFirebird }

uses U_ConfigBanco;


function TConexaoFirebird.ConexaoFirebird: TFDConnection;
begin
  Result := FConnection;
end;

constructor TConexaoFirebird.Create;
begin
  try

    FConnection        := TFDConnection.Create(nil);
    FDPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
    FDPhysFBDriverLink.VendorLib := TConfigBanco.GetInstance.DLLConexao;

    with FConnection do
    begin
      Params.Clear;
      Params.DriverID               := TConfigBanco.GetInstance.DriveID;
      Params.Database               := TConfigBanco.GetInstance.DataBase;
      Params.Add('Server='          +  TConfigBanco.GetInstance.Server);
      Params.Add('Port='            +  TConfigBanco.GetInstance.PortBd);
      Params.Add('Protocol = TCPIP');
      Params.UserName               := TConfigBanco.GetInstance.Usuario;
      Params.Password               := TConfigBanco.GetInstance.Senha;
      LoginPrompt := False;
    end;

    FConnection.Open();

  except
    on E:Exception do
    begin
      raise Exception.Create(E.Message);
    end;

  end;

end;

destructor TConexaoFirebird.Destroy;
begin
  if Assigned(FConnection) then
    FConnection.Free;

  if Assigned(FDPhysFBDriverLink) then
    FDPhysFBDriverLink.Free;

  inherited;
end;

end.

