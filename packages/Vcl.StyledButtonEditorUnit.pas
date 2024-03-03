{******************************************************************************}
{                                                                              }
{       StyledButton Editor: Component editor for Styled Button                }
{                                                                              }
{       Copyright (c) 2022-2024 (Ethea S.r.l.)                                 }
{       Author: Carlo Barazzetta                                               }
{       Contributors:                                                          }
{                                                                              }
{       https://github.com/EtheaDev/StyledComponents                           }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit Vcl.StyledButtonEditorUnit;

interface

{$INCLUDE ..\Source\StyledComponents.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  Vcl.ActnList,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.StyledButton,
  Vcl.ButtonStylesAttributes,
  Vcl.StandardButtonStyles,
  Vcl.BootstrapButtonStyles,
  Vcl.AngularButtonStyles,
  Vcl.ColorButtonStyles,
  Vcl.ImgList;

const
  BUTTON_WIDTH = 100;
  BUTTON_HEIGHT = 34;
  BUTTON_MARGIN = 10;
type
  TStyledButtonEditor = class(TForm)
    BottomPanel: TPanel;
    OKButton: TStyledButton;
    ApplyButton: TStyledButton;
    CancelButton: TStyledButton;
    HelpButton: TStyledButton;
    paTop: TPanel;
    ActualGroupBox: TGroupBox;
    NewGroupBox: TGroupBox;
    SplitterTop: TSplitter;
    SourceButton: TStyledGraphicButton;
    DestButton: TStyledGraphicButton;
    TabControl: TTabControl;
    AttributesPanel: TPanel;
    AttributesGroupBox: TGroupBox;
    StyleDrawTypeLabel: TLabel;
    StyleRadiusLabel: TLabel;
    EnabledCheckBox: TCheckBox;
    StyleDrawTypeComboBox: TComboBox;
    RadiusTrackBar: TTrackBar;
    ImageList: TImageList;
    ScrollBox: TScrollBox;
    FlatButtonCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure paTopResize(Sender: TObject);
    procedure StyleDrawTypeComboBoxSelect(Sender: TObject);
    procedure EnabledCheckBoxClick(Sender: TObject);
    procedure DestButtonClick(Sender: TObject);
    procedure RadiusTrackBarChange(Sender: TObject);
    procedure FlatButtonCheckBoxClick(Sender: TObject);
  private
    FUpdating: Boolean;
    FFamilyBuilt: TStyledButtonFamily;
    FStyledButtonRender: TStyledButtonRender;
    FStyledButton: TControl;
    FCustomStyleDrawType: Boolean;
    procedure BuildTabControls;
    procedure BuildFamilyPreview(const AFamily: TStyledButtonFamily);
    procedure BuildButtonsPreview(const AFamily: TStyledButtonFamily;
      const AAppearance: TStyledButtonAppearance; const AFlowPanel: TFlowPanel);
    procedure ApplyStyle;
    procedure InitGUI;
    procedure UpdateDestFromGUI;
    procedure ButtonClick(Sender: TObject);
    //procedure ButtonEnter(Sender: TObject);
    procedure UpdateSizeGUI;
    procedure FlowPanelResize(Sender: TObject);
  protected
    procedure Loaded; override;
  public
    property CustomStyleDrawType: Boolean read FCustomStyleDrawType;
  end;

function EditStyledButton(const AButton: TControl): Boolean; overload;
function EditStyledGraphicButton(const AButton: TCustomStyledGraphicButton): Boolean; overload;
function EditStyledButton(const AButton: TCustomStyledButton): Boolean; overload;
function EditStyledButtonRender(const AButtonRender: TStyledButtonRender): Boolean; overload;

implementation

{$R *.dfm}

uses
  Vcl.Themes
  , Vcl.Graphics
  //WARNING: you must define this directive to use this unit outside the IDE
{$IFNDEF UseStyledCompEditorsAtRunTime}
  , ToolsAPI
  , BrandingAPI
  {$IF (CompilerVersion >= 32.0)}, IDETheme.Utils{$IFEND}
{$ENDIF}
  , Winapi.ShellAPI
  , System.Contnrs
  , Vcl.StyledCmpStrUtils
  , System.TypInfo
  ;

var
  SavedBounds: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);

function EditStyledButton(const AButton: TControl): Boolean;
begin
  if AButton is TCustomStyledGraphicButton then
    Result := EditStyledGraphicButton(TCustomStyledGraphicButton(AButton))
  else if AButton is TCustomStyledButton then
    Result := EditStyledButton(TCustomStyledButton(AButton))
  else
    raise Exception.CreateFmt('Cannot Edit Control "%s"', [AButton.Name]);
end;

function EditStyledGraphicButton(const AButton: TCustomStyledGraphicButton): Boolean;
begin
  Result := EditStyledButtonRender(AButton.Render);
end;

function EditStyledButton(const AButton: TCustomStyledButton): Boolean;
begin
  Result := EditStyledButtonRender(AButton.Render);
end;

function EditStyledButtonRender(const AButtonRender: TStyledButtonRender): Boolean;
var
  LEditor: TStyledButtonEditor;
begin
  LEditor := TStyledButtonEditor.Create(nil);
  with LEditor do
  begin
    try
      FStyledButtonRender := AButtonRender;
      FStyledButton := FStyledButtonRender.OwnerControl;
      paTop.Height := SourceButton.Top + AButtonRender.Height + SourceButton.Top;
      AButtonRender.AssignStyleTo(SourceButton.Render);
      SourceButton.Enabled := AButtonRender.Enabled;
      SourceButton.Caption := AButtonRender.Caption;
      SourceButton.Hint := AButtonRender.Hint;
      SourceButton.Width := AButtonRender.Width;
      SourceButton.Height := AButtonRender.Height;
      SourceButton.Flat := AButtonRender.Flat;
      SourceButton.Style := AButtonRender.Style;

      AButtonRender.AssignStyleTo(DestButton.Render);
      DestButton.Enabled := AButtonRender.Enabled;
      DestButton.Width := AButtonRender.Width;
      DestButton.Height := AButtonRender.Height;
      DestButton.Caption := AButtonRender.Caption;
      DestButton.Hint := AButtonRender.Hint;
      DestButton.Flat := AButtonRender.Flat;
      DestButton.Style := AButtonRender.Style;

      Result := ShowModal = mrOk;
      SavedBounds := BoundsRect;
    finally
      Free;
    end;
  end;
end;

{ TStyledButtonEditorForm }

procedure TStyledButtonEditor.ButtonClick(Sender: TObject);
var
  LStyledButton: TStyledGraphicButton;
begin
  LStyledButton := Sender as TStyledGraphicButton;
  FCustomStyleDrawType := False;
  LStyledButton.Render.SetCustomStyleDrawType(FCustomStyleDrawType);
  LStyledButton.AssignStyleTo(DestButton.Render);
  StyleDrawTypeComboBox.ItemIndex := Ord(LStyledButton.StyleDrawType);
  UpdateDestFromGUI;
end;

(*
procedure TStyledButtonEditor.ButtonEnter(Sender: TObject);
begin
  ButtonClick(Sender);
end;
*)

procedure TStyledButtonEditor.ApplyStyle;
begin
  Screen.Cursor := crHourglass;
  try
    DestButton.Render.SetCustomStyleDrawType(FCustomStyleDrawType);
    DestButton.AssignStyleTo(FStyledButtonRender);
    FStyledButton.Enabled := DestButton.Enabled;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TStyledButtonEditor.ApplyButtonClick(Sender: TObject);
begin
  ApplyStyle;
  UpdateDestFromGUI;
end;

procedure TStyledButtonEditor.BuildFamilyPreview(
  const AFamily: TStyledButtonFamily);
var
  I: Integer;
  LAppearances: TButtonAppearances;
  LAppearance: TStyledButtonAppearance;
  LGroupBox: TGroupBox;
  LFlowPanel: TFlowPanel;
  LGroupBoxHeight: Integer;
begin
  //Clear components
  while ScrollBox.ControlCount > 0 do
  begin
    LGroupBox := ScrollBox.Controls[0] as TGroupBox;
    while LGroupBox.ControlCount > 0 do
      LGroupBox.Controls[0].Free;
    LGroupBox.Free;
  end;
  //Build a GroupBox for any Appearance
  LAppearances := GetButtonFamilyAppearances(AFamily);
  LGroupBoxHeight := BUTTON_HEIGHT + BUTTON_MARGIN;
  for I := 0 to Length(LAppearances)-1 do
  begin
    LAppearance := LAppearances[I];
    LGroupBox := TGroupBox.Create(Self);
    LGroupBox.AlignWithMargins := True;
    LGroupBox.Caption := LAppearances[I];
    LGroupBox.Parent := ScrollBox;
    LGroupBox.Top := LGroupBoxHeight * (I);
    LGroupBox.Align := alTop;
    LGroupBox.Caption :=
      Format('StyleFamily: "%s" - StyleAppearance: "%s": List of StyleClass',
        [AFamily, LAppearance]);

    //Create a FlowPanel inside the GroupBox
    LFlowPanel := TFlowPanel.Create(Self);
    LFlowPanel.AlignWithMargins := True;
    LFlowPanel.Margins.Top := 6;
    LFlowPanel.Margins.Bottom := 6;
    LFlowPanel.Align := alTop;
    LFlowPanel.AutoSize := True;
    LFlowPanel.BevelOuter := bvNone;
    LFlowPanel.OnResize := FlowPanelResize;
    LFlowPanel.DoubleBuffered := True;
    LFlowPanel.Parent := LGroupBox;

    BuildButtonsPreview(AFamily, LAppearance, LFlowPanel);
  end;
  FFamilyBuilt := AFamily;
end;

procedure TStyledButtonEditor.BuildTabControls;
var
  LFamilies: TObjectList;
  LFamily: TStyledButtonFamily;
  I: Integer;
begin
  TabControl.Tabs.Clear;
  LFamilies := GetButtonFamilies;
  if Assigned(LFamilies) then
  begin
    for I := 0 to LFamilies.Count -1 do
    begin
      LFamily := GetButtonFamilyName(I);
      TabControl.Tabs.Add(LFamily);
      if SameText(LFamily, FStyledButtonRender.StyleFamily) then
        TabControl.TabIndex := I;
    end;
  end;
  TabControlChange(TabControl);
end;

procedure TStyledButtonEditor.DestButtonClick(Sender: TObject);
begin
  ; //Do nothing
end;

procedure TStyledButtonEditor.EnabledCheckBoxClick(Sender: TObject);
begin
  UpdateDestFromGUI;
end;

procedure TStyledButtonEditor.FormCreate(Sender: TObject);
{$IFNDEF UseStyledCompEditorsAtRunTime}
  {$IF (CompilerVersion >= 32.0)}
  var
    LStyle: TCustomStyleServices;
  {$IFEND}
{$ENDIF}
begin
{$IFNDEF UseStyledCompEditorsAtRunTime}
  {$IF (CompilerVersion >= 32.0)}
    {$IF (CompilerVersion <= 34.0)}
    if UseThemeFont then
      Self.Font.Assign(GetThemeFont);
    {$IFEND}
    {$IF CompilerVersion > 34.0}
    if TIDEThemeMetrics.Font.Enabled then
      Self.Font.Assign(TIDEThemeMetrics.Font.GetFont);
    {$IFEND}

    if ThemeProperties <> nil then
    begin
      LStyle := ThemeProperties.StyleServices;
      StyleElements := StyleElements - [seClient];
      Color := LStyle.GetSystemColor(clWindow);
      BottomPanel.StyleElements := BottomPanel.StyleElements - [seClient];
      BottomPanel.ParentBackground := False;
      BottomPanel.Color := LStyle.GetSystemColor(clBtnFace);

      OKButton.StyleClass := LStyle.Name;
      CancelButton.StyleClass := LStyle.Name;
      ApplyButton.StyleClass := LStyle.Name;
      HelpButton.StyleClass := LStyle.Name;

      IDEThemeManager.RegisterFormClass(TStyledButtonEditor);
      ThemeProperties.ApplyTheme(Self);
    end;
  {$IFEND}
{$ENDIF}
end;

procedure TStyledButtonEditor.InitGUI;
var
  I: TStyledButtonDrawType;
  LPos: Integer;
  LDrawName: string;
begin
  TabControl.OnChange := nil;
  try
    Caption := Format(Caption, [StyledButtonsVersion]);
    for I := Low(TStyledButtonDrawType) to High(TStyledButtonDrawType) do
    begin
      LDrawName := GetEnumName(TypeInfo(TStyledButtonDrawType), Ord(I));
      LPos := StyleDrawTypeComboBox.Items.Add(LDrawName);
      if I = SourceButton.StyleDrawType then
        StyleDrawTypeComboBox.ItemIndex := LPos;
    end;
    EnabledCheckBox.Checked := SourceButton.Enabled;
    RadiusTrackBar.Position := SourceButton.StyleRadius;
    FlatButtonCheckBox.Checked := SourceButton.Flat;

    UpdateDestFromGUI;
  finally
    TabControl.OnChange := TabControlChange;
  end;
  BuildTabControls;
end;

procedure TStyledButtonEditor.UpdateSizeGUI;
begin
  FUpdating := True;
  try
    Screen.Cursor := crHourGlass;
    InitGUI;
  finally
    FUpdating := False;
    Screen.Cursor := crDefault;
  end;
end;

procedure TStyledButtonEditor.FormShow(Sender: TObject);
begin
  UpdateSizeGUI;

  if SavedBounds.Right - SavedBounds.Left > 0 then
    SetBounds(SavedBounds.Left, SavedBounds.Top, SavedBounds.Width, SavedBounds.Height);
end;

procedure TStyledButtonEditor.HelpButtonClick(Sender: TObject);
begin
  ShellExecute(handle, 'open',
    PChar(GetProjectWikiURL), nil, nil, SW_SHOWNORMAL)
end;

procedure TStyledButtonEditor.Loaded;
begin
  inherited;
end;

procedure TStyledButtonEditor.OKButtonClick(Sender: TObject);
begin
  ApplyStyle;
end;

procedure TStyledButtonEditor.paTopResize(Sender: TObject);
begin
  ActualGroupBox.Width := paTop.Width div 2;
end;

procedure TStyledButtonEditor.RadiusTrackBarChange(Sender: TObject);
begin
  DestButton.StyleRadius := RadiusTrackBar.Position;
  UpdateDestFromGUI;
  FFamilyBuilt := '';
  TabControlChange(TabControl);
end;

procedure TStyledButtonEditor.StyleDrawTypeComboBoxSelect(Sender: TObject);
begin
  FCustomStyleDrawType := True;
  UpdateDestFromGUI;
  FFamilyBuilt := '';
  TabControlChange(TabControl);
end;

procedure TStyledButtonEditor.TabControlChange(Sender: TObject);
var
  LFamily: TStyledButtonFamily;
begin
  LFamily := TabControl.Tabs[TabControl.TabIndex];
  if FFamilyBuilt <> LFamily then
    BuildFamilyPreview(LFamily);
end;

procedure TStyledButtonEditor.UpdateDestFromGUI;
var
  LRoundRect: Boolean;
begin
  DestButton.StyleDrawType := TStyledButtonDrawType(StyleDrawTypeComboBox.ItemIndex);
  LRoundRect := DestButton.StyleDrawType = btRoundRect;
  DestButton.StyleRadius := RadiusTrackBar.Position;
  StyleRadiusLabel.Visible := LRoundRect;
  RadiusTrackBar.Visible := LRoundRect;
  StyleRadiusLabel.Caption := Format('StyleRadius: %d', [DestButton.StyleRadius]);
  DestButton.Enabled := EnabledCheckBox.Checked;
  ActualGroupBox.Caption := Format('ACTUAL: %s/%s/%s',
    [SourceButton.StyleFamily, SourceButton.StyleClass, SourceButton.StyleAppearance]);
  SourceButton.Hint := ActualGroupBox.Caption;
  NewGroupBox.Caption := Format('NEW: %s/%s/%s',
    [DestButton.StyleFamily, DestButton.StyleClass, DestButton.StyleAppearance]);
  DestButton.Hint := NewGroupBox.Caption;
  DestButton.Flat := FlatButtonCheckBox.Checked;
end;

procedure TStyledButtonEditor.BuildButtonsPreview(const AFamily: TStyledButtonFamily;
  const AAppearance: TStyledButtonAppearance;
  const AFlowPanel: TFlowPanel);
var
  J: Integer;
  LClasses: TButtonClasses;
  LDefaultClass: TStyledButtonClass;

  procedure CreateButton(
    const AParent: TFlowPanel;
    const AClass: TStyledButtonClass);
  var
    LStyledButton: TStyledGraphicButton;
  begin
    LStyledButton := TStyledGraphicButton.Create(Self);
    LStyledButton.Width := BUTTON_WIDTH;
    LStyledButton.Height := BUTTON_HEIGHT;
    LStyledButton.AlignWithMargins := True;
    LStyledButton.Caption := AClass;
    LStyledButton.Hint := Format('StyleFamily: "%s" - StyleAppearance: "%s" - StyleClass: "%s"',
      [AFamily, AAppearance, AClass]);
    LStyledButton.StyleFamily := AFamily;
    LStyledButton.StyleClass := AClass;
    LStyledButton.StyleAppearance := AAppearance;
    LStyledButton.OnClick := ButtonClick;
    //LStyledButton.OnEnter := ButtonEnter;
    LStyledButton.StyleDrawType := TStyledButtonDrawType(StyleDrawTypeComboBox.ItemIndex);
    LStyledButton.StyleRadius := RadiusTrackBar.Position;
    LStyledButton.Parent := AParent;
  end;

begin
  if AFlowPanel.ControlCount > 0 then
    Exit;

  Screen.Cursor := crHourGlass;
  Try
    AFlowPanel.OnResize := nil;
    AFlowPanel.DisableAlign;

    LClasses := GetButtonFamilyClasses(AFamily);
    LDefaultClass := LClasses[0];

    //Build Buttons for Family/Class/Appearance
    for J := 0 to Length(LClasses)-1 do
      CreateButton(AFlowPanel, LClasses[J]);
  Finally
    AFlowPanel.OnResize := FlowPanelResize;
    AFlowPanel.EnableAlign;
    Screen.Cursor := crDefault;
  End;
end;

procedure TStyledButtonEditor.FlatButtonCheckBoxClick(Sender: TObject);
begin
  UpdateDestFromGUI;
end;

procedure TStyledButtonEditor.FlowPanelResize(Sender: TObject);
begin
  TFlowPanel(Sender).Parent.Height := TFlowPanel(Sender).Height +
    SourceButton.Top;
end;

end.
