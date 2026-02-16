object DM_Dados: TDM_Dados
  Height = 505
  Width = 450
  PixelsPerInch = 120
  object memDocNFe: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 44
    Top = 34
    object memDocNFeID_DOCUMENTO: TIntegerField
      FieldName = 'ID_DOCUMENTO'
    end
    object memDocNFeCHAVE_ACESSO: TStringField
      FieldName = 'CHAVE_ACESSO'
      Size = 44
    end
    object memDocNFeNUMERO: TStringField
      FieldName = 'NUMERO'
      Size = 12
    end
    object memDocNFeSERIE: TStringField
      FieldName = 'SERIE'
      Size = 5
    end
    object memDocNFeDT_EMISSAO: TDateTimeField
      FieldName = 'DT_EMISSAO '
    end
    object memDocNFeEMIT_CNPJ_CPF: TStringField
      FieldName = 'EMIT_CNPJ_CPF'
      Size = 14
    end
    object memDocNFeEMIT_RAZAO: TStringField
      FieldName = 'EMIT_RAZAO'
      Size = 120
    end
    object memDocNFeDEST_CNPJ_CPF: TStringField
      FieldName = 'DEST_CNPJ_CPF'
      Size = 14
    end
    object memDocNFeDEST_RAZAO: TStringField
      FieldName = 'DEST_RAZAO'
      Size = 120
    end
    object memDocNFeVL_TOTAL: TCurrencyField
      FieldName = 'VL_TOTAL'
    end
    object memDocNFeSTATUS_PROC: TStringField
      FieldName = 'STATUS_PROC'
    end
    object memDocNFeMSG_STATUS: TStringField
      FieldName = 'MSG_STATUS'
      Size = 255
    end
    object memDocNFeARQUIVO_NOME: TStringField
      FieldName = 'ARQUIVO_NOME'
      Size = 200
    end
    object memDocNFeXML_CONTEUDO: TBlobField
      FieldName = 'XML_CONTEUDO'
      Size = 10000
    end
    object memDocNFeDT_IMPORTACAO: TDateTimeField
      FieldName = 'DT_IMPORTACAO'
    end
  end
  object dsDocNFe: TDataSource
    DataSet = memDocNFe
    Left = 184
    Top = 42
  end
  object memItens: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 44
    Top = 130
    object memItensID_ITEM: TIntegerField
      FieldName = 'ID_ITEM'
    end
    object memItensID_DOCUMENTO: TIntegerField
      FieldName = 'ID_DOCUMENTO'
    end
    object memItensITEM: TIntegerField
      FieldName = 'ITEM'
    end
    object memItensDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      Size = 160
    end
    object memItensNCM: TStringField
      FieldName = 'NCM'
      Size = 8
    end
    object memItensQUANTIDADE: TCurrencyField
      FieldName = 'QUANTIDADE'
      currency = False
    end
    object memItensVL_UNITARIO: TCurrencyField
      FieldName = 'VL_UNITARIO'
    end
    object memItensVL_TOTAL: TCurrencyField
      FieldName = 'VL_TOTAL'
    end
  end
  object dsItens: TDataSource
    DataSet = memItens
    Left = 188
    Top = 146
  end
  object memDocEventos: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 43
    Top = 250
    object memDocEventosID_EVENTO: TIntegerField
      FieldName = 'ID_EVENTO'
    end
    object memDocEventosID_DOCUMENTO: TIntegerField
      FieldName = 'ID_DOCUMENTO'
    end
    object memDocEventosDT_EVENTO: TDateTimeField
      FieldName = 'DT_EVENTO'
    end
    object memDocEventosTIPO_EVENTO: TStringField
      FieldName = 'TIPO_EVENTO'
      Size = 30
    end
    object memDocEventosSTATUS_ANTES: TStringField
      FieldName = 'STATUS_ANTES'
    end
    object memDocEventosSTATUS_DEPOIS: TStringField
      FieldName = 'STATUS_DEPOIS'
    end
    object memDocEventosMENSAGEM: TStringField
      FieldName = 'MENSAGEM'
      Size = 255
    end
    object memDocEventosDETALHE: TStringField
      FieldName = 'DETALHE'
      Size = 2000
    end
    object memDocEventosUSUARIO: TStringField
      FieldName = 'USUARIO'
      Size = 60
    end
  end
  object dsDocEventos: TDataSource
    DataSet = memDocEventos
    Left = 195
    Top = 242
  end
end
