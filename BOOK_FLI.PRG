SET TALK OFF
ON KEY LABEL ESC cancel
CLEAR
iflno='          '
x=3

@1,1 say "BOOK FLIGHT"
@2,1 say "Fl_No  Orig.        Dest.        Depart.   Arriv.   Avai_Seats   Sub_Price"
USE FLIGHTS
GOTO BOTTOM
	FOR i=1 to recno()
		GOTO RECORD i
		@x,1 say flight_no
		@x,8 say origin
		@x,21 say destinatio
		@x,34 say dep_time
		@x,44 say arri_time
		@x,49 say str(av_aseats+av_eseats)		
		@x,67 say sub_price
		x=x+1
	endfor
	
@x,30 say "Flight No:" get iflno
READ
USE FLIGHTS
LOCATE FOR flight_no==iflno
if found()
	do Fill
else
	WAIT WINDOW "Invalid Flight No!" NOWAIT TIMEOUT 3
	do book_flight
endif	


FUNCTION Fill
iclass='  '
CLEAR
@1,1 say "BOOK FLIGHT"
USE FLIGHTS
LOCATE FOR flight_no==iflno
@4,1 say "Flight No: " + flight_no
@5,1 say "Origin: " + origin
@6,1 say "Destination: " + destinatio
@7,1 say "Departure: " + dep_time
@8,1 say "Arrival: " + arri_time
@9,1 say "Sub Price: " 
@9,12 say sub_price
iplid=plane_id
USE PLANES
locate for plane_id=iplid
@10,1 say "Amenities:" + amenities
iaid=airline_id
USE AIRLINES
LOCATE FOR airline_id=iaid
@3,1 say "Airlines: " + air_name
USE FLIGHTS
LOCATE FOR flight_no==iflno
@4,35 say "Seats Left:"
@5,35 say "Price:"
@3,50 say "CLASS A"
@3,65 say "ECO_CLASS"
@4,50 say AV_Aseats
@4,65 say AV_Eseats
USE Seat_price
goto record 1
@5,47 say price
goto record 2
@5,62 say price
@7,35 say "[1] Class A   [2] Economy Class"
@8,35 say "Class:" get iclass
READ
USE seat_price
do case
	case iclass='1' 
		goto record 1
		iseat=seat_class
		icprice=price
	case iclass='2'
		goto record 2
		iseat=seat_class
		icprice=price
	otherwise	
		WAIT WINDOW "Invalid Class!" NOWAIT TIMEOUT 3
		do fill
	endcase
USE FLIGHTS
LOCATE FOR flight_no=iflno
@10,35 say "TOTAL:"
itot=sub_price+icprice
@10,42 say sub_price+icprice
READ
do fill1

FUNCTION fill1
ipid=0
ipname='                    '
ipbdate=date()
ipadd='                    '
ippassport='          '
@13,1 say "Passengers Info"
@14,1 say "Name: " get ipname
@15,1 say "Birthday: " get ipbdate
@16,1 say "Address: " get ipadd
@17,1 say "Passport No.: " get ippassport
READ
@19,1 say "Press any key to book ticket..."
READ
CLEAR
USE FLIGHTS
LOCATE FOR flight_no=iflno
idest=alltrim(destinatio)
idest=alltrim(right(idest,3))
h=alltrim(str(int((val(sys(2))/60)/60)))
m=alltrim(str(int((val(sys(2))/60)%60)))
itkt='hat'+alltrim(iflno)+idest+alltrim(str(month(date())))+alltrim(str(day(date())))+h+m
itkt=alltrim(itkt)

@2,1 say "PLANE TICKET"
@3,1 say "Plane Ticket No:"
@3,18 say itkt
@4,1 say "Origin: " + origin
@5,1 say "Destination: " + destinatio
@6,1 say "Date: " + dtoc(date()) +"   " + time()
do update
READ
do HAT

FUNCTION update
USE Passengers
LOCATE for pasport_no=ippassport
if found()
	ipid=pass_id
else
	LOCATE for pass_id=1
	if found()
		goto bottom
		ipid=pass_id+1
	else
		ipid=1
	endif
	USE Passengers
	APPEND BLANK
	locate for empty(pass_id)
	REPLACE pass_id with ipid, pass_name with ipname, birth_date with ipbdate, address with ipadd, pasport_no with ippassport
endif
USE trans_list
locate for trans_id=1
if found()
	goto bottom
	itid=trans_id+1
else
	itid=1
endif
USE trans_list
APPEND BLANK
locate for empty(trans_id)
REPLACE trans_id with itid, pass_id with ipid, pl_tckt_no with itkt, flight_no with iflno, trans_date with date(), seat_class with iseat, tot_price with itot
USE Flights
LOCATE for flight_no=iflno
do case
	case iclass='1'
		replace AV_ASeats with AV_ASeats-1
	case iclass='2'
		replace AV_ESeats with AV_ESeats-1
endcase

