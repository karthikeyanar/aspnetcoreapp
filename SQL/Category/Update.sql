UPDATE [dbo].[Category]
   SET [CategoryName] = @CategoryName
      ,[IsBookMark] = @IsBookMark
      ,[IsArchive] = @IsArchive
 WHERE [CategoryID] = @CategoryID


