object frmTetris: TfrmTetris
  Left = 397
  Top = 712
  Width = 911
  Height = 695
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Tetris'
  Color = clNavy
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object BackIMG: TImage
    Left = 0
    Top = 0
    Width = 105
    Height = 105
  end
  object panelScore: TPanel
    Left = 8
    Top = 16
    Width = 145
    Height = 337
    BevelInner = bvRaised
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 39
      Height = 16
      Caption = 'Score:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 8
      Top = 72
      Width = 77
      Height = 16
      Caption = 'Timer Delay:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 8
      Top = 128
      Width = 35
      Height = 16
      Caption = 'Lines:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object pnNB: TPanel
      Left = 5
      Top = 200
      Width = 135
      Height = 129
      TabOrder = 0
      object Label3: TLabel
        Left = 51
        Top = 8
        Width = 31
        Height = 16
        Caption = 'Next'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object NB: TFastIMG
        Left = 12
        Top = 32
        Width = 112
        Height = 89
        AutoSize = False
      end
    end
    object panelscr1: TPanel
      Left = 8
      Top = 32
      Width = 129
      Height = 25
      Color = clBtnText
      TabOrder = 1
      object lblSCR: TLabel
        Left = 8
        Top = 4
        Width = 8
        Height = 16
        Caption = '0'
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clLime
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
    end
    object panelscr2: TPanel
      Left = 8
      Top = 88
      Width = 129
      Height = 25
      Color = clBtnText
      TabOrder = 2
      object lbllevel: TLabel
        Left = 8
        Top = 4
        Width = 8
        Height = 16
        Caption = '0'
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clLime
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
    end
    object panelscr3: TPanel
      Left = 8
      Top = 144
      Width = 129
      Height = 25
      Color = clBtnText
      TabOrder = 3
      object lbllines: TLabel
        Left = 8
        Top = 4
        Width = 8
        Height = 16
        Caption = '0'
        Color = clBlack
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clLime
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
    end
  end
  object panelPlayArea: TPanel
    Left = 256
    Top = 16
    Width = 104
    Height = 104
    AutoSize = True
    BevelInner = bvRaised
    TabOrder = 1
    object PlayArea: TFastIMG
      Left = 2
      Top = 2
      Width = 100
      Height = 100
      AutoSize = True
    end
  end
  object GameClock: TTimer
    Enabled = False
    Interval = 140
    OnTimer = GameClockTimer
    Left = 200
    Top = 16
  end
  object MainMenu: TMainMenu
    Left = 160
    Top = 16
    object mnuGame: TMenuItem
      Caption = '&Game'
      object mnuNewGame: TMenuItem
        Caption = '&New'
        ShortCut = 113
        OnClick = mnuNewGameClick
      end
      object mnuPause: TMenuItem
        Caption = '&Pause'
        ShortCut = 114
        OnClick = mnuPauseClick
      end
      object mnuScores: TMenuItem
        Caption = '&High Scores...'
        OnClick = mnuScoresClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Caption = 'E&xit'
        OnClick = mnuExitClick
      end
    end
    object Skill1: TMenuItem
      Caption = '&Skill'
      Hint = 'mnuSkill'
      object mnuStartingLevels: TMenuItem
        Caption = 'Starting &Levels'
      end
      object mnuStartingRows: TMenuItem
        Caption = 'Starting &Rows'
        object N01: TMenuItem
          Caption = '&0'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N11: TMenuItem
          Tag = 1
          Caption = '&1'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N21: TMenuItem
          Tag = 2
          Caption = '&2'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N31: TMenuItem
          Tag = 3
          Caption = '&3'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N41: TMenuItem
          Tag = 4
          Caption = '&4'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N51: TMenuItem
          Tag = 5
          Caption = '&5'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N61: TMenuItem
          Tag = 6
          Caption = '&6'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N71: TMenuItem
          Tag = 7
          Caption = '&7'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N81: TMenuItem
          Tag = 8
          Caption = '&8'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
        object N91: TMenuItem
          Tag = 9
          Caption = '&9'
          GroupIndex = 1
          RadioItem = True
          OnClick = N01Click
        end
      end
    end
    object mnuOptions: TMenuItem
      Caption = '&Options'
      object mnuSFX: TMenuItem
        Caption = 'Special Effects'
        OnClick = mnuSFXClick
      end
      object mnuNB: TMenuItem
        Caption = 'Block Preview'
        OnClick = mnuNBClick
      end
      object mnuCS: TMenuItem
        Caption = 'Choose &dataset...'
        OnClick = mnuCSClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = '&Help'
      object mnuAbout: TMenuItem
        Caption = '&About...'
        OnClick = mnuAboutClick
      end
    end
  end
end
