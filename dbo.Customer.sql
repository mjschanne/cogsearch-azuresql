drop table Customer

create table Customer (
    cid int identity(1,1) primary key,
    name varchar(50) not null,
    address varchar(50) not null,
    city varchar(50) not null,
    state varchar(2) not null,
    zipCode varchar(16) not null,
    phone varchar(50) not null,
    email varchar(50) not null,
    active bit not null default 1
)

insert into Customers (name, address, city, state, zipCode, phone, email, active)
values 
    ('Alice Smith', '123 Main Street', 'Devon', 'PA', '19333', '610-555-1234', 'alice.smith@example.com', 1),
    ('Bob Jones', '456 Elm Avenue', 'Wayne', 'PA', '19087', '610-555-5678', 'bob.jones@example.com', 1),
    ('Charlie Brown', '789 Pine Road', 'Berwyn', 'PA', '19312', '610-555-9012', 'charlie.brown@example.com', 1),
    ('David Lee', '101 Maple Lane', 'Malvern', 'PA', '19355', '610-555-3456', 'david.lee@example.com', 1),
    ('Eve Green', '102 Oak Street', 'Paoli', 'PA', '19301', '610-555-7890', 'eve.green@example.com', 1);