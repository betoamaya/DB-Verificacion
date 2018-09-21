SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-19
-- Descripción:			Validar Email
-- =============================================
CREATE FUNCTION [CNF].[fnCompruebaEmail] (@email VARCHAR(255))
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @valid BIT;
    DECLARE @domain AS NVARCHAR(256);
    DECLARE @str1 VARCHAR(128);
    DECLARE @i INT;

    IF @email IS NOT NULL
        SET @email = REPLACE(@email, CHAR(10), '');
    SET @email = REPLACE(@email, CHAR(13), '');
    SET @email = REPLACE(@email, ';', '');
    SET @email = LOWER(@email);
    SET @email = LTRIM(RTRIM(@email));
    WHILE (CHARINDEX('  ', @email, 0) <> 0)
    BEGIN
        SET @email = REPLACE(@email, '  ', '');
        CONTINUE;
    END;
    SET @email = LTRIM(RTRIM(@email));
    SET @valid = 0;
    --IF @email like '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%'  
    IF PATINDEX('[a-z,0-9,_,-]%@[a-z,0-9,-]%.[a-z][a-z]%', @email) = 1
       AND @email NOT LIKE '%@%\_%' ESCAPE '\'
       AND @email NOT LIKE '%@%@%'
       AND CHARINDEX('.@', @email) = 0
       AND CHARINDEX('..', @email) = 0
       AND CHARINDEX(',', @email) = 0
       AND RIGHT(@email, 1)
       BETWEEN 'a' AND 'z'
       AND PATINDEX('%[ &'',":;!+=\/()<>]%', @email) = 0
        SET @valid = 1;
    IF @email LIKE '%._'
        SET @valid = 0;
    IF @valid = 0
    BEGIN
        SET @email = '';
    END;

    --Se comprueba el dominio.

    IF @email <> ''
    BEGIN
        SET @str1 = '';
        SET @i = 48;
        WHILE @i <= 57
        BEGIN
            SET @str1 = @str1 + '|' + CHAR(@i);
            SET @i = @i + 1;
        END;

        SET @i = 97;
        WHILE @i <= 122
        BEGIN
            SET @str1 = @str1 + '|' + CHAR(@i);
            SET @i = @i + 1;
        END;

        SET @str1 = @str1 + '|.';
        SET @str1 = @str1 + '|-';

        SET @domain = RIGHT(@email, LEN(@email) - CHARINDEX('@', @email));

        IF @domain LIKE '%[^' + @str1 + ']%' ESCAPE '|'
        BEGIN
            SET @email = '';
        END;

    END;

    RETURN @email;
END;
GO
