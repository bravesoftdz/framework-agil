unit ViewUI.FormDefaultCadastroUI;

interface

uses
  TypeAgil.Constants,
  InterfaceAgil.Observer,
  InterfaceAgil.Controller,
  Controller.Rotina,
  DataModule.Recursos,
  DataModule.Base,
  ViewUI.FormDefaultUI,
  ViewUI.FormRequiredFields,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, Data.DB,
  cxLookAndFeels, cxLookAndFeelPainters, dxCustomWizardControl, dxWizardControl,
  System.Actions, Vcl.ActnList,

  dxSkinsCore, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White;

type
  TFormDefaultCadastroUI = class(TFormDefaultUI)
    wcCadastro: TdxWizardControl;
    pgNominal: TdxWizardControlPage;
    dtsCadastro: TDataSource;
    acnEvento: TActionList;
    acnCancelarFechar: TAction;
    acnNovo: TAction;
    acnEditar: TAction;
    procedure FormCreate(Sender: TObject);
    procedure dtsCadastroStateChange(Sender: TObject);
    procedure wcCadastroButtonClick(Sender: TObject;
      AKind: TdxWizardControlButtonKind; var AHandled: Boolean);
    procedure acnCancelarFecharExecute(Sender: TObject);
    procedure acnNovoExecute(Sender: TObject);
    procedure acnEditarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    function GetEmEdicao : Boolean;
  public
    { Public declarations }
    property FormularioEmEdicao : Boolean read GetEmEdicao;

    procedure New; virtual; abstract;
    procedure Edit; virtual; abstract;
    procedure Cancel; virtual; abstract;
    procedure Save; virtual; abstract;
    procedure RefreshRecord; virtual; abstract;
    procedure SaveFieldsRestinctions(const aController : IController; const aDataSet : TDataSet); virtual;

    function RequiredFields(const AOnwer : TComponent; aTableName : String) : Boolean;
  end;

var
  FormDefaultCadastroUI: TFormDefaultCadastroUI;

implementation

{$R *.dfm}

procedure TFormDefaultCadastroUI.acnCancelarFecharExecute(Sender: TObject);
begin
  if FormularioEmEdicao then
    Cancel
  else
    Self.Close;
end;

procedure TFormDefaultCadastroUI.acnEditarExecute(Sender: TObject);
begin
  if IsOwnerForm(Owner) or RotinaController.Model.Parent.Busca then
    if Assigned(dtsCadastro.DataSet) then
      if dtsCadastro.DataSet.Active then
        Self.Edit;
end;

procedure TFormDefaultCadastroUI.acnNovoExecute(Sender: TObject);
begin
  if IsOwnerForm(Owner) or RotinaController.Model.Parent.Busca then
    if Assigned(dtsCadastro.DataSet) then
    begin
      Self.New;
      wcCadastro.ActivePage := pgNominal;
    end;
end;

procedure TFormDefaultCadastroUI.dtsCadastroStateChange(Sender: TObject);
begin
  if Assigned(dtsCadastro.DataSet) then
    with wcCadastro.Buttons do
    begin
      Finish.Enabled := FormularioEmEdicao;

      if FormularioEmEdicao then
      begin
        Cancel.Caption    := '&Cancelar';
        Cancel.ImageIndex := IDX_OFFICE13_IMAGE_CANCEL;
      end
      else
      begin
        Cancel.Caption    := '&Fechar';
        Cancel.ImageIndex := IDX_OFFICE13_IMAGE_CLOSE;
      end;
    end;
end;

procedure TFormDefaultCadastroUI.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//  inherited;
  Action := caFree;
end;

procedure TFormDefaultCadastroUI.FormCreate(Sender: TObject);
begin
  pgNominal.Header.Title       := Trim(Self.Caption);
  pgNominal.Header.Description := Trim(Self.Hint);

  Descricao := pgNominal.Header.Description;
  inherited;
  wcCadastro.ActivePage  := pgNominal;
end;

function TFormDefaultCadastroUI.GetEmEdicao: Boolean;
begin
  if Assigned(dtsCadastro.DataSet) then
    Result := (dtsCadastro.DataSet.State in [dsEdit, dsInsert])
  else
    Result := False;
end;

function TFormDefaultCadastroUI.RequiredFields(const AOnwer: TComponent;
  aTableName: String): Boolean;
var
  aLista   : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  try
    if Assigned(dtsCadastro.DataSet) then
    begin
      aLista   := IdentifyEmptyFields( DtmBase.EmptyFields(dtsCadastro.DataSet) );
      aRetorno := ShowRequiredFields(Self, aLista, aTableName);
    end;
  finally
    Result := aRetorno;
  end;
end;

procedure TFormDefaultCadastroUI.SaveFieldsRestinctions(const aController : IController;
  const aDataSet: TDataSet);
begin
  if Assigned(aController) then
    if RotinaController.Model.RestricaoCampo then
      RotinaController.SaveFieldsRestinctions(Self, aDataSet, DtmBase.fdSetSistemaRotina)
    else
      RotinaController.ClearFieldsRestinctions(Self, DtmBase.fdQryRotina, False);
end;

procedure TFormDefaultCadastroUI.wcCadastroButtonClick(Sender: TObject;
  AKind: TdxWizardControlButtonKind; var AHandled: Boolean);
begin
  Case AKind of
    wcbkBack   : ;
    wcbkNext   : ;
    wcbkFinish : Save;
    wcbkCancel : acnCancelarFechar.Execute;
    wcbkHelp   : ;
  end;
end;

end.
