unit U_DmDados;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  System.Generics.Collections,
  U_DocumentoNfe,
  U_DocumentoNfeItem,
  U_DocumentoEvento;

type
  TDM_Dados = class(TDataModule)
    memDocNFe: TFDMemTable;
    memDocNFeID_DOCUMENTO: TIntegerField;
    memDocNFeCHAVE_ACESSO: TStringField;
    memDocNFeNUMERO: TStringField;
    memDocNFeSERIE: TStringField;
    memDocNFeDT_EMISSAO: TDateTimeField;
    memDocNFeEMIT_CNPJ_CPF: TStringField;
    memDocNFeEMIT_RAZAO: TStringField;
    memDocNFeDEST_CNPJ_CPF: TStringField;
    memDocNFeDEST_RAZAO: TStringField;
    memDocNFeVL_TOTAL: TCurrencyField;
    memDocNFeSTATUS_PROC: TStringField;
    memDocNFeMSG_STATUS: TStringField;
    memDocNFeARQUIVO_NOME: TStringField;
    memDocNFeXML_CONTEUDO: TBlobField;
    memDocNFeDT_IMPORTACAO: TDateTimeField;
    dsDocNFe: TDataSource;
    memItens: TFDMemTable;
    memItensID_ITEM: TIntegerField;
    memItensID_DOCUMENTO: TIntegerField;
    memItensITEM: TIntegerField;
    memItensDESCRICAO: TStringField;
    memItensNCM: TStringField;
    memItensQUANTIDADE: TCurrencyField;
    memItensVL_UNITARIO: TCurrencyField;
    memItensVL_TOTAL: TCurrencyField;
    dsItens: TDataSource;
    memDocEventos: TFDMemTable;
    memDocEventosID_EVENTO: TIntegerField;
    memDocEventosID_DOCUMENTO: TIntegerField;
    memDocEventosDT_EVENTO: TDateTimeField;
    memDocEventosTIPO_EVENTO: TStringField;
    memDocEventosSTATUS_ANTES: TStringField;
    memDocEventosSTATUS_DEPOIS: TStringField;
    memDocEventosMENSAGEM: TStringField;
    memDocEventosDETALHE: TStringField;
    memDocEventosUSUARIO: TStringField;
    dsDocEventos: TDataSource;
  private

  public
    procedure ConsultarDocumentoNFe(AListaDocNFe:TList<TDocumentoNfe>);
    procedure ConsultarDocumentoNFeItem(AListaDocNFeItem:TList<TDocumentoNfeItem>);
    procedure ConsultarDocumentoEvento(AListaEvento:TList<TDocumentoEvento>);
  end;

var
  DM_Dados: TDM_Dados;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}


{$R *.dfm}

{ TDM_Dados }

procedure TDM_Dados.ConsultarDocumentoEvento(AListaEvento: TList<TDocumentoEvento>);
var
  vListaDocEvento : TList<TDocumentoEvento>;
  vIndex : Integer;
begin
  vListaDocEvento := AListaEvento;
  memDocEventos.DisableControls;
  try
    if memDocEventos.Active then
      memDocEventos.EmptyDataSet
    else
      memDocEventos.Active := True;

    for vIndex := 0 to Pred(vListaDocEvento.Count) do
    begin
      memDocEventos.Append;
      memDocEventosID_EVENTO.AsInteger    := vListaDocEvento.Items[vIndex].IdEvento;
      memDocEventosID_DOCUMENTO.AsInteger := vListaDocEvento.Items[vIndex].IdDocumento;
      memDocEventosDT_EVENTO.AsDateTime   := vListaDocEvento.Items[vIndex].DtEvento;
      memDocEventosTIPO_EVENTO.AsString   := vListaDocEvento.Items[vIndex].TipoEvento;
      memDocEventosSTATUS_ANTES.AsString  := vListaDocEvento.Items[vIndex].StatusAntes;
      memDocEventosSTATUS_DEPOIS.AsString := vListaDocEvento.Items[vIndex].StatusDepois;
      memDocEventosMENSAGEM.AsString      := vListaDocEvento.Items[vIndex].Mensagem;
      memDocEventosDETALHE.AsString       := vListaDocEvento.Items[vIndex].Detalhe;
      memDocEventosUSUARIO.AsString       := vListaDocEvento.Items[vIndex].Usuario;
      memDocEventos.Post;
      vListaDocEvento.Items[vIndex].Free;
    end;

  finally
    vListaDocEvento.Free;
    memDocEventos.EnableControls;
  end;

end;

procedure TDM_Dados.ConsultarDocumentoNFe(AListaDocNFe:TList<TDocumentoNfe>);
var
  vListaDocumentoNFe : TList<TDocumentoNfe>;
  vIndex : Integer;
begin
  vListaDocumentoNFe := AListaDocNFe;
  memDocNFe.DisableControls;
  try
    if memDocNFe.Active then
      memDocNFe.EmptyDataSet
    else
      memDocNFe.Active := True;

    for vIndex := 0 to Pred(vListaDocumentoNFe.Count) do
    begin
      memDocNFe.Append;
      memDocNFeID_DOCUMENTO.AsInteger    := vListaDocumentoNFe.Items[vIndex].IdDocumento;
      memDocNFeCHAVE_ACESSO.AsString     := vListaDocumentoNFe.Items[vIndex].ChaveAcesso;
      memDocNFeNUMERO.AsString           := vListaDocumentoNFe.Items[vIndex].Numero;
      memDocNFeSERIE.AsString            := vListaDocumentoNFe.Items[vIndex].Serie;
      memDocNFeDT_EMISSAO.AsDateTime     := vListaDocumentoNFe.Items[vIndex].DtEmissao;
      memDocNFeEMIT_CNPJ_CPF.AsString    := vListaDocumentoNFe.Items[vIndex].EmitCnpjCpf;
      memDocNFeEMIT_RAZAO.AsString       := vListaDocumentoNFe.Items[vIndex].EmitRazao;
      memDocNFeDEST_CNPJ_CPF.AsString    := vListaDocumentoNFe.Items[vIndex].DestCnpjCpf;
      memDocNFeDEST_RAZAO.AsString       := vListaDocumentoNFe.Items[vIndex].DestRazao;
      memDocNFeVL_TOTAL.AsCurrency       := vListaDocumentoNFe.Items[vIndex].VlTotal;
      memDocNFeSTATUS_PROC.AsString      := vListaDocumentoNFe.Items[vIndex].StatusProc;
      memDocNFeMSG_STATUS.AsString       := vListaDocumentoNFe.Items[vIndex].MsgStatus;
      memDocNFeARQUIVO_NOME.AsString     := vListaDocumentoNFe.Items[vIndex].ArquivoNome;
      memDocNFeXML_CONTEUDO.AsString     := vListaDocumentoNFe.Items[vIndex].XmlConteudo;
      memDocNFeDT_IMPORTACAO.AsDateTime  := vListaDocumentoNFe.Items[vIndex].DtImportacao;
      memDocNFe.Post;
      vListaDocumentoNFe.Items[vIndex].Free;
    end;

  finally
    vListaDocumentoNFe.Free;
    memDocNFe.EnableControls;
  end;

end;

procedure TDM_Dados.ConsultarDocumentoNFeItem(AListaDocNFeItem: TList<TDocumentoNfeItem>);
var
  vListaDocNFeItem : TList<TDocumentoNfeItem>;
  vIndex : Integer;
begin
  vListaDocNFeItem := AListaDocNFeItem;
  memItens.DisableControls;
  try
    if memItens.Active then
      memItens.EmptyDataSet
    else
      memItens.Active := True;

    for vIndex := 0 to Pred(vListaDocNFeItem.Count) do
    begin
      memItens.Append;
      memItensID_ITEM.AsInteger      := vListaDocNFeItem.Items[vIndex].IdItem;
      memItensID_DOCUMENTO.AsInteger := vListaDocNFeItem.Items[vIndex].IdDocumento;
      memItensITEM.AsInteger         := vListaDocNFeItem.Items[vIndex].Item;
      memItensDESCRICAO.AsString     := vListaDocNFeItem.Items[vIndex].Descricao;
      memItensNCM.AsString           := vListaDocNFeItem.Items[vIndex].Ncm;
      memItensQUANTIDADE.AsCurrency  := vListaDocNFeItem.Items[vIndex].Quantidade;
      memItensVL_UNITARIO.AsCurrency := vListaDocNFeItem.Items[vIndex].VlUnitario;
      memItensVL_TOTAL.AsCurrency    := vListaDocNFeItem.Items[vIndex].VlTotal;
      memItens.Post;
      vListaDocNFeItem.Items[vIndex].Free;
    end;

  finally
    vListaDocNFeItem.Free;
    memItens.EnableControls;
  end;

end;

end.
