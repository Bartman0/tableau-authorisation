-- customer_masked: data masking of sensitive columns
create or replace
view public.customer_masked
as
select c.c_custkey
    , case
        when u.level <= 1 then c.c_name
        else 'xxx'
      end as c_name
    , case
            when u.level <= 1 then c.c_address
        else 'xxx'
      end as c_address
    , c.c_nationkey
    , case
        when u.level <= 1 then c.c_phone
        else '##########'
      end as c_phone
    , c.c_acctbal
    , c.c_mktsegment
    , case
        when u.level <= 2 then c.c_comment
        else '---'
      end as c_comment
    , c.groups
    , u.user_id
from
    customer c
join security.user_info u on
    c.groups && u.groups
;

select * from customer_masked cm
;

select * from "security".user_info ui 
;

select c_name, c_address, c_comment, c_phone, count(*) from customer_masked cm
where user_id = 'ashay'
group by 1, 2, 3, 4
;

select c_name, c_address, c_comment, c_phone, count(*) from customer_masked cm
where user_id = 'william'
group by 1, 2, 3, 4
;

select c_custkey, count(*) from customer_masked cm
where user_id = 'ashay'
group by 1
having count(*) > 1 
;

select c_custkey, count(*) from customer_masked cm
where user_id = 'william'
group by 1
having count(*) > 1 
;
