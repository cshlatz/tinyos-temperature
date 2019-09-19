configuration tempApp 
{ 
} 
implementation { 
  
  components temp, LedsC, new TimerMilliC(), new SensirionSht11C() as Sensor;

  SenseC.Boot -> MainC;
  SenseC.Leds -> LedsC;
  SenseC.Timer -> TimerMilliC;
  SenseC.Read -> Sensor.Temperature;
}
