#ifndef TEMP_H
#define TEMP_H

enum {
  AM_BLINKTORADIO = 37,
  TIMER_PERIOD_MILLI = 300000 // This is 5 minutes, per the assignment notes
};

typedef nx_struct TempMsg {
  nx_uint16_t nodeid;
  nx_uint16_t temperature;
  nx_uint16_t counter;
  nx_uint32_t timestamp;
} TempMsg;

#endif
