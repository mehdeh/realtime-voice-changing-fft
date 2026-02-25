unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,MultiMedia, System.ComponentModel, Borland.Vcl.StdCtrls,
  Borland.Vcl.ExtCtrls, Borland.Vcl.ComCtrls, Borland.Vcl.Buttons,Drawing,
  fourier,Types, Borland.Vcl.Menus, DrawLinePoint,math;
{$UNSAFECODE ON}

const
     Black : TRGBTriple = (rgbtBlue:0;rgbtGreen:0;rgbtRed:0);
     Whith : TRGBTriple = (rgbtBlue:255;rgbtGreen:255;rgbtRed:255);
     LenWindow=1024;

type
  TForm1 = class(TForm)
    Image1: TImage;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Timer1: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    Frame41: TFrame4;
    Image2: TImage;
    Panel3: TPanel;
    ImageA: TImage;
    ImageB: TImage;
    ImageC: TImage;
    ImageD: TImage;
    ImageE: TImage;
    ImageF: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
  X          :TDoubleDynArray;
  Y          :TDoubleDynArray;
  A          :TDoubleDynArray;
  Theta      :TDoubleDynArray;
  Data       :TDoubleDynArray;
  X1         :TDoubleDynArray;
  Y1         :TDoubleDynArray;
  temp       :TDoubleDynArray;
  temp1       :TDoubleDynArray;
  temp2       :TDoubleDynArray;
  X2,Y2      :TDoubleDynArray;
  FtoF       :TDoubleDynArray;

    Recorder : Trecorder;
    Player   : TPlayer;
    FStart    : Boolean;
    RecPos   : Cardinal;
    m1       : Cardinal;
    BufferRec  : TSmallInt;
    BufferPlay : TSmallInt;
    hdd      : Integer;
    pbih     : PBITMAPINFOHEADER;
    SWBufRec : array[1..130,1..200] of TRGBTriple;
    SWbufPlay  : array[1..130,1..200] of TRGBTriple;
    ImageOn    : Boolean;
    f:boolean;
    procedure Change(t : Cardinal);
    procedure ShowShapeWave(pos : Cardinal);

    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
implementation

{$R *.nfm}

procedure TForm1.FormCreate(Sender: TObject); unsafe;
var
     p : intptr;
begin
     hdd:=DrawDibOpen;
     p:=GetMem(SizeOf(BITMAPINFOHEADER));
     pbih:=p.ToPointer;
     pbih^.biSize         := SizeOf(BITMAPINFOHEADER);
     pbih^.biWidth        := 200;
     pbih^.biHeight       := 130;
     pbih^.biPlanes       := 1;
     pbih^.biBitCount     := 24;
     pbih^.biCompression  := BI_RGB;
     pbih^.biSizeImage    := 0;
     pbih^.biXPelsPerMeter:= 0;
     pbih^.biYPelsPerMeter:= 0;
     pbih^.biClrUsed      := 0;
     pbih^.biClrImportant := 0;
   //  DrawDibBegin(hdd,Panel1.Canvas.Handle,200,130,pbih,200,130,0);
     Player:=Tplayer.Create;
     Recorder:=Trecorder.Create;
     m1:=0;
     FFTInitial(LenWindow);
     SetLength(X,LenWindow);
     SetLength(Y,LenWindow);
     SetLength(A,LenWindow);
     SetLength(Theta,LenWindow);
     SetLength(Data,LenWindow);
     SetLength(X1,LenWindow);
     SetLength(Y1,LenWindow);
     SetLength(temp,LenWindow);
     SetLength(temp1,LenWindow);
     SetLength(temp2,LenWindow);
     SetLength(X2,LenWindow);
     SetLength(Y2,LenWindow);
     ImageOn:=False;
     FtoF:=Frame41.Initialize(LenWindow,0,LenWindow-10);
     Panel1.Canvas.Pen.Mode:=pmXor;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
     i : Cardinal;

begin
     RecPos:=Recorder.GetPosition-60000;
     for i := m1 to RecPos do
     begin
          if ((i+1) mod LenWindow = 0) then
               Change(i-LenWindow+1);
        //  if recpos>61000 then
        //  BufferPlay[i]:=(BufferRec[i]+BufferRec[i+10000]+BufferRec[i+20000]+BufferRec[i+40000])div 4;
     end;
     if f and (recpos>61000) then //m1=0 then
     begin
          f:=false;
          Player.Play;
     end;
   //  ShowShapeWave(m1);
     m1:=RecPos+1;

end;

procedure TForm1.Change(t : Cardinal);
var
     i:Integer;
     p1,p2:Double;
     f1,f2:Integer;
begin
//     BufferPlay[t]:=BufferRec[t];
     HanningWindow(BufferRec,t,Data);
     FFT(Data,X,Y);
   (*  for i:=0 to LenWindow-1 do
     begin
          A[i]:=0.001+Sqrt(X[i]*X[i]+Y[i]*Y[i])/LenWindow;
          temp[i]:=A[Round(sqrt(i*4095))];
          X[i]:=temp[i]*X[i]/A[i];
          Y[i]:=temp[i]*Y[i]/A[i];
         { if y[i] <> 0 then
               Theta[i]:=20*(ArcTan(x[i]/y[i])+pi/2)
          else
               Theta[i]:=20*(Sign(x[i])*PI/2+PI/2);}
     end;
     FFT(A,X2,Y2);  *)
    { for i:=0 to LenWindow-1 do
     begin
          A[i]:=20*Sqrt(X2[i]*X2[i]+Y2[i]*Y2[i])/LenWindow;
     end;  }

     FFT(X,X1,temp);
     FFT(Y,temp,Y1);
     for i:=0 to LenWindow-1 do
          BufferPlay[t+i]:=Round((Y1[i]+X1[i])/LenWindow);
end;

procedure Tform1.ShowShapeWave(pos : Cardinal);unsafe;
var
     j,i : Integer;
     r:byte;

begin
   {  for j:=1 to 130 do
     for i:=1 to 200 do
     begin
          if (130-j) = Round((X[i*20-1]+9627680)*130/19255360) then
               swbufRec[j,i]:=black
          else
               swbufRec[j,i]:=Whith;
          if (130-j) = Round((BufferPlay[pos+i]+32768)*130/65535) then
               swbufPlay[j,i]:=black
          else
               swbufPlay[j,i]:=Whith;

     end;
          DrawDibDraw(hdd,Panel1.Canvas.Handle,0,0,200,130,
     pbih,@swbufRec[1,1],0,0,200,130,0);
          DrawDibDraw(hdd,Panel2.Canvas.Handle,0,0,200,130,
     pbih,@swbufPlay[1,1],0,0,200,130,0); }
     if m1=0 then
     begin
          panel1.Canvas.MoveTo(0,260);
          for i:= 0 to 700 do
          begin
               temp1[i]:=A[i];
               j:=260-Round(temp1[i]);
               panel1.Canvas.LineTo(i,j);
          end;
     end;
     panel1.Canvas.MoveTo(0,260);
     for i:= 0 to 700 do
     begin
          j:=260-Round(temp1[i]);
          panel1.Canvas.LineTo(i,j);
     end;
    panel1.Canvas.MoveTo(0,260);
    for i:= 0 to 700 do
     begin
          temp1[i]:=A[i];
          j:=260-Round(temp1[i]);
          panel1.Canvas.LineTo(i,j);
     end;

end;

procedure TForm1.Image2Click(Sender: TObject);
begin
     if not FStart then
     begin
        //  Image1.Picture.LoadFromFile();
        f:=true;
          Player.Open;
          Recorder.Open;
          Recorder.SetMaxLenRecSecond(300);
          BufferRec:=Recorder.GetBuffer;
          BufferPlay:=GetMemArray(High(BufferRec)+1);
          Player.SetBuffer(BufferPlay);
          Recorder.Start;
          Timer1.Enabled:=True;
          Panel1.Repaint;
          sleep(4000);  //?
          m1:=0;
          FStart:=True;
     end
     else
     begin
          //Image1.Picture.LoadFromFile();
          Timer1.Enabled:=False;
          Recorder.Reset;
          Player.Pause;
         // Player.SaveToWaveFile();
         // Recorder.SaveToWaveFile();
          Player.Close;
          Recorder.Close;
          FreeMemArray(BufferPlay);
          FStart:=False;
     end;
end;

procedure TForm1.Image2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if Not FStart then
          Image2.Picture.Bitmap:=ImageB.Picture.Bitmap
     else
          Image2.Picture.Bitmap:=ImageD.Picture.Bitmap;
end;

procedure TForm1.Image2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
     if FStart then
          Image2.Picture.Bitmap:=ImageF.Picture.Bitmap
     else
          Image2.Picture.Bitmap:=ImageE.Picture.Bitmap;
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
     if Not ImageOn then
     begin
          if FStart then
               Image2.Picture.Bitmap:=ImageF.Picture.Bitmap
          else
               Image2.Picture.Bitmap:=ImageE.Picture.Bitmap;
          ImageOn:=True;
     end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
     if ImageOn then
     begin
          if FStart then
               Image2.Picture.Bitmap:=ImageC.Picture.Bitmap
          else
               Image2.Picture.Bitmap:=ImageA.Picture.Bitmap;
          ImageOn:=False;
     end;
end;

end.
