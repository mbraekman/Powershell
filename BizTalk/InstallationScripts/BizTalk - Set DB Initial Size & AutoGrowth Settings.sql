ALTER DATABASE BizTalkMsgBoxDb MODIFY FILE (NAME = BizTalkMsgBoxDb , SIZE = 2GB , FILEGROWTH = 100MB)
GO
ALTER DATABASE BizTalkMsgBoxDb MODIFY FILE (NAME = BizTalkMsgBoxDb_log , SIZE =  2GB , FILEGROWTH = 100MB)
GO


ALTER DATABASE BizTalkDTADb MODIFY FILE (NAME = BizTalkDTADb , SIZE = 2GB , FILEGROWTH = 100MB)
GO
ALTER DATABASE BizTalkDTADb MODIFY FILE (NAME = BizTalkDTADb_log , SIZE =  1GB , FILEGROWTH = 100MB)
GO


ALTER DATABASE BAMPrimaryImport MODIFY FILE (NAME = BAMPrimaryImport , SIZE = 250MB , FILEGROWTH = 100MB)
GO
ALTER DATABASE BAMPrimaryImport MODIFY FILE (NAME = BAMPrimaryImport_log , SIZE =  50MB , FILEGROWTH = 10MB)
GO


ALTER DATABASE BizTalkRuleEngineDb MODIFY FILE ( NAME = BizTalkRuleEngineDb , FILEGROWTH = 1024KB )
GO
ALTER DATABASE BizTalkRuleEngineDb MODIFY FILE ( NAME = BizTalkRuleEngineDb_log , FILEGROWTH = 1024KB )
GO


ALTER DATABASE BizTalkMgmtdb MODIFY FILE (NAME = BizTalkMgmtDb , SIZE = 512MB , FILEGROWTH = 100MB)
GO
ALTER DATABASE BizTalkMgmtdb MODIFY FILE (NAME = BizTalkMgmtDb_log , SIZE =  512MB , FILEGROWTH = 100MB)
GO


ALTER DATABASE SSODB MODIFY FILE (NAME = SSODB , SIZE = 512MB , FILEGROWTH = 100MB)
GO
ALTER DATABASE SSODB MODIFY FILE (NAME = SSODB_log , SIZE =  512MB , FILEGROWTH = 100MB)
GO


ALTER DATABASE BAMArchive MODIFY FILE (NAME = BAMArchive , SIZE = 70MB , FILEGROWTH = 10MB)
GO
ALTER DATABASE BAMArchive MODIFY FILE (NAME = BAMArchive_log , SIZE =  200MB , FILEGROWTH = 10MB)
GO


