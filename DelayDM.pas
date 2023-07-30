unit DelayDM;

interface

uses 
  Windows, Messages, SysUtils, Classes, Forms, 
  DAVDCommon, DVSTModule;

type
  TDelayDataModule = class(TVSTModule)
    // Ketika GUI untuk plugin VST dibuka, fungsi ini akan dipanggil untuk menginisialisasi dan menampilkan tampilan GUI.
    procedure VSTModuleEditOpen(Sender: TObject; var GUI: TForm; ParentWindow: Cardinal);
    procedure VSTModuleCreate(Sender: TObject);
    // Fungsi utama pemrosesan sinyal delay, yang akan dipanggil oleh host VST saat setiap blok sample diproses.
    procedure VSTModuleProcess(const Inputs, Outputs: TAVDArrayOfSingleDynArray; const SampleFrames: Integer);
    // Fungsi ini dipanggil saat nilai parameter untuk delay diubah. Ini akan mengatur ukuran buffer delay sesuai dengan nilai parameter yang baru.
    procedure DelayDataModuleParameterProperties0ParameterChange(Sender: TObject; const Index: Integer; var Value: Single);
  private
    // Array yang menyimpan buffer delay untuk masing-masing kanal (stereo: kiri dan kanan).
    fBuffer     : array[0..1] of TAVDSingleDynArray;
    // Ukuran buffer delay, ditentukan oleh parameter yang dapat diubah oleh pengguna.
    fBufferSize : Integer;
    // Posisi saat ini dalam buffer delay.
    fBufferPos  : Integer;
  public
  end;

implementation

{$R *.DFM}

uses
  DelayUI;

// Implementasi fungsi untuk membuka GUI plugin VST.
procedure TDelayDataModule.VSTModuleEditOpen(Sender: TObject; var GUI: TForm; ParentWindow: Cardinal);
begin
  GUI := TArvinDelayUI.Create(Self);
end;

// Implementasi fungsi untuk inisialisasi modul delay.
procedure TDelayDataModule.VSTModuleCreate(Sender: TObject);
begin
  // Nilai default untuk parameter delay adalah 441.
  Parameter[0] := 441;
  fBufferPos := 0;
end;

// Implementasi fungsi untuk pemrosesan sinyal delay.
procedure TDelayDataModule.VSTModuleProcess(const Inputs, Outputs: TAVDArrayOfSingleDynArray; const SampleFrames: Integer);
var
  j : Integer;
begin
  for j := 0 to SampleFrames - 1 do
  begin
    // Menghitung output untuk setiap sampel dengan menambahkan input dengan nilai dari buffer delay saat ini.
    outputs[0, j] := inputs[0, j] + fBuffer[0, fBufferPos];
    outputs[1, j] := inputs[1, j] + fBuffer[1, fBufferPos];

    // Menyimpan input ke buffer delay untuk digunakan di masa depan.
    fBuffer[0, fBufferPos] := inputs[0, j];
    fBuffer[1, fBufferPos] := inputs[1, j];

    // Menambahkan posisi buffer delay untuk menyimpan sampel berikutnya.
    Inc(fBufferPos);
    if fBufferPos >= fBufferSize then
      fBufferPos := 0;
  end;
end;

// Implementasi fungsi untuk mengubah ukuran buffer delay sesuai dengan nilai parameter yang baru.
procedure TDelayDataModule.DelayDataModuleParameterProperties0ParameterChange(Sender: TObject; const Index: Integer; var Value: Single);
begin
  fBufferSize := Round(Value);
  // Mengatur ulang ukuran buffer delay untuk masing-masing kanal.
  SetLength(fBuffer[0], fBufferSize);
  SetLength(fBuffer[1], fBufferSize);
  
  // Jika posisi buffer delay saat ini melebihi ukuran buffer yang baru, reset posisi ke awal buffer.
  if fBufferPos >= fBufferSize then
    fBufferPos := 0;
end;

end.

