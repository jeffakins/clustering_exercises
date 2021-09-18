use zillow;

/* are there duplicate parcels in the predictions table? */
select parcelid, count(*)
from predictions_2017
group by parcelid
having count(*) > 1;

/* is this the case in the properties table? any duplicate parcels? */
select parcelid, count(*)
from properties_2017
group by parcelid
having count(*) > 1;


/* we need the latest transaction date for each parcelid */
select parcelid, max(transactiondate) as transactiondate
from predictions_2017
group by parcelid;

/* how can we confirm this removed the duplicates */
-- 1. how many rows did we start out with? 
select count(*) from predictions_2017; 
-- 77,614

-- 2. how many rows do we have when we group by parcelid? 
select count(*) from 
(select parcelid, max(transactiondate) as transactiondate
from predictions_2017
group by parcelid
) a
;
-- 77,414

-- we want the info from properties table and the date and logerror from the predictions table

-- 2. next I selected 2 columns from the primary table (properties_2017) and inner joined with the txn date subquery
select 	prop.parcelid, 
			prop.airconditioningtypeid,
            ac.airconditioningdesc,-- 4. finally I did a left join with the airconditioning table to get the description. 
            txn.transactiondate, 
            pred.logerror -- 3.i joined with the predictions table again to get the log error that is associated with the parcel AND transaction date
            -- (see join below labeled #3)
from properties_2017 prop
join 
	(
    -- 1. this is what i did first...create a dataset with each parcelid and their last transaction date. 
    select parcelid, max(transactiondate) as transactiondate
	from predictions_2017
	group by parcelid
	) as txn on prop.parcelid = txn.parcelid  -- using(parcelid)

-- # 3:     
join predictions_2017 as pred  on prop.parcelid = pred.parcelid and pred.transactiondate = txn.transactiondate -- using(parcelid, transactiondate)

-- #4: left join otherwise we would have dropped a TON of rows due to all the nulls 
left join airconditioningtype as ac on prop.airconditioningtypeid = ac.airconditioningtypeid
;

/* i can verify we have the correct number of rows by wrapping the entire query in a count */

select count(*) from 
(
-- 2. next I selected 2 columns from the primary table (properties_2017) and inner joined with the txn date subquery
			select 	prop.parcelid, 
						prop.airconditioningtypeid,
						ac.airconditioningdesc,-- 4. finally I did a left join with the airconditioning table to get the description. 
						txn.transactiondate, 
						pred.logerror -- 3.i joined with the predictions table again to get the log error that is associated with the parcel AND transaction date
						-- (see join below labeled #3)
			from properties_2017 prop
			join 
				(
				-- 1. this is what i did first...create a dataset with each parcelid and their last transaction date. 
				select parcelid, max(transactiondate) as transactiondate
				from predictions_2017
				group by parcelid
				) as txn on prop.parcelid = txn.parcelid  -- using(parcelid)

			-- # 3:     
			join predictions_2017 as pred  on prop.parcelid = pred.parcelid and pred.transactiondate = txn.transactiondate -- using(parcelid, transactiondate)

			-- #4: left join otherwise we would have dropped a TON of rows due to all the nulls 
			left join airconditioningtype as ac on prop.airconditioningtypeid = ac.airconditioningtypeid
) AS a -- because subqueries need to be aliased. 
;

select * from predictions_2017
where parcelid = 11721753;