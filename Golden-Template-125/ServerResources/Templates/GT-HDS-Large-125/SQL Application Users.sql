/*
----------------INSTRUCTIONS-----------------

Do a find and replace for the term "hc061", replace hc061 with your ICM's instance name

EXAMPLE
FIND: hc061
REPLACE: hc075

There are two spots below this section that 

Error Handling:
If you run this script pre-maturely, encounter an error or simply want to revert the changes
1. Under Security, locate the ece user.  Revoke all of their database access.  Save the changes and then delete the user.
2. Under Security, locate the livedata user.  Revoke all of their database access.  Save the changes and then delete the user.
3. Under Security, locate the icaproduser user.  Revoke all of their database access.  Save the changes and then delete the user.

You can re-run this script as many times as you want.  It will not change passwords of users, however if they do not exist in the database
it will assign them a default one.

*/
----------------MASTER DB STUFF-------------------------

USE [master]
GO

If not Exists (select loginname from master.dbo.syslogins 
    where name = 'livedatauser')
Begin
create login [livedatauser] with password = 'HCSliv123!', sid = 0x60d0b5eb66a19a409264e70e7862074a, check_expiration = OFF, check_policy = OFF, default_database = master, default_language = us_english
PRINT 'SQL User: livedatauser created successfully.'
End
Else
Begin
PRINT 'SQL User: livedatauser already exists.  Not creating and moving to next statement'
End

PRINT 'Adding necessary roles to livedatauser'
EXEC master..sp_addsrvrolemember @loginame = N'livedatauser', @rolename = N'sysadmin'
EXEC master..sp_addsrvrolemember @loginame = N'livedatauser', @rolename = N'securityadmin'
EXEC master..sp_addsrvrolemember @loginame = N'livedatauser', @rolename = N'serveradmin'
EXEC master..sp_addsrvrolemember @loginame = N'livedatauser', @rolename = N'setupadmin'
PRINT 'Added roles to livedatauser'

If not Exists (select loginname from master.dbo.syslogins 
    where name = 'ece')
Begin
create login [ece] with password = 'HCSece123!', sid = 0xfc1b4f8bd8e0c242844741f60733f4bb, check_expiration = OFF, check_policy = OFF, default_database = master, default_language = us_english
PRINT 'SQL User: ece created successfully.'
End
Else
Begin
PRINT 'SQL User: ece already exists.  Not creating and moving to next statement'
End

If not Exists (select loginname from master.dbo.syslogins 
    where name = 'cuic')
Begin
create login [cuic] with password = 'HCScuic123!', sid = 0x2DBD843A61E3F84F899FBCDA23BF2300, check_expiration = OFF, check_policy = OFF, default_database = master, default_language = us_english
PRINT 'SQL User: cuic created successfully.'
End
Else
Begin
PRINT 'SQL User: cuic already exists.  Not creating and moving to next statement'
End

If not Exists (select loginname from master.dbo.syslogins 
    where name = 'icaproduser')
Begin
create login [icaproduser] with password = 0x0200aa8a65e07a4fd066b961814ced1fa6b97922c49dcc46ae5617100fd1f5b2c59021fdf2e66649584a8087903f9342baa7f7b5cbd79e187999593be5582a65886a983ee5cd hashed, sid = 0xfbcf13f5ce6e8b4588695426e9f1b8fd, check_expiration = OFF, check_policy = OFF, default_database = master, default_language = us_english
PRINT 'SQL User: icaproduser created successfully.'
End
Else
Begin
PRINT 'SQL User: icaproduser already exists.  Not creating and moving to next statement'
End

PRINT 'Adding necessary roles to icaproduser'
EXEC master..sp_addsrvrolemember @loginame = N'icaproduser', @rolename = N'sysadmin'
PRINT 'Added roles to icaproduser'

If not Exists (select loginname from master.dbo.syslogins 
    where name = 'svc_CBS_RO')
Begin
create login [svc_CBS_RO] with password = '6x^W/y-zJ%r6mYrT7jNh', sid = 0x6913BB9875BE564999CE373C9C39C534, check_expiration = OFF, check_policy = OFF, default_database = master, default_language = us_english
PRINT 'SQL User: svc_CBS_RO created successfully.'
End
Else
Begin
PRINT 'SQL User: svc_CBS_RO already exists.  Not creating and moving to next statement'
End

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'livedatauser')
BEGIN
PRINT 'Add User: livedatauser is already created in Master.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
END
ELSE
BEGIN
create user livedatauser from login livedatauser
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
PRINT 'Add User: livedatauser successfully created in Master.'
END


PRINT 'Granting view defintion to UCCE Symmetric Key to livedatauser user'
GRANT VIEW DEFINITION ON CERTIFICATE::UCCESymmetricKeyCertificate TO livedatauser
GRANT VIEW DEFINITION ON SYMMETRIC KEY::UCCESymmetricKey TO livedatauser
GRANT CONTROL ON CERTIFICATE::UCCESymmetricKeyCertificate TO livedatauser
PRINT 'Done granting view defintion to UCCE Symmetric Key to livedatauser user'

PRINT 'Granting view defintion to UCCE Symmetric Key to ece user'
GRANT VIEW DEFINITION ON CERTIFICATE::UCCESymmetricKeyCertificate TO ece
GRANT VIEW DEFINITION ON SYMMETRIC KEY::UCCESymmetricKey TO ece
GRANT CONTROL ON CERTIFICATE::UCCESymmetricKeyCertificate TO ece
PRINT 'Done granting view defintion to UCCE Symmetric Key to ece user'


--------------HDS STUFF-----------------------------

USE hc061_hds

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'livedatauser')
BEGIN
PRINT 'Add User: livedatauser is already created in HDS.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
EXEC sp_addrolemember N'db_datawriter', N'livedatauser'
EXEC sp_addrolemember N'db_ddladmin', N'livedatauser'
EXEC sp_addrolemember N'db_owner', N'livedatauser'
EXEC sp_addrolemember N'db_securityadmin', N'livedatauser'
END
ELSE
BEGIN
create user livedatauser from login livedatauser
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
EXEC sp_addrolemember N'db_datawriter', N'livedatauser'
EXEC sp_addrolemember N'db_ddladmin', N'livedatauser'
EXEC sp_addrolemember N'db_owner', N'livedatauser'
EXEC sp_addrolemember N'db_securityadmin', N'livedatauser'
PRINT 'Add User: livedatauser successfully created in HDS.'
END

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'cuic')
BEGIN
PRINT 'Add User: cuic is already created in HDS.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'cuic'
END
ELSE
BEGIN
create user cuic from login cuic
EXEC sp_addrolemember N'db_datareader', N'cuic'
PRINT 'Add User: cuic successfully created in HDS.'
END

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'svc_CBS_RO')
BEGIN
PRINT 'Add User: svc_CBS_RO is already created in HDS.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'svc_CBS_RO'
END
ELSE
BEGIN
create user svc_CBS_RO from login svc_CBS_RO
EXEC sp_addrolemember N'db_datareader', N'svc_CBS_RO'
PRINT 'Add User: svc_CBS_RO successfully created in HDS.'
END


-----------AWDB STUFF----------------

USE hc061_awdb

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'livedatauser')
BEGIN
PRINT 'Add User: livedatauser is already created in AW DB.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
EXEC sp_addrolemember N'db_datawriter', N'livedatauser'
EXEC sp_addrolemember N'db_ddladmin', N'livedatauser'
EXEC sp_addrolemember N'db_owner', N'livedatauser'
EXEC sp_addrolemember N'db_securityadmin', N'livedatauser'
END
ELSE
BEGIN
create user livedatauser from login livedatauser
EXEC sp_addrolemember N'db_datareader', N'livedatauser'
EXEC sp_addrolemember N'db_datawriter', N'livedatauser'
EXEC sp_addrolemember N'db_ddladmin', N'livedatauser'
EXEC sp_addrolemember N'db_owner', N'livedatauser'
EXEC sp_addrolemember N'db_securityadmin', N'livedatauser'
PRINT 'Add User: livedatauser successfully created in AW DB.'
END

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'cuic')
BEGIN
PRINT 'Add User: cuic is already created in AW DB.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'cuic'
END
ELSE
BEGIN
create user cuic from login cuic
EXEC sp_addrolemember N'db_datareader', N'cuic'
PRINT 'Add User: cuic successfully created in AW DB.'
END

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'svc_CBS_RO')
BEGIN
PRINT 'Add User: svc_CBS_RO is already created in AW DB.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'svc_CBS_RO'
END
ELSE
BEGIN
create user svc_CBS_RO from login svc_CBS_RO
EXEC sp_addrolemember N'db_datareader', N'svc_CBS_RO'
PRINT 'Add User: svc_CBS_RO successfully created in AW DB.'
END

IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'ece')
BEGIN
PRINT 'Add User: ece is already created in AWDB.  Going to add permissions just to be sure'
EXEC sp_addrolemember N'db_datareader', N'ece'
END
ELSE
BEGIN
create user ece from login ece
EXEC sp_addrolemember N'db_datareader', N'ece'
PRINT 'Add User: ece successfully created in AWDB.'
END