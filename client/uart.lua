
--[[ protocol description:
-- heater hdr		0x88 00 18 00 msg len 31
-- Heating circuit 1	0x88 00 19 00 msg len 33
-- Hot water		0x88 00 34 00 msg len 23
-- Request		0x88 00 07 00 msg len 21
-- heating circuit 2	0x90 00 FF 00 msg len 17
-- date			0x90 00 06 00 msg len 14
-- solar		0xB0 00 FF 00 msg len 21
--]]
crc_table = {
	0x00, 0x02 ,0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12,
	0x14, 0x16, 0x18, 0x1A, 0x1C, 0x1E, 0x20, 0x22, 0x24, 0x26,
	0x28, 0x2A, 0x2C, 0x2E, 0x30, 0x32, 0x34, 0x36, 0x38, 0x3A,
	0x3C, 0x3E, 0x40, 0x42, 0x44, 0x46, 0x48, 0x4A, 0x4C, 0x4E,
	0x50, 0x52, 0x54, 0x56, 0x58, 0x5A, 0x5C, 0x5E, 0x60, 0x62,
	0x64, 0x66, 0x68, 0x6A, 0x6C, 0x6E, 0x70, 0x72, 0x74, 0x76,
	0x78, 0x7A, 0x7C, 0x7E, 0x80, 0x82, 0x84, 0x86, 0x88, 0x8A,
	0x8C, 0x8E, 0x90, 0x92, 0x94, 0x96, 0x98, 0x9A,	0x9C, 0x9E,
	0xA0, 0xA2, 0xA4, 0xA6, 0xA8, 0xAA, 0xAC, 0xAE, 0xB0, 0xB2,
	0xB4, 0xB6, 0xB8, 0xBA, 0xBC, 0xBE, 0xC0, 0xC2, 0xC4, 0xC6,
	0xC8, 0xCA, 0xCC, 0xCE, 0xD0, 0xD2, 0xD4, 0xD6, 0xD8, 0xDA,
	0xDC, 0xDE, 0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE,
	0xF0, 0xF2, 0xF4, 0xF6, 0xF8, 0xFA, 0xFC, 0xFE, 0x19, 0x1B,
	0x1D, 0x1F, 0x11, 0x13, 0x15, 0x17, 0x09, 0x0B, 0x0D, 0x0F,
	0x01, 0x03, 0x05, 0x07, 0x39, 0x3B, 0x3D, 0x3F, 0x31, 0x33,
	0x35, 0x37, 0x29, 0x2B, 0x2D, 0x2F, 0x21, 0x23, 0x25, 0x27,
	0x59, 0x5B, 0x5D, 0x5F, 0x51, 0x53, 0x55, 0x57, 0x49, 0x4B,
	0x4D, 0x4F, 0x41, 0x43, 0x45, 0x47, 0x79, 0x7B, 0x7D, 0x7F,
	0x71, 0x73, 0x75, 0x77, 0x69, 0x6B, 0x6D, 0x6F, 0x61, 0x63,
	0x65, 0x67, 0x99, 0x9B, 0x9D, 0x9F, 0x91, 0x93, 0x95, 0x97,
	0x89, 0x8B, 0x8D, 0x8F, 0x81, 0x83, 0x85, 0x87, 0xB9, 0xBB,
	0xBD, 0xBF, 0xB1, 0xB3, 0xB5, 0xB7, 0xA9, 0xAB, 0xAD, 0xAF,
	0xA1, 0xA3, 0xA5, 0xA7, 0xD9, 0xDB, 0xDD, 0xDF, 0xD1, 0xD3,
	0xD5, 0xD7, 0xC9, 0xCB, 0xCD, 0xCF, 0xC1, 0xC3, 0xC5, 0xC7,
	0xF9, 0xFB, 0xFD, 0xFF, 0xF1, 0xF3, 0xF5, 0xF7, 0xE9, 0xEB,
	0xED, 0xEF, 0xE1, 0xE3, 0xE5, 0xE7
}

msg = {}

local function dumpmsg()
	for i = 1, #msg do
		io.write(string.format("%02x ", msg[i]))
	end
	print("")
end

local function crc_test(len)
	local crc = 0
	for i = 1, len do
		--print(string.format("crc: %2d| buffer[%2d] = %02x ^ crc_table[%3d] = %02x =",
		--     crc, i, msg[i], crc+1, crc_table[crc+1]))
		crc = crc_table[crc+1]
		crc = crc ~ msg[i]
		--print(string.format("%x", crc))
	end

	return crc == msg[len+1] and true or false
end

local function heater_msg(crc_len)
	print("heater msg:")
	-- dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	--[[
	1-4 88 00 18 00	- HDR
	  5 00		- requested temp
	6-7 01 14	- current temp
	  8 4c		- operating mode
	  9 00		- power
	 10 00		- flame
	 11 26		-
	 12 20		- pump
	 13 c0		- ???
	01 5b		- mixer temp
	80 00		- heater type
	80 00		- countercurrent
	ff ff ff 00 00 00 00 00 00 00 24 00
	]]

	local requested_t	= msg[5]
	local current_t		= (msg[6] * 256 + msg[7])/10
	-- neaisku kuris, reiktu debuginti
	--local operating_mode	= msg[8] & 0x50 == 0x50 and "heating" or "hot water"
	local operating_mode	= msg[10] & 0x03
	local power		= msg[9]
	local mixer_t		= (msg[14]*256+ msg[15])/10
	local countercurrent_t	= (msg[18]*256+ msg[19])/10
	local flame_on		= (msg[10] & 0x08) ~= 0
	local burner		= (msg[12] & 0x1) ~= 0
	local heat_pump		= (msg[12] & 0x20) ~= 0
	local primary_pump	= (msg[12] & 0x40) ~= 0
	local circulation_pump	= (msg[12] & 0x80) ~= 0


	print(string.format("requested temp: %d", requested_t))
	print(string.format("current temp:   %f", current_t))
	print(string.format("power:          %d%%", power))
	print(string.format("operating mode: %d", operating_mode))
	print(string.format("mixer temp:     %f", mixer_t))
	print(string.format("countercurrent: %f", countercurrent_t))
	print(string.format("flame:          %s", tostring(flame_on)))
	print(string.format("burner:         %s", tostring(burner)))
	print(string.format("heat pump:      %s", tostring(heat_pump)))
	print(string.format("primary pump    %s", tostring(primary_pump)))
	print(string.format("circulation pump:%s", tostring(circulation_pump)))


	msg = {}
end

local function heating_circuit1_msg(crc_len)
	print("heating circuit 1 msg received")
	--dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	--88 00 19 00
	--00 3b -outside temp
	--80 00 80 00 ff ff 00 64 03 54 0f 02 28 88 00 00 00 01 dc 32 03 1f ab 80 00 5d 00

	local outside_t = 0
	if msg[5] ~= 0xff then
		outside_t = (msg[5]*256+msg[6])/10
	else
		outside_t = (255-msg[6])/-10
	end
	local working_time_in_min  = msg[18]*65536+ msg[19]*256+ msg[20]
	local heating_time_in_min  = msg[24]*65536+ msg[25]*256+ msg[26]
	local burner_counter       = msg[15]*65536+ msg[16]*256+ msg[17]



	print(string.format("outside temp: %f", outside_t))
	print(string.format("working time: %d min", working_time_in_min))
	print(string.format("heating time: %d min", heating_time_in_min))
	print(string.format("burner counter: %d min", burner_counter))

	msg = {}
end

local function hot_water_msg(crc_len)
	print("hot water 1 msg received")
	dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	local required_t = msg[5]
	local current_t	= (msg[6]*256 + msg[7])/10
	local storage_t	= (msg[8]*256 + msg[9])/10
	local uptime	= (msg[15]*65536 + msg[16]*256 + msg[17])

	print(string.format("required temp: %d", required_t))
	print(string.format("current  temp: %f", current_t))
	print(string.format("strorage  temp: %f", storage_t))
	print(string.format("uptime  : %d", uptime))

	msg = {}
end

local function request_msg(crc_len)
	print("request msg received")
	dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end
	msg = {}
end

local function heating_circuit2_msg(crc_len)
	print("heating circuit 2 msg received")
	dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	--90 00 ff 00
	--00 6f
	--03 - operating mode
	--01 00 d2 00 ef f3 34 00 4c 00
	local operating_mode = msg[7]
	print(string.format("operating mode		%d", operating_mode))
	if msg[6] == 0x6f then
		local required  = (msg[9]*256 + msg[10])/10
		local curent    = (msg[11]*256 + msg[12])/10
		local duty      = (msg[13]*256 + msg[14])/10

		print(string.format("requested		%f", required))
		print(string.format("current		%f", curent))
		print(string.format("duty		%f", duty))
	end



	msg = {}
end

local function date_msg(crc_len)
	--print("date msg received")
	--dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	local year	= msg[5] + 2000
	local mounth	= msg[6]
	local day	= msg[7]
	local hour	= msg[8]
	local minute	= msg[9]
	local second	= msg[10]
	local dayofweek = msg[11]

	print(string.format("date: %d-%02d-%02d %02d:%02d:%02d (day of week: %d)",
		     year, mounth, hour, day, minute, second, dayofweek))

	msg = {}
end

local function solar_msg(crc_len)
	print("solar msg received")
	dumpmsg()
	if not crc_test(crc_len) then
		print("CRC - FAIL")
	end

	msg = {}
end

hdr = {0x88, 0x90, 0xb0}
hdr[0x88] = {0x0}
hdr[0x88][0x0] = {0x18, 0x19, 0x34, 0x07}
hdr[0x88][0x0][0x18] = {0x0}
hdr[0x88][0x0][0x19] = {0x0}
hdr[0x88][0x0][0x34] = {0x0}
hdr[0x88][0x0][0x07] = {0x0}
hdr[0x88][0x0][0x18][0x0] = {len = 31, func = heater_msg}
hdr[0x88][0x0][0x19][0x0] = {len = 33, func = heating_circuit1_msg}
hdr[0x88][0x0][0x34][0x0] = {len = 23, func = hot_water_msg}
hdr[0x88][0x0][0x07][0x0] = {len = 21, func = request_msg}

hdr[0x90] = {0x0}
hdr[0x90][0x0] = {0xff, 0x06}
hdr[0x90][0x0][0xff] = {0x0}
hdr[0x90][0x0][0x06] = {0x0}
hdr[0x90][0x0][0xff][0x0] = {len = 17, func = heating_circuit2_msg}
hdr[0x90][0x0][0x06][0x0] = {len = 14, func = date_msg}

hdr[0xb0] = {0x0}
hdr[0xb0][0x0] = {0xff}
hdr[0xb0][0x0][0xff] = {0x00}
hdr[0xb0][0x0][0xff][0x0] = {len = 21, func = solar_msg}


local function test_table(t, b)
	if type(t) == "table"  then
		table.insert(msg, b)
	else
		msg = {}
	end
end

function get_byte(data)
	byte = string.byte(data)

	-- print(string.format("gautas %02x #msg %d", byte, #msg))
	-- is it first byte
	if #msg == 0 then
		test_table(hdr[byte], byte)
		return
	end

	if #msg == 1 then
		test_table(hdr[msg[1]][byte], byte)
		return
	end

	if #msg == 2 then
		test_table(hdr[msg[1]][msg[2]][byte], byte)
		return
	end

	if #msg == 3 then
		test_table(hdr[msg[1]][msg[2]][msg[3]][byte], byte)
		return
	end

	table.insert(msg, byte)

	if #msg == hdr[msg[1]][msg[2]][msg[3]][msg[4]].len then
		hdr[msg[1]][msg[2]][msg[3]][msg[4]].func(hdr[msg[1]][msg[2]][msg[3]][msg[4]].len - 2)
	end
end


f = io.open("ht3.bin", "rb")
while true do
	local byte = f:read(1)
	if not byte then break end
	get_byte(byte)
end

--uart.on("data", 1, get_byte, 0)
