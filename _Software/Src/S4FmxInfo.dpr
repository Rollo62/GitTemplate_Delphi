program S4FmxInfo;

uses
  System.StartUpCopy,
  FMX.Forms,
  UMainFrm in 'UMainFrm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
