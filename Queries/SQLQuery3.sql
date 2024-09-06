create table userContact
(
UserId int Primary key identity(1,1),
Name varchar(50),
Email varchar(50),
Subject varchar(50),
Comments varchar(100)
)

Alter table userContact
ADD 
Email varchar(50)

Select * from userContact

