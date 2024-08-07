-- Table: public.store

-- DROP TABLE IF EXISTS public.store;

CREATE TABLE IF NOT EXISTS public.store
(
    storeid integer NOT NULL DEFAULT nextval('store_storeid_seq'::regclass),
    storename character varying(50) COLLATE pg_catalog."default",
    location character varying(100) COLLATE pg_catalog."default",
    storage numeric(10,2),
    contactinformation text COLLATE pg_catalog."default",
    CONSTRAINT store_pkey PRIMARY KEY (storeid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.store
    OWNER to postgres;

-- Table: public.role

-- DROP TABLE IF EXISTS public.role;

CREATE TABLE IF NOT EXISTS public.role
(
    roleid integer NOT NULL DEFAULT nextval('role_roleid_seq'::regclass),
    rolename character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT role_pkey PRIMARY KEY (roleid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.role
    OWNER to postgres;

-- Table: public.employee

-- DROP TABLE IF EXISTS public.employee;

CREATE TABLE IF NOT EXISTS public.employee
(
    employeeid integer NOT NULL DEFAULT nextval('employee_employeeid_seq'::regclass),
    storeid integer,
    roleid integer,
    firstname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    lastname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    email character varying(50) COLLATE pg_catalog."default" NOT NULL,
    hiredate date,
    status character varying(20) COLLATE pg_catalog."default",
    CONSTRAINT employee_pkey PRIMARY KEY (employeeid),
    CONSTRAINT employee_roleid_fkey FOREIGN KEY (roleid)
        REFERENCES public.role (roleid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT employee_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.employee
    OWNER to postgres;

-- Table: public.shift

-- DROP TABLE IF EXISTS public.shift;

CREATE TABLE IF NOT EXISTS public.shift
(
    shiftid integer NOT NULL DEFAULT nextval('shift_shiftid_seq'::regclass),
    employeeid integer,
    storeid integer,
    hourlypay numeric(8,2),
    shiftstart timestamp without time zone,
    shiftend timestamp without time zone,
    shiftdate date,
    CONSTRAINT shift_pkey PRIMARY KEY (shiftid),
    CONSTRAINT shift_employeeid_fkey FOREIGN KEY (employeeid)
        REFERENCES public.employee (employeeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT shift_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT shift_hourlypay_check CHECK (hourlypay >= 0::numeric)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.shift
    OWNER to postgres;

-- Table: public.vendor

-- DROP TABLE IF EXISTS public.vendor;

CREATE TABLE IF NOT EXISTS public.vendor
(
    vendorid integer NOT NULL DEFAULT nextval('vendor_vendorid_seq'::regclass),
    vendorname character varying(100) COLLATE pg_catalog."default",
    contactinformation text COLLATE pg_catalog."default",
    CONSTRAINT vendor_pkey PRIMARY KEY (vendorid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.vendor
    OWNER to postgres;

-- Table: public.product

-- DROP TABLE IF EXISTS public.product;

CREATE TABLE IF NOT EXISTS public.product
(
    productid integer NOT NULL DEFAULT nextval('product_productid_seq'::regclass),
    productname character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT product_pkey PRIMARY KEY (productid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.product
    OWNER to postgres;

-- Table: public.inventory

-- DROP TABLE IF EXISTS public.inventory;

CREATE TABLE IF NOT EXISTS public.inventory
(
    storeid integer NOT NULL,
    productid integer NOT NULL,
    totalquantity integer,
    lastupdate date,
    CONSTRAINT inventory_pkey PRIMARY KEY (storeid, productid),
    CONSTRAINT inventory_productid_fkey FOREIGN KEY (productid)
        REFERENCES public.product (productid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT inventory_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT inventory_totalquantity_check CHECK (totalquantity >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.inventory
    OWNER to postgres;

-- Table: public.sale

-- DROP TABLE IF EXISTS public.sale;

CREATE TABLE IF NOT EXISTS public.sale
(
    saleid integer NOT NULL DEFAULT nextval('sale_saleid_seq'::regclass),
    storeid integer,
    totalitem integer,
    saledate timestamp without time zone,
    CONSTRAINT sale_pkey PRIMARY KEY (saleid),
    CONSTRAINT sale_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT sale_totalitem_check CHECK (totalitem >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sale
    OWNER to postgres;

-- Table: public.receipt

-- DROP TABLE IF EXISTS public.receipt;

CREATE TABLE IF NOT EXISTS public.receipt
(
    saleid integer NOT NULL,
    productid integer NOT NULL,
    price numeric(10,2),
    quantity integer,
    CONSTRAINT receipt_pkey PRIMARY KEY (saleid, productid),
    CONSTRAINT receipt_productid_fkey FOREIGN KEY (productid)
        REFERENCES public.product (productid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT receipt_saleid_fkey FOREIGN KEY (saleid)
        REFERENCES public.sale (saleid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT receipt_quantity_check CHECK (quantity >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.receipt
    OWNER to postgres;

-- Table: public.department

-- DROP TABLE IF EXISTS public.department;

CREATE TABLE IF NOT EXISTS public.department
(
    departmentid integer NOT NULL DEFAULT nextval('department_departmentid_seq'::regclass),
    storeid integer,
    departmentname character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT department_pkey PRIMARY KEY (departmentid),
    CONSTRAINT department_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.department
    OWNER to postgres;

-- Table: public.budget

-- DROP TABLE IF EXISTS public.budget;

CREATE TABLE IF NOT EXISTS public.budget
(
    departmentid integer NOT NULL,
    fiscalyear integer NOT NULL,
    amount numeric(12,2),
    CONSTRAINT budget_pkey PRIMARY KEY (departmentid, fiscalyear),
    CONSTRAINT budget_departmentid_fkey FOREIGN KEY (departmentid)
        REFERENCES public.department (departmentid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.budget
    OWNER to postgres;

-- Table: public.expenses

-- DROP TABLE IF EXISTS public.expenses;

CREATE TABLE IF NOT EXISTS public.expenses
(
    expenseid integer NOT NULL DEFAULT nextval('expenses_expenseid_seq'::regclass),
    storeid integer,
    expensetype character varying(50) COLLATE pg_catalog."default",
    amount numeric(10,2),
    expensedate date,
    CONSTRAINT expenses_pkey PRIMARY KEY (expenseid),
    CONSTRAINT expenses_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.expenses
    OWNER to postgres;

-- Table: public.customerservice

-- DROP TABLE IF EXISTS public.customerservice;

CREATE TABLE IF NOT EXISTS public.customerservice
(
    interactionid integer NOT NULL DEFAULT nextval('customerservice_interactionid_seq'::regclass),
    saleid integer,
    employeeid integer,
    interactiontype character varying(50) COLLATE pg_catalog."default",
    interactiondate timestamp without time zone,
    resolutiondate timestamp without time zone,
    amount numeric(10,2),
    notes text COLLATE pg_catalog."default",
    CONSTRAINT customerservice_pkey PRIMARY KEY (interactionid),
    CONSTRAINT customerservice_employeeid_fkey FOREIGN KEY (employeeid)
        REFERENCES public.employee (employeeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT customerservice_saleid_fkey FOREIGN KEY (saleid)
        REFERENCES public.sale (saleid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.customerservice
    OWNER to postgres;

-- Table: public.supplychain

-- DROP TABLE IF EXISTS public.supplychain;

CREATE TABLE IF NOT EXISTS public.supplychain
(
    shipmentid integer NOT NULL DEFAULT nextval('supplychain_shipmentid_seq'::regclass),
    vendorid integer,
    storeid integer,
    productid integer,
    quantity integer,
    expirationdate date,
    shipmentdate timestamp without time zone,
    expectedarrivaldate timestamp without time zone,
    arrivaldate timestamp without time zone,
    CONSTRAINT supplychain_pkey PRIMARY KEY (shipmentid),
    CONSTRAINT supplychain_productid_fkey FOREIGN KEY (productid)
        REFERENCES public.product (productid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT supplychain_storeid_fkey FOREIGN KEY (storeid)
        REFERENCES public.store (storeid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT supplychain_vendorid_fkey FOREIGN KEY (vendorid)
        REFERENCES public.vendor (vendorid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT supplychain_quantity_check CHECK (quantity >= 0)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.supplychain
    OWNER to postgres;

-- Table: public.sales_by_date

-- DROP TABLE IF EXISTS public.sales_by_date;

CREATE TABLE IF NOT EXISTS public.sales_by_date
(
    "Date" date,
    sales_value double precision
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sales_by_date
    OWNER to postgres;

-- Table: public.top_Hour

-- DROP TABLE IF EXISTS public."top_Hour";

CREATE TABLE IF NOT EXISTS public."top_Hour"
(
    "Hour of Purchase" bigint,
    sales_value double precision
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."top_Hour"
    OWNER to postgres;