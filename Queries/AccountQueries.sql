--***********Accounts queries***********

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY,
    AccountNumber NVARCHAR(10) UNIQUE NOT NULL,
    Balance DECIMAL(18, 2),
    ClientID1 INT,
    ClientID2 INT,
    FOREIGN KEY (ClientID1) REFERENCES Clients(ClientID),
    FOREIGN KEY (ClientID2) REFERENCES Clients(ClientID)
);

Insert into Accounts (AccountNumber, Balance, ClientID1 ) Values ('5465768667', 656576, 5);
Insert into Accounts (AccountNumber, Balance, ClientID1, ClientID2 ) Values ('5558758794', 3546456, 6, 8);

SELECT 
    a.AccountID,
    a.AccountNumber,
    a.Balance,
    c1.ClientID AS ClientID1,
    c1.FirstName AS ClientName1,
    c2.ClientID AS ClientID2,
    c2.FirstName AS ClientName2
FROM 
    Accounts a
LEFT JOIN 
    Clients c1 ON a.ClientID1 = c1.ClientID
LEFT JOIN 
    Clients c2 ON a.ClientID2 = c2.ClientID;


Alter PROCEDURE spGetAccounts
AS
BEGIN
    SELECT 
        a.AccountID,
        a.AccountNumber,
        a.Balance,
        CONCAT(c1.FirstName, ' ', c1.LastName) AS Client1FullName,
        CONCAT(c2.FirstName, ' ', c2.LastName) AS Client2FullName
    FROM 
        Accounts a
    LEFT JOIN 
        Clients c1 ON a.ClientID1 = c1.ClientID
    LEFT JOIN 
        Clients c2 ON a.ClientID2 = c2.ClientID
	ORDER BY 
        a.AccountID DESC;
END;



CREATE SEQUENCE dbo.AccountNumberSeq
    START WITH 1000000000
    INCREMENT BY 1
    NO CYCLE;

CREATE PROCEDURE spAddAccount
	@Balance DECIMAL(18, 2),
    @ClientID1 INT,
    @ClientID2 INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @NewAccountNumber NVARCHAR(10);
    DECLARE @NextValue BIGINT;

    SET @NextValue = NEXT VALUE FOR dbo.AccountNumberSeq;

    SET @NewAccountNumber = CONVERT(NVARCHAR(10), @NextValue);

    INSERT INTO Accounts (AccountNumber, Balance, ClientID1, ClientID2)
    VALUES (@NewAccountNumber, @Balance, @ClientID1, @ClientID2);
END;

EXEC spAddAccount @Balance = 1000.00, @ClientID1 = 5,  @ClientID2 = 8;



Alter PROCEDURE spDeleteAccount
    @AccountID INT
AS
BEGIN
    DELETE FROM Accounts WHERE AccountID = @AccountID;
END;


Alter PROCEDURE spUpdateAccount
	@AccountID INT,
	@Balance DECIMAL
AS
BEGIN
	UPDATE Accounts 
	SET Balance = @Balance
	WHERE AccountID = @AccountID;
END;


CREATE PROCEDURE spGetAccountsByClientID
    @ClientID INT
AS
BEGIN
    SELECT AccountID, AccountNumber, Balance
    FROM Accounts
    WHERE ClientID1 = @ClientID OR ClientID2 = @ClientID
END

Execute spGetAccountsByClientID @ClientID = 5


Alter PROCEDURE spIsAccountValid
	@AccountNumber NVARCHAR(10),
	@ClientID INT,
	@TargetAccount NVARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @IsClientAccountValid BIT;
    DECLARE @IsTargetAccountValid BIT = 1;

	IF EXISTS (
		SELECT 1
		FROM Accounts
		WHERE AccountNumber = @AccountNumber
		AND (ClientID1 = @ClientID OR ClientID2 = @ClientID)
	)
	BEGIN
		SET @IsClientAccountValid = 1;
	END
	ELSE
	BEGIN
		SET @IsClientAccountValid = 0;
	END

	IF @TargetAccount IS NOT NULL
	BEGIN
		IF EXISTS(
			SELECT 1
			FROM Accounts
			WHERE AccountNumber = @TargetAccount 
			AND @AccountNumber <> @TargetAccount
		)
		BEGIN 
			SET @IsTargetAccountValid = 1;
		END
		ELSE
		BEGIN
			SET @IsTargetAccountValid = 0;
		END
	END

		SELECT @IsClientAccountValid AS IsClientAccountValid, @IsTargetAccountValid AS IsTargetAccountValid;
END



