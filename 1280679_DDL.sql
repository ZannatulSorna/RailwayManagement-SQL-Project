--1280679
--PROJECT:RailwayDB
--RailwayDB_DDL

use master
go
if DB_ID('RailwayDB') is not null
drop database RailwayDB
go
create database RailwayDB
on
(
name='RailwayDB_Data_1',
filename='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RailwayDB_Data_1.mdf',
size=25mb,
maxsize=100mb,
filegrowth=5%
)
log on
(
name='RailwayDB_Log_1',
filename='C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\RailwayDB_Log_1.ldf',
size=2mb,
maxsize=25mb,
filegrowth=1%
)
go

USE RailwayDB
go

CREATE TABLE Train_t
(
TrainID INT PRIMARY KEY NOT NULL,
TrainName varchar(100) not null,
FromStation varchar(30) not null,
ToStation varchar(30) not null
)
go

CREATE TABLE Journey_t
(
JourneyID INT PRIMARY KEY NOT NULL,
JourneyName varchar(100) not null
)
go

CREATE TABLE Station_t
(
StationID INT PRIMARY KEY NOT NULL,
StationName varchar(100) not null
)
go

CREATE TABLE Class_t
(
ClassID INT PRIMARY KEY NOT NULL,
ClassName varchar(100) not null
)
go

CREATE TABLE Ticket_t
(
TicketID INT UNIQUE NOT NULL,
TrainID INT REFERENCES Train_t(TrainID),
JourneyID INT REFERENCES Journey_t(JourneyID),
ClassID INT REFERENCES Class_t(ClassID),
TicketPrice money not null,
Vat float not null,
ServiceCharge money not null,
PRIMARY KEY(JourneyID,ClassID)
)
go

CREATE TABLE BookingStatus_t
(
StatusID INT PRIMARY KEY NOT NULL,
BookingStatus varchar(100) not null
)
go

create table Passenger_t
(
PassengerID INT PRIMARY KEY NOT NULL,
PassangerFname varchar(40) not null,
PassangerLname varchar(40) not null,
Phn varchar(11) not null,
IdentificationType varchar(20) not null,
IdentificationNo varchar(40) not null
)
go

create table Booking_t
(
BookingID INT PRIMARY KEY NOT NULL,
PassengerID INT REFERENCES Passenger_t(PassengerID),
TicketID INT REFERENCES Ticket_t(TicketID),
StatusID INT REFERENCES BookingStatus_t(StatusID),
PNR VARCHAR(30) NOT NULL,
StartingStation int not null,
EndingStation int not null,
BookingDate date not null,
TotalSeatNo int not null,
AmountPaid money not null,
JourneyDate date not null
)
go

use RailwayDB
go

----------
create table Food
(
ID INT PRIMARY KEY NOT NULL,
FoodName varchar(20) not null,
Price money not null
)
go

---ALTER Statement
--1.

alter table Food
add UpdatePrice money ;
--2.

alter table Food
drop column UpdatePrice


---DROP Table.

drop table Food
go

-----Create NONCLUSTERED INDEX.

CREATE NONCLUSTERED INDEX IX_Train_t_TrainName
ON Train_t(TrainName)


------Create an UPDATEABLE VIEW.

CREATE VIEW BookingView
as
select PassengerID,BookingDate,JourneyDate,AmountPaid
from Booking_t



----A create VIEW Statement that creates a READ-ONLY VIEW(Non updateable).

create view TotalAmountPay
as
SELECT TicketID,TicketPrice,Vat,ServiceCharge,
TicketPrice+vat+ServiceCharge as TotalPay
FROM Ticket_t


---ENCRYPTED VIEW.

create view BookingInfo
with encryption
as
select BookingID,BookingDate,JourneyDate,PassengerID
from Booking_t



----A Create PROCEDURE statement that includes output and optional parameter.

create proc spAmountTotal
@AmountTotal money output,
@JourneyDateVar date=null,
@PassengerVar varchar(40) ='%'
as
if @JourneyDateVar is null
select @JourneyDateVar=min(JourneyDate) from Booking_t;

select @AmountTotal=sum(AmountPaid) from Booking_t join Passenger_t
on Passenger_t.PassengerID=Booking_t.PassengerID
where (JourneyDate>=@JourneyDateVar) and
(PassangerFname like @PassengerVar);


----RETURN statement for a stored procedure/A STORED PROCEDURE that returns a value.

create proc spPassengerCount
@DateVar date=null,
@PassengerVar varchar(40) ='%'
as
if @DateVar is null
select @DateVar=min(BookingDate) from Booking_t;

declare @passengerCount int;

select @passengerCount=count(Passenger_t.PassengerID) from Booking_t join Passenger_t
on Booking_t.PassengerID=Passenger_t.PassengerID
where (BookingDate>=@DateVar) and
(PassangerFname like @PassengerVar);
return @passengerCount;



---A statement that creates a SCALAR-VALUED FUNCTION.

CREATE FUNCTION fnTotalPrice()
returns money
begin
return(select sum(TicketPrice+Vat+ServiceCharge) from Ticket_t where ServiceCharge>0)
end;


----A statement that creates a SIMPLE TABLE-VALUED function.

create function fnTopPassenger
(@Cutoff money=0)
returns table
return
(select PassangerFname,sum(AmountPaid) as TotalPay from Booking_t join Passenger_t
on Passenger_t.PassengerID=Booking_t.PassengerID
where AmountPaid>200
group by PassangerFname
having sum(AmountPaid)>=@Cutoff);


---A statement that create a multi valued table function.
create function fnVatAdjust1(@HowMuch money)
returns @OutTable table
(TrainID INT,ClassID INT,TicketPrice money,Vat money,ServiceCharge money)
begin
insert @OutTable
select TrainID,ClassID,TicketPrice,Vat,ServiceCharge from Ticket_t
where ServiceCharge>0;
while (select sum(TicketPrice+Vat+ServiceCharge) from @OutTable)>=@HowMuch
update @OutTable
set Vat=Vat+10
where ServiceCharge>0;
return;
end;


---An AFTER TRIGGER that archive deleted data.

create trigger Booking_DELETE
ON Booking_t
AFTER DELETE
AS
INSERT INTO BookingArchive
(BookingID,PassengerID,TicketID,StatusID,PNR,StartingStation,
EndingStation,BookingDate,TotalSeatNo,AmountPaid,JourneyDate)
select BookingID,PassengerID,TicketID,StatusID,PNR,StartingStation,
EndingStation,BookingDate,TotalSeatNo,AmountPaid,JourneyDate
from deleted




---Validate data and raise error using THROW statement.

create proc spInsertIntoTicket
@TicketID int,@TrainID int,@JourneyID INT,@ClassID int,@TicketPrice money,@Vat float,@ServiceCharge money
as
if exists(select * from Train_t where TrainID=@TrainID)
insert Ticket_t VALUES
(@TicketID,@TrainID,@JourneyID,@ClassID,@TicketPrice,@Vat,@ServiceCharge);
else
throw 50001,'not a valid trainID',1;



---EXAMPLE OF MERGE.

USE RailwayDB
GO
CREATE TABLE Product
(
ProductID INT PRIMARY KEY NOT NULL,
ProductName varchar(30) not null,
Price money not null
)
go
CREATE TABLE UpdateProduct
(
UpProductID INT PRIMARY KEY NOT NULL,
UpProductName varchar(30) not null,
UpPrice money not null
)
go