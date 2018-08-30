--Token to test the new website version
print("Script startup\r\n")
vmsleep(5000)
sio.send('at+cpin=1234\r\n')
vmsleep(15000)
sio.send('at+cgps=1\r\n')
vmsleep(10000)
sio.send('at+netopen=,,1\r\n')
vmsleep(10000)
sio.send('at+printdir=1\r\n')

-- The version I got from Sylvain had a token here. I've removed it from the
-- public version, but we can find it if needed. -TK
token = ""


tracker_id = '"6"'
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

while true do
	rst = gps.gpsinfo();
	-- rst="3113.343286,N,12121.234064,E,250311,072809.3,44.1,0.0,0";
	if rst==",,,,,,,," then
		print("No GPS fix\r\n")
		vmsleep(1000)
	else
		print("GPS data received:\r\n ")
		print(rst .. "\r\n")

		-- Data formating
		j=0
		data={}
		for word in string.gmatch(rst, '([^,]+)') do
			data[j] = word
			j = j + 1
		end
		x={}
		k=1
		while k <= string.len(data[0]) do
			x[k] = string.sub(data[0],k,k)
			k = k+1
		end
		latitude = tonumber(string.sub(x, 1, 2)) + tonumber(string.sub(x, 3, 11))/60*1.0
		data[0] = tostring(latitude)
		y = {}
		l = 1
		while l <= string.len(data[2]) do
			y[l] = string.sub(data[2], l, l)
			l = l + 1
		end
		longitude1=string.concat(y[1],y[2])
		longitude1=tonumber(string.concat(longitude1,y[3]))*1.0
		longitude2=string.concat(y[4],y[5])
		longitude2=string.concat(longitude2,y[6])
		longitude2=string.concat(longitude2,y[7])
		longitude2=string.concat(longitude2,y[8])
		longitude2=string.concat(longitude2,y[9])
		longitude2=string.concat(longitude2,y[10])
		longitude2=string.concat(longitude2,y[11])
		longitude2=string.concat(longitude2,y[12])
		longitude2=tonumber(longitude2)*1.0
		longitude2=longitude2/60*1.0
		longitude3=longitude1+longitude2
		data[2]=tostring(longitude3)

		if data[1] == "S" then
			data[0] = string.concat('-', data[0])
		end
		if data[3] == "W" then
			data[2] = string.concat('-', data[2])
		end

		-- format the date from DD-MM-YY to YYYY-MM-DD
		v1 = data[4]
		v2 = string.gsub(v1, "(%d%d)", "%1-")
		j = 0
		v3={}
		for word in string.gmatch(v2, '([^-]+)') do
			v3[j] = word
			j = j + 1
		end

		raiponce1=string.concat("20", v3[2])
		raiponce2=string.concat(raiponce1, v3[1])
		no=string.concat(raiponce2, v3[0])
		-- append time
		raiponce=string.concat(no, data[5])


		-- concating data and further processing
		if counter == 1 then
			mesLats = data[0]
			mesLons = data[2]
			mesdatetimes = raiponce
			-- 1 knot = 1.852 km/h
			messpeeds = tonumber(data[7])*1.852
			mescourses = data[8]
			if string.len(date) == 0 then
				date = mesdatetimes
			end
		end
		if counter ~= 1 then
			mesLats = string.concat(mesLats, "_")
			mesLats = string.concat(mesLats, data[0])
			mesLons = string.concat(mesLons, "_")
			mesLons = string.concat(mesLons, data[2])
			mesdatetimes = string.concat(mesdatetimes, "_")
			mesdatetimes = string.concat(mesdatetimes, raiponce)
			messpeeds = string.concat(messpeeds, '_')
			messpeeds = string.concat(messpeeds, tonumber(data[7])*1.852)
			mescourses = string.concat(mescourses, '_')
			mescourses = string.concat(mescourses, data[8])
		end

		if counter == 5 then -- Connexion opening
			print(" Open connection \r\n")
			cmd1 = 'at+chttpact="167.99.205.49",80 \r ' 
			sio.send(cmd1); 
			rtc1 = sio.recv(5000) 
			print(" Connection opened \r\n")
		end
		if counter == 10	then
			counter=0

			body = '{"latitude":"'
			body = string.concat(body, mesLats)

			body = string.concat(body, '","longitude":"')
			body = string.concat(body, mesLons)

			body = string.concat(body, '","datetime":"')
			body = string.concat(body, mesdatetimes)

			body = string.concat(body, '","speed":"')
			body = string.concat(body, messpeeds)

			body = string.concat(body, '","course":"')
			body = string.concat(body, mescourses)
			
			body = string.concat(body, '","tracker_id":' .. tracker_id)

			str9 = string.format(',"token":"%s"', token)
			body = string.concat(body, str9)

			body = string.concat(body, "}")
			length = string.len(body)

			header = string.format('POST /coordinates HTTP/1.1\r\nContent-type: application/json\r\nAccept: application/json\r\nContent-length: %d\r\n\r\n', length)
		

			-- Writing of data in a file
			file = io.open(string.format("D:\\latitude%s.txt", date), "a")
			print("file= ")
			print(file)
			if file ~= nil then -- IF no SD card
				mesLats = string.concat(mesLats,"_")
				file:write(mesLats)
				file:close()
				
				file = io.open(string.format("D:\\longitude%s.txt", date), "a")
				mesLons = string.concat(mesLons,"_")
				file:write(mesLons)
				file:close()
				
				file = io.open(string.format("D:\\datetime%s.txt", date), "a")
				mesdatetimes = string.concat(mesdatetimes, "_")
				file:write(mesdatetimes)
				file:close()

				file = io.open(string.format("D:\\speed%s.txt", date), "a")
				messpeeds = string.concat(messpeeds, "_")
				file:write(messpeeds)
				file:close()

				file = io.open(string.format("D:\\course%s.txt", date), "a")
				mescourses = string.concat(mescourses, "_")
				file:write(mescourses)
				file:close()

			end
			-- Sending of data
			print("Starting data transfer... \r\n")
			sio.send(header .. body .. string.char(0x1A));
			--print(body)
			rtc2 = sio.recv(5000) 
			print(" Data transfer (possibly) complete. \r\n")
			print(rtc2)
			
			
		end
		counter = counter + 1
		vmsleep(1000)
	end 
end
