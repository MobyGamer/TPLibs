Unit OV2Init;
INTERFACE
IMPLEMENTATION
Uses Overlay;
Const
   OvrMaxSize = 75000;
begin
   OvrInit('demov2.OVR');
   OvrInitEMS;
   OvrSetBuf(OvrMaxSize);
end.
