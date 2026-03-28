with stg_orders as (
    select * from {{ source('northwind', 'Orders') }}
),
stg_order_details as (
    select * from {{ source('northwind', 'Order_Details') }}
),
d_customer as (
    select * from {{ ref('dim_customer') }}
),
d_employee as (
    select * from {{ ref('dim_employee') }}
),
d_product as (
    select * from {{ ref('dim_product') }}
)

select
    o.orderid,
    c.customerkey,
    e.employeekey,
    replace(to_date(o.orderdate)::varchar, '-', '')::int as orderdatekey,
    p.productkey,
    od.quantity,
    od.quantity * od.unitprice as extendedpriceamount,
    (od.quantity * od.unitprice) * od.discount as discountamount,
    (od.quantity * od.unitprice) - ((od.quantity * od.unitprice) * od.discount) as soldamount
from stg_orders o
    join stg_order_details od
        on o.orderid = od.orderid
    left join d_customer c
        on o.customerid = c.customerid
    left join d_employee e
        on o.employeeid = e.employeeid
    left join d_product p
        on od.productid = p.productid