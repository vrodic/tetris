object frmScores: TfrmScores
  Left = 199
  Top = 108
  BorderStyle = bsDialog
  Caption = 
    '                                                      High Score' +
    's'
  ClientHeight = 376
  ClientWidth = 529
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 88
    Top = 8
    Width = 1
    Height = 329
    Shape = bsLeftLine
  end
  object Bevel2: TBevel
    Left = 288
    Top = 8
    Width = 1
    Height = 329
    Shape = bsLeftLine
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Score:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 96
    Top = 8
    Width = 28
    Height = 13
    Caption = 'Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 296
    Top = 8
    Width = 47
    Height = 13
    Caption = 'Comment:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object btnClose: TButton
    Left = 8
    Top = 344
    Width = 513
    Height = 25
    Cancel = True
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
  end
  object stScore: TStaticText
    Left = 8
    Top = 32
    Width = 73
    Height = 305
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object stName: TStaticText
    Left = 96
    Top = 32
    Width = 185
    Height = 305
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object stComment: TStaticText
    Left = 296
    Top = 32
    Width = 225
    Height = 305
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object edName: TEdit
    Left = 96
    Top = 32
    Width = 185
    Height = 16
    BorderStyle = bsNone
    TabOrder = 4
    Visible = False
    OnKeyPress = edNameKeyPress
  end
  object edComment: TEdit
    Left = 296
    Top = 32
    Width = 225
    Height = 16
    BorderStyle = bsNone
    TabOrder = 5
    Visible = False
    OnKeyPress = edCommentKeyPress
  end
end
