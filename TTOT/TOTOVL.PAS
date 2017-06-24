{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totOVL;

{
 Development History:

}

INTERFACE
IMPLEMENTATION
Uses Overlay;
Const
   OvrMaxSize = 75000;
begin
   OvrInit('program.OVR'); {Change overlay file name as appropriate}
   OvrInitEMS;
   OvrSetBuf(OvrMaxSize);
end.