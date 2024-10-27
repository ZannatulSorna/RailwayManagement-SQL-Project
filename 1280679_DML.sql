--1280679
--PROJECT:RailwayDB
--RailwayDB_DML

use RailwayDB
go

insert into Train_t(TrainID,TrainName,FromStation,ToStation) values
(101,'Chilhati express(805)','Dhaka','Chilhati'),
(102,'Nilsagar express(765)','Dhaka', 'Chilhati'),
(103,'Nilsagar express(766)','Chilhati','Dhaka'),
(104,'Ekota express(705)','Dhaka','B Sirajul Islam'),
(105,'Ekota express(706)','B Sirajul Islam','Dhaka'),
(106,'Simanto express(748)','Chilhati','Khulna')
go

insert into Journey_t(JourneyID,JourneyName) values
(201,'9:30 am Dhaka to Nilphamari'),
(202,'11:00 am Dhaka to Natore'),
(203,'12:00 am Dhaka to Natore'),
(204,'3:00 pm Natore to Khulna'),
(205,'10:00 am Dhaka to Natore')
go

insert into Station_t(StationID,StationName) values
(301,'Dhaka'),
(302,'Nilphamary'),
(303,'Natore'),
(304,'Khulna')
go

insert into Class_t(ClassID,ClassName) values
(401,'AC_S'),
(402,'Snigdha'),
(403,'C_Chair'),
(404,'S_Chair'),
(405,'Shovon')
go

insert into Ticket_t(TicketID,TrainID,JourneyID,ClassID,TicketPrice,Vat,ServiceCharge) values
(501,101,201,401,1076,0,0),
(502,102,202,402,610,0,0),
(503,104,203,403,320,0,0),
(504,106,204,404,290,0,0),
(505,103,205,405,300,0,0)
go

insert into BookingStatus_t(StatusID,BookingStatus) values
(601,'Booked'),
(602,'Available')
go

insert into Passenger_t(PassengerID,PassangerFname,PassangerLname,Phn,IdentificationType,IdentificationNo) values
(701,'Shefine','Ahmed','01712345678','NID','11223344'),
(702,'Harry','Potter','01712345679','NID','11223355'),
(703,'Rayan','Gosling','01712345671','NID','11223366'),
(704,'Joye','Tribbiany','01712345672','NID','11223377'),
(705,'Ross','Galler','01712345673','NID','11223388')
go

insert into Booking_t
(BookingID,PassengerID,TicketID,StatusID,PNR,StartingStation,EndingStation,BookingDate,TotalSeatNo,AmountPaid,JourneyDate)
values
(1,701,501,601,'12345AD1BD7',301,302,'03-01-2024',1,(1076+0+0)*1,'04-01-2024'),
(2,702,502,601,'12345AD2BD1',301,303,'04-01-2024',1,(610+0+0)*1,'05-01-2024'),
(3,703,503,601,'12345AD3BD2',301,303,'04-01-2024',2,(320+0+0)*2,'06-01-2024'),
(4,704,504,601,'12345AD4BD3',303,304,'05-01-2024',1,(290+0+0)*1,'06-01-2024'),
(5,705,505,601,'12345AD5BD4',303,301,'05-01-2024',1,(300+0+0)*1,'07-01-2024')
GO

use RailwayDB
go

---------Those passengers who have booked more than one seat and in a particular date.

select PassangerFname,TotalSeatNo,BookingDate
from Passenger_t p join Booking_t b
on p.PassengerID=b.PassengerID
where TotalSeatNo>1 and BookingDate='2024-04-01'

-----Passengers whoses class are all except AC_S and Snigdha and journey date are later than 2024-05-01.

select PassangerFname,ClassName,TotalSeatNo,JourneyDate
from Passenger_t join Booking_t
on Passenger_t.PassengerID=Booking_t.PassengerID join Ticket_t
on Ticket_t.TicketID=Booking_t.TicketID join Class_t
on Class_t.ClassID=Ticket_t.ClassID
where ClassName not in ('AC_S','Snigdha')
and JourneyDate>'2024-05-01'

-------Passengers who travel from 2024-04-01 to 2024-06-01.

select PassangerFname,ClassName,TotalSeatNo,JourneyDate
from Passenger_t join Booking_t
on Passenger_t.PassengerID=Booking_t.PassengerID join Ticket_t
on Ticket_t.TicketID=Booking_t.TicketID join Class_t
on Class_t.ClassID=Ticket_t.ClassID
where JourneyDate between '2024-04-01' and '2024-06-01'

---Stations that starts with Nil.

select * from Station_t
where StationName like 'Nil%'

---Passengers whose name has one of the following characters:a,e,i,t

select * from Passenger_t
where PassangerLname like '[aeit]%'

--Passengers whose name starts with R ana next letter is one of the A through J.

select * from Passenger_t
where PassangerFname like 'R[A-J]%'

---Passengers whose name starts with R ana next letter is not one of the A through J.

select * from Passenger_t
where PassangerFname like 'R[^A-J]%'

----Use of TOP Clause.

select top 2 BookingID,PassengerID,AmountPaid,JourneyDate
from Booking_t
order by AmountPaid desc

---OFFSET and FETCH Clause.

select  BookingID,PassengerID,AmountPaid,JourneyDate
from Booking_t
order by AmountPaid
offset 2 rows
fetch next 2 rows only

---Group Query.

select JourneyDate,sum(AmountPaid) as SumAmount
from Booking_t join Passenger_t
on Booking_t.PassengerID=Passenger_t.PassengerID
group by JourneyDate
having sum(AmountPaid)>1000

---ROLLUP operator(A summary query that includes a summary row for each GROUPING LEVEL).

select BookingDate,TotalSeatNo,count(*) as AllCount
from Booking_t
group by rollup(BookingDate,TotalSeatNo)
order by BookingDate desc,TotalSeatNo desc

---CUBE operator(A summary query that includes a summary row for each set of group).

select BookingDate,TotalSeatNo,count(*) as AllCount
from Booking_t
group by cube(BookingDate,TotalSeatNo)
order by BookingDate desc,TotalSeatNo desc

---GROUPING SETS operator(A summary query with a composite grouping).

select BookingDate,TotalSeatNo,PassengerID, count(*) as AllCount
from Booking_t
group by GROUPING SETS(BookingDate,TotalSeatNo,PassengerID,())
order by BookingDate desc,TotalSeatNo desc

---OVER Clause(A query that calculates a cumulative total and moving average).

select PNR,JourneyDate,AmountPaid,
sum(AmountPaid) over(order by JourneyDate) as CumTotal,
count(AmountPaid) over(order by JourneyDate) as Count,
avg(AmountPaid) over(order by JourneyDate) as MovingAvg
from Booking_t

-----SUBQUERY(Select statement that uses a subquery in where clause).

select BookingID,BookingDate,JourneyDate,AmountPaid
from Booking_t where AmountPaid>(
select avg(AmountPaid) from Booking_t)

------INSERT Record into table using script.

insert into Booking_t
(BookingID,PassengerID,TicketID,StatusID,PNR,StartingStation,EndingStation,BookingDate,TotalSeatNo,AmountPaid,JourneyDate)
values
(6,702,504,601,'12345AD5BD7',303,304,'09-01-2024',1,(410+0+0)*1,'10-01-2024')

------ALL Keyword(A query that return passengers who have paid larger amount than the largest amount paid by passenger 702)

select b.PassengerID,PassangerFname,PNR,JourneyDate,AmountPaid
from Booking_t b join Passenger_t p
on p.PassengerID=b.PassengerID
where AmountPaid>all
(select AmountPaid from Booking_t
where PassengerID=702)
order by PassangerFname

----ANY Keyword(A query that return passengers who have paid smaller amount than the largest amount paid by passenger 702)

select b.PassengerID,PassangerFname,PNR,JourneyDate,AmountPaid
from Booking_t b join Passenger_t p
on p.PassengerID=b.PassengerID
where AmountPaid<any
(select AmountPaid from Booking_t
where PassengerID=702)
order by PassangerFname

----SOME Keyword(A query that return passengers who have paid smaller amount than the largest amount paid by passenger 702)

select b.PassengerID,PassangerFname,PNR,JourneyDate,AmountPaid
from Booking_t b join Passenger_t p
on p.PassengerID=b.PassengerID
where AmountPaid<some
(select AmountPaid from Booking_t
where PassengerID=702)
order by PassangerFname

----CORRELATED SUBQUERY(A query that uses acorrelated subquery to return passengers whoses amount paid is higher than 
---the passengers average amount paied)

SELECT PassengerID,PNR,JourneyDate,AmountPaid
FROM Booking_t AS Main
where AmountPaid>
(SELECT AVG(AmountPaid) FROM Booking_t
AS SUB where Main.PassengerID=SUB.PassengerID)

----INSERT A PASSENGER RECORD.

insert into Passenger_t values
(706,'Monika','Galler','01712345669','NID','11223456'),
(707,'Selena','Gomez','01712885669','NID','99223456')
go

----DELETE A PASSENGER RECORD.

DELETE Passenger_t 
WHERE PassengerID=707

---Example of EXISTS Operator

SELECT * FROM Passenger_t
WHERE NOT  EXISTS 
(SELECT PassengerID FROM Booking_t
WHERE Passenger_t.PassengerID=Booking_t.PassengerID)

----CAST function.
select cast('01-Jan-2024 10:00 AM' AS DATE)

----CONVERT function.
select convert(time,'01-Jan-2024 10:00 AM' ,101)

---CTE(Common Table Expression)

with Summary as
(
select PassangerFname,p.PassengerID,sum(AmountPaid) as SumAmountPaid
from Booking_t b join Passenger_t p
on b.PassengerID=p.PassengerID
group by  PassangerFname,p.PassengerID
)
select Summary.PassangerFname,Summary.PassengerID,Summary.SumAmountPaid
from Summary

----------
insert into Food VALUES
(1,'Singara',10),
(2,'Tea',20),
(3,'Coffee',30)
go

-----UPDATE Statement.
update Food
set Price=50
where ID=3
---justify
select * from Food

---DELETE Row.

delete Food
where ID=3
---justify
select * from Food

---ERROR HANDLING with TRY....CATCH statement.

begin try
insert into Passenger_t values
(706,'Monika','Galler','01712345669','NID','11223456'),
(707,'Selena','Gomez','01712885669','NID','99223456');
print 'Successfully inserted records.'
end try
begin catch
print 'Failed to insert records. ';
print 'Error '+convert(varchar,error_number(),1)+': '+error_message();
end catch;

---EXAMPLE OF MERGE.

USE RailwayDB
GO
insert into Product values
(1,'Tea',10),
(2,'Coffee',20),
(3,'Singara',15)
go
insert into UpdateProduct values
(1,'Tea',10),
(2,'Coffee',30),
(3,'Singara',15),
(4,'Cake',40)
go
merge Product as t
using UpdateProduct as s
on t.ProductID=s.UpProductID
when matched and t.ProductName<>s.UpProductName
or t.Price<>s.UpPrice
then update set t.ProductName=s.UpProductName,t.Price=s.UpPrice
when not matched
then insert (ProductID,ProductName,Price) values
(s.UpProductID,s.UpProductName,s.UpPrice);

--justify
select * from Product

--Justify
sp_helpindex Train_t

---An update statement that update the view.
update BookingView
set AmountPaid=AmountPaid+100
where PassengerID=702 and BookingDate='2024-09-01'
----Justify
select * from Booking_t

---justify
select * from TotalAmountPay

----CURSOR.

USE RailwayDB;

DECLARE @TicketIdVar int,@TicketPriceVar money,@UpdateCount int;
SET @UpdateCount=0;

DECLARE Ticket_Cursor cursor
for
select TicketID,TicketPrice from Ticket_t
where TicketPrice+Vat+ServiceCharge>100;

open Ticket_Cursor;

fetch next from Ticket_Cursor into @TicketIdVar,@TicketPriceVar;
while @@FETCH_STATUS<>-1
begin
if @TicketPriceVar>300
begin
update Ticket_t
set ServiceCharge=ServiceCharge+50
where TicketID=@TicketIdVar;
set @UpdateCount=@UpdateCount+1;
end;
fetch next from Ticket_Cursor into @TicketIdVar,@TicketPriceVar;
end;
close Ticket_Cursor;
deallocate Ticket_Cursor;

print '';
print convert(varchar,@UpdateCount)+' row(s) affected.';

---A script that calls the stored procedure.
declare @myamount money;
execute spAmountTotal @myamount output,null,'R%';

---A script that calls the stored procedure.
declare @passengerCount int;
exec @passengerCount=spPassengerCount '2024-03-01','s%';
print 'Passenger count = '+ convert(varchar,@passengerCount)

---A script that invokes the function.
print 'Total ticket price: '+CONVERT(VARCHAR,dbo.fnTotalPrice(),1)+' Taka';

---A SELECT statement that invokes the function.
select * from dbo.fnTopPassenger(400);

select ClassName,sum(Vat) as VatRequest
from Class_t join dbo.fnVatAdjust1(1) as vatadjust
on Class_t.ClassID=vatadjust.ClassID
group by ClassName

--justify
delete Booking_t
where BookingID=6

---A script that calls the procedure.
BEGIN TRY
EXEC spInsertIntoTicket
506,110,202,402,380,0,0
END TRY
BEGIN CATCH
PRINT 'An error occurred.';
print 'Message: '+convert(varchar,error_message());
if ERROR_NUMBER()>50000
print 'This is a custom error message.'
END CATCH;

---A TRANSACTION with two save points.

if OBJECT_ID('tempdb..#PassengerCopy') is not null
drop table tempdb..#PassengerCopy;

select PassengerID,PassangerFname into #PassengerCopy 
from Passenger_t
where PassengerID<705
begin tran;
delete #PassengerCopy where PassengerID=701;
save tran Passenger1;
delete #PassengerCopy where PassengerID=702;
save tran Passenger2;
delete #PassengerCopy where PassengerID=703;
select * from #PassengerCopy;
rollback tran Passenger2;
select * from #PassengerCopy;
rollback tran Passenger1;
select * from #PassengerCopy;
commit tran;
select * from #PassengerCopy;
