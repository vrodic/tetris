object frmChooseSkin: TfrmChooseSkin
  Left = 350
  Top = 139
  BorderStyle = bsDialog
  Caption = 'Choose dataset'
  ClientHeight = 316
  ClientWidth = 257
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 89
    Height = 13
    Caption = 'Available datasets:'
  end
  object btnOK: TButton
    Left = 96
    Top = 280
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 174
    Top = 280
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object lbSkins: TListBox
    Left = 8
    Top = 24
    Width = 241
    Height = 249
    ItemHeight = 13
    TabOrder = 2
    OnDblClick = lbSkinsDblClick
  end
end
