unit U_ControllerDocumentoNfe;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  U_IDocumentoNfe,
  U_DocumentoNfeImplementacao,
  U_DocumentoNfe,
  U_DocumentoNfeItem,
  U_DocumentoEvento;


type
  TControllerDocumentoNfe = class
  private
    FNFeInterface: IDocumentoNfe;
  public
    constructor Create;
    destructor Destroy; override;
    function SelecionarXML : String;
    function ImportarXML(const ANomeArquivo: String): TDocumentoNfe;
    function CadastrarXML(ADocumento: TDocumentoNfe): Boolean;
    function Processar(const ADocNfe : TDocumentoNfe) : Boolean;
    function Reprocessar(ADocNfe: TDocumentoNfe) : TDocumentoNfe;
    function ConsultarDocNFe:TList<TDocumentoNfe>;
    function ConsultarDocNFeItem(const AIdDocumento:Integer):TList<TDocumentoNfeItem>;
    function ConsultarDocEvento(const AIdDocumento:Integer):TList<TDocumentoEvento>;

  end;

implementation


{ TControllerDocumentoNfe }
 
function TControllerDocumentoNfe.ImportarXML(const ANomeArquivo: String): TDocumentoNfe;
begin
  Result := FNFeInterface.ImportarXML(ANomeArquivo);
end;

function TControllerDocumentoNfe.Processar(const ADocNfe: TDocumentoNfe): Boolean;
begin
  Result := FNFeInterface.Processar(ADocNfe);
end;

function TControllerDocumentoNfe.Reprocessar(ADocNfe: TDocumentoNfe) : TDocumentoNfe;
begin
  Result := FNFeInterface.Reprocessar(ADocNfe);
end;

function TControllerDocumentoNfe.CadastrarXML(ADocumento: TDocumentoNfe): Boolean;
begin
  Result := FNFeInterface.CadastrarXML(ADocumento);
end;

function TControllerDocumentoNfe.ConsultarDocEvento(const AIdDocumento: Integer): TList<TDocumentoEvento>;
begin
  Result := FNFeInterface.ConsultarDocEvento(AIdDocumento);
end;

function TControllerDocumentoNfe.ConsultarDocNFe:TList<TDocumentoNfe>;
begin
  Result := FNFeInterface.ConsultarDocNFe;
end;

function TControllerDocumentoNfe.ConsultarDocNFeItem(const AIdDocumento: Integer): TList<TDocumentoNfeItem>;
begin
  Result := FNFeInterface.ConsultarDocNFeItem(AIdDocumento);
end;

constructor TControllerDocumentoNfe.Create;
begin
  FNFeInterface := TDocumentoNfeImplementacao.Create;
end;
 
destructor TControllerDocumentoNfe.Destroy;
begin
  inherited;
end;

function TControllerDocumentoNfe.SelecionarXML: String;
begin
  Result := FNFeInterface.SelecionarXML;
end;

end.