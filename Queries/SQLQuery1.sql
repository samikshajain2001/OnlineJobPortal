use JobPortal

Create Table Contact (
ContactId int primary key identity(1,1) not null,
Name varchar(50),
Email varchar(50),
Subject varchar(100),
Message varchar(Max)
)

select * from Contact;

select * from Country;