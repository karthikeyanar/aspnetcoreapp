--declare @companyID int;
--declare @date date;
--declare @open decimal(19,4);
--declare @low decimal(19,4);
--declare @high decimal(19,4);
--declare @close decimal(19,4);
--declare @prevClose decimal(19,4);
--set @companyID = 3;
--set @date = '2019-01-01';
declare @cnt int;
select @cnt = isnull(count(*),0) from CompanyPriceHistory where CompanyID = @companyID and [Date] = @date;

if isnull(@cnt,0) <= 0
	begin
		INSERT INTO [dbo].[CompanyPriceHistory]
					([CompanyID]
					,[Date]
					,[Open]
					,[Low]
					,[High]
					,[Close]
					,[PrevClose]
					,[OriginalOpen]
					,[OriginalLow]
					,[OriginalHigh]
					,[OriginalPrevClose]
					,[OriginalClose])
				VALUES
					(@companyID
					,@date
					,@open
					,@low
					,@high
					,@close
					,@prevClose
					,@open
					,@low
					,@high
					,@close
					,@prevClose
					)
	end
else
	begin
		UPDATE [dbo].[CompanyPriceHistory]
		   SET [Open] = @open
			  ,[Low] = @low
			  ,[High] = @high
			  ,[Close] = @close
			  ,[PrevClose] = @prevClose
			  ,[OriginalOpen] = @open
			  ,[OriginalLow] = @low
			  ,[OriginalHigh] = @high
			  ,[OriginalPrevClose] = @close
			  ,[OriginalClose] = @prevClose
		 WHERE CompanyID = @companyID and [Date] = @date
	end



