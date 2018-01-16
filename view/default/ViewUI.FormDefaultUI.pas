unit ViewUI.FormDefaultUI;

interface

uses
  TypeAgil.ComplexTypes,
  InterfaceAgil.Observer,
  Controller.Rotina,
  DataModule.Base,
  DataModule.Recursos,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  TypInfo, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxRibbon, dxRibbonForm, dxRibbonSkins;

type
  TFormDefaultUI = class(TdxRibbonForm, IObservador)
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    aRotinaController : TRotinaController;
    procedure SetRotinaController(Value : TRotinaController);
    procedure SetDescricao(Value : String);
    function GetRotinaController : TRotinaController;
    function GetDescricao : String;
  protected
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; Controller: TRotinaController); overload;
  public
    { Public declarations }
    property RotinaController : TRotinaController read GetRotinaController;// write SetRotinaController;
    property Descricao : String read GetDescricao write SetDescricao;

    constructor CreateForm(AOwner: TComponent; Controller: TRotinaController); reintroduce;
    procedure Update(Observable: IObservable);
  end;

var
  FormDefaultUI: TFormDefaultUI;

implementation

{$R *.dfm}

{ TFormDefaultUI }

constructor TFormDefaultUI.Create(AOwner: TComponent);
var
  aParenteController : TRotinaController;
begin
  inherited Create(AOwner);
  aParenteController := nil;

  if Assigned(Self.Owner) then
  begin
    if (Self.Owner is TFormDefaultUI) then
      if (TFormDefaultUI(Self.Owner).RotinaController <> nil) then
        aParenteController := TFormDefaultUI(Self.Owner).RotinaController;
  end;

  aRotinaController := TRotinaController.Create;
  with aRotinaController do
  begin
    Model.Codigo    := Self.Name;
    Model.Nome      := Self.Caption;
    Model.Descricao := Self.Hint;
    Model.Tipo      := tr_Formulario;
    Model.Sistema   := gSistema.Model;

    if (aParenteController <> nil) then
      Model.Parent := aParenteController.Model;

//    Esta rotina est� fazendo o objeto ser destru�do antes do tempo
//    Model.addObserver(Self);
  end;
end;

constructor TFormDefaultUI.Create(AOwner: TComponent; Controller: TRotinaController);
begin
  inherited Create(AOwner);
  aRotinaController := TRotinaController.Create;
  with aRotinaController do
  begin
    Model.Codigo    := Self.Name;
    Model.Nome      := Self.Caption;
    Model.Descricao := Self.Hint;
    Model.Tipo      := tr_Formulario;
    Model.Sistema   := gSistema.Model;
    Model.Parent    := Controller.Model;

//    Esta rotina est� fazendo o objeto ser destru�do antes do tempo
//    Model.addObserver(Self);
  end;
end;

constructor TFormDefaultUI.CreateForm(AOwner: TComponent;
  Controller: TRotinaController);
begin
  Self.Create(AOwner, Controller);
end;

procedure TFormDefaultUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFormDefaultUI.FormCreate(Sender: TObject);
begin
  DisableAero := True;
end;

procedure TFormDefaultUI.FormShow(Sender: TObject);
begin
  aRotinaController.Load(DtmBase.fdQryRotina);
  if (aRotinaController.Model.Indice = 0) then
  begin
    aRotinaController.Model.Indice := DtmBase.GetNewValueDB('SYS_ROTINA', 'IX_ROTINA', EmptyStr);
    aRotinaController.Save(DtmBase.fdSetSistemaRotina);
  end;
end;

function TFormDefaultUI.GetDescricao: String;
begin
  Result := aRotinaController.Model.Descricao;
end;

function TFormDefaultUI.GetRotinaController: TRotinaController;
begin
  Result := aRotinaController;
end;

procedure TFormDefaultUI.SetDescricao(Value: String);
begin
  Self.Hint := Trim(Value);
  if Assigned(aRotinaController) then
    aRotinaController.Model.Descricao := Trim(Self.Hint);
end;

procedure TFormDefaultUI.SetRotinaController(Value: TRotinaController);
begin
  aRotinaController := Value;
end;

procedure TFormDefaultUI.Update(Observable: IObservable);
begin
  Self.Tag := aRotinaController.Model.Indice;
end;

end.
