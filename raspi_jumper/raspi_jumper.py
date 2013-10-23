#!/usr/bin/python
import sys
import signal

import spidev
import smbus
from time import sleep
import RPi.GPIO as GPIO

pin = 13  # GPIO27

def sigint_handler(signo, frame):
	GPIO.output(pin, False)
	GPIO.cleanup()
	sys.exit(0)

class MCP3208:
	def __init__(self, spi_channel=0):
		self.spi_channel = spi_channel
		self.conn = spidev.SpiDev(0, spi_channel)
		self.conn.max_speed_hz = 1000000 # 1MHz
		#self.conn.max_speed_hz = 4096 # 1MHz

	def __del__( self ):
		self.close

	def close(self):
		if self.conn != None:
			self.conn.close
			self.conn = None
	
	def bitstring(self, n):
		s = bin(n)[2:]
		return '0'*(8-len(s)) + s

	def read(self, adc_channel=0):
		# build command
		cmd  = 128 # start bit
		cmd +=  64 # single end / diff
		if adc_channel % 2 == 1:
			cmd += 8 
		if (adc_channel/2) % 2 == 1:
			cmd += 16 
		if (adc_channel/4) % 2 == 1:
			cmd += 32 

		# send & receive data
		reply_bytes = self.conn.xfer2([cmd, 0, 0, 0])

		#
		reply_bitstring = ''.join(self.bitstring(n) for n in reply_bytes)
		# print reply_bitstring

		# see also... http://akizukidenshi.com/download/MCP3204.pdf (page.20)
		reply = reply_bitstring[5:19]
		return int(reply, 2)


class AkiI2CLCD:
	def __init__(self, i2c_bus, addr=0x3e):
		self.i2c_bus = i2c_bus
		self.addr    = addr
		self._init()

	def _init(self):
		self.enable_is1()
		self.send_command(0x14) # (IS1) internal osc freq
		self.send_command(0x56) # (IS1) power, icon control, contrast set... 
		self.send_command(0x6c) # (IS1) follower control
		self.send_command(0x06) # entry mode
		self.send_command(0x0c) # display on(db2), cursor off(db1), cursor position off(db0)
		#self.send_command(0x0f) # display on(db2), cursor on(db1), cursor position on(db0)

	def _send(self, rsrw, data):
		self.i2c_bus.write_byte_data(self.addr, rsrw, data)

	def send_command(self, data):
		self._send(0x00, data)

	def enable_is0(self):
		self.send_command(0x38) # function set (8bit, 2lines, enable instraction set 0)

	def enable_is1(self):
		self.send_command(0x39) # function set (8bit, 2lines, enable instraction set 1)

	def write_data_to_ram(self, data):
		self._send(0x40, data) # write data to ram

	def contrast(self, val):
		if val < 0x00: val = 0
		if val > 0x0f: val = 0x0f
		self.enable_is1()
		self.send_command(0x70 + val) # contrast set

	def clear(self):
		self.send_command(0x01) # clear display
		self.send_command(0x02) # return to home

	def move(self, x, y):
		if x < 0: x = 0  
		if y < 0: y = 0  
		addr = x + y * 0x40
		self.send_command(0x80 + addr) # set ddram address

	def putc(self, val):
		self.write_data_to_ram(val)

	def puts(self, str):
		for c in str:
			self.putc(ord(c))


if __name__ == '__main__':
	signal.signal(signal.SIGINT, sigint_handler)
	GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BOARD)
	GPIO.setup(pin, GPIO.OUT) 

	spi = MCP3208(0)

	lcd = AkiI2CLCD(smbus.SMBus(1))
	lcd.clear()
	lcd.contrast(2)

	count = 0
	a0 = 0
	a2 = 0
	a3 = 0
	
	while True:
		count += 1
		a0 += spi.read(0)
		a2 += spi.read(2)
		a3 += spi.read(3)

		if count == 10:
			# average
			a0 /= 10
			a2 /= 10
			a3 /= 10

			# detect
			if a0 > a2:
				GPIO.output(pin, True)
			else:
				GPIO.output(pin, False)

			# debug print
			print "ch0=%04d, ch1=n/a, ch2=%04d, ch3=%04d" % (a0, a2, a3)
			lcd.move(0, 0)
			lcd.puts("val=%4d" % a0)
			lcd.move(0, 1)
			lcd.puts("%4d" % a2)
			lcd.move(4, 1)
			lcd.puts("%4d" % a3)

			# clear data
			count = 0
			a0 = 0
			a1 = 0
			a2 = 0
			a3 = 0


