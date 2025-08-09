-- DATABASE SCHEMA: HỆ THỐNG QUẢN LÝ TÀI CHÍNH CÁ NHÂN - SQL SERVER
-- ===================================================================

-- CREATE DATABASE FinanceChatbotDB;
-- USE FinanceChatbotDB;

-- 1. BẢNG QUẢN LÝ NGƯỜI DÙNG
-- ===================================================================

CREATE TABLE Users (
    UserID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    Currency NCHAR(3) DEFAULT 'VND',
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    LastLogin DATETIME2
);

CREATE TABLE UserSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    RefreshToken NVARCHAR(500) NOT NULL,
    DeviceInfo NVARCHAR(255),
    IPAddress NVARCHAR(45),
    ExpiresAt DATETIME2 NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 2. DANH MỤC
-- ===================================================================

CREATE TABLE Categories (
    CategoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryType NVARCHAR(20) NOT NULL CHECK (CategoryType IN ('income', 'expense')),
    ParentCategoryID UNIQUEIDENTIFIER REFERENCES Categories(CategoryID),
    Description NVARCHAR(500),
    Icon NVARCHAR(50),
    Color NVARCHAR(7),
    IsDefault BIT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    SortOrder INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE UserCategories (
    UserCategoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    CategoryID UNIQUEIDENTIFIER NULL REFERENCES Categories(CategoryID),
    CustomName NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UNIQUE(UserID, CategoryID)
);

-- 3. GIAO DỊCH
-- ===================================================================

CREATE TABLE Transactions (
    TransactionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    UserCategoryID UNIQUEIDENTIFIER NOT NULL REFERENCES UserCategories(UserCategoryID),
    TransactionType NVARCHAR(20) NOT NULL CHECK (TransactionType IN ('income', 'expense')),
    Amount DECIMAL(15,2) NOT NULL CHECK (Amount > 0),
    Description NVARCHAR(500),
    TransactionDate DATE NOT NULL,
    TransactionTime TIME DEFAULT CONVERT(TIME, GETDATE()),
    PaymentMethod NVARCHAR(50),
    Location NVARCHAR(255),
    Notes NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    CreatedBy NVARCHAR(20) DEFAULT 'manual' CHECK (CreatedBy IN ('manual', 'chatbot'))
);

-- 4. NGÂN SÁCH
-- ===================================================================

CREATE TABLE Budgets (
    BudgetID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    
    BudgetName NVARCHAR(255) NOT NULL,
    BudgetType NVARCHAR(20) NOT NULL CHECK (BudgetType IN ('monthly', 'weekly', 'yearly')),
    Amount DECIMAL(15,2) NOT NULL CHECK (Amount > 0),
    
    PeriodStart DATE NOT NULL,
    PeriodEnd DATE NOT NULL,
    
    AutoAdjust BIT DEFAULT 0,            -- Tự động điều chỉnh các danh mục con khi thay đổi tổng ngân sách
    IncludeIncome BIT DEFAULT 0,         -- Bao gồm cả thu nhập (1) hay chỉ chi tiêu (0)

    AlertThreshold DECIMAL(5,2) DEFAULT 80.00 CHECK (AlertThreshold BETWEEN 0 AND 100),
    IsActive BIT DEFAULT 1,

    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);


CREATE TABLE BudgetAlerts (
    AlertID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),           -- Khóa chính
    BudgetID UNIQUEIDENTIFIER NOT NULL REFERENCES Budgets(BudgetID) , -- Liên kết tới ngân sách
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ,       -- Người dùng liên quan

    AlertType NVARCHAR(20) NOT NULL 
        CHECK (AlertType IN ('warning', 'exceeded', 'near_limit')), -- Loại cảnh báo:
        -- 'warning'     → Cảnh báo sớm (ví dụ: vượt 70%)
        -- 'near_limit' → Gần vượt mức (ví dụ: 90%)
        -- 'exceeded'   → Đã vượt quá ngân sách

    CurrentAmount DECIMAL(15,2) NOT NULL,   -- Số tiền đã chi tiêu
    BudgetAmount DECIMAL(15,2) NOT NULL,    -- Ngân sách đã đặt
    PercentageUsed DECIMAL(5,2) NOT NULL,   -- % đã sử dụng = Current / Budget * 100

    Message NVARCHAR(MAX),                  -- Nội dung thông báo chi tiết (tùy chỉnh)
    IsRead BIT DEFAULT 0,                   -- Đánh dấu đã đọc thông báo hay chưa

    CreatedAt DATETIME2 DEFAULT GETDATE()   -- Thời gian tạo cảnh báo
);


CREATE TABLE BudgetCategories (
    BudgetCategoryID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    BudgetID UNIQUEIDENTIFIER NOT NULL REFERENCES Budgets(BudgetID) ,
    UserCategoryID UNIQUEIDENTIFIER NOT NULL REFERENCES UserCategories(UserCategoryID),

    AllocatedAmount DECIMAL(15,2) NOT NULL CHECK (AllocatedAmount >= 0),
    SpentAmount DECIMAL(15,2) DEFAULT 0 CHECK (SpentAmount >= 0), -- Tổng chi tiêu thực tế (tính toán hoặc lưu để tối ưu)

    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),

    UNIQUE (BudgetID, UserCategoryID)
);

-- 5. CHATBOT
-- ===================================================================

CREATE TABLE ChatSessions (
    SessionID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    SessionName NVARCHAR(255),
    StartedAt DATETIME2 DEFAULT GETDATE(),
    EndedAt DATETIME2,
    IsActive BIT DEFAULT 1,
    MessageCount INT DEFAULT 0
);

CREATE TABLE ChatMessages (
    MessageID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SessionID UNIQUEIDENTIFIER NOT NULL REFERENCES ChatSessions(SessionID) ON DELETE CASCADE,
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    MessageType NVARCHAR(20) NOT NULL CHECK (MessageType IN ('user', 'bot', 'system')),
    Content NVARCHAR(MAX) NOT NULL,
    Intent NVARCHAR(50),
    ActionTaken NVARCHAR(50),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 6. REPORTS
-- ===================================================================

CREATE TABLE SavedReports (
    ReportID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID) ON DELETE CASCADE,
    -- Tên tùy chỉnh người dùng đặt
    ReportName NVARCHAR(100) NOT NULL,
    -- Loại nội dung: report, chart, budget_template, export_template,...
    TemplateType NVARCHAR(30) NOT NULL CHECK (TemplateType IN (
        'report', 'chart', 'budget_template', 'export_template', 'custom'
    )),
    -- Kiểu báo cáo cụ thể: income_expense, category_analysis, ...
    ReportType NVARCHAR(50) NOT NULL CHECK (ReportType IN (
        'income_expense', 'budget_tracking', 'category_analysis',
        'monthly_summary', 'custom'
    )),
    -- JSON config: chứa bộ lọc, khoảng ngày, danh mục, ngân sách, biểu đồ...
    ReportConfig NVARCHAR(MAX) NOT NULL,
    Description NVARCHAR(300),
    -- Có lên lịch tự động không
    IsScheduled BIT DEFAULT 0,
    -- Tần suất (nếu có): daily, weekly, monthly
    ScheduleFrequency NVARCHAR(15) CHECK (
        ScheduleFrequency IN ('daily', 'weekly', 'monthly') OR ScheduleFrequency IS NULL
    ),
    -- Lần chạy gần nhất (nếu có)
    LastGenerated DATETIME,
    -- Thời gian tạo và cập nhật
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);


-- 7. AUDIT LOGS
-- ===================================================================

CREATE TABLE AuditLogs (
    AuditID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserID UNIQUEIDENTIFIER REFERENCES Users(UserID),
    TableName NVARCHAR(50) NOT NULL,
    RecordID UNIQUEIDENTIFIER NOT NULL,
    Action NVARCHAR(20) NOT NULL CHECK (Action IN ('INSERT', 'UPDATE', 'DELETE')),
    OldValues NVARCHAR(MAX),
    NewValues NVARCHAR(MAX),
    IPAddress NVARCHAR(45),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- TRIGGERS
-- ===================================================================

CREATE TRIGGER TR_Users_UpdatedAt ON Users AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users SET UpdatedAt = GETDATE()
    WHERE UserID IN (SELECT UserID FROM inserted);
END;

CREATE TRIGGER TR_Transactions_UpdatedAt ON Transactions AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Transactions SET UpdatedAt = GETDATE()
    WHERE TransactionID IN (SELECT TransactionID FROM inserted);
END;

CREATE TRIGGER TR_Budgets_UpdatedAt ON Budgets AFTER UPDATE AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Budgets SET UpdatedAt = GETDATE()
    WHERE BudgetID IN (SELECT BudgetID FROM inserted);
END;

CREATE TRIGGER TR_ChatMessages_UpdateCount ON ChatMessages AFTER INSERT AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ChatSessions SET MessageCount = MessageCount + 1
    WHERE SessionID IN (SELECT SessionID FROM inserted);
END;

-- INDEXES
-- ===================================================================

CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_Active ON Users(IsActive);

CREATE INDEX IX_Categories_Type ON Categories(CategoryType);
CREATE INDEX IX_Categories_Parent ON Categories(ParentCategoryID);

CREATE INDEX IX_Transactions_UserID_Date ON Transactions(UserID, TransactionDate DESC);
CREATE INDEX IX_Transactions_CategoryID ON Transactions(CategoryID);
CREATE INDEX IX_Transactions_Type ON Transactions(TransactionType);

CREATE INDEX IX_Budgets_User_Active ON Budgets(UserID, IsActive);
CREATE INDEX IX_Budgets_Period ON Budgets(PeriodStart, PeriodEnd);

CREATE INDEX IX_BudgetAlerts_User_Read ON BudgetAlerts(UserID, IsRead);

CREATE INDEX IX_ChatMessages_Session ON ChatMessages(SessionID);
CREATE INDEX IX_ChatMessages_User ON ChatMessages(UserID);
CREATE INDEX IX_ChatMessages_Created ON ChatMessages(CreatedAt DESC);

-- FUNCTION
-- ===================================================================

CREATE FUNCTION GetCategoryFullName(@CategoryID UNIQUEIDENTIFIER)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Result NVARCHAR(255), @ParentName NVARCHAR(100), @CategoryName NVARCHAR(100);
    SELECT @CategoryName = CategoryName, @ParentName = p.CategoryName
    FROM Categories c
    LEFT JOIN Categories p ON c.ParentCategoryID = p.CategoryID
    WHERE c.CategoryID = @CategoryID;
    SET @Result = CASE 
        WHEN @ParentName IS NOT NULL THEN @ParentName + ' > ' + @CategoryName
        ELSE @CategoryName
    END;
    RETURN @Result;
END;

-- STORED PROCEDURE
-- ===================================================================

CREATE PROCEDURE GetUserFinancialOverview
    @UserID UNIQUEIDENTIFIER,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @StartDate IS NULL SET @StartDate = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    IF @EndDate IS NULL SET @EndDate = EOMONTH(GETDATE());
    SELECT 
        SUM(CASE WHEN TransactionType = 'income' THEN Amount ELSE 0 END) as TotalIncome,
        SUM(CASE WHEN TransactionType = 'expense' THEN Amount ELSE 0 END) as TotalExpense,
        SUM(CASE WHEN TransactionType = 'income' THEN Amount ELSE -Amount END) as NetAmount,
        COUNT(*) as TotalTransactions
    FROM Transactions 
    WHERE UserID = @UserID 
    AND TransactionDate BETWEEN @StartDate AND @EndDate;
END;

CREATE PROCEDURE CheckBudgetStatus
    @UserID UNIQUEIDENTIFIER,
    @BudgetID UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        b.BudgetID,
        b.BudgetName,
        b.Amount as BudgetAmount,
        ISNULL(SUM(t.Amount), 0) as SpentAmount,
        (ISNULL(SUM(t.Amount), 0) / b.Amount * 100) as PercentageUsed,
        CASE 
            WHEN (ISNULL(SUM(t.Amount), 0) / b.Amount * 100) >= 100 THEN 'exceeded'
            WHEN (ISNULL(SUM(t.Amount), 0) / b.Amount * 100) >= b.AlertThreshold THEN 'warning'
            ELSE 'normal'
        END as Status
    FROM Budgets b
    LEFT JOIN Transactions t ON b.CategoryID = t.CategoryID 
        AND t.UserID = b.UserID
        AND t.TransactionDate BETWEEN b.PeriodStart AND b.PeriodEnd
        AND t.TransactionType = 'expense'
    WHERE b.UserID = @UserID 
    AND b.IsActive = 1
    AND (@BudgetID IS NULL OR b.BudgetID = @BudgetID)
    GROUP BY b.BudgetID, b.BudgetName, b.Amount, b.AlertThreshold;
END;

