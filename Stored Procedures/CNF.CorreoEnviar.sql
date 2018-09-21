SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Responsable:			Roberto Amaya
-- Ultima Modificación: 2018-07-23
-- Descripción:			Enviar correo
-- =============================================
CREATE PROCEDURE [CNF].[CorreoEnviar]
    @From VARCHAR(100),
    @To VARCHAR(MAX),
    @Subject VARCHAR(100) = " ",
    @Body VARCHAR(MAX) = " "
AS
BEGIN


    DECLARE @iMsg INT,
            @hr INT,
            @source VARCHAR(255),
            @description VARCHAR(500),
            @output VARCHAR(1000);

    --************* Create the CDO.Message Object ************************ 
    EXEC @hr = sp_OACreate 'CDO.Message', @iMsg OUT;
    --***************Configuring the Message Object ****************** 

    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value',
                                '2';
    -- This is to configure the Server Name or IP address. 
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value',
                                'smtp.gmail.com';

    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport").Value',
                                '465';
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpusessl").Value',
                                '1';
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout").Value',
                                '60';
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate").Value',
                                '1';
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusername").Value',
                                'trackingtpe@transpais.com.mx';
    EXEC @hr = sp_OASetProperty @iMsg,
                                'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendpassword").Value',
                                'transpais2315';


    -- Guardar las configuraciones del objeto de mensaje. 
    EXEC @hr = sp_OAMethod @iMsg, 'Configuration.Fields.Update', NULL;

    -- Establecer los parámetros de correo electrónico. 
    EXEC @hr = sp_OASetProperty @iMsg, 'To', @To;
    EXEC @hr = sp_OASetProperty @iMsg, 'From', @From;
    --EXEC @hr = sp_OASetProperty @iMsg, 'CC', @CopyTo 
    EXEC @hr = sp_OASetProperty @iMsg, 'Subject', @Subject;
    EXEC @hr = sp_OASetProperty @iMsg, 'HTMLBody', @Body;
    ---
    EXEC @hr = sp_OAMethod @iMsg, 'Send', NULL;
    EXEC @hr = sp_OADestroy @iMsg;
    PRINT @Body;
END;
GO
