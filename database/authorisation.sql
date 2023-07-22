create table "security".user_info
(
user_id text,
level integer,
groups integer[],
primary key (user_id)
)
;

create table "security".group_info (
	group_id integer not null,
	group_name text null,
	"level" integer null,
	primary key (group_id)
)
;

insert into "security".group_info 
values
(1, 'super', 1),
(2, 'normal', 2)
;

insert into "security".user_info 
values
('richard', 1, '{1}'),
('william', 2, '{2}'),
('ashay', 3, '{1,2}'),
('mohammed', 1, '{2}'),
('jacques', 2, '{}')
;



-- lineitem preparation

-- take samples from the original table
drop table if exists lineitem_group_1;
create table lineitem_group_1 as
select l_orderkey,
l_partkey,
l_suppkey,
l_linenumber,
l_quantity,
l_extendedprice,
l_discount,
l_tax,
l_returnflag,
l_linestatus,
l_shipdate,
l_commitdate,
l_receiptdate,
l_shipinstruct,
l_shipmode,
l_comment, 
{1} groups from lineitem TABLESAMPLE SYSTEM (60)
;

drop table if exists lineitem_group_2;
create table lineitem_group_2 as
select l_orderkey,
l_partkey,
l_suppkey,
l_linenumber,
l_quantity,
l_extendedprice,
l_discount,
l_tax,
l_returnflag,
l_linestatus,
l_shipdate,
l_commitdate,
l_receiptdate,
l_shipinstruct,
l_shipmode,
l_comment, 
{2} groups from lineitem TABLESAMPLE SYSTEM (40)
;

drop table if exists lineitem_group_3;
create table lineitem_group_3 as
select l_orderkey,
l_partkey,
l_suppkey,
l_linenumber,
l_quantity,
l_extendedprice,
l_discount,
l_tax,
l_returnflag,
l_linestatus,
l_shipdate,
l_commitdate,
l_receiptdate,
l_shipinstruct,
l_shipmode,
l_comment, 
{1,2} groups from lineitem TABLESAMPLE SYSTEM (20)
;

-- delete duplicate keys from group 1 and 2 based on group 2 and 3
delete from lineitem_group_1
where (l_orderkey, l_linenumber) in (select l_orderkey, l_linenumber from lineitem_group_2)
;

delete from lineitem_group_1
where (l_orderkey, l_linenumber) in (select l_orderkey, l_linenumber from lineitem_group_3)
;

delete from lineitem_group_2
where (l_orderkey, l_linenumber) in (select l_orderkey, l_linenumber from lineitem_group_3)
;

-- copy the table for safe keeping, execute once, so no drop table here
create table lineitem_orig as
select * from lineitem
;

select count(*) from lineitem_orig;
select count(*) from lineitem;

update lineitem i
set groups = n.groups
from (
select * from lineitem_group_1
union all
select * from lineitem_group_2
union all
select * from lineitem_group_3
) n
where i.l_orderkey = n.l_orderkey
and i.l_linenumber = n.l_linenumber
;

select count(*) from lineitem;

select groups, count(*) from lineitem
group by 1 
;
--{1}   1933232
--{1,2} 806504
--{2}   3057661
--NULL  203818



-- customer preparation

-- take samples from the original table
drop table if exists customer_group_1;
create table customer_group_1 as
select c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment
, '{1}'::integer[] groups from customer TABLESAMPLE SYSTEM (60)
;

drop table if exists customer_group_2;
create table customer_group_1 as
select c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment
, '{2}'::integer[] groups from customer TABLESAMPLE SYSTEM (40)
;

drop table if exists customer_group_1;
create table customer_group_1 as
select c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment
, '{1,2}'::integer[] groups from customer TABLESAMPLE SYSTEM (20)
;

-- copy the table for safe keeping, execute once, so no drop table here
create table customer_orig as
select * from customer
;

select count(*) from customer_orig;
select count(*) from customer;

update customer i
set groups = n.groups
from (
select * from customer_group_1
union all
select * from customer_group_2
union all
select * from customer_group_3
) n
where i.c_custkey = n.c_custkey
;

select count(*) from customer;

select groups, count(*) from customer
group by 1 
;
--{1} 81440
--{1,2}   14873
--{2} 53479
--NULL    208
