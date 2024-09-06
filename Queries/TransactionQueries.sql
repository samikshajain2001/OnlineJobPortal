--***********transaction queries***********

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY,
    AccountID INT,
    TransactionType NVARCHAR(10),
    Amount DECIMAL(18, 2),
    TransactionDate DATETIME,
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

ALTER TABLE Transactions
ADD TransferAccountID INT NULL;

ALTER TABLE Transactions
ADD CONSTRAINT FK_Transactions_TransferAccountID
FOREIGN KEY (TransferAccountID) REFERENCES Accounts(AccountID);


Insert into Transactions (AccountID, TransactionType, Amount, TransactionDate) Values (6, 'Deposit', 1000.00,GETDATE());
Insert into Transactions (AccountID, TransactionType, Amount, TransactionDate ) Values (7, 'Withdrawal', 4000.00, GETDATE());


Alter PROCEDURE spGetTransactionData
AS
BEGIN
    SELECT 
        t.TransactionID,
        a.AccountNumber,
        t.TransactionType,
		ISNULL(ta.AccountNumber, '') AS TransferAccountNumber,
        t.Amount,
        FORMAT(t.TransactionDate, 'dd/MM/yyyy') AS TransactionDate
    FROM 
        Transactions t
    JOIN 
        Accounts a ON t.AccountID = a.AccountID
	LEFT JOIN 
        Accounts ta ON t.TransferAccountID = ta.AccountID
    ORDER BY 
        t.TransactionDate DESC;
END;

Alter PROCEDURE spGetTransactionsByClientID
    @ClientID INT
AS
BEGIN
    SELECT t.TransactionID, a.AccountNumber, t.TransactionType, ISNULL(ta.AccountNumber, '') AS TransferAccountNumber, t.Amount, FORMAT(t.TransactionDate, 'dd/MM/yyyy') AS TransactionDate
    FROM Transactions t
    INNER JOIN Accounts a ON t.AccountID = a.AccountID
	LEFT JOIN Accounts ta ON t.TransferAccountID = ta.AccountID
    WHERE a.ClientID1 = @ClientID OR a.ClientID2 = @ClientID
    ORDER BY t.TransactionDate DESC
END


EXECUTE spGetTransactionsByClientID @ClientID = 5

Alter PROCEDURE spPerformTransaction
	@ClientID INT,
	@AccountNumber NVARCHAR(10),
	@Amount DECIMAL(18, 2),
	@TransactionType NVARCHAR(10),
	@TargetAccount NVARCHAR(10) =  NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AccountID INT;
	DECLARE @CurrentBalance DECIMAL(18, 2);
	DECLARE @TargetAccountID INT;
	DECLARE @TargetCurrentBalance DECIMAL(18, 2);

	SELECT @AccountID = AccountID, @CurrentBalance = Balance
	FROM Accounts
	WHERE AccountNumber = @AccountNumber
	AND (ClientID1 = @ClientID OR ClientID2 = @ClientID);

	IF(@TransactionType = 'Withdraw' OR @TransactionType = 'Transfer') AND @CurrentBalance < @Amount
	BEGIN
		RAISERROR('Insufficent balance in the Account.', 16, 1);
		RETURN;
	END

	IF @TransactionType = 'Transfer'
	BEGIN
		SELECT @TargetAccountID = AccountID, @TargetCurrentBalance = Balance
		FROM Accounts
		WHERE AccountNumber = @TargetAccount

		IF @TargetAccountID IS NULL
        BEGIN
            RAISERROR('Tranfer account is invalid.', 16, 1);
            RETURN;
        END
	END

	BEGIN TRANSACTION;

	BEGIN TRY
		IF @TransactionType = 'Deposit'
		BEGIN
			UPDATE Accounts
			SET Balance = Balance + @Amount
			WHERE AccountID = @AccountID
		END
		ELSE IF @TransactionType = 'Withdraw'
		BEGIN
			UPDATE Accounts
			SET Balance = Balance - @Amount
			WHERE AccountID = @AccountID
		END
		ELSE IF @TransactionType = 'Transfer'
		BEGIN
			UPDATE Accounts
			SET Balance = Balance - @Amount
			WHERE AccountID = @AccountID

			UPDATE Accounts
			SET Balance = Balance + @Amount
			WHERE AccountID = @TargetAccountID
		END

		INSERT INTO Transactions (AccountID, TransactionType, Amount, TransactionDate, TransferAccountID)
        VALUES (@AccountID, @TransactionType, @Amount, GETDATE(),
				CASE WHEN @TransactionType = 'Transfer' THEN @TargetAccountID ELSE NULL END);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END;
