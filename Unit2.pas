unit Unit2;

interface

uses
  Windows, Forms, SysUtils, Menus, Dialogs, StdCtrls, Controls, Spin, Classes,
  IniFiles, Messages, ShellAPI, UFileCatcher, Unit1, ComCtrls;

type
  TForm2 = class(TForm)
    TimeInterval_spEdt: TSpinEdit;
    Size_spEdt: TSpinEdit;
    StopDrawing_btn: TButton;
    StartDrawing_btn: TButton;
    TimeInterval_lbl: TLabel;
    Size_lbl: TLabel;
    SaveCnfg_SaveDlg: TSaveDialog;
    LoadCnfg_openDlg: TOpenDialog;
    Program_menu: TMainMenu;
    Configuration_menu: TMenuItem;
    LoadCnfg_menu: TMenuItem;
    SaveCnfg_menu: TMenuItem;
    isRandomSquares_chkBx: TCheckBox;
    Percent_Slider: TTrackBar;
    Percent_Label: TLabel;
    procedure StartDrawing_btnClick(Sender: TObject);
    procedure StopDrawing_btnClick(Sender: TObject);
    procedure ValidSpinnerValue(Sender: TObject);
    procedure TimeInterval_spEdtKeyPress(Sender: TObject; var Key: Char);
    procedure LoadCnfg_menuClick(Sender: TObject);
    procedure SaveCnfg_menuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure isRandomSquares_chkBxClick(Sender: TObject);
    procedure Percent_SliderChange(Sender: TObject);
    procedure Percent_SliderContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure TimeInterval_spEdtClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure DropFiles(var Msg: TWMDropFiles); message WM_DROPFILES; //перетаскивание файла настроек на форму
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.TimeInterval_spEdtKeyPress(Sender: TObject; var Key: Char);
begin
  if ((GetKeyState(VK_CONTROL) < 0) and (Key = #1)) then (Sender as TSpinEdit).SelectAll(); //Ctrl+A
  if not ((GetKeyState(VK_CONTROL) < 0) and (key in [#26, #24, #3, #22])) and //можно использовать hotkeys: Ctrl+Z/X/C/V
    not (key in ['0'..'9']) and (Key <> #8) then key := #0 //ввод только цифр и Backspace
end;

procedure TForm2.ValidSpinnerValue(Sender: TObject);
var
  i: Integer;
  spEdt: TSpinEdit;
begin
  spEdt := Sender as TSpinEdit;
  if not TryStrToInt(spEdt.Text, i) then spEdt.Value := spEdt.MinValue;
  if i < spEdt.MinValue then spEdt.Value := spEdt.MinValue;
  if i > spEdt.MaxValue then spEdt.Value := spEdt.MaxValue
end;

procedure TForm2.StartDrawing_btnClick(Sender: TObject);
begin
  Form2.Close();
  b.Canvas.FillRect(Form1.PaintBox1.ClientRect);
  Form1.Timer1.Enabled := True;
  Form1.Timer1.Interval := TimeInterval_spEdt.Value;
  Unit1.size := Form2.Size_spEdt.Value;
  Form1.Timer1Timer(nil);
end;

procedure TForm2.StopDrawing_btnClick(Sender: TObject);
begin
  Form1.Timer1.Enabled := False;
end;

procedure SaveLoadConfig(const path: string; const IsSave: Boolean = False; const Sender: TObject = nil);
var
  iniCnfg: TIniFile;
begin
  iniCnfg := TIniFile.Create(path);
  with Form2 do begin
    if IsSave then begin
      iniCnfg.WriteInteger('Config', 'TimeInterval', TimeInterval_spEdt.Value);
      iniCnfg.WriteInteger('Config', 'Size', Size_spEdt.Value);
      iniCnfg.WriteBool('Config', 'isRandom', isRandomSquares_chkBx.Checked);
      iniCnfg.WriteInteger('Config', 'Percent', Percent_Slider.Position);
      Form2.Close(); end
    else begin
      if (Sender = nil) or (Sender = TimeInterval_spEdt) then TimeInterval_spEdt.Value := iniCnfg.ReadInteger('Config', 'TimeInterval', 45);
      if (Sender = nil) or (Sender = Size_spEdt) then Size_spEdt.Value := iniCnfg.ReadInteger('Config', 'Size', 250);
      if (Sender = nil) or (Sender = isRandomSquares_chkBx) then isRandomSquares_chkBx.Checked := iniCnfg.ReadBool('Config', 'isRandom', False);
      if (Sender = nil) or (Sender = Percent_Slider) then Percent_Slider.Position := iniCnfg.ReadInteger('Config', 'Percent', 50); end;
  end;
end;

function LoadDefaultConfig(const Sender: TObject): Boolean; //Если нажали Ctrl+Alt по параметру то загружает значение по умолчанию
begin
  Result := (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_MENU) < 0);
  if Result then
    if (GetKeyState(VK_SHIFT) < 0) then with Form2 do begin
        FormDeactivate(nil);
        Form1.AppDeactivate(nil);
        if LoadCnfg_openDlg.Execute then SaveLoadConfig(LoadCnfg_openDlg.FileName, False, Sender);
        Form1.AppActivate(nil); end
    else SaveLoadConfig('', False, Sender);
end;

procedure TForm2.LoadCnfg_menuClick(Sender: TObject);
begin
  FormDeactivate(nil);
  Form1.AppDeactivate(nil);
  if DirectoryExists(ExtractFilePath(LoadCnfg_openDlg.FileName)) then
    LoadCnfg_openDlg.InitialDir := ExtractFilePath(LoadCnfg_openDlg.FileName);
  if LoadCnfg_openDlg.Execute then begin
    SaveLoadConfig(LoadCnfg_openDlg.FileName);
    StartDrawing_btnClick(nil); end;
  Form1.AppActivate(nil);
end;

procedure TForm2.SaveCnfg_menuClick(Sender: TObject);
begin
  FormDeactivate(nil);
  Form1.AppDeactivate(nil);
  if DirectoryExists(ExtractFilePath(SaveCnfg_saveDlg.FileName)) then
    SaveCnfg_saveDlg.InitialDir := ExtractFilePath(SaveCnfg_saveDlg.FileName);
  if SaveCnfg_SaveDlg.Execute then
    SaveLoadConfig(SaveCnfg_saveDlg.FileName, True);
  Form1.AppActivate(nil);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  SaveCnfg_SaveDlg.FileName := ExtractFilePath(Application.ExeName) + 'RandomColor_BG_Default.ini';
  LoadCnfg_openDlg.FileName := ExtractFilePath(Application.ExeName) + 'RandomColor_BG_Default.ini';
  SaveLoadConfig((ExtractFilePath(Application.ExeName) + 'RandomColor_BG_Default.ini'));
  DragAcceptFiles(Self.Handle, True); //форма может принимать файлы
  Unit1.b.Canvas.TextOut((b.Width div 2) -
    (b.Canvas.TextWidth('Для старта программы нажмите дважды ЛКМ или ПКМ --> Установки --> Выбрав нужные установки, нажмите "Рисовать"') div 2),
    (b.Height div 2), 'Для старта программы нажмите дважды ЛКМ или ПКМ --> Установки --> Выбрав нужные установки, нажмите "Рисовать"');
  Form1.Timer1.Interval := TimeInterval_spEdt.Value;
  Unit1.size := Size_spEdt.Value;
end;

procedure TForm2.DropFiles(var Msg: TWMDropFiles); //перетаскивание файла настроек на форму
var
  i: Integer;
  Catcher: TFileCatcher;
begin
  inherited;
  Catcher := TFileCatcher.Create(Msg.Drop);
  try
    if Catcher.FileCount > 0 then //т.к. нам не нужно загружать все файлы, то загрузится только первый
      for i := 0 to Pred(Catcher.FileCount) do
        if LowerCase(ExtractFileExt(Catcher.Files[i])) = '.ini' then begin
          SaveLoadConfig(Catcher.Files[i]);
          StartDrawing_btnClick(nil);
          Break; end;
  finally Catcher.Free;
  end;
  Msg.Result := 0;
end;

procedure TForm2.FormDeactivate(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TSpinEdit then
      (Components[i] as TSpinEdit).OnExit(Components[i] as TSpinEdit)
end;

procedure TForm2.isRandomSquares_chkBxClick(Sender: TObject);
begin
  if LoadDefaultConfig(Sender) then Exit;
  Percent_Slider.Enabled := isRandomSquares_chkBx.Checked;
  Percent_Label.Enabled := Percent_Slider.Enabled;
end;

procedure TForm2.Percent_SliderChange(Sender: TObject);
begin
  Percent_Label.Caption := IntToStr(Percent_Slider.Position) + '%';
end;

procedure TForm2.Percent_SliderContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  LoadDefaultConfig(Sender);
end;

procedure TForm2.TimeInterval_spEdtClick(Sender: TObject);
begin
  LoadDefaultConfig(Sender);
end;

end.

