unit U_DaoDocumentoNFe;

interface

uses
  System.SysUtils,
  System.Classes,
  U_ConexaoFirebird,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  U_DocumentoNfe;

type
  TDaoDocumentoNFe = class
  private
    FConectar: TConexaoFirebird;
    function RetornarSQLDocumentoNFe:String;
    function RetornarSQLCadastrarXML:String;
    function RetornarSQLAlteracaoXML:String;
    function RetornarSQLVerificaChaveAcesso:String;
  public
    constructor Create;
    destructor  Destroy; override;
    function RetornarDataSetDocumentoNFe:TFDQuery;
    function RetornarDataSetDocumentoNFeItem(const AIdDocumento:Integer):TFDQuery;
    function RetornarDataSetDocumentoEvento(const AIdDocumento:Integer):TFDQuery;
    function CadastrarXML(ADocumento: TDocumentoNfe): Boolean;
    function Processar(const ADocNfe: TDocumentoNfe): Boolean;
    function Reprocessar(const ADocNFe: TDocumentoNfe):Boolean;
    function VerificarSeExisteChaveAcesso(const AChave:String) : Boolean;
    property Conectar: TConexaoFirebird  read FConectar write FConectar;
  end;

implementation

{ TDaoDocumentoNFe }

uses U_DaoDocumentoNFeItem,
     U_DaoDocumentoEvento;

function TDaoDocumentoNFe.CadastrarXML(ADocumento: TDocumentoNfe): Boolean;
var
  vQryCadastrarXML : TFDQuery;
  vConexao         : TFDConnection;
  vDocNFeItemDao   : TDaoDocumentoNFeItem;
  vDocEventoDao    : TDaoDocumentoEvento;
  vIndex           : Integer;
begin
  vQryCadastrarXML := TFDQuery.Create(nil);
  try
    vConexao                    := Conectar.ConexaoFirebird;
    vQryCadastrarXML.Connection := vConexao;
    vQryCadastrarXML.SQL.Add(RetornarSQLCadastrarXML);
    vConexao.StartTransaction;
    try
      // Parametros do Cabecalho
      vQryCadastrarXML.ParamByName('CHAVE_ACESSO').AsString    := ADocumento.ChaveAcesso;
      vQryCadastrarXML.ParamByName('NUMERO').AsString          := ADocumento.Numero;
      vQryCadastrarXML.ParamByName('SERIE').AsString           := ADocumento.Serie;
      vQryCadastrarXML.ParamByName('DT_EMISSAO').AsDateTime    := ADocumento.DtEmissao;
      vQryCadastrarXML.ParamByName('EMIT_CNPJ_CPF').AsString   := ADocumento.EmitCnpjCpf;
      vQryCadastrarXML.ParamByName('EMIT_RAZAO').AsString      := ADocumento.EmitRazao;
      vQryCadastrarXML.ParamByName('DEST_CNPJ_CPF').AsString   := ADocumento.DestCnpjCpf;
      vQryCadastrarXML.ParamByName('DEST_RAZAO').AsString      := ADocumento.DestRazao;
      vQryCadastrarXML.ParamByName('VL_TOTAL').AsCurrency      := ADocumento.VlTotal;
      vQryCadastrarXML.ParamByName('STATUS_PROC').AsString     := ADocumento.StatusProc;
      vQryCadastrarXML.ParamByName('MSG_STATUS').AsString      := ADocumento.MsgStatus;
      vQryCadastrarXML.ParamByName('ARQUIVO_NOME').AsString    := ADocumento.ArquivoNome;
      vQryCadastrarXML.ParamByName('XML_CONTEUDO').AsString    := ADocumento.XmlConteudo;
      vQryCadastrarXML.ParamByName('DT_IMPORTACAO').AsDateTime := ADocumento.DtImportacao;

      vQryCadastrarXML.Open();
      Result                  := vQryCadastrarXML.RowsAffected > 0;
      ADocumento.IdDocumento  := vQryCadastrarXML.Fields[0].AsInteger;

      // Inserindo os Itens
      if (Result) and (ADocumento.IdDocumento > 0) and (ADocumento.Itens.Count > 0) then
      begin
        vDocNFeItemDao   :=  TDaoDocumentoNFeItem.Create(vConexao);
        try
          for vIndex := 0 to Pred(ADocumento.Itens.Count) do
          begin
            ADocumento.Itens[vIndex].IdDocumento   := ADocumento.IdDocumento;
            vDocNFeItemDao.CadastrarXMLItem(ADocumento.Itens[vIndex]);
            ADocumento.Itens[vIndex].Free;
          end;
        finally
          vDocNFeItemDao.Free;
        end;

      end;

       // Inserindo os Eventos
      if (Result) and (ADocumento.IdDocumento > 0) then
      begin
        vDocEventoDao  := TDaoDocumentoEvento.Create(vConexao);
        try
          ADocumento.Eventos[0].IdDocumento := ADocumento.IdDocumento;
          vDocEventoDao.CadastrarDocumentoEvento(ADocumento.Eventos[0]);
          ADocumento.Eventos[0].Free;
        finally
          vDocEventoDao.Free;
        end;
      end;

      vConexao.Commit;

    except
     on E: Exception do
      begin
        vConexao.Rollback;
        raise Exception.Create('Erro ao cadastrar xml: '+  E.Message);
      end;

    end;

  finally
    vQryCadastrarXML.Free;
  end;

end;

constructor TDaoDocumentoNFe.Create;
begin
  FConectar := TConexaoFirebird.Create;
end;

destructor TDaoDocumentoNFe.Destroy;
begin
  if Assigned(FConectar) then
    FConectar.Free;
  inherited;
end;

function TDaoDocumentoNFe.Processar(const ADocNfe: TDocumentoNfe): Boolean;
var
  vQryProcessarXML : TFDQuery;
  vConexao         : TFDConnection;
  vDocEventoDao    : TDaoDocumentoEvento;
begin
  vQryProcessarXML := TFDQuery.Create(nil);
  try
    vConexao                    := Conectar.ConexaoFirebird;
    vQryProcessarXML.Connection := vConexao;
    vQryProcessarXML.SQL.Add(RetornarSQLAlteracaoXML);
    vConexao.StartTransaction;
    try
      // Parametros do Cabecalho
      vQryProcessarXML.ParamByName('ID_DOCUMENTO').AsInteger   := ADocNfe.IdDocumento;
      vQryProcessarXML.ParamByName('CHAVE_ACESSO').AsString    := ADocNfe.ChaveAcesso;
      vQryProcessarXML.ParamByName('NUMERO').AsString          := ADocNfe.Numero;
      vQryProcessarXML.ParamByName('SERIE').AsString           := ADocNfe.Serie;
      vQryProcessarXML.ParamByName('DT_EMISSAO').AsDateTime    := ADocNfe.DtEmissao;
      vQryProcessarXML.ParamByName('EMIT_CNPJ_CPF').AsString   := ADocNfe.EmitCnpjCpf;
      vQryProcessarXML.ParamByName('EMIT_RAZAO').AsString      := ADocNfe.EmitRazao;
      vQryProcessarXML.ParamByName('DEST_CNPJ_CPF').AsString   := ADocNfe.DestCnpjCpf;
      vQryProcessarXML.ParamByName('DEST_RAZAO').AsString      := ADocNfe.DestRazao;
      vQryProcessarXML.ParamByName('VL_TOTAL').AsCurrency      := ADocNfe.VlTotal;
      vQryProcessarXML.ParamByName('STATUS_PROC').AsString     := ADocNfe.StatusProc;
      vQryProcessarXML.ParamByName('MSG_STATUS').AsString      := ADocNfe.MsgStatus;
      vQryProcessarXML.ParamByName('ARQUIVO_NOME').AsString    := ADocNfe.ArquivoNome;
      vQryProcessarXML.ParamByName('XML_CONTEUDO').AsString    := ADocNfe.XmlConteudo;

      vQryProcessarXML.ExecSQL;
      Result       := vQryProcessarXML.RowsAffected > 0;

       // Inserindo os Eventos
      if (Result) then
      begin
        vDocEventoDao  := TDaoDocumentoEvento.Create(vConexao);
        try
          vDocEventoDao.CadastrarDocumentoEvento(ADocNfe.Eventos[0]);
          ADocNfe.Eventos[0].Free;
        finally
          vDocEventoDao.Free;
        end;
      end;

      vConexao.Commit;

    except
     on E: Exception do
      begin
        vConexao.Rollback;
        raise Exception.Create('Erro ao processar xml: '+  E.Message);
      end;

    end;

  finally
    vQryProcessarXML.Free;
  end;


end;

function TDaoDocumentoNFe.Reprocessar(const ADocNFe: TDocumentoNfe): Boolean;
var
  vQryReprocessarXML : TFDQuery;
  vConexao           : TFDConnection;
  vDocNFeItemDao     : TDaoDocumentoNFeItem;
  vDocEventoDao      : TDaoDocumentoEvento;
  vIndex             : Integer;
begin
  vQryReprocessarXML := TFDQuery.Create(nil);
  try
    vConexao                      := Conectar.ConexaoFirebird;
    vQryReprocessarXML.Connection := vConexao;
    vQryReprocessarXML.SQL.Add(RetornarSQLAlteracaoXML);
    vConexao.StartTransaction;
    try
      // Parametros do Cabecalho
      vQryReprocessarXML.ParamByName('ID_DOCUMENTO').AsInteger   := ADocNfe.IdDocumento;
      vQryReprocessarXML.ParamByName('CHAVE_ACESSO').AsString    := ADocNfe.ChaveAcesso;
      vQryReprocessarXML.ParamByName('NUMERO').AsString          := ADocNfe.Numero;
      vQryReprocessarXML.ParamByName('SERIE').AsString           := ADocNfe.Serie;
      vQryReprocessarXML.ParamByName('DT_EMISSAO').AsDateTime    := ADocNfe.DtEmissao;
      vQryReprocessarXML.ParamByName('EMIT_CNPJ_CPF').AsString   := ADocNfe.EmitCnpjCpf;
      vQryReprocessarXML.ParamByName('EMIT_RAZAO').AsString      := ADocNfe.EmitRazao;
      vQryReprocessarXML.ParamByName('DEST_CNPJ_CPF').AsString   := ADocNfe.DestCnpjCpf;
      vQryReprocessarXML.ParamByName('DEST_RAZAO').AsString      := ADocNfe.DestRazao;
      vQryReprocessarXML.ParamByName('VL_TOTAL').AsCurrency      := ADocNfe.VlTotal;
      vQryReprocessarXML.ParamByName('STATUS_PROC').AsString     := ADocNfe.StatusProc;
      vQryReprocessarXML.ParamByName('MSG_STATUS').AsString      := ADocNfe.MsgStatus;
      vQryReprocessarXML.ParamByName('ARQUIVO_NOME').AsString    := ADocNfe.ArquivoNome;
      vQryReprocessarXML.ParamByName('XML_CONTEUDO').AsString    := ADocNfe.XmlConteudo;

      vQryReprocessarXML.ExecSQL;
      Result       := vQryReprocessarXML.RowsAffected > 0;

      // Inserindo os Itens
      if (Result) and (ADocNfe.Itens.Count > 0) then
      begin
        vDocNFeItemDao    := TDaoDocumentoNFeItem.Create(vConexao);
        try
          for vIndex := 0 to Pred(ADocNfe.Itens.Count) do
          begin
            vDocNFeItemDao.CadastrarXMLItem(ADocNfe.Itens[vIndex]);
            ADocNfe.Itens[vIndex].Free;
          end;
        finally
          vDocNFeItemDao.Free;
        end;

      end;

       // Inserindo os Eventos
      if (Result) then
      begin
        vDocEventoDao  := TDaoDocumentoEvento.Create(vConexao);
        try
          vDocEventoDao.CadastrarDocumentoEvento(ADocNfe.Eventos[0]);
          ADocNfe.Eventos[0].Free;
        finally
          vDocEventoDao.Free;
        end;
      end;

      vConexao.Commit;

    except
     on E: Exception do
      begin
        vConexao.Rollback;
        raise Exception.Create('Erro ao reprocessar xml: '+  E.Message);
      end;

    end;

  finally
    vQryReprocessarXML.Free;
  end;

end;

function TDaoDocumentoNFe.RetornarDataSetDocumentoEvento(const AIdDocumento: Integer): TFDQuery;
var
  vDocEventoDao : TDaoDocumentoEvento;
begin
  vDocEventoDao := TDaoDocumentoEvento.Create(Conectar.ConexaoFirebird);
  try
    Result := vDocEventoDao.RetornarDataSetDocumentoEvento(AIdDocumento);
  finally
    vDocEventoDao.Free;
  end;

end;

function TDaoDocumentoNFe.RetornarDataSetDocumentoNFe: TFDQuery;
begin
  Result   := TFDQuery.Create(nil);
  try
    Result.Connection := Conectar.ConexaoFirebird;
    Result.SQL.Add(RetornarSQLDocumentoNFe);
    Result.Open();
  except
     on E: Exception do
       raise Exception.Create('Erro ao consultar Documento NFe: ' + E.Message);
  end;
end;

function TDaoDocumentoNFe.RetornarDataSetDocumentoNFeItem(const AIdDocumento:Integer):TFDQuery;
var
  vDocNFeItemDao : TDaoDocumentoNFeItem;
begin
  vDocNFeItemDao := TDaoDocumentoNFeItem.Create(Conectar.ConexaoFirebird);
  try
    Result := vDocNFeItemDao.RetornarDataSetDocumentoNFeItem(AIdDocumento);
  finally
    vDocNFeItemDao.Free;
  end;
end;

function TDaoDocumentoNFe.RetornarSQLAlteracaoXML: String;
var
 vSQLAlterar : TStringList;
begin
  vSQLAlterar := TStringList.Create;
  try
    vSQLAlterar.Add('UPDATE DOCUMENTO_NFE                                      ');
    vSQLAlterar.Add('SET NUMERO = :NUMERO, SERIE = :SERIE,                     ');
    vSQLAlterar.Add('DT_EMISSAO = :DT_EMISSAO, EMIT_CNPJ_CPF = :EMIT_CNPJ_CPF, ');
    vSQLAlterar.Add('EMIT_RAZAO = :EMIT_RAZAO, DEST_CNPJ_CPF = :DEST_CNPJ_CPF, ');
    vSQLAlterar.Add('DEST_RAZAO = :DEST_RAZAO, VL_TOTAL = :VL_TOTAL,           ');
    vSQLAlterar.Add('STATUS_PROC = :STATUS_PROC, MSG_STATUS = :MSG_STATUS,     ');
    vSQLAlterar.Add('ARQUIVO_NOME = :ARQUIVO_NOME, XML_CONTEUDO = :XML_CONTEUDO');
    vSQLAlterar.Add('WHERE ID_DOCUMENTO = :ID_DOCUMENTO                        ');
    vSQLAlterar.Add('AND CHAVE_ACESSO = :CHAVE_ACESSO                          ');

    Result := vSQLAlterar.Text;

  finally
    vSQLAlterar.Free;
  end;

end;

function TDaoDocumentoNFe.RetornarSQLCadastrarXML: String;
var
  vSQLCadastrarXML : TStringList;
begin
  vSQLCadastrarXML := TStringList.Create;
  try
    vSQLCadastrarXML.Add('INSERT INTO DOCUMENTO_NFE                                ');
    vSQLCadastrarXML.Add('(                                                        ');
    vSQLCadastrarXML.Add('CHAVE_ACESSO                                             ');
    vSQLCadastrarXML.Add(',NUMERO                                                  ');
    vSQLCadastrarXML.Add(',SERIE                                                   ');
    vSQLCadastrarXML.Add(',DT_EMISSAO                                              ');
    vSQLCadastrarXML.Add(',EMIT_CNPJ_CPF                                           ');
    vSQLCadastrarXML.Add(',EMIT_RAZAO                                              ');
    vSQLCadastrarXML.Add(',DEST_CNPJ_CPF                                           ');
    vSQLCadastrarXML.Add(',DEST_RAZAO                                              ');
    vSQLCadastrarXML.Add(',VL_TOTAL                                                ');
    vSQLCadastrarXML.Add(',STATUS_PROC                                             ');
    vSQLCadastrarXML.Add(',MSG_STATUS                                              ');
    vSQLCadastrarXML.Add(',ARQUIVO_NOME                                            ');
    vSQLCadastrarXML.Add(',XML_CONTEUDO                                            ');
    vSQLCadastrarXML.Add(',DT_IMPORTACAO                                           ');

    vSQLCadastrarXML.Add(')                                                        ');
    vSQLCadastrarXML.Add('VALUES                                                   ');
    vSQLCadastrarXML.Add('(                                                        ');
    vSQLCadastrarXML.Add(':CHAVE_ACESSO                                            ');
    vSQLCadastrarXML.Add(',:NUMERO                                                 ');
    vSQLCadastrarXML.Add(',:SERIE                                                  ');
    vSQLCadastrarXML.Add(',:DT_EMISSAO                                             ');
    vSQLCadastrarXML.Add(',:EMIT_CNPJ_CPF                                          ');
    vSQLCadastrarXML.Add(',:EMIT_RAZAO                                             ');
    vSQLCadastrarXML.Add(',:DEST_CNPJ_CPF                                          ');
    vSQLCadastrarXML.Add(',:DEST_RAZAO                                             ');
    vSQLCadastrarXML.Add(',:VL_TOTAL                                               ');
    vSQLCadastrarXML.Add(',:STATUS_PROC                                            ');
    vSQLCadastrarXML.Add(',:MSG_STATUS                                             ');
    vSQLCadastrarXML.Add(',:ARQUIVO_NOME                                           ');
    vSQLCadastrarXML.Add(',:XML_CONTEUDO                                           ');
    vSQLCadastrarXML.Add(',:DT_IMPORTACAO                                          ');
    vSQLCadastrarXML.Add(')                                                        ');
    vSQLCadastrarXML.Add('RETURNING ID_DOCUMENTO                                   ');

    Result := vSQLCadastrarXML.Text;
  finally
    FreeAndNil(vSQLCadastrarXML);
  end;


end;

function TDaoDocumentoNFe.RetornarSQLDocumentoNFe: String;
var
  vSQLDocNFe : TStringList;
begin
  vSQLDocNFe := TStringList.Create;
  try
    vSQLDocNFe.Add('SELECT * FROM DOCUMENTO_NFE ORDER BY ID_DOCUMENTO ');
    Result := vSQLDocNFe.Text;
  finally
    vSQLDocNFe.Free;
  end;
end;

function TDaoDocumentoNFe.RetornarSQLVerificaChaveAcesso: String;
var
  vSQLDocNFe : TStringList;
begin
  vSQLDocNFe := TStringList.Create;
  try
    vSQLDocNFe.Add('SELECT CHAVE_ACESSO FROM DOCUMENTO_NFE');
    vSQLDocNFe.Add('WHERE CHAVE_ACESSO =:CHAVE_ACESSO     ');
    Result := vSQLDocNFe.Text;
  finally
    vSQLDocNFe.Free;
  end;
end;

function TDaoDocumentoNFe.VerificarSeExisteChaveAcesso(const AChave: String): Boolean;
var
  vQryVerificaChave : TFDQuery;
begin
  vQryVerificaChave := TFDQuery.Create(nil);
  try
    try
      vQryVerificaChave.Connection := Conectar.ConexaoFirebird;
      vQryVerificaChave.SQL.Add(RetornarSQLVerificaChaveAcesso);
      vQryVerificaChave.ParamByName('CHAVE_ACESSO').AsString := AChave;
      vQryVerificaChave.Open();
      Result := not vQryVerificaChave.IsEmpty;
    except
      on E: Exception do
       raise Exception.Create('Erro ao verificar chave de acesso: ' + E.Message);
    end;
  finally
    vQryVerificaChave.Free;
  end;


end;

end.
