unit Unit1;

interface

uses
  Windows, Messages, Forms, Graphics, Menus, ExtCtrls, Classes, Controls, Math;

type
  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    Timer1: TTimer;
    PaintBox_pMenu: TPopupMenu;
    Properties_pMenu: TMenuItem;
    Pause_pMenu: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure Properties_pMenuClick(Sender: TObject);
    procedure Pause_pMenuClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
  public
    procedure HotKeys(var Message: TMessage); message WM_HOTKEY;
    procedure AppDeactivate(Sender: TObject);
    procedure AppActivate(Sender: TObject);
  end;

var
  Form1: TForm1;
  b: TBitmap;
  Left_coord, Top_coord: Integer; //положение квадрата на PaintBox
  size: Integer = -1;

implementation

uses Unit2;

{$R *.dfm}

procedure AllSquares(); //рисует все квадратики на весь экран
var
  j, i, Top_coord: Integer;
begin
  Top_coord := 0;
  for j := 0 to Round((Form1.PaintBox1.Height) / size) + 1 do begin
    Left_coord := 0;
    for i := 0 to Round((Form1.PaintBox1.Width) / size) + 1 do begin
      b.Canvas.Brush.Color := (Random(16777216));
      b.Canvas.FillRect(Rect(Left_coord, Top_coord, Left_coord + size, Top_coord + size));
      Inc(Left_coord, size); end;
    Inc(Top_coord, size); end;
  Form1.PaintBox1.Canvas.Draw(0, 0, b);
end;

procedure RandomSquares(); //рисует случайый квадрат
var
  k, m, i, N, Left_coord, Top_coord: Integer;
  Squares: array of Integer; //индексы случайных квадратиков
begin
  i := Ceil(Form1.PaintBox1.Height / size);
  m := Ceil(Form1.PaintBox1.Width / size);
  N := i * m;
  k := N;
  SetLength(Squares, N);
  Dec(N);
  for i := 0 to N do Squares[i] := i;

  for N := 0 to Round(N * Form2.Percent_Slider.Position * 0.01) do begin
    i := Random(k);
    b.Canvas.Brush.Color := (Random(16777216));
    Left_coord := (Squares[i] mod m) * size;
    Top_coord := (Squares[i] div m) * size;
    b.Canvas.FillRect(Rect(Left_coord, Top_coord, Left_coord + size, Top_coord + size));
    Dec(k);
    Squares[i] := Squares[k]; end;
  Form1.PaintBox1.Canvas.Draw(0, 0, b);
end;

procedure TForm1.AppDeactivate(Sender: TObject);
begin
  UnRegisterHotKey(Handle, 0);
  UnRegisterHotKey(Handle, 1);
  UnRegisterHotKey(Handle, 2);
  UnRegisterHotKey(Handle, 3);
end;

procedure TForm1.AppActivate(Sender: TObject);
begin //если надо Hotkey: Ctrl + Alt + <Любой символ или Shift, т.е. любая клавиша> и вызываем LoadDefaultConfig, то надо проверять ещё и нажатие ЛКМ
  RegisterHotKey(Handle, 0, MOD_CONTROL, Ord('P'));
  RegisterHotKey(Handle, 1, 0, 32); //Space - пауза
  RegisterHotKey(Handle, 2, 0, VK_F2);
  RegisterHotKey(Handle, 3, MOD_CONTROL, Ord('R'));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  b := TBitmap.Create();
  b.Width := PaintBox1.Width - PaintBox1.Left;
  b.Height := PaintBox1.Height - PaintBox1.Top;
  PaintBox1.ControlStyle := Paintbox1.controlstyle + [csOpaque]; //чтобы не было мерцания при перерисовке
  DoubleBuffered := True; //двойная буферизация (т.е. пока рисуется на монитор, то уже рисуется на виртуальный экран)
  b.Canvas.Font.Size := 16;
  b.Canvas.Font.Name := 'Times New Roman';
  b.Canvas.Font.Style := [fsBold];
  b.Canvas.Brush.Color := Form1.Color;
  b.Canvas.FillRect(ClientRect);
  Application.OnDeactivate := AppDeactivate;
  Application.OnActivate := AppActivate;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Form2.isRandomSquares_chkBx.Checked then RandomSquares()
  else AllSquares();
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  b.Width := PaintBox1.Width;
  b.Height := PaintBox1.Height;
end;

procedure TForm1.PaintBox1DblClick(Sender: TObject);
begin
  Form2.StartDrawing_btnClick(nil);
end;

procedure TForm1.Properties_pMenuClick(Sender: TObject);
begin
  Form2.Show();
end;

procedure TForm1.HotKeys(var Message: TMessage);
begin
  if (Message.WParam = 0) then Properties_pMenuClick(nil)
  else if (Message.WParam = 1) then Pause_pMenuClick(nil)
  else if (Message.WParam = 2) then Form2.StartDrawing_btnClick(nil)
  else if (Message.WParam = 3) then Form2.isRandomSquares_chkBx.Checked := Form2.isRandomSquares_chkBx.Checked xor True
end;

procedure TForm1.Pause_pMenuClick(Sender: TObject);
begin
  if Timer1.Enabled then Timer1.Enabled := False
  else Timer1.Enabled := True;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, b);
end;

end.

