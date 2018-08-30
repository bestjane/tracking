-- insert data from your MYT rails instance here:
server = "167.99.205.49"
tracker_id = "1"
token = "XXXXX"

sio.send('at+printdir=1\r\n')

print("WRSC tracing hardware revision 1, script 2.0 \r\nStartup")
-- Unlock sim card when necessary
-- sio.send('at+cpin=1234')
sio.send('at+cgsockcont=1,\"IP\",\"giffgaff.com\"\r\n')
sio.send('at+csockauth=1,1,\"giffgaff\",\"\"\r\n')
sio.send('at+csocksetpn=1\r\n')
sio.send('at+cgps=1\r\n')
print(".")
vmsleep(10000)
sio.send('at+netopen=,,1\r\n')
print(".")



-- initialize variables
mesLats = ''
mesLons = ''
mesdatetimes = ''
messpeeds = ''
mescourses = ''
counter = 1;
date = ''
--os.remove("D:/latitude.txt")
--os.remove("D:/longitude.txt")
--os.remove("D:/datetime.txt")

-- Define script lua envois
-- file=io.open("envois.lua","w")
-- print (file)
-- print("\n \r")
--file:write("printdir(1) \n print(\"Demarrage envois \\r \\n\") \n cmd1=\'at+chttpact=\"haggis.ensta-bretagne.fr\",3000 \\r \' \n file2=io.open(\"donnee.txt\",\"r\") \n str10=file2:read(\"*all\") \n file2:close() \n reponce=os.remove(\"donnee.txt\") \n print(\"\\n \\r\") \n print(\"os.remove=\") \n print(reponce) \n print(\"\\n \\r\") \n print(\"\\n \\r\") \n print(\"\\n\\r\") \n print(\"str10=\") \n print(str10) \n print(\" \\n \\r\") \n print(\"\\n \\r\") \n sio.send(cmd1); \n rtc1=sio.recv(5000) \n vmsleep(5000) \n print(\"rtc1=\") \n print(rtc1, \" \\r \\n\") \n sio.send(str10); \n rtc2=sio.recv(5000) \n vmsleep(5000) \n print(\"rtc2=\") \n print(rtc2, \" \\r \\n\") \n print(\"Fin envois\\r\\n\") \n ")
-- file:close()
-- Fin Define script lua envois
success = 0
errors = 0

while true do
	rst = gps.gpsinfo();
	-- rst="3113.343286,N,12121.234064,E,250311,072809.3,44.1,0.0,0";
	if rst==",,,,,,,," then
		print("Waiting for GPS fix...\r\n")
		vmsleep(1000)
	else
		print("GPS data received: ")
		print(rst)
		print("\r\n")

		-- content of var rst is e.g. 
		-- - 3113.343286,N,12121.234064,E,250311,072809.3,44.1,0.0,0
		-- - 5049.134774,N,00118.424937,W,290818,185118.0,54.5,0,0
		
		-- Data formating: split rst by , into data
		j = 0
		data = {}
		for word in string.gmatch(rst, '([^,]+)') do
			data[j] = word
			j = j+1
		end

		-- latitude: "5049.134774,N" to "50.8189129"
		latitude = tonumber(string.sub(data[0], 1, 2)) + tonumber(string.sub(data[0], 3, 11))/60.0
		-- prepend minus when neccessary
		if data[1] == "S" then
			latitude = -latitude
		end	

		-- longitude: "00118.424937,W" to "-1.3070822833333"
		longitude = tonumber(string.sub(data[2], 1, 3)) + tonumber(string.sub(data[2], 4, 12))/60.0
		-- prepend minus when neccessary
		if data[3] == "W" then
			longitude = -longitude
		end

		-- format the date "290818" from DDMMYY to YYYYMMDD
		datetime = string.gsub(data[4], "(%d%d)(%d%d)(%d%d)", "20%3%2%1")
		-- append time
		datetime = string.concat(datetime, data[5])


		-- concating data and further processing
		if counter == 1 then
			mesLats = latitude
			mesLons = longitude
			mesdatetimes = datetime
			-- 1 knot = 1.852 km/h
			messpeeds = tonumber(data[7])*1.852
			mescourses = data[8]
			if string.len(date) == 0 then
				date = datetime
			end
		end
		if counter ~= 1 then
			mesLats = mesLats .. "_" .. latitude
			mesLons = mesLons .. "_" .. longitude
			mesdatetimes = mesdatetimes .. "_" .. datetime
			messpeeds = messpeeds .. '_' .. tonumber(data[7])*1.852
			mescourses = mescourses .. '_' .. data[8]
		end

		if counter == 5 then -- Connexion opening
			print("Opening connection to server...")
			sio.send('at+chttpact="' .. server .. '",80 \r' )
			rtc1 = sio.recv(5000) 
			print(" opened ")
		end


		if counter == 10 then
			counter=0

			body = '{"latitude":"' .. mesLats .. '","longitude":"' .. mesLons
			body = body .. '","datetime":"' .. mesdatetimes
			body = string.concat(body, '","speed":"' .. messpeeds)
			body = string.concat(body, '","course":"' .. mescourses)
			body = string.concat(body, '","tracker_id":' .. tracker_id)
			body = string.concat(body, string.format(',"token":"%s"', token))

			print(body)
			print("\r\n")

			-- Writing of data in a file
			file = io.open(string.format("D:\\latitude%s.txt", date), "a")
			print("file= ")
			print(file)
			if file ~= nil then -- IF no SD card
				print("Writing data to SD card...")
				mesLats = string.concat(mesLats,"_")
				file:write(mesLats)
				file:close()
				print(".")
				
				file = io.open(string.format("D:\\longitude%s.txt", date), "a")
				mesLons = string.concat(mesLons,"_")
				file:write(mesLons)
				file:close()
				print(".")
				
				file = io.open(string.format("D:\\datetime%s.txt", date), "a")
				mesdatetimes = string.concat(mesdatetimes, "_")
				file:write(mesdatetimes)
				file:close()
				print(".")

				file = io.open(string.format("D:\\speed%s.txt", date), "a")
				messpeeds = string.concat(messpeeds, "_")
				file:write(messpeeds)
				file:close()
				print(".")

				file = io.open(string.format("D:\\course%s.txt", date), "a")
				mescourses = string.concat(mescourses, "_")
				file:write(mescourses)
				file:close()

				print(".")
			else 
				print("WARNING: no SD card available!\r\n")
			end
			print("Done \r\n")
			body = string.concat(body, "}")
			-- Sending of data
			print("Starting data transfer...")
			length = string.len(body)
			print(".")
			header = string.format('POST /coordinates HTTP/1.1\r\nContent-type: application/json\r\nAccept: application/json\r\nContent-length: %d\r\n\r\n', length)
			print(".")

			sio.send(header .. body .. string.char(0x1A));
			--print(body)
			rtc2 = sio.recv(5000) 
			print("\r\nData transfer attempt done, response:\r\n")
			print(rtc2)
			
			
			print("\r\n")
			rlen = string.len(rtc2)
			if rlen > 23 then
				success = success + 1
			else
				errors = errors + 1
			end
			print("\r\nSuccessful transmissions: " .. success .. ", errors: " .. errors)
			print("\r\n")
			print("\r\n")
		end
		counter = counter + 1
		vmsleep(1000)
	end 
end
