unit DelayUI;

interface

uses 
  Windows, Messages, SysUtils, Classes, Forms, DAVDCommon, DVSTModule,
  Graphics, Controls, ExtCtrls, StdCtrls, DGuiBaseControl, DGuiDial;

type
  TArvinDelayUI = class(TForm)
    Skins: TImage;
    KnobLength: TGuiDial;
    procedure KnobLengthChange(Sender: TObject);
  end;

implementation

Uses DelayDM;
{$R *.DFM}

procedure TArvinDelayUI.KnobLengthChange(Sender: TObject);
begin
TDelayDataModule(Owner).Parameter[0]:=KnobLength.Position;
end;

end.
