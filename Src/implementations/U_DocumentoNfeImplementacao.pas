unit U_DocumentoNfeImplementacao;
 
interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  U_IDocumentoNfe,
  U_DocumentoNfe,
  U_DocumentoNfeItem,
  U_DocumentoEvento,
  U_DaoDocumentoNFe;


type
  TDocumentoNfeImplementacao = class(TInterfacedObject, IDocumentoNfe)
  private
    FDocumentoNFeDao : TDaoDocumentoNFe;
    function VerificarSeExisteChaveAcesso(const AChave:String) : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function SelecionarXML : String;
    function ImportarXML(const ANomeArquivo:String): TDocumentoNfe;
    function CadastrarXML(ADocNfe: TDocumentoNfe)  : Boolean;
    function Processar(ADocNfe : TDocumentoNfe) : Boolean;
    function Reprocessar(ADocNfe: TDocumentoNfe) : TDocumentoNfe;
    function ConsultarDocNFe:TList<TDocumentoNfe>;
    function ConsultarDocNFeItem(const AIdDocumento:Integer):TList<TDocumentoNfeItem>;
    function ConsultarDocEvento(const AIdDocumento:Integer):TList<TDocumentoEvento>;

  end;

implementation

uses  Vcl.Dialogs,
      Winapi.Windows,
      Vcl.Forms,
      ACBrBase,
      ACBrDFe,
      ACBrNFe,
      Data.DB;

 
{ TDocumentoNfeImplementacao }

function TDocumentoNfeImplementacao.ImportarXML(const ANomeArquivo: String): TDocumentoNfe;
var
  vACBrNFe    : TACBrNFe;
  vDocNfeItem : TDocumentoNfeItem;
  vDocEvento  : TDocumentoEvento;
  vIndex      : Integer;
begin
  if ANomeArquivo.IsEmpty then
    raise Exception.Create('Nome do arquivo xml não informado');

  if not FileExists(ANomeArquivo) then
    raise Exception.Create('O arquivo xml informado não existe');

  vACBrNFe := TACBrNFe.Create(nil);
  Result   := TDocumentoNfe.Create;
  try

    try
      // Carrega o XML selecionado
      vACBrNFe.NotasFiscais.LoadFromFile(ANomeArquivo);

       //      Result.ChaveAcesso := vACBrNFe.NotasFiscais.Items[0].NFe.infNFe.ID;
      Result.ChaveAcesso := vACBrNFe.NotasFiscais.Items[0].NFe.procNFe.chNFe;

      if Result.ChaveAcesso.IsEmpty then
      begin
        Result.ExisteChaveAcesso := True;
        Application.MessageBox(Pchar('Não existe chave de acesso no xml'), 'Importação de XML', MB_ICONERROR);
        exit;
      end;

      if VerificarSeExisteChaveAcesso(Result.ChaveAcesso) then
      begin
        Result.ExisteChaveAcesso := True;
        Application.MessageBox(Pchar('A chave de Acesso já existe'), 'Importação de XML', MB_ICONWARNING);
        exit;
      end;

      Result.Numero      := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.nNF.ToString;
      Result.Serie       := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.serie.ToString;
      Result.DtEmissao   := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.dEmi;
      Result.EmitCnpjCpf := vACBrNFe.NotasFiscais.Items[0].NFe.Emit.CNPJCPF;
      Result.EmitRazao   := vACBrNFe.NotasFiscais.Items[0].NFe.Emit.xNome;
      Result.DestCnpjCpf := vACBrNFe.NotasFiscais.Items[0].NFe.Dest.CNPJCPF;
      Result.DestRazao   := vACBrNFe.NotasFiscais.Items[0].NFe.Dest.xNome;
      Result.VlTotal     := vACBrNFe.NotasFiscais.Items[0].NFe.Total.ICMSTot.vNF;
      Result.StatusProc  := 'NOVO';
      Result.MsgStatus   := 'XML IMPORTADO COM SUCESSO';
      Result.ArquivoNome := vACBrNFe.NotasFiscais.Items[0].NomeArq;
      Result.XmlConteudo := vACBrNFe.NotasFiscais.Items[0].XML;
      Result.DtImportacao:= Now;


      // Adicionando os itens
      for vIndex := 0 to vACBrNFe.NotasFiscais.Items[0].NFe.Det.Count - 1 do
      begin
        vDocNfeItem           := TDocumentoNfeItem.Create;
        vDocNfeItem.Item      := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.cProd.ToInteger;
        vDocNfeItem.Descricao := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.xProd;
        vDocNfeItem.Quantidade:= vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.qCom;
        vDocNfeItem.Ncm       := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.NCM;
        vDocNfeItem.VlUnitario:= vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.vProd;
        vDocNfeItem.VlTotal   := vDocNfeItem.Quantidade * vDocNfeItem.VlUnitario;

        Result.Itens.Add(vDocNfeItem);

      end;

      // Registrando Evento de Criação
      vDocEvento  := TDocumentoEvento.Create;
      vDocEvento.DtEvento     := Now;
      vDocEvento.TipoEvento   := 'CRIADO';
      vDocEvento.StatusDepois := 'NOVO';
      vDocEvento.Mensagem     := Result.MsgStatus;
      vDocEvento.Usuario      := 'USER_LOGADO';
      Result.Eventos.Add(vDocEvento);

    except
      on E: Exception do
      begin
        Result.Free;
        raise Exception.Create('Erro ao importar XML: '+ E.Message);
      end;
    end;

  finally
    vACBrNFe.Free;
  end;

end;

function TDocumentoNfeImplementacao.CadastrarXML(ADocNfe: TDocumentoNfe)  : Boolean;
begin
  Result  := FDocumentoNFeDao.CadastrarXML(ADocNfe);
end;

function TDocumentoNfeImplementacao.ConsultarDocEvento(const AIdDocumento: Integer): TList<TDocumentoEvento>;
var
  vDataSetDocEvento    : TDataSet;
  vDocumentoEvento     : TDocumentoEvento;
begin
  vDataSetDocEvento   := FDocumentoNFeDao.RetornarDataSetDocumentoEvento(AIdDocumento);
  Result              := TList<TDocumentoEvento>.Create;
  try
    vDataSetDocEvento.First;
    while not vDataSetDocEvento.Eof do
    begin
      // Preencher eventos
      vDocumentoEvento             := TDocumentoEvento.Create;
      vDocumentoEvento.IdEvento    := vDataSetDocEvento.FieldByName('ID_EVENTO').AsInteger;
      vDocumentoEvento.IdDocumento := vDataSetDocEvento.FieldByName('ID_DOCUMENTO').AsInteger;
      vDocumentoEvento.DtEvento    := vDataSetDocEvento.FieldByName('DT_EVENTO').AsDateTime;
      vDocumentoEvento.TipoEvento  := vDataSetDocEvento.FieldByName('TIPO_EVENTO').AsString;
      vDocumentoEvento.StatusAntes := vDataSetDocEvento.FieldByName('STATUS_ANTES').AsString;
      vDocumentoEvento.StatusDepois:= vDataSetDocEvento.FieldByName('STATUS_DEPOIS').AsString;
      vDocumentoEvento.Mensagem    := vDataSetDocEvento.FieldByName('MENSAGEM').AsString;
      vDocumentoEvento.Detalhe     := vDataSetDocEvento.FieldByName('DETALHE').AsString;
      vDocumentoEvento.Usuario     := vDataSetDocEvento.FieldByName('USUARIO').AsString;

      Result.Add(vDocumentoEvento);

      vDataSetDocEvento.Next;
    end;

  finally
    vDataSetDocEvento.Free;
  end;

end;

function TDocumentoNfeImplementacao.ConsultarDocNFe:TList<TDocumentoNfe>;
var
  vDataSetDocNFe   : TDataSet;
  vDocumentoNFe    : TDocumentoNfe;
begin
  vDataSetDocNFe   := FDocumentoNFeDao.RetornarDataSetDocumentoNFe;
  Result           := TList<TDocumentoNfe>.Create;
  try
    vDataSetDocNFe.First;
    while not vDataSetDocNFe.Eof do
    begin
      // Preencher Cabecalho
      vDocumentoNFe             := TDocumentoNfe.Create;
      vDocumentoNFe.IdDocumento := vDataSetDocNFe.FieldByName('ID_DOCUMENTO').AsInteger;
      vDocumentoNFe.ChaveAcesso := vDataSetDocNFe.FieldByName('CHAVE_ACESSO').AsString;
      vDocumentoNFe.Numero      := vDataSetDocNFe.FieldByName('NUMERO').AsString;
      vDocumentoNFe.Serie       := vDataSetDocNFe.FieldByName('SERIE').AsString;
      vDocumentoNFe.DtEmissao   := vDataSetDocNFe.FieldByName('DT_EMISSAO').AsDateTime;
      vDocumentoNFe.EmitCnpjCpf := vDataSetDocNFe.FieldByName('EMIT_CNPJ_CPF').AsString;
      vDocumentoNFe.EmitRazao   := vDataSetDocNFe.FieldByName('EMIT_RAZAO').AsString;
      vDocumentoNFe.DestCnpjCpf := vDataSetDocNFe.FieldByName('DEST_CNPJ_CPF').AsString;
      vDocumentoNFe.DestRazao   := vDataSetDocNFe.FieldByName('DEST_RAZAO').AsString;
      vDocumentoNFe.VlTotal     := vDataSetDocNFe.FieldByName('VL_TOTAL').AsCurrency;
      vDocumentoNFe.StatusProc  := vDataSetDocNFe.FieldByName('STATUS_PROC').AsString;
      vDocumentoNFe.MsgStatus   := vDataSetDocNFe.FieldByName('MSG_STATUS').AsString;
      vDocumentoNFe.ArquivoNome := vDataSetDocNFe.FieldByName('ARQUIVO_NOME').AsString;
      vDocumentoNFe.XmlConteudo := vDataSetDocNFe.FieldByName('XML_CONTEUDO').AsString;
      vDocumentoNFe.DtImportacao:= vDataSetDocNFe.FieldByName('DT_IMPORTACAO').AsDateTime;

      Result.Add(vDocumentoNFe);

      vDataSetDocNFe.Next;
    end;


  finally
    vDataSetDocNFe.Free;
  end;

end;

function TDocumentoNfeImplementacao.ConsultarDocNFeItem(const AIdDocumento:Integer):TList<TDocumentoNfeItem>;
var
  vDataSetDocNFeItem   : TDataSet;
  vDocumentoNFeItem    : TDocumentoNfeItem;
begin
  vDataSetDocNFeItem   := FDocumentoNFeDao.RetornarDataSetDocumentoNFeItem(AIdDocumento);
  Result               := TList<TDocumentoNfeItem>.Create;
  try
    vDataSetDocNFeItem.First;
    while not vDataSetDocNFeItem.Eof do
    begin
      // Preencher Itens
      vDocumentoNFeItem             := TDocumentoNfeItem.Create;
      vDocumentoNFeItem.IdItem      := vDataSetDocNFeItem.FieldByName('ID_ITEM').AsInteger;
      vDocumentoNFeItem.IdDocumento := vDataSetDocNFeItem.FieldByName('ID_DOCUMENTO').AsInteger;
      vDocumentoNFeItem.Item        := vDataSetDocNFeItem.FieldByName('ITEM').AsInteger;
      vDocumentoNFeItem.Descricao   := vDataSetDocNFeItem.FieldByName('DESCRICAO').AsString;
      vDocumentoNFeItem.Ncm         := vDataSetDocNFeItem.FieldByName('NCM').AsString;
      vDocumentoNFeItem.Quantidade  := vDataSetDocNFeItem.FieldByName('QUANTIDADE').AsExtended;
      vDocumentoNFeItem.VlUnitario  := vDataSetDocNFeItem.FieldByName('VL_UNITARIO').AsCurrency;
      vDocumentoNFeItem.VlTotal     := vDataSetDocNFeItem.FieldByName('VL_TOTAL').AsCurrency;

      Result.Add(vDocumentoNFeItem);

      vDataSetDocNFeItem.Next;
    end;

  finally
    vDataSetDocNFeItem.Free;
  end;

end;

constructor TDocumentoNfeImplementacao.Create;
begin
  FDocumentoNFeDao := TDaoDocumentoNFe.Create;
end;

destructor TDocumentoNfeImplementacao.Destroy;
begin
  FDocumentoNFeDao.Free;
  inherited;
end;

function TDocumentoNfeImplementacao.Processar(ADocNfe: TDocumentoNfe): Boolean;
var
  vDocEvento    : TDocumentoEvento;
begin

  ADocNfe.ValidarRegraStatus;

  // Registrando Evento de Criação do processamento
  vDocEvento  := TDocumentoEvento.Create;
  vDocEvento.IdDocumento  := ADocNfe.IdDocumento;
  vDocEvento.DtEvento     := Now;
  vDocEvento.TipoEvento   := 'ALTERADO';
  vDocEvento.StatusAntes  := 'NOVO';
  vDocEvento.StatusDepois := ADocNfe.StatusProc;
  vDocEvento.Mensagem     := ADocNfe.MsgStatus;
  vDocEvento.Usuario      := 'USER_LOGADO';

  ADocNfe.Eventos.Add(vDocEvento);

  Result := FDocumentoNFeDao.Processar(ADocNfe);

end;

function TDocumentoNfeImplementacao.Reprocessar(ADocNfe: TDocumentoNfe) : TDocumentoNfe;
var
  vACBrNFe    : TACBrNFe;
  vDocNfeItem : TDocumentoNfeItem;
  vDocEvento  : TDocumentoEvento;
  vIndex      : Integer;
begin
  if ADocNfe.ArquivoNome.IsEmpty then
    raise Exception.Create('Nome do arquivo xml não informado');

  if not FileExists(ADocNfe.ArquivoNome) then
    raise Exception.Create('O arquivo xml informado não existe');

  vACBrNFe := TACBrNFe.Create(nil);
  Result   := TDocumentoNfe.Create;
  try

    try
      // Carrega o XML selecionado
      vACBrNFe.NotasFiscais.LoadFromFile(ADocNfe.ArquivoNome);

       //      Result.ChaveAcesso := vACBrNFe.NotasFiscais.Items[0].NFe.infNFe.ID;
      Result.ChaveAcesso := vACBrNFe.NotasFiscais.Items[0].NFe.procNFe.chNFe;
      Result.Numero      := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.nNF.ToString;
      Result.Serie       := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.serie.ToString;
      Result.DtEmissao   := vACBrNFe.NotasFiscais.Items[0].NFe.Ide.dEmi;
      Result.EmitCnpjCpf := vACBrNFe.NotasFiscais.Items[0].NFe.Emit.CNPJCPF;
      Result.EmitRazao   := vACBrNFe.NotasFiscais.Items[0].NFe.Emit.xNome;
      Result.DestCnpjCpf := vACBrNFe.NotasFiscais.Items[0].NFe.Dest.CNPJCPF;
      Result.DestRazao   := vACBrNFe.NotasFiscais.Items[0].NFe.Dest.xNome;
      Result.VlTotal     := vACBrNFe.NotasFiscais.Items[0].NFe.Total.ICMSTot.vNF;
      Result.StatusProc  := 'REPROCESSADO';
      Result.MsgStatus   := 'REPROCESSADO COM SUCESSO';
      Result.ArquivoNome := vACBrNFe.NotasFiscais.Items[0].NomeArq;
      Result.XmlConteudo := vACBrNFe.NotasFiscais.Items[0].XML;

      Result.IdDocumento := ADocNfe.IdDocumento;

      // Adicionando os itens para documentos os que já possuem itens serão considerados do banco
      if ADocNfe.Itens.Count < 1 then
      begin
        for vIndex := 0 to vACBrNFe.NotasFiscais.Items[0].NFe.Det.Count - 1 do
        begin
          vDocNfeItem             := TDocumentoNfeItem.Create;
          vDocNfeItem.IdDocumento := Result.IdDocumento;
          vDocNfeItem.Item        := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.cProd.ToInteger;
          vDocNfeItem.Descricao   := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.xProd;
          vDocNfeItem.Quantidade  := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.qCom;
          vDocNfeItem.Ncm         := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.NCM;
          vDocNfeItem.VlUnitario  := vACBrNFe.NotasFiscais.Items[0].NFe.Det.Items[vIndex].Prod.vProd;
          vDocNfeItem.VlTotal     := vDocNfeItem.Quantidade * vDocNfeItem.VlUnitario;

          Result.Itens.Add(vDocNfeItem);

        end;
      end
      else
      begin
        // preencher os itens para validar na regra dando prioridade aos que já estão no banco
        for vIndex := 0 to ADocNfe.Itens.Count - 1 do
        begin
          vDocNfeItem             := TDocumentoNfeItem.Create;
          vDocNfeItem.IdDocumento := ADocNfe.Itens.Items[vIndex].IdDocumento;
          vDocNfeItem.Item        := ADocNfe.Itens.Items[vIndex].Item;
          vDocNfeItem.Descricao   := ADocNfe.Itens.Items[vIndex].Descricao;
          vDocNfeItem.Quantidade  := ADocNfe.Itens.Items[vIndex].Quantidade;
          vDocNfeItem.Ncm         := ADocNfe.Itens.Items[vIndex].Ncm;
          vDocNfeItem.VlUnitario  := ADocNfe.Itens.Items[vIndex].VlUnitario;
          vDocNfeItem.VlTotal     := ADocNfe.Itens.Items[vIndex].VlTotal;

          Result.Itens.Add(vDocNfeItem);

        end;
      end;

      Result.ValidarRegraStatus;

      // depois de passar na regra se existir itens vamos remover pois estamos considerando os do banco
      vIndex := 0;
      if ADocNfe.Itens.Count > 0 then
      begin
        for vIndex := 0 to Result.Itens.Count - 1 do
          Result.Itens.Items[vIndex].Free;
        Result.Itens.Clear;
      end;


      // Registrando Evento de Reprocessamento
      vDocEvento  := TDocumentoEvento.Create;
      vDocEvento.IdDocumento  := Result.IdDocumento;
      vDocEvento.DtEvento     := Now;
      vDocEvento.TipoEvento   := 'ALTERADO';
      vDocEvento.StatusAntes  := ADocNfe.StatusProc;
      vDocEvento.StatusDepois := Result.StatusProc;
      vDocEvento.Mensagem     := Result.MsgStatus;
      vDocEvento.Usuario      := 'USER_LOGADO';
      Result.Eventos.Add(vDocEvento);

      // Gravar no Banco
      if not FDocumentoNFeDao.Reprocessar(Result) then
      begin
        Result.StatusProc := ADocNfe.StatusProc;
        Result.MsgStatus  := ADocNfe.MsgStatus;
      end;

    except
      on E: Exception do
      begin
        Result.Free;
        raise Exception.Create('Erro ao reprocessar XML: '+ E.Message);
      end;
    end;

  finally
    vACBrNFe.Free;
  end;

end;

function TDocumentoNfeImplementacao.SelecionarXML : String;
var
  OpenDialog: TOpenDialog;
begin
  Result := '';
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'Arquivos XML (*.xml)|*.xml';
    OpenDialog.DefaultExt := 'xml';
    OpenDialog.Title := 'Selecionar Arquivo XML da NF-e';

    if OpenDialog.Execute then
    begin
      Result := OpenDialog.FileName;
    end;
  finally
    OpenDialog.Free;
  end;

end;

function TDocumentoNfeImplementacao.VerificarSeExisteChaveAcesso(const AChave: String): Boolean;
begin
  Result  := FDocumentoNFeDao.VerificarSeExisteChaveAcesso(AChave);
end;

end.