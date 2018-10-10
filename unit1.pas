unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynExportHTML, SynPluginSyncroEdit,
  SynCompletion, SynMacroRecorder, SynHighlighterPas, PrintersDlgs, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, Menus, Drawng2D;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    FileExit: TMenuItem;
    MenuItem2: TMenuItem;
    FileNew: TMenuItem;
    FileOpen: TMenuItem;
    FileSave: TMenuItem;
    FileSaveAs: TMenuItem;
    AddConstrSquare: TMenuItem;
    AddConstrCircleYellow: TMenuItem;
    AddConstrCircleGreen: TMenuItem;
    AddConstrFrame: TMenuItem;
    MenuItem7: TMenuItem;
    FilePrint: TMenuItem;
    FilePrinterSetup: TMenuItem;
    OpenDialog: TOpenDialog;
    PaintBox: TPaintBox;
    PrintDialog: TPrintDialog;
    PrinterSetupDialog: TPrinterSetupDialog;
    SaveDialog: TSaveDialog;
    procedure AddConstrCircleGreenClick(Sender: TObject);
    procedure AddConstrCircleYellowClick(Sender: TObject);
    procedure AddConstrFrameClick(Sender: TObject);
    procedure FileExitClick(Sender: TObject);
    procedure FilePrintClick(Sender: TObject);
    procedure FilePrinterSetupClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FileNewClick(Sender: TObject);
    procedure FileOpenClick(Sender: TObject);
    procedure FileSaveClick(Sender: TObject);
    procedure AddConstrSquareClick(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxClick(Sender: TObject);
    procedure PaintBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxStartDrag(Sender: TObject; var DragObject: TDragObject);
  private
  public
    Drawing: TDrawing2D;
    FileName: string;
    LastSaved: TDateTime;
    StickyElement: TElement;
    function HasChanged: Boolean;
    procedure ResetDrawing;
    procedure SaveDrawing;
    procedure SaveDrawingAs;
  end;

var
  Form1: TForm1;

implementation

uses FormEx;

{$R *.lfm}

{ TForm1 }

procedure TForm1.PaintBoxPaint(Sender: TObject);
var
  PB: TPaintBox absolute Sender;
begin
  Drawing.Draw
end;

procedure TForm1.PaintBoxStartDrag(Sender: TObject; var DragObject: TDragObject
  );
begin
  DragObject := TDragObject.AutoCreate(Sender as TControl);
end;

function TForm1.HasChanged: Boolean;
begin
  Result := LastSaved < Drawing.LastModified
end;

procedure TForm1.ResetDrawing;
begin
  Drawing.Clear;
  LastSaved := Drawing.LastModified;
  PaintBox.Refresh;
end;

procedure TForm1.SaveDrawing;
begin
  if HasChanged then
    if FileName <> '' then begin
      Drawing.SaveToFile(FileName);
      LastSaved := Drawing.LastModified
    end
    else SaveDrawingAs
end;

procedure TForm1.SaveDrawingAs;
begin
  SaveDialog.FileName := FileName;
  if SaveDialog.Execute then begin
    Drawing.SaveToFile(SaveDialog.FileName);
    FileName := SaveDialog.FileName;
    LastSaved := Drawing.LastModified;
  end
  else ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Drawing := TDrawing2D.Create(Self);
  Drawing.Control := Paintbox;
  ResetDrawing;
  FormAdjust(Self);
  PaintBox.Height := ClientHeight;
  PaintBox.Width := ClientWidth;
  PaintBox.Canvas.Brush.Color := clWhite;
end;

procedure TForm1.FilePrintClick(Sender: TObject);
begin
  PrintDialog.Execute
end;

procedure TForm1.FileExitClick(Sender: TObject);
begin
  Close
end;

procedure TForm1.AddConstrCircleYellowClick(Sender: TObject);
begin
  StickyElement := Drawing.NewElement(TConstrCircle);
  (StickyElement as TConstrCircle).Color := clYellow;
end;

procedure TForm1.AddConstrFrameClick(Sender: TObject);
begin
  StickyElement := Drawing.NewElement(TConstrFrame)
end;

procedure TForm1.AddConstrCircleGreenClick(Sender: TObject);
begin
  StickyElement := Drawing.NewElement(TConstrCircle);
  (StickyElement as TConstrCircle).Color := clLime
end;

procedure TForm1.FilePrinterSetupClick(Sender: TObject);
begin
  PrinterSetupDialog.Execute
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := not HasChanged;
  if HasChanged then
    case MessageDlg('Die Zeichnung wurde seit dem letzten Speichern verändert. Soll die Änderung gespeichert werden?',
      mtConfirmation, mbYesNoCancel, 0, mbYes) of
      mrYes: begin
          SaveDrawing;
          CanClose := HasChanged
        end;
      mrNo: CanClose := True;
      mrCancel: CanClose := False;
    end;
end;

procedure TForm1.FileNewClick(Sender: TObject);
begin
  if HasChanged then
    case MessageDlg('Die aktuelle Zeichnung wurde geändert. Soll sie gespeichert werden?', mtConfirmation, mbYesNoCancel, 0, mbYes) of
      mrYes: begin
          SaveDrawing;
          ResetDrawing;
        end;
      mrNo: begin
          ResetDrawing
        end;
      mrCancel:;
    end
  else ResetDrawing
end;

procedure TForm1.FileOpenClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    SaveDrawing;
    Drawing.LoadFromFile(OpenDialog.FileName);
    Drawing.Control := PaintBox;
    LastSaved := Drawing.LastModified;
    FileName := OpenDialog.FileName;
  end;
end;

procedure TForm1.FileSaveClick(Sender: TObject);
begin
  SaveDrawing
end;

procedure TForm1.AddConstrSquareClick(Sender: TObject);
begin
  StickyElement := Drawing.NewElement(TConstrSquare);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if StickyElement <> nil then begin
    if X > ClientWidth - 8 then ScrollBy(8, 0)
    else if X < 8 then ScrollBy(-8, 0)
  end;
end;

procedure TForm1.PaintBoxClick(Sender: TObject);
begin
  if StickyElement <> nil then
    if not StickyElement.Dragging then StickyElement := nil
end;

procedure TForm1.PaintBoxDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin

end;

procedure TForm1.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if StickyElement <> nil then Exit;
  if Button = mbLeft then begin
    StickyElement := Drawing.GetElementAt(X, Y);
    if StickyElement <> nil then StickyElement.Dragging := True
  end;
end;

procedure TForm1.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  P: TPoint;
begin
  if StickyElement <> nil then begin
    StickyElement.PixelsCenter := Point(X, Y);
    PaintBox.Refresh;
  end;
end;

procedure TForm1.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if StickyElement <> nil then
    if StickyElement.Dragging then
      if Button = mbLeft then begin
        StickyElement.Dragging := False;
        StickyElement := nil
      end;
end;

end.

