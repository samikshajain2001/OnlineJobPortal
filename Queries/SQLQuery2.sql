create table [User](
UserId int primary key identity(1,1),
Username varchar(50),
Password varchar(50),
Name varchar(50),
Email varchar(50),
Mobile varchar(50),
TenthGrade varchar(50),
TwelthGrade varchar(50),
GraduationGrade varchar(50),
PostGraduationGrade varchar(50),
Phd varchar(50),
WorksOn varchar(50),
Experience varchar(50),
Resume varchar(50),
Address varchar(Max),
Country varchar(50)
)

Alter table [User]
add unique (Username)

select * from [User]

delete from [User] where UserId = 7