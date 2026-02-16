unit U_DocumentoNfeItem;
 
interface
 
uses
  System.SysUtils, System.Classes;
 
type
  TDocumentoNfeItem = class
  private
    FIdItem: Integer;
    FIdDocumento: Integer;
    FItem: Integer;
    FDescricao: string;
    FNcm: string;
    FQuantidade: Extended;
    FVlUnitario: Currency;
    FVlTotal: Currency;
  public
    property IdItem: Integer read FIdItem write FIdItem;
    property IdDocumento: Integer read FIdDocumento write FIdDocumento;
    property Item: Integer read FItem write FItem;
    property Descricao: string read FDescricao write FDescricao;
    property Ncm: string read FNcm write FNcm;
    property Quantidade: Extended read FQuantidade write FQuantidade;
    property VlUnitario: Currency read FVlUnitario write FVlUnitario;
    property VlTotal: Currency read FVlTotal write FVlTotal;
  end;
 
implementation
 
end.