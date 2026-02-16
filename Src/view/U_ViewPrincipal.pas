unit U_ViewPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  System.ImageList,
  Vcl.ImgList,
  U_ControllerDocumentoNfe,
  U_DocumentoNfe,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  System.Actions,
  Vcl.ActnList;

type
  TF_ViewPrincipal = class(TForm)
    page_XML: TPageControl;
    tabPesquisa: TTabSheet;
    tabCrud: TTabSheet;
    pnlHeaderPesquisa: TPanel;
    lblDescricaoXml: TLabel;
    edtArquivoXML: TEdit;
    pnlBotoes: TPanel;
    pnlSelecionar: TPanel;
    btnSelecionar: TSpeedButton;
    btnImportar: TSpeedButton;
    imgLista: TImageList;
    pnlDadosNfe: TPanel;
    pnlLine1: TPanel;
    pnlItensNota: TPanel;
    pnlLine2: TPanel;
    pnlRodapeDados: TPanel;
    btnVoltar: TSpeedButton;
    btnProcessar: TSpeedButton;
    btnReprocessar: TSpeedButton;
    pnlHistoricoEventos: TPanel;
    lblTituloItens: TLabel;
    lblTituloEventos: TLabel;
    lblChaveAcesso: TLabel;
    edtChaveAcesso: TEdit;
    lblNumeroNota: TLabel;
    edtNumeroNota: TEdit;
    lblSerie: TLabel;
    edtSerieNota: TEdit;
    lblStatusNota: TLabel;
    edtStatusNota: TEdit;
    lblDtEmissao: TLabel;
    edtDtEmissao: TEdit;
    lblDocEmitente: TLabel;
    edtDocEmitente: TEdit;
    lblRzEmitente: TLabel;
    edtRzEmitente: TEdit;
    lblDocDestinatario: TLabel;
    edtDocDestinatario: TEdit;
    lblRzDestinatario: TLabel;
    edtRzDestinatario: TEdit;
    lblValorNota: TLabel;
    edtTotalNota: TEdit;
    lblLocalArquivo: TLabel;
    edtLocalArquivo: TEdit;
    gridItens: TDBGrid;
    gridDocNFe: TDBGrid;
    pnlRodapePesquisa: TPanel;
    btnAlterar: TSpeedButton;
    btnFiltrar: TSpeedButton;
    actLista: TActionList;
    act_selecionar: TAction;
    act_importar: TAction;
    act_alterar: TAction;
    gridEventos: TDBGrid;
    act_processar: TAction;
    act_reprocessar: TAction;
    act_voltar: TAction;
    act_Filtrar: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure act_alterarExecute(Sender: TObject);
    procedure act_importarExecute(Sender: TObject);
    procedure act_selecionarExecute(Sender: TObject);
    procedure act_processarExecute(Sender: TObject);
    procedure act_voltarExecute(Sender: TObject);
    procedure act_reprocessarExecute(Sender: TObject);
    procedure gridDocNFeDblClick(Sender: TObject);
  private
    FControllerNFe : TControllerDocumentoNfe;
    FDocumentoNfe  : TDocumentoNfe;
    FMSG_STATUS: String;
    FXML_CONTEUDO: String;
    FID_DOC: Integer;

    procedure ConsultarDocumentoNFe;
    procedure ConsultarDocumentoNFeItem(const AIdDocumento:Integer);
    procedure ConsultarDocumentoEvento(const AIdDocumento:Integer);
    function ImportarDocumentoNFe:Boolean;
    function CadastrarDocumentoNFe:Boolean;
    procedure AlterarDocumentoNFe;
    procedure ProcessarDocumentoNFe;
    function ReprocessarDocumentoNFe:Boolean;
    procedure LimparComponenteTela;


    property ID_DOC: Integer read FID_DOC write FID_DOC;
    property MSG_STATUS: String read FMSG_STATUS write FMSG_STATUS;
    property XML_CONTEUDO: String read FXML_CONTEUDO write FXML_CONTEUDO;

  public

  end;

var
  F_ViewPrincipal: TF_ViewPrincipal;

implementation

{$R *.dfm}

uses U_ConfigBanco,
     U_DocumentoNfeItem,
     U_DmDados;

procedure TF_ViewPrincipal.act_alterarExecute(Sender: TObject);
begin
  AlterarDocumentoNFe;
end;

procedure TF_ViewPrincipal.act_importarExecute(Sender: TObject);
begin
  if (ImportarDocumentoNFe) and (CadastrarDocumentoNFe) then
  begin

    ID_DOC                := FDocumentoNfe.IdDocumento;
    MSG_STATUS            := FDocumentoNfe.MsgStatus;
    XML_CONTEUDO          := FDocumentoNfe.XmlConteudo;
    ConsultarDocumentoNFeItem(FDocumentoNfe.IdDocumento);
    ConsultarDocumentoEvento(FDocumentoNfe.IdDocumento);
    btnProcessar.Visible   := edtStatusNota.Text = 'NOVO';
    btnReprocessar.Visible := False;
    tabCrud.TabVisible     := True;
    tabPesquisa.TabVisible := False;

  end;
  if Assigned(FDocumentoNfe) then
    FDocumentoNfe.Free;
end;

procedure TF_ViewPrincipal.act_processarExecute(Sender: TObject);
begin
  ProcessarDocumentoNFe;
  ConsultarDocumentoEvento(ID_DOC);

  if edtStatusNota.Text = 'PROCESSADO' then
    Application.MessageBox(Pchar(MSG_STATUS), 'Processamento de XML', MB_ICONINFORMATION)
  else
  if edtStatusNota.Text <> 'ERRO' then
    Application.MessageBox(Pchar(MSG_STATUS), 'Processamento de XML', MB_ICONWARNING)
  else
    Application.MessageBox(Pchar(MSG_STATUS), 'Processamento de XML', MB_ICONERROR);

  btnProcessar.Visible   := edtStatusNota.Text = 'NOVO';
  btnReprocessar.Visible := (edtStatusNota.Text <> 'NOVO') and (edtStatusNota.Text <> 'PROCESSADO');
end;

procedure TF_ViewPrincipal.act_reprocessarExecute(Sender: TObject);
begin
  if ReprocessarDocumentoNFe then
    Application.MessageBox(Pchar(MSG_STATUS), 'Reprocessamento de XML', MB_ICONINFORMATION)
  else
  if edtStatusNota.Text <> 'ERRO' then
    Application.MessageBox(Pchar(MSG_STATUS), 'Reprocessamento de XML', MB_ICONWARNING)
  else
    Application.MessageBox(Pchar(MSG_STATUS), 'Reprocessamento de XML', MB_ICONERROR);
end;

procedure TF_ViewPrincipal.act_selecionarExecute(Sender: TObject);
begin
  edtArquivoXML.Text := FControllerNFe.SelecionarXML;
end;

procedure TF_ViewPrincipal.act_voltarExecute(Sender: TObject);
begin
  LimparComponenteTela;
  ConsultarDocumentoNFe;
  tabCrud.TabVisible     := False;
  tabPesquisa.TabVisible := True;
  MSG_STATUS             := '';
  XML_CONTEUDO           := '';
  ID_DOC                 :=0;
end;

procedure TF_ViewPrincipal.AlterarDocumentoNFe;
begin
  if DM_Dados.memDocNFe.RecordCount > 0 then
  begin
    edtChaveAcesso.Text     := DM_Dados.memDocNFeCHAVE_ACESSO.AsString;
    edtNumeroNota.Text      := DM_Dados.memDocNFeNUMERO.AsString;
    edtSerieNota.Text       := DM_Dados.memDocNFeSERIE.AsString;
    edtStatusNota.Text      := DM_Dados.memDocNFeSTATUS_PROC.AsString;
    edtDtEmissao.Text       := DM_Dados.memDocNFeDT_EMISSAO.AsString;
    edtDocEmitente.Text     := DM_Dados.memDocNFeEMIT_CNPJ_CPF.AsString;
    edtRzEmitente.Text      := DM_Dados.memDocNFeEMIT_RAZAO.AsString;
    edtDocDestinatario.Text := DM_Dados.memDocNFeDEST_CNPJ_CPF.AsString;
    edtRzDestinatario.Text  := DM_Dados.memDocNFeDEST_RAZAO.AsString;
    edtTotalNota.Text       := DM_Dados.memDocNFeVL_TOTAL.AsString;
    edtLocalArquivo.Text    := DM_Dados.memDocNFeARQUIVO_NOME.AsString;
    ID_DOC                  := DM_Dados.memDocNFeID_DOCUMENTO.AsInteger;
    MSG_STATUS              := DM_Dados.memDocNFeMSG_STATUS.AsString;
    XML_CONTEUDO            := DM_Dados.memDocNFeXML_CONTEUDO.AsString;

    ConsultarDocumentoNFeItem(ID_DOC);

    ConsultarDocumentoEvento(ID_DOC);

    btnProcessar.Visible   := edtStatusNota.Text = 'NOVO';
    btnReprocessar.Visible := (edtStatusNota.Text <> 'NOVO') and (edtStatusNota.Text <> 'PROCESSADO') and (edtStatusNota.Text <> 'REPROCESSADO');

    tabCrud.TabVisible     := True;
    tabPesquisa.TabVisible := False;

  end;
end;

function TF_ViewPrincipal.CadastrarDocumentoNFe:Boolean;
begin
  Result := False;
  if FControllerNFe.CadastrarXML(FDocumentoNFe) then
  begin
    Result := True;
    Application.MessageBox(Pchar(FDocumentoNFe.MsgStatus), 'Importação de XML', MB_ICONINFORMATION);
  end
    else
      Application.MessageBox('não foi possível importar o xml', 'Importação de XML', MB_ICONERROR);

end;

procedure TF_ViewPrincipal.ConsultarDocumentoEvento(const AIdDocumento: Integer);
begin
  DM_Dados.ConsultarDocumentoEvento(FControllerNFe.ConsultarDocEvento(AIdDocumento));
end;

procedure TF_ViewPrincipal.ConsultarDocumentoNFe;
begin
  DM_Dados.ConsultarDocumentoNFe(FControllerNFe.ConsultarDocNFe);
end;

procedure TF_ViewPrincipal.ConsultarDocumentoNFeItem(const AIdDocumento:Integer);
begin
  DM_Dados.ConsultarDocumentoNFeItem(FControllerNFe.ConsultarDocNFeItem(AIdDocumento));
end;

procedure TF_ViewPrincipal.FormCreate(Sender: TObject);
begin
  TConfigBanco.GetInstance.PreparaConfigBanco;
  tabCrud.TabVisible := False;
  try
    FControllerNFe := TControllerDocumentoNfe.Create;
  except
    on E: Exception do
    begin
      Application.MessageBox(Pchar('Erro: '+E.Message),'Iniciando Sistema', MB_ICONERROR);
      FControllerNFe.Free;
      Application.Terminate;
    end;
  end;
end;

procedure TF_ViewPrincipal.FormDestroy(Sender: TObject);
begin
  if Assigned(FControllerNFe) then
    FControllerNFe.Free;
end;

procedure TF_ViewPrincipal.FormShow(Sender: TObject);
begin
  ConsultarDocumentoNFe;
end;

procedure TF_ViewPrincipal.gridDocNFeDblClick(Sender: TObject);
begin
  btnAlterar.Click;
end;

function TF_ViewPrincipal.ImportarDocumentoNFe: Boolean;
begin
  Result        := False;

  FDocumentoNfe := FControllerNFe.ImportarXML(edtArquivoXML.Text);

  if not FDocumentoNfe.ExisteChaveAcesso then
  begin
    edtChaveAcesso.Text     := FDocumentoNfe.ChaveAcesso;
    edtNumeroNota.Text      := FDocumentoNfe.Numero;
    edtSerieNota.Text       := FDocumentoNfe.Serie;
    edtStatusNota.Text      := FDocumentoNfe.StatusProc;
    edtDtEmissao.Text       := DateToStr(FDocumentoNfe.DtEmissao);
    edtDocEmitente.Text     := FDocumentoNfe.EmitCnpjCpf;
    edtRzEmitente.Text      := FDocumentoNfe.EmitRazao;
    edtDocDestinatario.Text := FDocumentoNfe.DestCnpjCpf;
    edtRzDestinatario.Text  := FDocumentoNfe.DestRazao;
    edtTotalNota.Text       := CurrToStr(FDocumentoNfe.VlTotal);
    edtLocalArquivo.Text    := FDocumentoNfe.ArquivoNome;

    Result := True;

  end;

end;

procedure TF_ViewPrincipal.LimparComponenteTela;
var
  vIndex: Integer;
begin
  for vIndex := Self.ComponentCount - 1 downto 0 do
  begin
    if Self.Components[vIndex] is TEdit then
      TEdit(Self.Components[vIndex]).Text := '';
  end;

end;

procedure TF_ViewPrincipal.ProcessarDocumentoNFe;
var
  vDocNFeItem : TDocumentoNfeItem;
  vIndex      : Integer;
begin
  FDocumentoNfe := TDocumentoNfe.Create;
  try
    FDocumentoNfe.IdDocumento := ID_DOC;
    FDocumentoNfe.ChaveAcesso := edtChaveAcesso.Text;
    FDocumentoNfe.Numero      := edtNumeroNota.Text;
    FDocumentoNfe.Serie       := edtSerieNota.Text;
    FDocumentoNfe.DtEmissao   := StrToDateTime(edtDtEmissao.Text);
    FDocumentoNfe.EmitCnpjCpf := edtDocEmitente.Text;
    FDocumentoNfe.EmitRazao   := edtRzEmitente.Text;
    FDocumentoNfe.DestCnpjCpf := edtDocDestinatario.Text;
    FDocumentoNfe.DestRazao   := edtRzDestinatario.Text;
    FDocumentoNfe.VlTotal     := StrToCurr(edtTotalNota.Text);
    FDocumentoNfe.StatusProc  := 'PROCESSADO';
    FDocumentoNfe.MsgStatus   := 'PROCESSADO COM SUCESSO';
    FDocumentoNfe.ArquivoNome := edtLocalArquivo.Text;
    FDocumentoNfe.XmlConteudo := XML_CONTEUDO;

    DM_Dados.memItens.First;
    DM_Dados.memItens.DisableControls;
    try
      while not DM_Dados.memItens.Eof do
      begin
        vDocNFeItem := TDocumentoNfeItem.Create;
        vDocNFeItem.IdItem      := DM_Dados.memItensID_ITEM.AsInteger;
        vDocNFeItem.IdDocumento := DM_Dados.memItensID_DOCUMENTO.AsInteger;
        vDocNFeItem.Item        := DM_Dados.memItensITEM.AsInteger;
        vDocNFeItem.Descricao   := DM_Dados.memItensDESCRICAO.AsString;
        vDocNFeItem.Ncm         := DM_Dados.memItensNCM.AsString;
        vDocNFeItem.Quantidade  := DM_Dados.memItensQUANTIDADE.AsExtended;
        vDocNFeItem.VlUnitario  := DM_Dados.memItensVL_UNITARIO.AsCurrency;
        vDocNFeItem.VlTotal     := DM_Dados.memItensVL_TOTAL.AsCurrency;

        FDocumentoNfe.Itens.Add(vDocNFeItem);
        DM_Dados.memItens.Next;
      end;
    finally
      DM_Dados.memItens.EnableControls;
    end;

    FControllerNFe.Processar(FDocumentoNfe);
    edtStatusNota.Text := FDocumentoNfe.StatusProc;
    MSG_STATUS         := FDocumentoNfe.MsgStatus;

  finally
    if FDocumentoNfe.Itens.Count > 0 then
      for vIndex := 0 to Pred(FDocumentoNfe.Itens.Count) do
        FDocumentoNfe.Itens.Items[vIndex].Free;

    FDocumentoNfe.Free;
  end;
end;

function TF_ViewPrincipal.ReprocessarDocumentoNFe: Boolean;
var
  vDocNFeReprocessado : TDocumentoNfe;
  vDocNFeItem         : TDocumentoNfeItem;
  vIndex              : Integer;
begin
  Result  := False;
  FDocumentoNfe := TDocumentoNfe.Create;
  try
    FDocumentoNfe.IdDocumento := ID_DOC;
    FDocumentoNfe.ChaveAcesso := edtChaveAcesso.Text;
    FDocumentoNfe.Numero      := edtNumeroNota.Text;
    FDocumentoNfe.Serie       := edtSerieNota.Text;
    FDocumentoNfe.DtEmissao   := StrToDateTime(edtDtEmissao.Text);
    FDocumentoNfe.EmitCnpjCpf := edtDocEmitente.Text;
    FDocumentoNfe.EmitRazao   := edtRzEmitente.Text;
    FDocumentoNfe.DestCnpjCpf := edtDocDestinatario.Text;
    FDocumentoNfe.DestRazao   := edtRzDestinatario.Text;
    FDocumentoNfe.VlTotal     := StrToCurr(edtTotalNota.Text);
    FDocumentoNfe.StatusProc  := edtStatusNota.Text;
    FDocumentoNfe.MsgStatus   := MSG_STATUS;
    FDocumentoNfe.ArquivoNome := edtLocalArquivo.Text;
    FDocumentoNfe.XmlConteudo := XML_CONTEUDO;

    DM_Dados.memItens.First;
    DM_Dados.memItens.DisableControls;
    try
      while not DM_Dados.memItens.Eof do
      begin
        vDocNFeItem := TDocumentoNfeItem.Create;
        vDocNFeItem.IdItem      := DM_Dados.memItensID_ITEM.AsInteger;
        vDocNFeItem.IdDocumento := DM_Dados.memItensID_DOCUMENTO.AsInteger;
        vDocNFeItem.Item        := DM_Dados.memItensITEM.AsInteger;
        vDocNFeItem.Descricao   := DM_Dados.memItensDESCRICAO.AsString;
        vDocNFeItem.Ncm         := DM_Dados.memItensNCM.AsString;
        vDocNFeItem.Quantidade  := DM_Dados.memItensQUANTIDADE.AsExtended;
        vDocNFeItem.VlUnitario  := DM_Dados.memItensVL_UNITARIO.AsCurrency;
        vDocNFeItem.VlTotal     := DM_Dados.memItensVL_TOTAL.AsCurrency;

        FDocumentoNfe.Itens.Add(vDocNFeItem);
        DM_Dados.memItens.Next;
      end;
    finally
      DM_Dados.memItens.EnableControls;
    end;

    vDocNFeReprocessado := FControllerNFe.Reprocessar(FDocumentoNfe);
    try
      if vDocNFeReprocessado.StatusProc = 'REPROCESSADO' then
        Result  := True;

      edtStatusNota.Text := vDocNFeReprocessado.StatusProc;
      MSG_STATUS         := vDocNFeReprocessado.MsgStatus;

    finally
      vDocNFeReprocessado.Free;
    end;

    ConsultarDocumentoNFeItem(ID_DOC);
    ConsultarDocumentoEvento(ID_DOC);
    btnReprocessar.Visible := (edtStatusNota.Text <> 'NOVO') and (edtStatusNota.Text <> 'PROCESSADO') and (edtStatusNota.Text <> 'REPROCESSADO');

  finally
    if FDocumentoNfe.Itens.Count > 0 then
      for vIndex := 0 to Pred(FDocumentoNfe.Itens.Count) do
        FDocumentoNfe.Itens.Items[vIndex].Free;

    FDocumentoNfe.Free;
  end;
end;

end.
