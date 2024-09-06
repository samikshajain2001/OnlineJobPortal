Alter TABLE Clients (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
	UserName NVARCHAR(100),
    Password NVARCHAR(100),
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(15),
	Address NVARCHAR(100)
);

ALTER TABLE Clients
ADD UserName NVARCHAR(100),
    Password NVARCHAR(100);

ALTER TABLE Clients
ADD CONSTRAINT UQ_UserName UNIQUE (UserName);


--***********Clients queries***********

ALTER PROCEDURE spAddClient
    @UserName NVARCHAR(100),
    @Password NVARCHAR(100),
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
    @Address NVARCHAR(255)
AS
BEGIN
    INSERT INTO Clients (UserName, Password, FirstName, LastName, Email, Phone, Address)
    VALUES (@UserName, @Password, @FirstName, @LastName, @Email, @Phone, @Address);
END
EXEC spAddClient 
    @UserName = 'testuser', 
    @Password = 'password123', 
    @FirstName = 'Test', 
    @LastName = 'User', 
    @Email = 'testuser@example.com', 
    @Phone = '1234567890', 
    @Address = '123 Test Street';



select * from Clients
delete from clients where ClientID = 3

Alter PROCEDURE spGetClient
AS
BEGIN
	SELECT 
		ClientID, 
		UserName,
		CONCAT(FirstName, ' ', LastName) AS Name, 
		Email, 
		Phone, 
		Address 
	FROM 
		Clients
	ORDER BY 
        ClientID DESC;
END

Alter PROCEDURE spUpdateClient
    @ClientID INT,
    @FirstName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(15),
	@Address NVARCHAR(100)
AS
BEGIN
    UPDATE Clients
    SET FirstName = @FirstName, Email = @Email, Phone = @Phone, Address = @Address
    WHERE ClientID = @ClientID;
END;

CREATE PROCEDURE spDeleteClient
    @ClientID INT
AS
BEGIN
    DELETE FROM Clients WHERE ClientID = @ClientID;
END;





