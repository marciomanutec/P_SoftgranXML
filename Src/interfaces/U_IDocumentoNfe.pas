unit U_IDocumentoNfe;

interface

uses U_DocumentoNfe,
     U_DocumentoNfeItem,
     U_DocumentoEvento,
     System.Generics.Collections,
     Data.DB,
     FireDAC.Comp.Client;

type
  IDocumentoNfe  = interface
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

end.
