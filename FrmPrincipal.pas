unit FrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,System.JSON,DataSet.Serialize,
  FireDAC.Stan.StorageBin, GestorCloud.Controller.Factory.Table,
  GestorCloud.Model.Table.Firedac, GestorCloud.Model.Table.Interfaces,
  System.Generics.Collections;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    dtsPai: TDataSource;
    dtsFilho: TDataSource;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FJsonObj,FJsonData,FJsonStructure : TJSONObject;
    FListMemTable : TList<iTable>;
    FMemTable1,FMemTable2 : TFDMemTable;
    procedure CriaJSON;
    procedure SetPropriedadesMT;
    procedure InitializaMasterDetail;
  public
    { Public declarations }
  end;


var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  FMemTable1  := TFDMemTable.Create(Self);
  FMemTable2  := TFDMemTable.Create(Self);
  dtsPai.DataSet   := FMemTable1;
  dtsFilho.DataSet := FMemTable2;


  CriaJSON; //Aqui separa o JSon a estrutura dos dados
  SetPropriedadesMT; //Aqui carrega a estrutura e os dados na MemTable

  Memo2.Lines.Add(FMemTable1.ToJSONObject().ToJSON); //Aqui aprenda o resultado da MemTableMaster


end;

procedure TForm1.CriaJSON;
begin
  FJsonObj   := TJSONObject
                   .ParseJSONValue(TEncoding
                                     .UTF8
                                     .GetBytes(Memo1.Text),
                                   0) as TJSONObject;

  FJsonData      := FJsonObj.GetValue('data') as TJSONObject;
  FJsonStructure := FJsonObj.GetValue('structure') as TJSONObject;
end;

procedure TForm1.SetPropriedadesMT;
var
  I: Integer;
begin
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition :=
    TCaseNameDefinition.cndLower;

  {Carrega estrutura da Master}
  FMemTable1.LoadStructure(FJsonStructure.GetValue('participante') as TJSONArray);
  FMemTable1.CreateDataSet;

  {Carrega estrutura do detail}
  FMemTable2.LoadStructure(FJsonStructure.GetValue('part_funcionario') as TJSONArray);
  FMemTable2.CreateDataSet;

  InitializaMasterDetail; //Configura a rela��o MasterDetail nas MemTable's

  {Carraga todo os dados do Json na MemTableMaster, incluindo os detail's}
  FMemTable1.LoadFromJSON(FJsonData.GetValue('participante') as TJSONArray);

end;

procedure TForm1.InitializaMasterDetail;
begin

  FMemTable1.Open; //Master
  FMemTable2.Open; //Detail
  FMemTable2.MasterSource := dtsPai;
  FMemTable2.MasterFields := 'id_participante';
  FMemTable2.DetailFields := 'id_participante';
  FMemTable2.IndexFieldNames := 'id_participante';



end;


end.
