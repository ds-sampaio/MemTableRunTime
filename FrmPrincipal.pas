unit FrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,System.JSON,DataSet.Serialize,
  FireDAC.Stan.StorageBin,
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
    participante: TFDMemTable;
    part_funcionario: TFDMemTable;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FJsonObj,FJsonData,FJsonStructure : TJSONObject;
    //FListMemTable : TList<iTable>;
   // participante,part_funcionario : TFDMemTable;
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
//  participante  := TFDMemTable.Create(Self);
//  part_funcionario  := TFDMemTable.Create(Self);

  dtsPai.DataSet   := participante;
  dtsFilho.DataSet := part_funcionario;


  CriaJSON; //Aqui separa o JSon a estrutura dos dados
  SetPropriedadesMT; //Aqui carrega a estrutura e os dados na MemTable

  Memo2.Lines.Add(participante.ToJSONObject().Format()); //Aqui aprenda o resultado da MemTableMaster


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
//  TDataSetSerializeConfig.GetInstance.CaseNameDefinition :=
//    TCaseNameDefinition.cndLower;
//
//  {Carrega estrutura da Master}
//  participante.LoadStructure(FJsonStructure.GetValue('participante') as TJSONArray);
//  //participante.CreateDataSet;
//
//  {Carrega estrutura do detail}
//  part_funcionario.LoadStructure(FJsonStructure.GetValue('part_funcionario') as TJSONArray);
//  //part_funcionario.CreateDataSet;
//
//
//  InitializaMasterDetail; //Configura a relação MasterDetail nas MemTable's
//
//  {Carraga todo os dados do Json na MemTableMaster, incluindo os detail's}
//  participante.LoadFromJSON(FJsonData.GetValue('participante') as TJSONArray);
    TDataSetSerializeConfig.GetInstance.CaseNameDefinition :=
             TCaseNameDefinition.cndLower;


   FJsonObj   := TJSONObject
                   .ParseJSONValue(TEncoding
                                     .UTF8
                                     .GetBytes(Memo1.Lines.Text),
                                   0) as TJSONObject;
  FJsonData      := FJsonObj.GetValue('data') as TJSONObject;
  FJsonStructure := FJsonObj.GetValue('structure') as TJSONObject;


  participante.LoadStructure(FJsonStructure.GetValue('participante') as TJSONArray);
  part_funcionario.LoadStructure(FJsonStructure.GetValue('part_funcionario') as TJSONArray);

  participante.Open;
  part_funcionario.Open;

  part_funcionario.MasterSource := dtsPai;
  part_funcionario.MasterFields := 'id_participante';
  part_funcionario.DetailFields := 'id_participante';
  part_funcionario.IndexFieldNames := 'id_participante';

  participante.LoadFromJSON(FJsonData.GetValue('participante') as TJSONArray);

  //LJSONArray := participante.ToJSONArray;
  Memo2.Lines.Add(participante.ToJSONObject().Format);

end;

procedure TForm1.InitializaMasterDetail;
begin

  participante.Open;

  part_funcionario.Open;
  part_funcionario.MasterSource := dtsPai;
  part_funcionario.MasterFields := 'id_participante'; //participante.Fields[0].FieldName;
  part_funcionario.DetailFields := 'id_participante';//part_funcionario.Fields[0].FieldName;
  part_funcionario.IndexFieldNames := 'id_participante'; //part_funcionario.Fields[0].FieldName;



end;


end.
