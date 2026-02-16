unit U_DocumentoNfe;
 
interface
 
uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  U_DocumentoNfeItem,
  U_DocumentoEvento;

 
type
  TDocumentoNfe = class
  private
    FIdDocumento: Integer;
    FChaveAcesso: string;
    FNumero: string;
    FSerie: string;
    FDtEmissao: TDateTime;
    FEmitCnpjCpf: string;
    FEmitRazao: string;
    FDestCnpjCpf: string;
    FDestRazao: string;
    FVlTotal: Currency;
    FStatusProc: string;
    FMsgStatus: string;
    FArquivoNome: string;
    FXmlConteudo: string;
    FDtImportacao: TDateTime;
    FItens: TList<TDocumentoNfeItem>;
    FExisteChaveAcesso: Boolean;
    FEventos: TList<TDocumentoEvento>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ValidarRegraStatus;

    property IdDocumento: Integer read FIdDocumento write FIdDocumento;
    property ChaveAcesso: string read FChaveAcesso write FChaveAcesso;
    property Numero: string read FNumero write FNumero;
    property Serie: string read FSerie write FSerie;
    property DtEmissao: TDateTime read FDtEmissao write FDtEmissao;
    property EmitCnpjCpf: string read FEmitCnpjCpf write FEmitCnpjCpf;
    property EmitRazao: string read FEmitRazao write FEmitRazao;
    property DestCnpjCpf: string read FDestCnpjCpf write FDestCnpjCpf;
    property DestRazao: string read FDestRazao write FDestRazao;
    property VlTotal: Currency read FVlTotal write FVlTotal;
    property StatusProc: string read FStatusProc write FStatusProc;
    property MsgStatus: string read FMsgStatus write FMsgStatus;
    property ArquivoNome: string read FArquivoNome write FArquivoNome;
    property XmlConteudo: string read FXmlConteudo write FXmlConteudo;
    property DtImportacao: TDateTime read FDtImportacao write FDtImportacao;
    property Itens: TList<TDocumentoNfeItem> read FItens write FItens;
    property Eventos: TList<TDocumentoEvento> read FEventos write FEventos;
    property ExisteChaveAcesso: Boolean read FExisteChaveAcesso write FExisteChaveAcesso;
  end;
 
implementation
 
{ TDocumentoNfe }

constructor TDocumentoNfe.Create;
begin
  FItens   := TList<TDocumentoNfeItem>.Create;
  FEventos := TList<TDocumentoEvento>.Create;
end;

destructor TDocumentoNfe.Destroy;
begin
  FItens.Free;
  FEventos.Free;
  inherited;
end;

procedure TDocumentoNfe.ValidarRegraStatus;
begin
  if (EmitCnpjCpf.IsEmpty) or (EmitRazao.IsEmpty) or
     (DestCnpjCpf.IsEmpty) or (DestRazao.IsEmpty) then
  begin
     StatusProc := 'PENDENTE_REVISAO';
     MsgStatus  := 'DADOS PENDENTES';
  end
  else
  if Itens.Count < 1 then
  begin
    StatusProc := 'ERRO';
    MsgStatus  := 'NÃO EXISTEM ITENS NA NOTA';
  end;

end;

end.