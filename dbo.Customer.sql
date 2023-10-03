drop table dbo.Customer

alter database SampleDB  
set change_tracking = on
(change_retention = 2 days, auto_cleanup = on)

if object_id('dbo.Customer', 'U') is not null
  drop table dbo.Customer; 

create table dbo.Customer (
    CustomerId int identity(1,1) primary key,
    Name varchar(50) not null,
    Phone varchar(50) not null,
    Email varchar(50) not null,
    Address varchar(50) not null,
    City varchar(50) not null,
    State varchar(2) not null,
    ZipCode varchar(16) not null,
    Active bit not null default 1
)

alter table dbo.Customer  
enable change_tracking
with (track_columns_updated = on)

insert into dbo.Customer (Name, address, City, State, ZipCode, Phone, Email, Active)
values 
    ('Alice Smith', '123 Main Street', 'Devon', 'PA', '19333', '610-555-1234', 'alice.smith@example.com', 1),
    ('Bob Jones', '456 Elm Avenue', 'Wayne', 'PA', '19087', '610-555-5678', 'bob.jones@example.com', 1),
    ('Charlie Brown', '789 Pine Road', 'Berwyn', 'PA', '19312', '610-555-9012', 'charlie.brown@example.com', 1),
    ('David Lee', '101 Maple Lane', 'Malvern', 'PA', '19355', '610-555-3456', 'david.lee@example.com', 1),
    ('Eve Green', '102 Oak Street', 'Paoli', 'PA', '19301', '610-555-7890', 'eve.green@example.com', 1);