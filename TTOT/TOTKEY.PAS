{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totKEY;
{$I TOTFLAGS.INC}

{
  Notes:

}
INTERFACE

CONST

   kA=097;kB=098;kC=099;kD=100;kE=101;kF=102;kG=103;
   kH=104;kI=105;kJ=106;kK=107;kL=108;kM=109;kN=110;
   kO=111;kP=112;kQ=113;kR=114;kS=115;kT=116;kU=117;
   kV=118;kW=119;kX=120;kY=121;kZ=122;                    
    
   kSftA=065;kSftB=066;kSftC=067;kSftD=068;kSftE=069;kSftF=070;kSftG=071;
   kSftH=072;kSftI=073;kSftJ=074;kSftK=075;kSftL=076;kSftM=077;kSftN=078;
   kSftO=079;kSftP=080;kSftQ=081;kSftR=082;kSftS=083;kSftT=084;kSftU=085;
   kSftV=086;kSftW=087;kSftX=088;kSftY=089;kSftZ=090;                    
    
   kAltA=286;kAltB=304;kAltC=302;kAltD=288;kAltE=274;kAltF=289;kAltG=290;
   kAltH=291;kAltI=279;kAltJ=292;kAltK=293;kAltL=294;kAltM=306;kAltN=305;
   kAltO=280;kAltP=281;kAltQ=272;kAltR=275;kAltS=287;kAltT=276;kAltU=278;
   kAltV=303;kAltW=273;kAltX=301;kAltY=277;kAltZ=300;                    
        
   kCtlA=001;kCtlB=002;kCtlC=003;kCtlD=004;kCtlE=005;kCtlF=006;kCtlG=007;
   kCtlH=008;kCtlI=009;kCtlJ=010;kCtlK=011;kCtlL=012;kCtlM=013;kCtlN=014;
   kCtlO=015;kCtlP=016;kCtlQ=017;kCtlR=018;kCtlS=019;kCtlT=020;kCtlU=021;
   kCtlV=022;kCtlW=023;kCtlX=024;kCtlY=025;kCtlZ=026;                    
        
   k1=49;k2=50;k3=51;k4=52;k5=53;k6=54;k7=55;k8=56;k9=57;k0=48;
   kMinus=45;kEquals=61;

   kSft1=33;kSft2=64;kSft3=35;kSft4=36;kSft5=37;kSft6=94;kSft7=38;kSft8=42;
   kSft9=40;kSft0=41;kSftMinus=95;kSftEquals=43;

   kAlt1=376;kAlt2=377;kAlt3=378;kAlt4=379;kAlt5=380;kAlt6=381;kAlt7=382;
   kAlt8=383;kAlt9=384;kAlt0=385;kAltMinus=386;kAltEquals=387;

   kCtl2=259;kCtl6=30;kCtlMinus=31;

   kF1=315;kF2=316;kF3=317;kF4=318;kF5=319;kF6=320;
   kF7=321;kF8=322;kF9=323;kF10=324;kF11=389;kF12=390;

   kSftF1=340;kSftF2=341;kSftF3=342;kSftF4=343;kSftF5=344;kSftF6=345;
   kSftF7=346;kSftF8=347;kSftF9=348;kSftF10=349;kSftF11=391;kSftF12=392;

   kAltF1=360;kAltF2=361;kAltF3=362;kAltF4=363;kAltF5=364;kAltF6=365;
   kAltF7=366;kAltF8=367;kAltF9=368;kAltF10=369;kAltF11=395;kAltF12=396;

   kCtlF1=350;kCtlF2=351;kCtlF3=352;kCtlF4=353;kCtlF5=354;kCtlF6=355;
   kCtlF7=356;kCtlF8=357;kCtlF9=358;kCtlF10=359;kCtlF11=393;kCtlF12=394;

   kBkSp=8;kUp=328;kDown=336;kLeft=331;kRight=333;kEnd=335;kHome=327;
   kPgUp=329;kPgDn=337;kIns=338;kDel=339;kTab=9;kEsc=27;kEnter=13;

   kSftBkSp=8;kSftUp=428;kSftDown=436;kSftLeft=431;kSftRight=433;
   kSftEnd=435;kSftHome=427;kSftPgUp=429;kSftPgDn=437;kSftIns=261;
   kSftDel=263;kSftTab=271;kSftEsc=27;kSftEnter=13;

   kAltBkSp=270;kAltUp=408;kAltDown=416;kAltLeft=411;kAltRight=413;
   kAltEnd=415;kAltHome=407;kAltPgUp=409;kAltPgDn=417;kAltIns=418;
   kAltDel=419;kAltTab=421;kAltEsc=257;kAltEnter=284;

   kCtlBkSp=127;kCtlUp=397;kCtlDown=401;kCtlLeft=371;kCtlRight=372;
   kCtlEnd=373;kCtlHome=375;kCtlPgUp=388;kCtlPgDn=374;kCtlIns=260;
   kCtlDel=262;kCtlTab=404;kCtlEsc=27;kCtlEnter=10;

   mLeft=513;mRight=514;mMiddle=515;mLeftRight=516;mLeftMiddle=517;
   mMiddleRight=518;mAll=519;mLeftDouble=523;mRightDouble=524;
   mMiddleDouble=525;

   mDragUp=584;mDragDown=592;mDragLeft=589;mDragRight=587;

   wClose=600;wMove=601;wStretch=602;wScrollUp=610;wScrollDown=611;
   wScrollLeft=612;wScrollRight=613;wVertElevator=614;wHorizElevator=615;

procedure KeyInit;


IMPLEMENTATION

procedure KeyInit;
{}
begin end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   KeyInit;
{$ENDIF}
end.
