Program ExtendedDemoEight;
{EXTDEM8 - this program shows how to communicate between fields by
           raising signals.}

Uses DOS,CRT,
     totFAST, totINPUT, totIO1, totIO2;

CONST
  SignalNewDirectory = 1;
  DefaultDirectory: string[5] = 'C:\TP';

TYPE
MasterStringIOOBJ = object (StringIOOBJ)
   vLastInput: string;
   {methods}
   constructor Init(X,Y,FieldLen: byte);
   function    ProcessEnter: tAction;                                 VIRTUAL;
   function    Select(K:word; X,Y:byte): tAction;                     VIRTUAL;
   procedure   RaiseSignal(var TheSig:tSignal);                       VIRTUAL;
   procedure   ShutdownSignal(var BaseSig:tSignal);                   VIRTUAL;
   function    Suspend:boolean;                                       VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {MasterStringIOOBJ}

SlaveStringIOOBJ = object (StringIOOBJ)
   constructor Init(X,Y,FieldLen: byte);
   procedure   HandleSignal(var BaseSig:tSignal; var NewSig:tSignal); VIRTUAL;
   destructor  Done;                                                  VIRTUAL;
end; {SlaveStringIOOBJ}

VAR
  DefDir: MasterStringIOOBJ;
  ProgDir,
  DocDir,
  TPUDir,
  HelpDir: SlaveStringIOOBJ;
  Keys: ControlkeysIOOBJ;
  Manager: FormOBJ;
  Result: tAction;

{\\\\\\\\\\\\\\\\\\ OBJECT EXTENSIONS \\\\\\\\\\\\\\\\\\\\\\\\}
constructor MasterStringIOOBJ.Init(X,Y,FieldLen: byte);
{}
begin
   StringIOOBJ.Init(X,Y,FieldLen);
end; {MasterStringIOOBJ.Init}

function MasterStringIOOBJ.Select(K:word; X,Y:byte): tAction;
{}
begin
   vLastInput := vInputStr;
   Select := StringIOOBJ.Select(K,X,Y);
end; {MasterStringIOOBJ.Select}

function MasterStringIOOBJ.ProcessEnter: tAction;
{}
begin
   if vLastInput <> vInputStr then {need to signal}
      ProcessEnter := Signal
   else
      ProcessEnter := none;
end; {MasterStringIOOBJ.ProcessEnter}

procedure MasterStringIOOBJ.RaiseSignal(var TheSig:tSignal); 
{}
begin
   with TheSig do
   begin
      ID := SignalNewDirectory;
      MsgType := length(vInputStr);
      MsgPtr := @vInputStr;
   end;
   vLastInput := vInputStr;
end; {MasterStringIOOBJ.RaiseSignal}

procedure MasterStringIOOBJ.ShutdownSignal(var BaseSig:tSignal);
{no data to dispose of}
begin
end; {MasterStringIOOBJ.ShutdownSignal}

function MasterStringIOOBJ.Suspend:boolean;
{}
begin
   if vLastInput <> vInputStr then {need to signal}
   begin
      Suspend := false;
      Key.StuffBuffer(13); {Enter}
      Key.StuffBuffer(9);   {Tab}
   end
   else
      Suspend := StringIOOBJ.Suspend;
end; {MasterStringIOOBJ.Suspend}

destructor MasterStringIOOBJ.Done;
{}
begin
  StringIOOBJ.Done;
end; {MasterStringIOOBJ.Done}

constructor SlaveStringIOOBJ.Init(X,Y,FieldLen: byte);
{}
begin
   StringIOOBJ.Init(X,Y,FieldLen);
end; {SlaveStringIOOBJ.Init}

procedure SlaveStringIOOBJ.HandleSignal(var BaseSig:tSignal; var NewSig:tSignal);
{}
var temp:string;
begin
   with BaseSig do
   begin
      if (ID = SignalNewDirectory) and (vInputStr = DefaultDirectory) then 
      begin
         move(MsgPtr^,Temp,succ(MsgType));
         if Temp <> vInputStr then
         begin
            vInputStr := Temp;
            Display(Norm);
         end;
      end;
   end;
end; {SlaveStringIOOBJ.HandleSignal}

destructor SlaveStringIOOBJ.Done;
{}
begin
   StringIOOBJ.Done;
end; {SlaveStringIOOBJ.Done}
{\\\\\\\\\\\\\\\\\\ MAIN PROGRAM CODE \\\\\\\\\\\\\\\\\\\\\\\\}

procedure InitFields;
{}
begin
   with DefDir do
   begin
      Init(40,5,30);
      SetLabel('Main Turbo Directory');
      SetValue(DefaultDirectory);
      SetRules(EraseDefault);
   end;
   with ProgDir do
   begin
      Init(40,7,30);
      SetLabel('Supplemental Program Directory');
      SetValue(DefaultDirectory);
      SetRules(EraseDefault);
   end;
   with DocDir do
   begin
      Init(40,9,30);
      SetLabel('Documentation Directory');
      SetValue(DefaultDirectory);
      SetRules(EraseDefault);
   end;
   with TPUDir do
   begin
      Init(40,11,30);
      SetLabel('TPU Directory');
      SetValue(DefaultDirectory);
      SetRules(EraseDefault);
   end;
   with HelpDir do
   begin
      Init(40,13,30);
      SetLabel('Help Files Directory');
      SetValue(DefaultDirectory);
      SetRules(EraseDefault);
   end;
   Keys.Init;
end; {InitFields}

begin
   InitFields;
      ClrScr;
   Screen.TitledBox(5,3,75,15,76,79,78,2,' Signal Demo ');
   Screen.WriteCenter(25,white,'Press TAB to switch fields and press ESC or F10 to end');
   with Manager do
   begin
      Init;
      AddItem(Keys);
      AddItem(DefDir);
      AddItem(ProgDir);
      AddItem(DocDir);
      AddItem(TPUDir);
      AddItem(HelpDir);
      Result := Go;
      if Result = Finished then
         {install program..}
      else
         {finish};
   end;
end.