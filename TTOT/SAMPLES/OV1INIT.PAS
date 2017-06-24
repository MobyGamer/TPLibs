Unit OV1Init;
INTERFACE
IMPLEMENTATION
Uses Overlay;
Const
   OvrMaxSize = 75000;
begin
   OvrInit('demov1.OVR');
   OvrInitEMS;
   OvrSetBuf(OvrMaxSize);
end.
