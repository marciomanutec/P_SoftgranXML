unit U_DaoDocumentoEvento;
 
interface
 
uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  U_DocumentoEvento;

type
  TDaoDocumentoEvento = class
  private
    FConexao: TFDConnection;
    function RetornarSQLDocumentoEvento: String;
    function RetornarSQLCadastrarEvento:String;
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    function RetornarDataSetDocumentoEvento(const AIdDocumento:Integer):TFDQuery;
    function CadastrarDocumentoEvento(ADocEvento: TDocumentoEvento): Boolean;
    property Conexao: TFDConnection read FConexao write FConexao;
  end;
 
implementation
 
{ TDaoDocumentoEvento }

function TDaoDocumentoEvento.CadastrarDocumentoEvento(ADocEvento: TDocumentoEvento): Boolean;
var
  vQryCadastrarEvento : TFDQuery;
begin
  vQryCadastrarEvento := TFDQuery.Create(nil);
  try
    vQryCadastrarEvento.Connection := Conexao;
    vQryCadastrarEvento.SQL.Add(RetornarSQLCadastrarEvento);
    try

      vQryCadastrarEvento.ParamByName('ID_DOCUMENTO').AsInteger  := ADocEvento.IdDocumento;
      vQryCadastrarEvento.ParamByName('DT_EVENTO').AsDateTime    := ADocEvento.DtEvento;
      vQryCadastrarEvento.ParamByName('TIPO_EVENTO').AsString    := ADocEvento.TipoEvento;
      vQryCadastrarEvento.ParamByName('STATUS_ANTES').AsString   := ADocEvento.StatusAntes;
      vQryCadastrarEvento.ParamByName('STATUS_DEPOIS').AsString  := ADocEvento.StatusDepois;
      vQryCadastrarEvento.ParamByName('MENSAGEM').AsString       := ADocEvento.Mensagem;
      vQryCadastrarEvento.ParamByName('DETALHE').AsString        := ADocEvento.Detalhe;
      vQryCadastrarEvento.ParamByName('USUARIO').AsString        := ADocEvento.Usuario;

      vQryCadastrarEvento.ExecSQL;
      Result := vQryCadastrarEvento.RowsAffected > 0;

    except
     on E: Exception do
      begin
        raise Exception.Create('Erro ao cadastrar eventos: '+  E.Message);
      end;

    end;

  finally
    vQryCadastrarEvento.Free;
  end;

end;

constructor TDaoDocumentoEvento.Create(AConexao: TFDConnection);
begin
  FConexao := AConexao;
end;

destructor TDaoDocumentoEvento.Destroy;
begin
  // Implementação do destrutor, se necessário
  inherited;
end;

function TDaoDocumentoEvento.RetornarDataSetDocumentoEvento(const AIdDocumento: Integer): TFDQuery;
begin
  Result   := TFDQuery.Create(nil);
  try
    Result.Connection := Conexao;
    Result.SQL.Add(RetornarSQLDocumentoEvento);
    Result.ParamByName('ID_DOCUMENTO').AsInteger := AIdDocumento;
    Result.Open();
  except
     on E: Exception do
       raise Exception.Create('Erro ao consultar eventos de documento: ' + E.Message);
  end

end;

function TDaoDocumentoEvento.RetornarSQLCadastrarEvento: String;
var
  vSQLEvento : TStringList;
begin
  vSQLEvento := TStringList.Create;
  try
    vSQLEvento.Add('INSERT INTO DOCUMENTO_EVENTO                             ');
    vSQLEvento.Add('(                                                        ');
    vSQLEvento.Add('ID_DOCUMENTO                                             ');
    vSQLEvento.Add(',DT_EVENTO                                               ');
    vSQLEvento.Add(',TIPO_EVENTO                                             ');
    vSQLEvento.Add(',STATUS_ANTES                                            ');
    vSQLEvento.Add(',STATUS_DEPOIS                                           ');
    vSQLEvento.Add(',MENSAGEM                                                ');
    vSQLEvento.Add(',DETALHE                                                 ');
    vSQLEvento.Add(',USUARIO                                                 ');
    vSQLEvento.Add(')                                                        ');
    vSQLEvento.Add('VALUES                                                   ');
    vSQLEvento.Add('(                                                        ');
    vSQLEvento.Add(':ID_DOCUMENTO                                            ');
    vSQLEvento.Add(',:DT_EVENTO                                              ');
    vSQLEvento.Add(',:TIPO_EVENTO                                            ');
    vSQLEvento.Add(',:STATUS_ANTES                                           ');
    vSQLEvento.Add(',:STATUS_DEPOIS                                          ');
    vSQLEvento.Add(',:MENSAGEM                                               ');
    vSQLEvento.Add(',:DETALHE                                                ');
    vSQLEvento.Add(',:USUARIO                                                ');
    vSQLEvento.Add(')                                                        ');

    Result := vSQLEvento.Text;
  finally
    FreeAndNil(vSQLEvento);
  end;


end;

function TDaoDocumentoEvento.RetornarSQLDocumentoEvento: string;
var
  vSQLDocEvento : TStringList;
begin
  vSQLDocEvento := TStringList.Create;
  try
    vSQLDocEvento.Add('SELECT * FROM DOCUMENTO_EVENTO    ');
    vSQLDocEvento.Add('WHERE ID_DOCUMENTO =:ID_DOCUMENTO ');
    vSQLDocEvento.Add('ORDER BY ID_EVENTO                ');
    Result := vSQLDocEvento.Text;
  finally
    vSQLDocEvento.Free;
  end;

end;
 
end.