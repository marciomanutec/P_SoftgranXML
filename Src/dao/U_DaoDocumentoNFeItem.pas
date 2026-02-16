unit U_DaoDocumentoNFeItem;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  U_DocumentoNfeItem;

type
  TDaoDocumentoNFeItem = class
  private
    FConexao: TFDConnection;
    function RetornarSQLDocumentoNFeItem:String;
    function RetornarSQLCadastrarItens:String;
  public
    constructor Create(AConexao: TFDConnection);
    function RetornarDataSetDocumentoNFeItem(const AIdDocumento:Integer):TFDQuery;
    function CadastrarXMLItem(ADocNFeItem: TDocumentoNfeItem): Boolean;
    property Conexao: TFDConnection read FConexao write FConexao;
  end;


implementation

{ TDaoDocumentoNFeItem }

function TDaoDocumentoNFeItem.CadastrarXMLItem(ADocNFeItem: TDocumentoNfeItem): Boolean;
var
  vQryCadastrarXMLItem : TFDQuery;
begin
  vQryCadastrarXMLItem := TFDQuery.Create(nil);
  try
    vQryCadastrarXMLItem.Connection := Conexao;
    vQryCadastrarXMLItem.SQL.Add(RetornarSQLCadastrarItens);
    try
      vQryCadastrarXMLItem.ParamByName('ID_DOCUMENTO').AsInteger   := ADocNFeItem.IdDocumento;
      vQryCadastrarXMLItem.ParamByName('ITEM').AsInteger           := ADocNFeItem.Item;
      vQryCadastrarXMLItem.ParamByName('DESCRICAO').AsString       := ADocNFeItem.Descricao;
      vQryCadastrarXMLItem.ParamByName('NCM').AsString             := ADocNFeItem.Ncm;
      vQryCadastrarXMLItem.ParamByName('QUANTIDADE').AsExtended    := ADocNFeItem.Quantidade;
      vQryCadastrarXMLItem.ParamByName('VL_UNITARIO').AsCurrency   := ADocNFeItem.VlUnitario;
      vQryCadastrarXMLItem.ParamByName('VL_TOTAL').AsCurrency      := ADocNFeItem.VlTotal;

      vQryCadastrarXMLItem.ExecSQL;
      Result := vQryCadastrarXMLItem.RowsAffected > 0;

    except
     on E: Exception do
      begin
        raise Exception.Create('Erro ao cadastrar xml itens: '+  E.Message);
      end;

    end;

  finally
    vQryCadastrarXMLItem.Free;
  end;
end;

constructor TDaoDocumentoNFeItem.Create(AConexao: TFDConnection);
begin
  FConexao := AConexao;
end;

function TDaoDocumentoNFeItem.RetornarDataSetDocumentoNFeItem(const AIdDocumento:Integer):TFDQuery;
begin
  Result   := TFDQuery.Create(nil);
  try
    Result.Connection := Conexao;
    Result.SQL.Add(RetornarSQLDocumentoNFeItem);
    Result.ParamByName('ID_DOCUMENTO').AsInteger := AIdDocumento;
    Result.Open();
  except
     on E: Exception do
       raise Exception.Create('Erro ao consultar os itens do DocumentoNFe: ' + E.Message);
  end;
end;

function TDaoDocumentoNFeItem.RetornarSQLCadastrarItens: String;
var
  vSQLXMLItem : TStringList;
begin
  vSQLXMLItem := TStringList.Create;
  try
    vSQLXMLItem.Add('INSERT INTO DOCUMENTO_NFE_ITEM                           ');
    vSQLXMLItem.Add('(                                                        ');
    vSQLXMLItem.Add('ID_DOCUMENTO                                             ');
    vSQLXMLItem.Add(',ITEM                                                    ');
    vSQLXMLItem.Add(',DESCRICAO                                               ');
    vSQLXMLItem.Add(',NCM                                                     ');
    vSQLXMLItem.Add(',QUANTIDADE                                              ');
    vSQLXMLItem.Add(',VL_UNITARIO                                             ');
    vSQLXMLItem.Add(',VL_TOTAL                                                ');
    vSQLXMLItem.Add(')                                                        ');
    vSQLXMLItem.Add('VALUES                                                   ');
    vSQLXMLItem.Add('(                                                        ');
    vSQLXMLItem.Add(':ID_DOCUMENTO                                            ');
    vSQLXMLItem.Add(',:ITEM                                                   ');
    vSQLXMLItem.Add(',:DESCRICAO                                              ');
    vSQLXMLItem.Add(',:NCM                                                    ');
    vSQLXMLItem.Add(',:QUANTIDADE                                             ');
    vSQLXMLItem.Add(',:VL_UNITARIO                                            ');
    vSQLXMLItem.Add(',:VL_TOTAL                                               ');
    vSQLXMLItem.Add(')                                                        ');

    Result := vSQLXMLItem.Text;
  finally
    FreeAndNil(vSQLXMLItem);
  end;


end;

function TDaoDocumentoNFeItem.RetornarSQLDocumentoNFeItem: String;
var
  vSQLDocNFeItem : TStringList;
begin
  vSQLDocNFeItem := TStringList.Create;
  try
    vSQLDocNFeItem.Add('SELECT * FROM DOCUMENTO_NFE_ITEM  ');
    vSQLDocNFeItem.Add('WHERE ID_DOCUMENTO =:ID_DOCUMENTO ');
    vSQLDocNFeItem.Add('ORDER BY ID_ITEM                  ');
    Result := vSQLDocNFeItem.Text;
  finally
    vSQLDocNFeItem.Free;
  end;

end;

end.
