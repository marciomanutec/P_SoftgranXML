unit U_DocumentoEvento;
 
interface
 
uses
  System.SysUtils;
 
type
  TDocumentoEvento = class
  private
    FIdEvento: Integer;
    FIdDocumento: Integer;
    FDtoEvento: TDateTime;
    FTipoEvento: string;
    FStatusAntes: string;
    FStatusDepois: string;
    FMensagem: string;
    FDetalhe: string;
    FUsuario: string;
  public
    property IdEvento: Integer read FIdEvento write FIdEvento;
    property IdDocumento: Integer read FIdDocumento write FIdDocumento;
    property DtEvento: TDateTime read FDtoEvento write FDtoEvento;
    property TipoEvento: string read FTipoEvento write FTipoEvento;
    property StatusAntes: string read FStatusAntes write FStatusAntes;
    property StatusDepois: string read FStatusDepois write FStatusDepois;
    property Mensagem: string read FMensagem write FMensagem;
    property Detalhe: string read FDetalhe write FDetalhe;
    property Usuario: string read FUsuario write FUsuario;
  end;
 
implementation
 
end.