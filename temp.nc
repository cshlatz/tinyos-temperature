#include <Timer.h>
#include "temp.h"

module temp {
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Boot;
  uses interface Leds;
  uses interface Packet;
  uses interface Read<uint16_t>;
  uses interface Receive;
  uses interface SplitControl as AMControl;
  uses interface Timer<TMilli> as Timer0;
}

implementation {
  // Does something stupid, don't know what
  uint16_t counter;
  // Our packet
  message_t pkt;
  // Is the sensor busy?
  bool busy = FALSE;

  event void Boot.booted() {
    call AMControl.start();
  }

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void AMControl.startDone(error_t err) {
    // We're good to do
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    } else { // Try again
      call AMControl.start();
    }
  }

  // Implement but not gonna do anything with this
  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    counter++;
    // Read temperature data
    call Read.read();
    // Send temperature data
    if (!busy) {
      TempMsg* btrpkt = (TempMsg*)(call Packet.getPayload(&pkt, sizeof(TempMsg)));
      if (btrpkt == NULL) {
	      return;
      }
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, 
          &pkt, sizeof(TempMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void Read.readDone(error_t result, uint16_t data) {
    if (result == SUCCESS){
      if (data & 0x0004)
        call Leds.led2On();
      else
        call Leds.led2Off();
      if (data & 0x0002)
        call Leds.led1On();
      else
        call Leds.led1Off();
      if (data & 0x0001)
        call Leds.led0On();
      else
        call Leds.led0Off();
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(TempMsg)) {
      TempMsg* btrpkt = (TempMsg*)payload;
      setLeds(btrpkt->counter);
    }
    return msg;
  }

}

