USE [task_mgmt]
GO
/****** Object:  Table [dbo].[tbStatus]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbStatus](
	[TableName] [varchar](127) NOT NULL,
	[Status] [char](1) NOT NULL,
	[Descr] [nvarchar](100) NULL,
	[Priority] [tinyint] NULL,
 CONSTRAINT [PK__tbStatus] PRIMARY KEY CLUSTERED 
(
	[TableName] ASC,
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbTask]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbTask](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Descr] [nvarchar](500) NOT NULL,
	[DateCreate] [datetime] NOT NULL,
	[Status] [char](1) NOT NULL,
	[LogDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vwTaskList]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwTaskList]
AS
	SELECT   t.[Id], t.[Title], t.[Descr], t.[DateCreate], t.[Status], s.[Descr] AS 'StatusDescr', t.[LogDate]
	FROM       [tbTask] (NOLOCK) t
	INNER JOIN [tbStatus] (NOLOCK) s ON s.[TableName]='tbTask' AND s.[Status]=t.[Status]
GO
INSERT [dbo].[tbStatus] ([TableName], [Status], [Descr], [Priority]) VALUES (N'tbTask', N'-', N'Pending', 2)
INSERT [dbo].[tbStatus] ([TableName], [Status], [Descr], [Priority]) VALUES (N'tbTask', N'A', N'Completed', 1)
INSERT [dbo].[tbStatus] ([TableName], [Status], [Descr], [Priority]) VALUES (N'tbTask', N'X', N'Deleted', 3)
GO
/****** Object:  StoredProcedure [dbo].[spTask_AddNew]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spTask_AddNew]
	@Title             NVARCHAR(50),
	@Descr             NVARCHAR(500),
	@Id                BIGINT OUTPUT,
	@Msg               NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	/*
	DECLARE @Title  NVARCHAR(50)  = 'Purchase KFC';
	DECLARE	@Descr	NVARCHAR(500) = 'Company celebration Malaysia National day!';
	DECLARE @Id BIGINT;
	DECLARE @Msg VARCHAR(MAX);
	*/
	
	SET @Id  = -1;
	SET @Msg = '';
	
	-- Validation
	IF LEN(@Title) < 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Title not allow empty.';
		GOTO SP_END;
	END
	IF LEN(@Descr) < 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Description not allow empty.';
		GOTO SP_END;
	END
	
	BEGIN TRAN

	DECLARE @CurrentDate DATETIME = GETDATE();
	
	INSERT INTO [tbTask] ([Title], [Descr], [DateCreate], [Status], [LogDate])
	VALUES (@Title, @Descr, @CurrentDate, '-', @CurrentDate)
	IF @@ROWCOUNT <> 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Fail to insert task record.';
		ROLLBACK TRAN
		GOTO SP_END;
	END
	
	SET @Id = SCOPE_IDENTITY();
	
	COMMIT TRAN
	
SP_END:
	SELECT @Id AS 'Id', @Msg AS 'Msg'
END



GO
/****** Object:  StoredProcedure [dbo].[spTask_Update]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spTask_Update]
	@TId			   INT,
	@Title             NVARCHAR(50),
	@Descr             NVARCHAR(500),
	@Id                BIGINT OUTPUT,
	@Msg               NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE @TId    INT = 6;
	--DECLARE @Title  NVARCHAR(50)  = 'Purchase MCD';
	--DECLARE	@Descr	NVARCHAR(500) = 'Company celebration Valentines day!';
	--DECLARE @Id BIGINT;
	--DECLARE @Msg VARCHAR(MAX);
	
	
	SET @Id  = -1;
	SET @Msg = '';
	
	-- Validation
	IF NOT EXISTS(SELECT 1 FROM [tbTask] (NOLOCK) WHERE [Id]=@TId)
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Invalid identity, no record found.';
		GOTO SP_END;
	END
	IF LEN(@Title) < 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Title not allow empty.';
		GOTO SP_END;
	END
	IF LEN(@Descr) < 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Description not allow empty.';
		GOTO SP_END;
	END
	
	BEGIN TRAN

	UPDATE [tbTask]
	SET    [Title]=@Title,
		   [Descr]=@Descr,
		   [LogDate]=GETDATE()
	WHERE  [Id]=@TId
	IF @@ROWCOUNT <> 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Fail to update task record.';
		ROLLBACK TRAN
		GOTO SP_END;
	END
	
	SET @Id = @TId;
	
	COMMIT TRAN
	
SP_END:
	SELECT @Id AS 'Id', @Msg AS 'Msg'
END



GO
/****** Object:  StoredProcedure [dbo].[spTask_UpdateStatus]    Script Date: 9/1/2024 9:28:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spTask_UpdateStatus]
	@TId			   INT,
	@Status			   CHAR(1),
	@Id                BIGINT OUTPUT,
	@Msg               NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE @TId    INT = 6;
	--DECLARE @Title  NVARCHAR(50)  = 'Purchase MCD';
	--DECLARE	@Descr	NVARCHAR(500) = 'Company celebration Valentines day!';
	--DECLARE @Id BIGINT;
	--DECLARE @Msg VARCHAR(MAX);
	
	SET @Id  = -1;
	SET @Msg = '';
	
	-- Validation
	IF NOT EXISTS(SELECT 1 FROM [tbTask] (NOLOCK) WHERE [Id]=@TId)
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Invalid identity, no record found.';
		GOTO SP_END;
	END
	IF NOT EXISTS(SELECT 1 FROM [tbStatus] (NOLOCK) WHERE [TableName]='tbTask' AND [Status]=@Status)
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Invalid status, no record found.';
		GOTO SP_END;
	END
	
	BEGIN TRAN

	UPDATE [tbTask]
	SET    [Status]=@Status,
		   [LogDate]=GETDATE()
	WHERE  [Id]=@TId
	IF @@ROWCOUNT <> 1
	BEGIN
		SET @Id  = -1;
		SET @Msg = 'Fail to update task status.';
		ROLLBACK TRAN
		GOTO SP_END;
	END
	
	SET @Id = @TId;
	
	COMMIT TRAN
	
SP_END:
	SELECT @Id AS 'Id', @Msg AS 'Msg'
END



GO
