program P_SoftgranXML;

uses
  Vcl.Forms,
  U_ViewPrincipal in 'Src\view\U_ViewPrincipal.pas' {F_ViewPrincipal},
  U_DocumentoNfe in 'Src\model\U_DocumentoNfe.pas',
  U_DocumentoNfeItem in 'Src\model\U_DocumentoNfeItem.pas',
  U_DocumentoEvento in 'Src\model\U_DocumentoEvento.pas',
  U_IDocumentoNfe in 'Src\interfaces\U_IDocumentoNfe.pas',
  U_DocumentoNfeImplementacao in 'Src\implementations\U_DocumentoNfeImplementacao.pas',
  U_ControllerDocumentoNfe in 'Src\controller\U_ControllerDocumentoNfe.pas',
  U_ConfigBanco in 'Src\conexao\U_ConfigBanco.pas',
  U_ConexaoFirebird in 'Src\conexao\U_ConexaoFirebird.pas',
  U_DaoDocumentoNFe in 'Src\dao\U_DaoDocumentoNFe.pas',
  U_DaoDocumentoNFeItem in 'Src\dao\U_DaoDocumentoNFeItem.pas',
  U_DaoDocumentoEvento in 'Src\dao\U_DaoDocumentoEvento.pas',
  U_DmDados in 'Src\conexao\U_DmDados.pas' {DM_Dados: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TF_ViewPrincipal, F_ViewPrincipal);
  Application.CreateForm(TDM_Dados, DM_Dados);
  Application.Run;
end.
