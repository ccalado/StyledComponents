{******************************************************************************}
{                                                                              }
{       StyledTaskDialogDemo: a Demo for Task Dialog Components                }
{                                                                              }
{       Copyright (c) 2022 (Ethea S.r.l.)                                      }
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
unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Grids, DBGrids, DB, DBClient, StdCtrls, DBCtrls,
  Vcl.CheckLst, Vcl.StyledTaskDialog,

{$IFDEF VCLSTYLEUTILS}
  //VCLStyles support
  Vcl.PlatformVclStylesActnCtrls,
  Vcl.Styles.ColorTabs,
  Vcl.Styles.ControlColor,
  Vcl.Styles.DbGrid,
  Vcl.Styles.DPIAware,
  Vcl.Styles.Ext,
  Vcl.Styles.Fixes,
  Vcl.Styles.FormStyleHooks,
  Vcl.Styles.NC,
  Vcl.Styles.Utils.Menus,
  Vcl.Styles.Utils.Misc,
  Vcl.Styles.Utils,
  Vcl.Styles.Utils.ScreenTips,
  Vcl.Styles.Utils.SysControls,
  Vcl.Styles.Utils.SysStyleHook,
  Vcl.Styles.Utils.SystemMenu,
  Vcl.Styles.WebBrowser,
  Vcl.Styles.Hooks,
  Vcl.Styles.OwnerDrawFix,
  Vcl.Styles.Utils.ComCtrls,
  Vcl.Styles.Utils.Forms,
  Vcl.Styles.Utils.Graphics,
  Vcl.Styles.Utils.StdCtrls,
  Vcl.Styles.UxTheme,
{$ENDIF}
  UITypes;

type
  TMainForm = class(TForm)
    edTitle: TEdit;
    edMessage: TMemo;
    btTask: TButton;
    rgDlgType: TRadioGroup;
    clbButtons: TCheckListBox;
    btMsg: TButton;
    btError: TButton;
    DefaultButtonComboBox: TComboBox;
    DefaultButtonLabel: TLabel;
    btStdTask: TButton;
    btStdMsgDlg: TButton;
    CBXButton2: TButton;
    TaskDialog: TTaskDialog;
    ShowTaskDialogCompButton: TButton;
    ShowStyleDialogButton: TButton;
    StyledTaskDialog: TStyledTaskDialog;
    TitleLabel: TLabel;
    MessageLabel: TLabel;
    cbUseStyledDialog: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ShowDlg(Sender: TObject);
    procedure RaiseError(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeStyleButtonClick(Sender: TObject);
    procedure ShowTaskDialog(Sender: TObject);
    procedure TaskDialogTimer(Sender: TObject; TickCount: Cardinal;
      var Reset: Boolean);
    procedure ShowStyleDialogButtonClick(Sender: TObject);
    procedure cbUseStyledDialogClick(Sender: TObject);
  private
  public
    procedure ShowError(Sender: TObject; E: Exception);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.TypInfo
  , Vcl.Themes
  , Vcl.StyledCmpMessages
  , Vcl.StyledCmpStrUtils
  , Vcl.StyledTaskDialogFormUnit;

procedure TMainForm.cbUseStyledDialogClick(Sender: TObject);
begin
  UseStyledDialogForm(cbUseStyledDialog.Checked);
end;

procedure TMainForm.ChangeStyleButtonClick(Sender: TObject);
//var
//  NewStyleName: string;
begin
(*
  NewStyleName := CBSelectStyleName(Self.Font);
  if StyleServices.Enabled then
  begin
    TStyleManager.SetStyle(NewStyleName);
    WriteAppStyleToReg('Ethea', ExtractFileName(Application.ExeName),NewStyleName);
  end;
*)
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  dt : TMsgDlgType;
  db : TMsgDlgBtn;
  Msg: string;
  LButtonName: string;
begin
  UnregisterCustomExecute;
  SetUseAlwaysTaskDialog(False);
  Font.Assign(Screen.IconFont);
  Font.Name := 'Century Gothic';
  Screen.MessageFont.Assign(Font);

  for dt := Low(TMsgDlgType) to High(TMsgDlgType)  do
    rgDlgType.Items.Add(GetEnumName(TypeInfo(TMsgDlgType), Ord(dt)));
  for db := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
  begin
    LButtonName := GetEnumName(TypeInfo(TMsgDlgBtn), Ord(db));
    clbButtons.Items.Add(LButtonName);
    if db = mbOK then
      clbButtons.Checked[Ord(db)] := True;
    DefaultButtonComboBox.Items.Add(LButtonName);
  end;

  rgDlgType.ItemIndex := 0;

  Msg :='The file was created: '+StringToHRef('C:\Windows\System32\license.rtf','license.rtf')+sLineBreak+
        'You can run: '+StringToHRef('C:\Windows\System32\Notepad.exe','Notepad Editor')+sLineBreak+
        'You can open folder: '+StringToHRef('C:\Windows\System32\')+sLineBreak+
        'You can visit site: '+StringToHRef('http://www.ethea.it','www.Ethea.it');

  edMessage.Text := Msg;
end;

procedure TMainForm.ShowDlg(Sender: TObject);
var
  Buttons: TMsgDlgButtons;
  db : TMsgDlgBtn;
  LDefaultButton: TMsgDlgBtn;
  LUseDefault: boolean;
begin
  Buttons := [];
  LUseDefault := False;
  LDefaultButton := mbOK;
  for db := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
    if clbButtons.Checked[Ord(db)] then
    begin
      Buttons := Buttons + [db];
      if SameText(DefaultButtonComboBox.Text, clbButtons.Items[Ord(db)]) then
      begin
        LDefaultButton := db;
        LUseDefault := True;
      end;
    end;

  if LUseDefault then
  begin
    if Sender = btTask then
      StyledTaskDlgPos(edTitle.Text, edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, LDefaultButton, 0)
    else if Sender = btStdTask then
      TaskMessageDlg(edTitle.Text, edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, 0)
    else if Sender = btStdMsgDlg then
      MessageDlg(edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, 0)
    else
      StyledMessageDlgPos(edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, LDefaultButton, 0);
  end
  else
  begin
    if Sender = btTask then
      StyledTaskDlgPos(edTitle.Text, edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, 0)
    else if Sender = btStdTask then
      TaskMessageDlg(edTitle.Text, edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, 0)
    else
      StyledMessageDlgPos(edMessage.Text, TMsgDlgType(rgDlgType.ItemIndex), Buttons, 0);
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
//  FActionResourceVCL.Free;
end;

procedure TMainForm.RaiseError(Sender: TObject);
var
  LHelpContext: Integer;
begin
  if Sender = btError then
    LHelpContext := -100
  else
    LHelpContext := 200;

  raise Exception.CreateHelp('Errore imprevisto!'+sLineBreak+
    'Consultare il file di errore: '+
    StringToHRef('C:\Windows\System32\license.rtf','license.rtf'),
    LHelpContext);
end;

procedure TMainForm.ShowError(Sender: TObject; E: Exception);
var
  Buttons: TMsgDlgButtons;
  Selection: Integer;
  LTitle: string;
  LMessage: string;
  LHelpContext: Integer;
  LUseTaskDialog: Boolean;
begin
  LTitle := GetErrorClassNameDesc(E.ClassName,
    E is EAccessViolation);
  LMessage := E.Message;
  LHelpContext := 0;

  LUseTaskDialog := (E.HelpContext = -100);

  if E.HelpContext <> 0 then
    LHelpContext := Abs(E.HelpContext);

  Buttons := [mbOK];
  if LHelpContext <> 0 then
    Buttons := Buttons + [mbHelp];
  if LUseTaskDialog and (Win32MajorVersion >= 6) then
  begin
    if E.InheritsFrom(EAccessViolation) then
      Buttons := Buttons + [mbAbort];

    Selection := StyledTaskDlgPos(LTitle, LMessage, mtError, Buttons, mbOK, LHelpContext);
    if Selection = mrAbort then
      Application.Terminate
    else if Selection = -1 then
      Application.HelpContext(LHelpContext);
  end
  else
  begin
    Selection := StyledMessageDlgPos(LMessage, mtError, Buttons, mbOK, LHelpContext);
    if Selection = mrAbort then
      Application.Terminate
    else if Selection = -1 then
      Application.HelpContext(LHelpContext);
  end;
end;

procedure TMainForm.ShowTaskDialog(Sender: TObject);
begin
//  TaskDialog.ProgressBar.Min := 0;
//  TaskDialog.ProgressBar.Max := 100;

  TaskDialog.Execute;
end;

procedure TMainForm.ShowStyleDialogButtonClick(Sender: TObject);
begin
  StyledTaskDialog.Execute(Self.Handle);
end;

procedure TMainForm.TaskDialogTimer(Sender: TObject; TickCount: Cardinal; var Reset: Boolean);
begin
   // TaskDialog1.ProgressBar.Position := MyThread.CurrentProgressPercent;
   // Demo
   //TaskDialog.ProgressBar.Position :=  TaskDialog.ProgressBar.Position + 1;
   TaskDialog.Execute(Self.Handle);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
