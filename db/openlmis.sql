--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: atomfeed; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA atomfeed;


ALTER SCHEMA atomfeed OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: getrgprogramsupplyline(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION getrgprogramsupplyline() RETURNS TABLE(snode text, name text, requisitiongroup text)
    LANGUAGE plpgsql
    AS $$
DECLARE
requisitionGroupQuery VARCHAR;
finalQuery            VARCHAR;
ultimateParentRecord  RECORD;
rowRG                 RECORD;
BEGIN
EXECUTE 'CREATE TEMP TABLE rg_supervisory_node (
requisitionGroupId INTEGER,
requisitionGroup TEXT,
supervisoryNodeId INTEGER,
sNode TEXT,
programId INTEGER,
name TEXT,
ultimateParentId INTEGER
) ON COMMIT DROP';
requisitionGroupQuery := 'SELECT RG.id, RG.code || '' '' || RG.name as requisitionGroup, RG.supervisoryNodeId, RGPS.programId, pg.name
FROM requisition_groups AS RG INNER JOIN requisition_group_program_schedules AS RGPS ON RG.id = RGPS.requisitionGroupId
INNER JOIN programs pg ON pg.id=RGPS.programid WHERE pg.active=true AND pg.push=false';
FOR rowRG IN EXECUTE requisitionGroupQuery LOOP
WITH RECURSIVE supervisoryNodesRec(id, sName, parentId, depth, path) AS
(
SELECT
superNode.id,
superNode.code || ' ' || superNode.name :: TEXT AS sName,
superNode.parentId,
1 :: INT                                        AS depth,
superNode.id :: TEXT                            AS path
FROM supervisory_nodes superNode
WHERE id IN (rowRG.supervisoryNodeId)
UNION
SELECT
sn.id,
sn.code || ' ' || sn.name :: TEXT AS sName,
sn.parentId,
snRec.depth + 1                   AS depth,
(snRec.path)
FROM supervisory_nodes sn
JOIN supervisoryNodesRec snRec
ON sn.id = snRec.parentId
)
SELECT
INTO ultimateParentRecord path  AS id,
id    AS ultimateParentId,
sName AS sNode
FROM supervisoryNodesRec
WHERE depth = (SELECT
max(depth)
FROM supervisoryNodesRec);
EXECUTE
'INSERT INTO rg_supervisory_node VALUES (' || rowRG.id || ',' ||
quote_literal(rowRG.requisitionGroup) || ',' || rowRG.supervisoryNodeId ||
',' || quote_literal(ultimateParentRecord.sNode) || ',' || rowRG.programId
|| ',' || quote_literal(rowRG.name) || ',' ||
ultimateParentRecord.ultimateParentId || ')';
END LOOP;
finalQuery := 'SELECT
RGS.snode            AS SupervisoryNode,
RGS.name             AS ProgramName,
RGS.requisitiongroup AS RequisitionGroup
FROM rg_supervisory_node AS RGS
WHERE NOT EXISTS
(SELECT
*
FROM supply_lines
INNER JOIN facilities f
ON f.id = supply_lines.supplyingFacilityId
WHERE supply_lines.supervisorynodeid = RGS.ultimateparentid AND
RGS.programid = supply_lines.programid AND f.enabled = TRUE)
ORDER BY SupervisoryNode, ProgramName, RequisitionGroup';
RETURN QUERY EXECUTE finalQuery;
END;
$$;


ALTER FUNCTION public.getrgprogramsupplyline() OWNER TO postgres;

SET search_path = atomfeed, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: chunking_history; Type: TABLE; Schema: atomfeed; Owner: postgres; Tablespace: 
--

CREATE TABLE chunking_history (
    id integer NOT NULL,
    chunk_length bigint,
    start bigint NOT NULL
);


ALTER TABLE atomfeed.chunking_history OWNER TO postgres;

--
-- Name: chunking_history_id_seq; Type: SEQUENCE; Schema: atomfeed; Owner: postgres
--

CREATE SEQUENCE chunking_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE atomfeed.chunking_history_id_seq OWNER TO postgres;

--
-- Name: chunking_history_id_seq; Type: SEQUENCE OWNED BY; Schema: atomfeed; Owner: postgres
--

ALTER SEQUENCE chunking_history_id_seq OWNED BY chunking_history.id;


--
-- Name: event_records; Type: TABLE; Schema: atomfeed; Owner: postgres; Tablespace: 
--

CREATE TABLE event_records (
    id integer NOT NULL,
    uuid character varying(40),
    title character varying(255),
    "timestamp" timestamp without time zone DEFAULT now(),
    uri character varying(255),
    object character varying(5000),
    category character varying(255)
);


ALTER TABLE atomfeed.event_records OWNER TO postgres;

--
-- Name: event_records_id_seq; Type: SEQUENCE; Schema: atomfeed; Owner: postgres
--

CREATE SEQUENCE event_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE atomfeed.event_records_id_seq OWNER TO postgres;

--
-- Name: event_records_id_seq; Type: SEQUENCE OWNED BY; Schema: atomfeed; Owner: postgres
--

ALTER SEQUENCE event_records_id_seq OWNED BY event_records.id;


SET search_path = public, pg_catalog;

--
-- Name: adult_coverage_opened_vial_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE adult_coverage_opened_vial_line_items (
    id integer NOT NULL,
    facilityvisitid integer NOT NULL,
    productvialname character varying(255) NOT NULL,
    openedvials integer,
    packsize integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.adult_coverage_opened_vial_line_items OWNER TO postgres;

--
-- Name: adult_coverage_opened_vial_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE adult_coverage_opened_vial_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adult_coverage_opened_vial_line_items_id_seq OWNER TO postgres;

--
-- Name: adult_coverage_opened_vial_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE adult_coverage_opened_vial_line_items_id_seq OWNED BY adult_coverage_opened_vial_line_items.id;


--
-- Name: budget_configuration; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE budget_configuration (
    headerinfile boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.budget_configuration OWNER TO postgres;

--
-- Name: budget_file_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE budget_file_columns (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    datafieldlabel character varying(150),
    "position" integer,
    include boolean NOT NULL,
    mandatory boolean NOT NULL,
    datepattern character varying(25),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.budget_file_columns OWNER TO postgres;

--
-- Name: budget_file_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE budget_file_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budget_file_columns_id_seq OWNER TO postgres;

--
-- Name: budget_file_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE budget_file_columns_id_seq OWNED BY budget_file_columns.id;


--
-- Name: budget_file_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE budget_file_info (
    id integer NOT NULL,
    filename character varying(200) NOT NULL,
    processingerror boolean DEFAULT false NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.budget_file_info OWNER TO postgres;

--
-- Name: budget_file_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE budget_file_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budget_file_info_id_seq OWNER TO postgres;

--
-- Name: budget_file_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE budget_file_info_id_seq OWNED BY budget_file_info.id;


--
-- Name: budget_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE budget_line_items (
    id integer NOT NULL,
    periodid integer NOT NULL,
    budgetfileid integer NOT NULL,
    perioddate timestamp without time zone NOT NULL,
    allocatedbudget numeric(20,2) NOT NULL,
    notes character varying(255),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    facilityid integer NOT NULL,
    programid integer NOT NULL
);


ALTER TABLE public.budget_line_items OWNER TO postgres;

--
-- Name: budget_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE budget_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budget_line_items_id_seq OWNER TO postgres;

--
-- Name: budget_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE budget_line_items_id_seq OWNED BY budget_line_items.id;


--
-- Name: child_coverage_opened_vial_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE child_coverage_opened_vial_line_items (
    id integer NOT NULL,
    facilityvisitid integer NOT NULL,
    productvialname character varying(255) NOT NULL,
    openedvials integer,
    packsize integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.child_coverage_opened_vial_line_items OWNER TO postgres;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    rnrid integer NOT NULL,
    commenttext character varying(250) NOT NULL,
    createdby integer NOT NULL,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: configurable_rnr_options; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE configurable_rnr_options (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    label character varying(200) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.configurable_rnr_options OWNER TO postgres;

--
-- Name: configurable_rnr_options_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE configurable_rnr_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configurable_rnr_options_id_seq OWNER TO postgres;

--
-- Name: configurable_rnr_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE configurable_rnr_options_id_seq OWNED BY configurable_rnr_options.id;


--
-- Name: coverage_product_vials; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE coverage_product_vials (
    id integer NOT NULL,
    vial character varying(255) NOT NULL,
    productcode character varying(50) NOT NULL,
    childcoverage boolean NOT NULL
);


ALTER TABLE public.coverage_product_vials OWNER TO postgres;

--
-- Name: coverage_product_vials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE coverage_product_vials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coverage_product_vials_id_seq OWNER TO postgres;

--
-- Name: coverage_product_vials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE coverage_product_vials_id_seq OWNED BY coverage_product_vials.id;


--
-- Name: coverage_target_group_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE coverage_target_group_products (
    id integer NOT NULL,
    targetgroupentity character varying(255) NOT NULL,
    productcode character varying(50) NOT NULL,
    childcoverage boolean NOT NULL
);


ALTER TABLE public.coverage_target_group_products OWNER TO postgres;

--
-- Name: coverage_vaccination_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE coverage_vaccination_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coverage_vaccination_products_id_seq OWNER TO postgres;

--
-- Name: coverage_vaccination_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE coverage_vaccination_products_id_seq OWNED BY coverage_target_group_products.id;


--
-- Name: delivery_zone_members; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE delivery_zone_members (
    id integer NOT NULL,
    deliveryzoneid integer NOT NULL,
    facilityid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.delivery_zone_members OWNER TO postgres;

--
-- Name: delivery_zone_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delivery_zone_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delivery_zone_members_id_seq OWNER TO postgres;

--
-- Name: delivery_zone_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delivery_zone_members_id_seq OWNED BY delivery_zone_members.id;


--
-- Name: delivery_zone_program_schedules; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE delivery_zone_program_schedules (
    id integer NOT NULL,
    deliveryzoneid integer NOT NULL,
    programid integer NOT NULL,
    scheduleid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.delivery_zone_program_schedules OWNER TO postgres;

--
-- Name: delivery_zone_program_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delivery_zone_program_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delivery_zone_program_schedules_id_seq OWNER TO postgres;

--
-- Name: delivery_zone_program_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delivery_zone_program_schedules_id_seq OWNED BY delivery_zone_program_schedules.id;


--
-- Name: delivery_zone_warehouses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE delivery_zone_warehouses (
    id integer NOT NULL,
    deliveryzoneid integer NOT NULL,
    warehouseid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.delivery_zone_warehouses OWNER TO postgres;

--
-- Name: delivery_zone_warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delivery_zone_warehouses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delivery_zone_warehouses_id_seq OWNER TO postgres;

--
-- Name: delivery_zone_warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delivery_zone_warehouses_id_seq OWNED BY delivery_zone_warehouses.id;


--
-- Name: delivery_zones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE delivery_zones (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.delivery_zones OWNER TO postgres;

--
-- Name: delivery_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE delivery_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.delivery_zones_id_seq OWNER TO postgres;

--
-- Name: delivery_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE delivery_zones_id_seq OWNED BY delivery_zones.id;


--
-- Name: refrigerator_readings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE refrigerator_readings (
    id integer NOT NULL,
    temperature numeric(4,1),
    functioningcorrectly character varying(1),
    lowalarmevents numeric(3,0),
    highalarmevents numeric(3,0),
    problemsincelasttime character varying(1),
    notes character varying(255),
    refrigeratorid integer NOT NULL,
    refrigeratorserialnumber character varying(30) NOT NULL,
    refrigeratorbrand character varying(20),
    refrigeratormodel character varying(20),
    facilityvisitid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.refrigerator_readings OWNER TO postgres;

--
-- Name: distribution_refrigerator_readings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE distribution_refrigerator_readings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distribution_refrigerator_readings_id_seq OWNER TO postgres;

--
-- Name: distribution_refrigerator_readings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE distribution_refrigerator_readings_id_seq OWNED BY refrigerator_readings.id;


--
-- Name: distributions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE distributions (
    id integer NOT NULL,
    deliveryzoneid integer NOT NULL,
    programid integer NOT NULL,
    periodid integer NOT NULL,
    status character varying(50),
    createdby integer NOT NULL,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.distributions OWNER TO postgres;

--
-- Name: distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distributions_id_seq OWNER TO postgres;

--
-- Name: distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE distributions_id_seq OWNED BY distributions.id;


--
-- Name: dosage_units; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dosage_units (
    id integer NOT NULL,
    code character varying(20),
    displayorder integer,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.dosage_units OWNER TO postgres;

--
-- Name: dosage_units_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dosage_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dosage_units_id_seq OWNER TO postgres;

--
-- Name: dosage_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE dosage_units_id_seq OWNED BY dosage_units.id;


--
-- Name: email_notifications; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE email_notifications (
    id integer NOT NULL,
    receiver character varying(250) NOT NULL,
    subject text,
    content text,
    sent boolean DEFAULT false NOT NULL,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.email_notifications OWNER TO postgres;

--
-- Name: email_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE email_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.email_notifications_id_seq OWNER TO postgres;

--
-- Name: email_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE email_notifications_id_seq OWNED BY email_notifications.id;


--
-- Name: epi_inventory_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE epi_inventory_line_items (
    id integer NOT NULL,
    productname character varying(250),
    idealquantity numeric,
    existingquantity numeric(7,0),
    spoiledquantity numeric(7,0),
    deliveredquantity numeric(7,0),
    facilityvisitid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    productdisplayorder integer,
    programproductid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.epi_inventory_line_items OWNER TO postgres;

--
-- Name: epi_inventory_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE epi_inventory_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epi_inventory_line_items_id_seq OWNER TO postgres;

--
-- Name: epi_inventory_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE epi_inventory_line_items_id_seq OWNED BY epi_inventory_line_items.id;


--
-- Name: epi_use_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE epi_use_line_items (
    id integer NOT NULL,
    productgroupid integer,
    productgroupname character varying(250),
    stockatfirstofmonth numeric(7,0),
    received numeric(7,0),
    distributed numeric(7,0),
    loss numeric(7,0),
    stockatendofmonth numeric(7,0),
    expirationdate character varying(10),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    facilityvisitid integer NOT NULL
);


ALTER TABLE public.epi_use_line_items OWNER TO postgres;

--
-- Name: epi_use_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE epi_use_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epi_use_line_items_id_seq OWNER TO postgres;

--
-- Name: epi_use_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE epi_use_line_items_id_seq OWNED BY epi_use_line_items.id;


--
-- Name: facilities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facilities (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    gln character varying(30),
    mainphone character varying(20),
    fax character varying(20),
    address1 character varying(50),
    address2 character varying(50),
    geographiczoneid integer NOT NULL,
    typeid integer NOT NULL,
    catchmentpopulation integer,
    latitude numeric(8,5),
    longitude numeric(8,5),
    altitude numeric(8,4),
    operatedbyid integer,
    coldstoragegrosscapacity numeric(8,4),
    coldstoragenetcapacity numeric(8,4),
    suppliesothers boolean,
    sdp boolean NOT NULL,
    online boolean,
    satellite boolean,
    parentfacilityid integer,
    haselectricity boolean,
    haselectronicscc boolean,
    haselectronicdar boolean,
    active boolean NOT NULL,
    golivedate date NOT NULL,
    godowndate date,
    comment text,
    enabled boolean NOT NULL,
    virtualfacility boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facilities OWNER TO postgres;

--
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facilities_id_seq OWNER TO postgres;

--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facilities_id_seq OWNED BY facilities.id;


--
-- Name: facility_approved_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_approved_products (
    id integer NOT NULL,
    facilitytypeid integer NOT NULL,
    programproductid integer NOT NULL,
    maxmonthsofstock numeric(4,2) NOT NULL,
    minmonthsofstock numeric(4,2),
    eop numeric(4,2),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facility_approved_products OWNER TO postgres;

--
-- Name: facility_approved_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_approved_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_approved_products_id_seq OWNER TO postgres;

--
-- Name: facility_approved_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_approved_products_id_seq OWNED BY facility_approved_products.id;


--
-- Name: facility_ftp_details; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_ftp_details (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    serverhost character varying(100) NOT NULL,
    serverport character varying(10) NOT NULL,
    username character varying(100) NOT NULL,
    password character varying(50) NOT NULL,
    localfolderpath character varying(255) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facility_ftp_details OWNER TO postgres;

--
-- Name: facility_ftp_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_ftp_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_ftp_details_id_seq OWNER TO postgres;

--
-- Name: facility_ftp_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_ftp_details_id_seq OWNED BY facility_ftp_details.id;


--
-- Name: facility_operators; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_operators (
    id integer NOT NULL,
    code character varying NOT NULL,
    text character varying(20),
    displayorder integer,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facility_operators OWNER TO postgres;

--
-- Name: facility_operators_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_operators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_operators_id_seq OWNER TO postgres;

--
-- Name: facility_operators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_operators_id_seq OWNED BY facility_operators.id;


--
-- Name: facility_program_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_program_products (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    programproductid integer NOT NULL,
    overriddenisa integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facility_program_products OWNER TO postgres;

--
-- Name: facility_program_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_program_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_program_products_id_seq OWNER TO postgres;

--
-- Name: facility_program_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_program_products_id_seq OWNED BY facility_program_products.id;


--
-- Name: facility_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_types (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(30) NOT NULL,
    description character varying(250),
    levelid integer,
    nominalmaxmonth integer NOT NULL,
    nominaleop numeric(4,2) NOT NULL,
    displayorder integer,
    active boolean,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.facility_types OWNER TO postgres;

--
-- Name: facility_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_types_id_seq OWNER TO postgres;

--
-- Name: facility_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_types_id_seq OWNED BY facility_types.id;


--
-- Name: facility_visits; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_visits (
    id integer NOT NULL,
    distributionid integer,
    facilityid integer,
    confirmedbyname character varying(50),
    confirmedbytitle character varying(50),
    verifiedbyname character varying(50),
    verifiedbytitle character varying(50),
    observations text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    synced boolean DEFAULT false,
    modifieddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    visited boolean,
    visitdate timestamp without time zone,
    vehicleid character varying(20),
    facilitycatchmentpopulation integer,
    reasonfornotvisiting character varying(50),
    otherreasondescription character varying(255)
);


ALTER TABLE public.facility_visits OWNER TO postgres;

--
-- Name: facility_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_visits_id_seq OWNER TO postgres;

--
-- Name: facility_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_visits_id_seq OWNED BY facility_visits.id;


--
-- Name: fulfillment_role_assignments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fulfillment_role_assignments (
    userid integer NOT NULL,
    roleid integer NOT NULL,
    facilityid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.fulfillment_role_assignments OWNER TO postgres;

--
-- Name: full_coverages; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE full_coverages (
    id integer NOT NULL,
    femalehealthcenter numeric(7,0),
    femaleoutreach numeric(7,0),
    maleoutreach numeric(7,0),
    malehealthcenter numeric(7,0),
    facilityvisitid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.full_coverages OWNER TO postgres;

--
-- Name: geographic_levels; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geographic_levels (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(250) NOT NULL,
    levelnumber integer NOT NULL,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.geographic_levels OWNER TO postgres;

--
-- Name: geographic_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geographic_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geographic_levels_id_seq OWNER TO postgres;

--
-- Name: geographic_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geographic_levels_id_seq OWNED BY geographic_levels.id;


--
-- Name: geographic_zones; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geographic_zones (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(250) NOT NULL,
    levelid integer NOT NULL,
    parentid integer,
    catchmentpopulation integer,
    latitude numeric(8,5),
    longitude numeric(8,5),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.geographic_zones OWNER TO postgres;

--
-- Name: geographic_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geographic_zones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geographic_zones_id_seq OWNER TO postgres;

--
-- Name: geographic_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geographic_zones_id_seq OWNED BY geographic_zones.id;


--
-- Name: losses_adjustments_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE losses_adjustments_types (
    name character varying(50) NOT NULL,
    description character varying(100) NOT NULL,
    additive boolean,
    displayorder integer,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.losses_adjustments_types OWNER TO postgres;

--
-- Name: master_regimen_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE master_regimen_columns (
    name character varying(100) NOT NULL,
    label character varying(100) NOT NULL,
    visible boolean NOT NULL,
    datatype character varying(50) NOT NULL
);


ALTER TABLE public.master_regimen_columns OWNER TO postgres;

--
-- Name: master_rnr_column_options; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE master_rnr_column_options (
    id integer NOT NULL,
    masterrnrcolumnid integer,
    rnroptionid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.master_rnr_column_options OWNER TO postgres;

--
-- Name: master_rnr_column_options_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE master_rnr_column_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.master_rnr_column_options_id_seq OWNER TO postgres;

--
-- Name: master_rnr_column_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE master_rnr_column_options_id_seq OWNED BY master_rnr_column_options.id;


--
-- Name: master_rnr_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE master_rnr_columns (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    "position" integer NOT NULL,
    source character varying(1) NOT NULL,
    sourceconfigurable boolean NOT NULL,
    label character varying(200),
    formula character varying(200),
    indicator character varying(50) NOT NULL,
    used boolean NOT NULL,
    visible boolean NOT NULL,
    mandatory boolean NOT NULL,
    description character varying(250),
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.master_rnr_columns OWNER TO postgres;

--
-- Name: master_rnr_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE master_rnr_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.master_rnr_columns_id_seq OWNER TO postgres;

--
-- Name: master_rnr_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE master_rnr_columns_id_seq OWNED BY master_rnr_columns.id;


--
-- Name: opened_vial_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE opened_vial_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.opened_vial_line_items_id_seq OWNER TO postgres;

--
-- Name: opened_vial_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE opened_vial_line_items_id_seq OWNED BY child_coverage_opened_vial_line_items.id;


--
-- Name: order_configuration; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_configuration (
    fileprefix character varying(8),
    headerinfile boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.order_configuration OWNER TO postgres;

--
-- Name: order_file_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_file_columns (
    id integer NOT NULL,
    datafieldlabel character varying(50),
    nested character varying(50),
    keypath character varying(50),
    includeinorderfile boolean DEFAULT true NOT NULL,
    columnlabel character varying(50),
    format character varying(20),
    "position" integer NOT NULL,
    openlmisfield boolean DEFAULT false NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.order_file_columns OWNER TO postgres;

--
-- Name: order_file_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE order_file_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_file_columns_id_seq OWNER TO postgres;

--
-- Name: order_file_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE order_file_columns_id_seq OWNED BY order_file_columns.id;


--
-- Name: order_number_configuration; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE order_number_configuration (
    ordernumberprefix character varying(8),
    includeordernumberprefix boolean,
    includeprogramcode boolean,
    includesequencecode boolean,
    includernrtypesuffix boolean
);


ALTER TABLE public.order_number_configuration OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    shipmentid integer,
    status character varying(20) NOT NULL,
    ftpcomment character varying(50),
    supplylineid integer,
    createdby integer NOT NULL,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now(),
    ordernumber character varying(100) NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: pod; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pod (
    id integer NOT NULL,
    orderid integer NOT NULL,
    receiveddate timestamp without time zone DEFAULT now(),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    facilityid integer NOT NULL,
    programid integer NOT NULL,
    periodid integer NOT NULL,
    deliveredby character varying(100),
    receivedby character varying(100),
    ordernumber character varying(100) NOT NULL
);


ALTER TABLE public.pod OWNER TO postgres;

--
-- Name: pod_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pod_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pod_id_seq OWNER TO postgres;

--
-- Name: pod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pod_id_seq OWNED BY pod.id;


--
-- Name: pod_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE pod_line_items (
    id integer NOT NULL,
    podid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    quantityreceived integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    productname character varying(250),
    dispensingunit character varying(20),
    packstoship integer,
    quantityshipped integer,
    notes character varying(250),
    fullsupply boolean,
    productcategory character varying(100),
    productcategorydisplayorder integer,
    productdisplayorder integer,
    quantityreturned integer,
    replacedproductcode character varying(50)
);


ALTER TABLE public.pod_line_items OWNER TO postgres;

--
-- Name: pod_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE pod_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pod_line_items_id_seq OWNER TO postgres;

--
-- Name: pod_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE pod_line_items_id_seq OWNED BY pod_line_items.id;


--
-- Name: processing_periods; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE processing_periods (
    id integer NOT NULL,
    scheduleid integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    numberofmonths integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.processing_periods OWNER TO postgres;

--
-- Name: processing_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE processing_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.processing_periods_id_seq OWNER TO postgres;

--
-- Name: processing_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE processing_periods_id_seq OWNED BY processing_periods.id;


--
-- Name: processing_schedules; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE processing_schedules (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.processing_schedules OWNER TO postgres;

--
-- Name: processing_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE processing_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.processing_schedules_id_seq OWNER TO postgres;

--
-- Name: processing_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE processing_schedules_id_seq OWNED BY processing_schedules.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_categories (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    displayorder integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.product_categories OWNER TO postgres;

--
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_categories_id_seq OWNER TO postgres;

--
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_categories_id_seq OWNED BY product_categories.id;


--
-- Name: product_forms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_forms (
    id integer NOT NULL,
    code character varying(20),
    displayorder integer,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.product_forms OWNER TO postgres;

--
-- Name: product_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_forms_id_seq OWNER TO postgres;

--
-- Name: product_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_forms_id_seq OWNED BY product_forms.id;


--
-- Name: product_groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_groups (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(250) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.product_groups OWNER TO postgres;

--
-- Name: product_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_groups_id_seq OWNER TO postgres;

--
-- Name: product_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_groups_id_seq OWNED BY product_groups.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    alternateitemcode character varying(20),
    manufacturer character varying(100),
    manufacturercode character varying(30),
    manufacturerbarcode character varying(20),
    mohbarcode character varying(20),
    gtin character varying(20),
    type character varying(100),
    primaryname character varying(150) NOT NULL,
    fullname character varying(250),
    genericname character varying(100),
    alternatename character varying(100),
    description character varying(250),
    strength character varying(14),
    formid integer,
    dosageunitid integer,
    productgroupid integer,
    dispensingunit character varying(20) NOT NULL,
    dosesperdispensingunit smallint NOT NULL,
    packsize smallint NOT NULL,
    alternatepacksize smallint,
    storerefrigerated boolean,
    storeroomtemperature boolean,
    hazardous boolean,
    flammable boolean,
    controlledsubstance boolean,
    lightsensitive boolean,
    approvedbywho boolean,
    contraceptivecyp numeric(8,4),
    packlength numeric(8,4),
    packwidth numeric(8,4),
    packheight numeric(8,4),
    packweight numeric(8,4),
    packspercarton smallint,
    cartonlength numeric(8,4),
    cartonwidth numeric(8,4),
    cartonheight numeric(8,4),
    cartonsperpallet smallint,
    expectedshelflife smallint,
    specialstorageinstructions text,
    specialtransportinstructions text,
    active boolean NOT NULL,
    fullsupply boolean NOT NULL,
    tracer boolean NOT NULL,
    roundtozero boolean NOT NULL,
    archived boolean,
    packroundingthreshold smallint NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: program_product_isa; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_product_isa (
    id integer NOT NULL,
    whoratio numeric(6,3) NOT NULL,
    dosesperyear integer NOT NULL,
    wastagefactor numeric(6,3) NOT NULL,
    programproductid integer NOT NULL,
    bufferpercentage numeric(6,3) NOT NULL,
    minimumvalue integer,
    maximumvalue integer,
    adjustmentvalue integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_product_isa OWNER TO postgres;

--
-- Name: program_product_isa_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_product_isa_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_product_isa_id_seq OWNER TO postgres;

--
-- Name: program_product_isa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_product_isa_id_seq OWNED BY program_product_isa.id;


--
-- Name: program_product_price_history; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_product_price_history (
    id integer NOT NULL,
    programproductid integer NOT NULL,
    price numeric(20,2) DEFAULT 0,
    priceperdosage numeric(20,2) DEFAULT 0,
    source character varying(50),
    startdate timestamp without time zone DEFAULT now(),
    enddate timestamp without time zone DEFAULT now(),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_product_price_history OWNER TO postgres;

--
-- Name: program_product_price_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_product_price_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_product_price_history_id_seq OWNER TO postgres;

--
-- Name: program_product_price_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_product_price_history_id_seq OWNED BY program_product_price_history.id;


--
-- Name: program_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_products (
    id integer NOT NULL,
    programid integer NOT NULL,
    productid integer NOT NULL,
    dosespermonth integer NOT NULL,
    active boolean NOT NULL,
    currentprice numeric(20,2) DEFAULT 0,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    productcategoryid integer NOT NULL,
    displayorder integer
);


ALTER TABLE public.program_products OWNER TO postgres;

--
-- Name: program_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_products_id_seq OWNER TO postgres;

--
-- Name: program_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_products_id_seq OWNED BY program_products.id;


--
-- Name: program_regimen_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_regimen_columns (
    id integer NOT NULL,
    programid integer NOT NULL,
    name character varying(100) NOT NULL,
    label character varying(100) NOT NULL,
    visible boolean NOT NULL,
    datatype character varying(50) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_regimen_columns OWNER TO postgres;

--
-- Name: program_regimen_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_regimen_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_regimen_columns_id_seq OWNER TO postgres;

--
-- Name: program_regimen_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_regimen_columns_id_seq OWNED BY program_regimen_columns.id;


--
-- Name: program_rnr_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_rnr_columns (
    id integer NOT NULL,
    mastercolumnid integer NOT NULL,
    programid integer NOT NULL,
    label character varying(200) NOT NULL,
    visible boolean NOT NULL,
    "position" integer NOT NULL,
    source character varying(1),
    formulavalidationrequired boolean,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    rnroptionid integer
);


ALTER TABLE public.program_rnr_columns OWNER TO postgres;

--
-- Name: program_rnr_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_rnr_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_rnr_columns_id_seq OWNER TO postgres;

--
-- Name: program_rnr_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_rnr_columns_id_seq OWNED BY program_rnr_columns.id;


--
-- Name: programs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE programs (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50),
    description character varying(50),
    active boolean,
    templateconfigured boolean,
    regimentemplateconfigured boolean,
    budgetingapplies boolean DEFAULT false NOT NULL,
    usesdar boolean,
    push boolean DEFAULT false,
    sendfeed boolean DEFAULT false,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.programs OWNER TO postgres;

--
-- Name: programs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE programs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.programs_id_seq OWNER TO postgres;

--
-- Name: programs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE programs_id_seq OWNED BY programs.id;


--
-- Name: programs_supported; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE programs_supported (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    programid integer NOT NULL,
    startdate timestamp without time zone,
    active boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.programs_supported OWNER TO postgres;

--
-- Name: programs_supported_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE programs_supported_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.programs_supported_id_seq OWNER TO postgres;

--
-- Name: programs_supported_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE programs_supported_id_seq OWNED BY programs_supported.id;


--
-- Name: refrigerator_problems; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE refrigerator_problems (
    id integer NOT NULL,
    readingid integer,
    operatorerror boolean DEFAULT false,
    burnerproblem boolean DEFAULT false,
    gasleakage boolean DEFAULT false,
    egpfault boolean DEFAULT false,
    thermostatsetting boolean DEFAULT false,
    other boolean DEFAULT false,
    otherproblemexplanation character varying(255),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.refrigerator_problems OWNER TO postgres;

--
-- Name: refrigerator_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE refrigerator_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.refrigerator_problems_id_seq OWNER TO postgres;

--
-- Name: refrigerator_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE refrigerator_problems_id_seq OWNED BY refrigerator_problems.id;


--
-- Name: refrigerators; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE refrigerators (
    id integer NOT NULL,
    brand character varying(20),
    model character varying(20),
    serialnumber character varying(30) NOT NULL,
    facilityid integer,
    createdby integer NOT NULL,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now(),
    enabled boolean DEFAULT true
);


ALTER TABLE public.refrigerators OWNER TO postgres;

--
-- Name: refrigerators_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE refrigerators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.refrigerators_id_seq OWNER TO postgres;

--
-- Name: refrigerators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE refrigerators_id_seq OWNED BY refrigerators.id;


--
-- Name: regimen_categories; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE regimen_categories (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    displayorder integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.regimen_categories OWNER TO postgres;

--
-- Name: regimen_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE regimen_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regimen_categories_id_seq OWNER TO postgres;

--
-- Name: regimen_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE regimen_categories_id_seq OWNED BY regimen_categories.id;


--
-- Name: regimen_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE regimen_line_items (
    id integer NOT NULL,
    code character varying(50),
    name character varying(250),
    regimendisplayorder integer,
    regimencategory character varying(50),
    regimencategorydisplayorder integer,
    rnrid integer NOT NULL,
    patientsontreatment integer,
    patientstoinitiatetreatment integer,
    patientsstoppedtreatment integer,
    remarks character varying(255),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.regimen_line_items OWNER TO postgres;

--
-- Name: regimen_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE regimen_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regimen_line_items_id_seq OWNER TO postgres;

--
-- Name: regimen_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE regimen_line_items_id_seq OWNED BY regimen_line_items.id;


--
-- Name: regimens; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE regimens (
    id integer NOT NULL,
    programid integer NOT NULL,
    categoryid integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    active boolean,
    displayorder integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.regimens OWNER TO postgres;

--
-- Name: regimens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE regimens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.regimens_id_seq OWNER TO postgres;

--
-- Name: regimens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE regimens_id_seq OWNED BY regimens.id;


--
-- Name: report_rights; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE report_rights (
    id integer NOT NULL,
    templateid integer NOT NULL,
    rightname character varying NOT NULL
);


ALTER TABLE public.report_rights OWNER TO postgres;

--
-- Name: report_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE report_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_rights_id_seq OWNER TO postgres;

--
-- Name: report_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE report_rights_id_seq OWNED BY report_rights.id;


--
-- Name: templates; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE templates (
    id integer NOT NULL,
    name character varying NOT NULL,
    data bytea NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    type character varying NOT NULL,
    description character varying(500)
);


ALTER TABLE public.templates OWNER TO postgres;

--
-- Name: report_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE report_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.report_templates_id_seq OWNER TO postgres;

--
-- Name: report_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE report_templates_id_seq OWNED BY templates.id;


--
-- Name: requisition_group_members; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_group_members (
    id integer NOT NULL,
    requisitiongroupid integer NOT NULL,
    facilityid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisition_group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisition_group_members_id_seq OWNER TO postgres;

--
-- Name: requisition_group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisition_group_members_id_seq OWNED BY requisition_group_members.id;


--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_group_program_schedules (
    id integer NOT NULL,
    requisitiongroupid integer NOT NULL,
    programid integer NOT NULL,
    scheduleid integer NOT NULL,
    directdelivery boolean NOT NULL,
    dropofffacilityid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.requisition_group_program_schedules OWNER TO postgres;

--
-- Name: requisition_group_program_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisition_group_program_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisition_group_program_schedules_id_seq OWNER TO postgres;

--
-- Name: requisition_group_program_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisition_group_program_schedules_id_seq OWNED BY requisition_group_program_schedules.id;


--
-- Name: requisition_groups; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_groups (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    supervisorynodeid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.requisition_groups OWNER TO postgres;

--
-- Name: requisition_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisition_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisition_groups_id_seq OWNER TO postgres;

--
-- Name: requisition_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisition_groups_id_seq OWNED BY requisition_groups.id;


--
-- Name: requisition_line_item_losses_adjustments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_line_item_losses_adjustments (
    requisitionlineitemid integer NOT NULL,
    type character varying(250) NOT NULL,
    quantity integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.requisition_line_item_losses_adjustments OWNER TO postgres;

--
-- Name: requisition_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_line_items (
    id integer NOT NULL,
    rnrid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    product character varying(250),
    productdisplayorder integer,
    productcategory character varying(100),
    productcategorydisplayorder integer,
    dispensingunit character varying(20) NOT NULL,
    beginningbalance integer,
    quantityreceived integer,
    quantitydispensed integer,
    stockinhand integer,
    quantityrequested integer,
    reasonforrequestedquantity text,
    calculatedorderquantity integer,
    quantityapproved integer,
    totallossesandadjustments integer,
    newpatientcount integer,
    stockoutdays integer,
    normalizedconsumption integer,
    amc integer,
    maxmonthsofstock numeric(4,2) NOT NULL,
    maxstockquantity integer,
    packstoship integer,
    price numeric(15,4),
    expirationdate character varying(10),
    remarks text,
    dosespermonth integer NOT NULL,
    dosesperdispensingunit integer NOT NULL,
    packsize smallint NOT NULL,
    roundtozero boolean,
    packroundingthreshold integer,
    fullsupply boolean NOT NULL,
    skipped boolean DEFAULT false NOT NULL,
    reportingdays integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    previousnormalizedconsumptions character varying(25) DEFAULT '[]'::character varying,
    previousstockinhand integer,
    periodnormalizedconsumption integer
);


ALTER TABLE public.requisition_line_items OWNER TO postgres;

--
-- Name: requisition_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisition_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisition_line_items_id_seq OWNER TO postgres;

--
-- Name: requisition_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisition_line_items_id_seq OWNED BY requisition_line_items.id;


--
-- Name: requisition_status_changes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisition_status_changes (
    id integer NOT NULL,
    rnrid integer NOT NULL,
    status character varying(20) NOT NULL,
    createdby integer NOT NULL,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now(),
    username character varying(100)
);


ALTER TABLE public.requisition_status_changes OWNER TO postgres;

--
-- Name: requisition_status_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisition_status_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisition_status_changes_id_seq OWNER TO postgres;

--
-- Name: requisition_status_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisition_status_changes_id_seq OWNED BY requisition_status_changes.id;


--
-- Name: requisitions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE requisitions (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    programid integer NOT NULL,
    periodid integer NOT NULL,
    status character varying(20) NOT NULL,
    emergency boolean DEFAULT false NOT NULL,
    fullsupplyitemssubmittedcost numeric(15,2),
    nonfullsupplyitemssubmittedcost numeric(15,2),
    supervisorynodeid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    allocatedbudget numeric(20,2)
);


ALTER TABLE public.requisitions OWNER TO postgres;

--
-- Name: requisitions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE requisitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.requisitions_id_seq OWNER TO postgres;

--
-- Name: requisitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE requisitions_id_seq OWNED BY requisitions.id;


--
-- Name: rights; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE rights (
    name character varying(200) NOT NULL,
    righttype character varying(20) NOT NULL,
    description character varying(200),
    createddate timestamp without time zone DEFAULT now(),
    displayorder integer,
    displaynamekey character varying(150)
);


ALTER TABLE public.rights OWNER TO postgres;

--
-- Name: role_assignments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE role_assignments (
    userid integer NOT NULL,
    roleid integer NOT NULL,
    programid integer,
    supervisorynodeid integer,
    deliveryzoneid integer
);


ALTER TABLE public.role_assignments OWNER TO postgres;

--
-- Name: role_rights; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE role_rights (
    roleid integer NOT NULL,
    rightname character varying NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.role_rights OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_version; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE schema_version (
    version character varying(20) NOT NULL,
    description character varying(100),
    type character varying(10) NOT NULL,
    script character varying(200) NOT NULL,
    checksum integer,
    installed_by character varying(30) NOT NULL,
    installed_on timestamp without time zone DEFAULT now(),
    execution_time integer,
    state character varying(15) NOT NULL,
    current_version boolean NOT NULL
);


ALTER TABLE public.schema_version OWNER TO postgres;

--
-- Name: shipment_configuration; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shipment_configuration (
    headerinfile boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.shipment_configuration OWNER TO postgres;

--
-- Name: shipment_file_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shipment_file_columns (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    datafieldlabel character varying(150),
    "position" integer,
    include boolean NOT NULL,
    mandatory boolean NOT NULL,
    datepattern character varying(25),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.shipment_file_columns OWNER TO postgres;

--
-- Name: shipment_file_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shipment_file_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipment_file_columns_id_seq OWNER TO postgres;

--
-- Name: shipment_file_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE shipment_file_columns_id_seq OWNED BY shipment_file_columns.id;


--
-- Name: shipment_file_info; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shipment_file_info (
    id integer NOT NULL,
    filename character varying(200) NOT NULL,
    processingerror boolean NOT NULL,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.shipment_file_info OWNER TO postgres;

--
-- Name: shipment_file_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shipment_file_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipment_file_info_id_seq OWNER TO postgres;

--
-- Name: shipment_file_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE shipment_file_info_id_seq OWNED BY shipment_file_info.id;


--
-- Name: shipment_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE shipment_line_items (
    id integer NOT NULL,
    orderid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    quantityshipped integer NOT NULL,
    cost numeric(15,2),
    packeddate timestamp without time zone,
    shippeddate timestamp without time zone,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    productname character varying(250) NOT NULL,
    dispensingunit character varying(20) NOT NULL,
    productcategory character varying(100),
    packstoship integer,
    productcategorydisplayorder integer,
    productdisplayorder integer,
    fullsupply boolean,
    replacedproductcode character varying(50),
    ordernumber character varying(100) NOT NULL
);


ALTER TABLE public.shipment_line_items OWNER TO postgres;

--
-- Name: shipment_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE shipment_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shipment_line_items_id_seq OWNER TO postgres;

--
-- Name: shipment_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE shipment_line_items_id_seq OWNED BY shipment_line_items.id;


--
-- Name: supervisory_nodes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supervisory_nodes (
    id integer NOT NULL,
    parentid integer,
    facilityid integer NOT NULL,
    name character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    description character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.supervisory_nodes OWNER TO postgres;

--
-- Name: supervisory_nodes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE supervisory_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supervisory_nodes_id_seq OWNER TO postgres;

--
-- Name: supervisory_nodes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE supervisory_nodes_id_seq OWNED BY supervisory_nodes.id;


--
-- Name: supply_lines; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE supply_lines (
    id integer NOT NULL,
    description character varying(250),
    supervisorynodeid integer NOT NULL,
    programid integer NOT NULL,
    supplyingfacilityid integer NOT NULL,
    exportorders boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.supply_lines OWNER TO postgres;

--
-- Name: supply_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE supply_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.supply_lines_id_seq OWNER TO postgres;

--
-- Name: supply_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE supply_lines_id_seq OWNED BY supply_lines.id;


--
-- Name: template_parameters; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE template_parameters (
    id integer NOT NULL,
    templateid integer NOT NULL,
    name character varying(250) NOT NULL,
    displayname character varying(250) NOT NULL,
    description character varying(500),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    defaultvalue character varying(500),
    datatype character varying(500) NOT NULL
);


ALTER TABLE public.template_parameters OWNER TO postgres;

--
-- Name: template_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE template_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.template_parameters_id_seq OWNER TO postgres;

--
-- Name: template_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE template_parameters_id_seq OWNED BY template_parameters.id;


--
-- Name: user_password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_password_reset_tokens (
    userid integer NOT NULL,
    token character varying(250) NOT NULL,
    createddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_password_reset_tokens OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(128) DEFAULT 'not-in-use'::character varying,
    firstname character varying(50) NOT NULL,
    lastname character varying(50) NOT NULL,
    employeeid character varying(50),
    restrictlogin boolean DEFAULT false,
    jobtitle character varying(50),
    primarynotificationmethod character varying(50),
    officephone character varying(30),
    cellphone character varying(30),
    email character varying(50) NOT NULL,
    supervisorid integer,
    facilityid integer,
    verified boolean DEFAULT false,
    active boolean DEFAULT true,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: vaccination_adult_coverage_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccination_adult_coverage_line_items (
    id integer NOT NULL,
    facilityvisitid integer NOT NULL,
    demographicgroup character varying(255) NOT NULL,
    targetgroup integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    healthcentertetanus1 integer,
    outreachtetanus1 integer,
    healthcentertetanus2to5 integer,
    outreachtetanus2to5 integer
);


ALTER TABLE public.vaccination_adult_coverage_line_items OWNER TO postgres;

--
-- Name: vaccination_adult_coverage_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccination_adult_coverage_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccination_adult_coverage_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccination_adult_coverage_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccination_adult_coverage_line_items_id_seq OWNED BY vaccination_adult_coverage_line_items.id;


--
-- Name: vaccination_child_coverage_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccination_child_coverage_line_items (
    id integer NOT NULL,
    facilityvisitid integer NOT NULL,
    vaccination character varying(255) NOT NULL,
    targetgroup integer,
    healthcenter11months integer,
    outreach11months integer,
    healthcenter23months integer,
    outreach23months integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccination_child_coverage_line_items OWNER TO postgres;

--
-- Name: vaccination_child_coverage_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccination_child_coverage_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccination_child_coverage_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccination_child_coverage_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccination_child_coverage_line_items_id_seq OWNED BY vaccination_child_coverage_line_items.id;


--
-- Name: vaccination_full_coverages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccination_full_coverages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccination_full_coverages_id_seq OWNER TO postgres;

--
-- Name: vaccination_full_coverages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccination_full_coverages_id_seq OWNED BY full_coverages.id;


SET search_path = atomfeed, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: atomfeed; Owner: postgres
--

ALTER TABLE ONLY chunking_history ALTER COLUMN id SET DEFAULT nextval('chunking_history_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: atomfeed; Owner: postgres
--

ALTER TABLE ONLY event_records ALTER COLUMN id SET DEFAULT nextval('event_records_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY adult_coverage_opened_vial_line_items ALTER COLUMN id SET DEFAULT nextval('adult_coverage_opened_vial_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_file_columns ALTER COLUMN id SET DEFAULT nextval('budget_file_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_file_info ALTER COLUMN id SET DEFAULT nextval('budget_file_info_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_line_items ALTER COLUMN id SET DEFAULT nextval('budget_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY child_coverage_opened_vial_line_items ALTER COLUMN id SET DEFAULT nextval('opened_vial_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY configurable_rnr_options ALTER COLUMN id SET DEFAULT nextval('configurable_rnr_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY coverage_product_vials ALTER COLUMN id SET DEFAULT nextval('coverage_product_vials_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY coverage_target_group_products ALTER COLUMN id SET DEFAULT nextval('coverage_vaccination_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_members ALTER COLUMN id SET DEFAULT nextval('delivery_zone_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_program_schedules ALTER COLUMN id SET DEFAULT nextval('delivery_zone_program_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_warehouses ALTER COLUMN id SET DEFAULT nextval('delivery_zone_warehouses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zones ALTER COLUMN id SET DEFAULT nextval('delivery_zones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dosage_units ALTER COLUMN id SET DEFAULT nextval('dosage_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY email_notifications ALTER COLUMN id SET DEFAULT nextval('email_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_inventory_line_items ALTER COLUMN id SET DEFAULT nextval('epi_inventory_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_use_line_items ALTER COLUMN id SET DEFAULT nextval('epi_use_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facilities ALTER COLUMN id SET DEFAULT nextval('facilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_approved_products ALTER COLUMN id SET DEFAULT nextval('facility_approved_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_ftp_details ALTER COLUMN id SET DEFAULT nextval('facility_ftp_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_operators ALTER COLUMN id SET DEFAULT nextval('facility_operators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_products ALTER COLUMN id SET DEFAULT nextval('facility_program_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_types ALTER COLUMN id SET DEFAULT nextval('facility_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_visits ALTER COLUMN id SET DEFAULT nextval('facility_visits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY full_coverages ALTER COLUMN id SET DEFAULT nextval('vaccination_full_coverages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographic_levels ALTER COLUMN id SET DEFAULT nextval('geographic_levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographic_zones ALTER COLUMN id SET DEFAULT nextval('geographic_zones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY master_rnr_column_options ALTER COLUMN id SET DEFAULT nextval('master_rnr_column_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY master_rnr_columns ALTER COLUMN id SET DEFAULT nextval('master_rnr_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY order_file_columns ALTER COLUMN id SET DEFAULT nextval('order_file_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod ALTER COLUMN id SET DEFAULT nextval('pod_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod_line_items ALTER COLUMN id SET DEFAULT nextval('pod_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY processing_periods ALTER COLUMN id SET DEFAULT nextval('processing_periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY processing_schedules ALTER COLUMN id SET DEFAULT nextval('processing_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_categories ALTER COLUMN id SET DEFAULT nextval('product_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_forms ALTER COLUMN id SET DEFAULT nextval('product_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_groups ALTER COLUMN id SET DEFAULT nextval('product_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_product_isa ALTER COLUMN id SET DEFAULT nextval('program_product_isa_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_product_price_history ALTER COLUMN id SET DEFAULT nextval('program_product_price_history_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_products ALTER COLUMN id SET DEFAULT nextval('program_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_regimen_columns ALTER COLUMN id SET DEFAULT nextval('program_regimen_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_rnr_columns ALTER COLUMN id SET DEFAULT nextval('program_rnr_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY programs ALTER COLUMN id SET DEFAULT nextval('programs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY programs_supported ALTER COLUMN id SET DEFAULT nextval('programs_supported_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerator_problems ALTER COLUMN id SET DEFAULT nextval('refrigerator_problems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerator_readings ALTER COLUMN id SET DEFAULT nextval('distribution_refrigerator_readings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerators ALTER COLUMN id SET DEFAULT nextval('refrigerators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_categories ALTER COLUMN id SET DEFAULT nextval('regimen_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_line_items ALTER COLUMN id SET DEFAULT nextval('regimen_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimens ALTER COLUMN id SET DEFAULT nextval('regimens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY report_rights ALTER COLUMN id SET DEFAULT nextval('report_rights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members ALTER COLUMN id SET DEFAULT nextval('requisition_group_members_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules ALTER COLUMN id SET DEFAULT nextval('requisition_group_program_schedules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_groups ALTER COLUMN id SET DEFAULT nextval('requisition_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_line_items ALTER COLUMN id SET DEFAULT nextval('requisition_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_status_changes ALTER COLUMN id SET DEFAULT nextval('requisition_status_changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisitions ALTER COLUMN id SET DEFAULT nextval('requisitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shipment_file_columns ALTER COLUMN id SET DEFAULT nextval('shipment_file_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shipment_file_info ALTER COLUMN id SET DEFAULT nextval('shipment_file_info_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shipment_line_items ALTER COLUMN id SET DEFAULT nextval('shipment_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes ALTER COLUMN id SET DEFAULT nextval('supervisory_nodes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supply_lines ALTER COLUMN id SET DEFAULT nextval('supply_lines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY template_parameters ALTER COLUMN id SET DEFAULT nextval('template_parameters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY templates ALTER COLUMN id SET DEFAULT nextval('report_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccination_adult_coverage_line_items ALTER COLUMN id SET DEFAULT nextval('vaccination_adult_coverage_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccination_child_coverage_line_items ALTER COLUMN id SET DEFAULT nextval('vaccination_child_coverage_line_items_id_seq'::regclass);


SET search_path = atomfeed, pg_catalog;

--
-- Name: chunking_history_pkey; Type: CONSTRAINT; Schema: atomfeed; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY chunking_history
    ADD CONSTRAINT chunking_history_pkey PRIMARY KEY (id);


--
-- Name: event_records_pkey; Type: CONSTRAINT; Schema: atomfeed; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY event_records
    ADD CONSTRAINT event_records_pkey PRIMARY KEY (id);


SET search_path = public, pg_catalog;

--
-- Name: adult_coverage_opened_vial_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY adult_coverage_opened_vial_line_items
    ADD CONSTRAINT adult_coverage_opened_vial_line_items_pkey PRIMARY KEY (id);


--
-- Name: budget_file_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY budget_file_columns
    ADD CONSTRAINT budget_file_columns_pkey PRIMARY KEY (id);


--
-- Name: budget_file_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY budget_file_info
    ADD CONSTRAINT budget_file_info_pkey PRIMARY KEY (id);


--
-- Name: budget_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY budget_line_items
    ADD CONSTRAINT budget_line_items_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: configurable_rnr_options_label_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configurable_rnr_options
    ADD CONSTRAINT configurable_rnr_options_label_key UNIQUE (label);


--
-- Name: configurable_rnr_options_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configurable_rnr_options
    ADD CONSTRAINT configurable_rnr_options_name_key UNIQUE (name);


--
-- Name: configurable_rnr_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configurable_rnr_options
    ADD CONSTRAINT configurable_rnr_options_pkey PRIMARY KEY (id);


--
-- Name: coverage_product_vials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY coverage_product_vials
    ADD CONSTRAINT coverage_product_vials_pkey PRIMARY KEY (id);


--
-- Name: coverage_product_vials_vial_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY coverage_product_vials
    ADD CONSTRAINT coverage_product_vials_vial_key UNIQUE (vial);


--
-- Name: coverage_vaccination_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY coverage_target_group_products
    ADD CONSTRAINT coverage_vaccination_products_pkey PRIMARY KEY (id);


--
-- Name: delivery_zone_members_deliveryzoneid_facilityid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zone_members
    ADD CONSTRAINT delivery_zone_members_deliveryzoneid_facilityid_key UNIQUE (deliveryzoneid, facilityid);


--
-- Name: delivery_zone_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zone_members
    ADD CONSTRAINT delivery_zone_members_pkey PRIMARY KEY (id);


--
-- Name: delivery_zone_program_schedules_deliveryzoneid_programid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zone_program_schedules
    ADD CONSTRAINT delivery_zone_program_schedules_deliveryzoneid_programid_key UNIQUE (deliveryzoneid, programid);


--
-- Name: delivery_zone_program_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zone_program_schedules
    ADD CONSTRAINT delivery_zone_program_schedules_pkey PRIMARY KEY (id);


--
-- Name: delivery_zone_warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zone_warehouses
    ADD CONSTRAINT delivery_zone_warehouses_pkey PRIMARY KEY (id);


--
-- Name: delivery_zones_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zones
    ADD CONSTRAINT delivery_zones_code_key UNIQUE (code);


--
-- Name: delivery_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY delivery_zones
    ADD CONSTRAINT delivery_zones_pkey PRIMARY KEY (id);


--
-- Name: distribution_refrigerator_readings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY refrigerator_readings
    ADD CONSTRAINT distribution_refrigerator_readings_pkey PRIMARY KEY (id);


--
-- Name: distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_pkey PRIMARY KEY (id);


--
-- Name: dosage_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dosage_units
    ADD CONSTRAINT dosage_units_pkey PRIMARY KEY (id);


--
-- Name: email_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY email_notifications
    ADD CONSTRAINT email_notifications_pkey PRIMARY KEY (id);


--
-- Name: epi_inventory_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY epi_inventory_line_items
    ADD CONSTRAINT epi_inventory_line_items_pkey PRIMARY KEY (id);


--
-- Name: epi_use_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT epi_use_line_items_pkey PRIMARY KEY (id);


--
-- Name: facilities_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_code_key UNIQUE (code);


--
-- Name: facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_approved_products_facilitytypeid_programproductid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_approved_products
    ADD CONSTRAINT facility_approved_products_facilitytypeid_programproductid_key UNIQUE (facilitytypeid, programproductid);


--
-- Name: facility_approved_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_approved_products
    ADD CONSTRAINT facility_approved_products_pkey PRIMARY KEY (id);


--
-- Name: facility_ftp_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_ftp_details
    ADD CONSTRAINT facility_ftp_details_pkey PRIMARY KEY (id);


--
-- Name: facility_operators_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_operators
    ADD CONSTRAINT facility_operators_code_key UNIQUE (code);


--
-- Name: facility_operators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_operators
    ADD CONSTRAINT facility_operators_pkey PRIMARY KEY (id);


--
-- Name: facility_program_products_facilityid_programproductid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_program_products
    ADD CONSTRAINT facility_program_products_facilityid_programproductid_key UNIQUE (facilityid, programproductid);


--
-- Name: facility_program_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_program_products
    ADD CONSTRAINT facility_program_products_pkey PRIMARY KEY (id);


--
-- Name: facility_types_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_types
    ADD CONSTRAINT facility_types_code_key UNIQUE (code);


--
-- Name: facility_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_types
    ADD CONSTRAINT facility_types_name_key UNIQUE (name);


--
-- Name: facility_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_types
    ADD CONSTRAINT facility_types_pkey PRIMARY KEY (id);


--
-- Name: facility_visits_distributionid_facilityid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_visits
    ADD CONSTRAINT facility_visits_distributionid_facilityid_key UNIQUE (distributionid, facilityid);


--
-- Name: facility_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_visits
    ADD CONSTRAINT facility_visits_pkey PRIMARY KEY (id);


--
-- Name: geographic_levels_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographic_levels
    ADD CONSTRAINT geographic_levels_code_key UNIQUE (code);


--
-- Name: geographic_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographic_levels
    ADD CONSTRAINT geographic_levels_pkey PRIMARY KEY (id);


--
-- Name: geographic_zones_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_code_key UNIQUE (code);


--
-- Name: geographic_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_pkey PRIMARY KEY (id);


--
-- Name: losses_adjustments_types_description_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY losses_adjustments_types
    ADD CONSTRAINT losses_adjustments_types_description_key UNIQUE (description);


--
-- Name: losses_adjustments_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY losses_adjustments_types
    ADD CONSTRAINT losses_adjustments_types_name_key UNIQUE (name);


--
-- Name: master_rnr_column_options_masterrnrcolumnid_rnroptionid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY master_rnr_column_options
    ADD CONSTRAINT master_rnr_column_options_masterrnrcolumnid_rnroptionid_key UNIQUE (masterrnrcolumnid, rnroptionid);


--
-- Name: master_rnr_column_options_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY master_rnr_column_options
    ADD CONSTRAINT master_rnr_column_options_pkey PRIMARY KEY (id);


--
-- Name: master_rnr_columns_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY master_rnr_columns
    ADD CONSTRAINT master_rnr_columns_name_key UNIQUE (name);


--
-- Name: master_rnr_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY master_rnr_columns
    ADD CONSTRAINT master_rnr_columns_pkey PRIMARY KEY (id);


--
-- Name: opened_vial_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY child_coverage_opened_vial_line_items
    ADD CONSTRAINT opened_vial_line_items_pkey PRIMARY KEY (id);


--
-- Name: order_file_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY order_file_columns
    ADD CONSTRAINT order_file_columns_pkey PRIMARY KEY (id);


--
-- Name: orders_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_id_key UNIQUE (id);


--
-- Name: pod_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pod_line_items
    ADD CONSTRAINT pod_line_items_pkey PRIMARY KEY (id);


--
-- Name: pod_orderid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_orderid_key UNIQUE (orderid);


--
-- Name: pod_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_pkey PRIMARY KEY (id);


--
-- Name: processing_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY processing_periods
    ADD CONSTRAINT processing_periods_pkey PRIMARY KEY (id);


--
-- Name: processing_schedules_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY processing_schedules
    ADD CONSTRAINT processing_schedules_code_key UNIQUE (code);


--
-- Name: processing_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY processing_schedules
    ADD CONSTRAINT processing_schedules_pkey PRIMARY KEY (id);


--
-- Name: product_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_categories
    ADD CONSTRAINT product_categories_code_key UNIQUE (code);


--
-- Name: product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_forms
    ADD CONSTRAINT product_forms_pkey PRIMARY KEY (id);


--
-- Name: product_groups_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_groups
    ADD CONSTRAINT product_groups_code_key UNIQUE (code);


--
-- Name: product_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_groups
    ADD CONSTRAINT product_groups_pkey PRIMARY KEY (id);


--
-- Name: products_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_code_key UNIQUE (code);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: program_product_isa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_product_isa
    ADD CONSTRAINT program_product_isa_pkey PRIMARY KEY (id);


--
-- Name: program_product_price_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_product_price_history
    ADD CONSTRAINT program_product_price_history_pkey PRIMARY KEY (id);


--
-- Name: program_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_products
    ADD CONSTRAINT program_products_pkey PRIMARY KEY (id);


--
-- Name: program_products_productid_programid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_products
    ADD CONSTRAINT program_products_productid_programid_key UNIQUE (productid, programid);


--
-- Name: program_regimen_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_regimen_columns
    ADD CONSTRAINT program_regimen_columns_pkey PRIMARY KEY (id);


--
-- Name: program_rnr_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_rnr_columns
    ADD CONSTRAINT program_rnr_columns_pkey PRIMARY KEY (id);


--
-- Name: program_rnr_columns_programid_mastercolumnid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_rnr_columns
    ADD CONSTRAINT program_rnr_columns_programid_mastercolumnid_key UNIQUE (programid, mastercolumnid);


--
-- Name: programs_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_code_key UNIQUE (code);


--
-- Name: programs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: programs_supported_facilityid_programid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY programs_supported
    ADD CONSTRAINT programs_supported_facilityid_programid_key UNIQUE (facilityid, programid);


--
-- Name: programs_supported_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY programs_supported
    ADD CONSTRAINT programs_supported_pkey PRIMARY KEY (id);


--
-- Name: refrigerator_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY refrigerator_problems
    ADD CONSTRAINT refrigerator_problems_pkey PRIMARY KEY (id);


--
-- Name: refrigerators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY refrigerators
    ADD CONSTRAINT refrigerators_pkey PRIMARY KEY (id);


--
-- Name: regimen_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY regimen_categories
    ADD CONSTRAINT regimen_categories_code_key UNIQUE (code);


--
-- Name: regimen_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY regimen_categories
    ADD CONSTRAINT regimen_categories_pkey PRIMARY KEY (id);


--
-- Name: regimen_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY regimen_line_items
    ADD CONSTRAINT regimen_line_items_pkey PRIMARY KEY (id);


--
-- Name: regimens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY regimens
    ADD CONSTRAINT regimens_pkey PRIMARY KEY (id);


--
-- Name: report_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY report_rights
    ADD CONSTRAINT report_rights_pkey PRIMARY KEY (id);


--
-- Name: report_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT report_templates_pkey PRIMARY KEY (id);


--
-- Name: requisition_group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT requisition_group_members_pkey PRIMARY KEY (id);


--
-- Name: requisition_group_members_requisitiongroupid_facilityid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT requisition_group_members_requisitiongroupid_facilityid_key UNIQUE (requisitiongroupid, facilityid);


--
-- Name: requisition_group_program_sche_requisitiongroupid_programid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_sche_requisitiongroupid_programid_key UNIQUE (requisitiongroupid, programid);


--
-- Name: requisition_group_program_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_pkey PRIMARY KEY (id);


--
-- Name: requisition_groups_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT requisition_groups_code_key UNIQUE (code);


--
-- Name: requisition_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT requisition_groups_pkey PRIMARY KEY (id);


--
-- Name: requisition_line_item_losses_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_line_item_losses_adjustments
    ADD CONSTRAINT requisition_line_item_losses_adjustments_pkey PRIMARY KEY (requisitionlineitemid, type);


--
-- Name: requisition_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_line_items
    ADD CONSTRAINT requisition_line_items_pkey PRIMARY KEY (id);


--
-- Name: requisition_status_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisition_status_changes
    ADD CONSTRAINT requisition_status_changes_pkey PRIMARY KEY (id);


--
-- Name: requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_pkey PRIMARY KEY (id);


--
-- Name: rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rights
    ADD CONSTRAINT rights_pkey PRIMARY KEY (name);


--
-- Name: roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_version_primary_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_primary_key PRIMARY KEY (version);


--
-- Name: schema_version_script_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_script_unique UNIQUE (script);


--
-- Name: shipment_file_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY shipment_file_columns
    ADD CONSTRAINT shipment_file_columns_pkey PRIMARY KEY (id);


--
-- Name: shipment_file_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY shipment_file_info
    ADD CONSTRAINT shipment_file_info_pkey PRIMARY KEY (id);


--
-- Name: shipment_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY shipment_line_items
    ADD CONSTRAINT shipment_line_items_pkey PRIMARY KEY (id);


--
-- Name: supervisory_nodes_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_code_key UNIQUE (code);


--
-- Name: supervisory_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_pkey PRIMARY KEY (id);


--
-- Name: supply_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_pkey PRIMARY KEY (id);


--
-- Name: template_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: uc_productgroupid_facilityvisitid_epi_use_line_items; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT uc_productgroupid_facilityvisitid_epi_use_line_items UNIQUE (productgroupid, facilityvisitid);


--
-- Name: uc_programproductid_facilityvisitid_epi_inventory_line_items; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY epi_inventory_line_items
    ADD CONSTRAINT uc_programproductid_facilityvisitid_epi_inventory_line_items UNIQUE (programproductid, facilityvisitid);


--
-- Name: uc_refrigeratorid_facilityvisitid_refrigerator_readings; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY refrigerator_readings
    ADD CONSTRAINT uc_refrigeratorid_facilityvisitid_refrigerator_readings UNIQUE (refrigeratorid, facilityvisitid);


--
-- Name: uc_serialnumber_facilityid_refrigerators; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY refrigerators
    ADD CONSTRAINT uc_serialnumber_facilityid_refrigerators UNIQUE (serialnumber, facilityid);


--
-- Name: uc_vaccination_coverage_vaccination_products; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY coverage_target_group_products
    ADD CONSTRAINT uc_vaccination_coverage_vaccination_products UNIQUE (targetgroupentity);


--
-- Name: unique_fulfillment_role_assignments; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fulfillment_role_assignments
    ADD CONSTRAINT unique_fulfillment_role_assignments UNIQUE (userid, roleid, facilityid);


--
-- Name: unique_role_assignment; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT unique_role_assignment UNIQUE (userid, roleid, programid, supervisorynodeid);


--
-- Name: unique_role_right; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT unique_role_right UNIQUE (roleid, rightname);


--
-- Name: unique_supply_line; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT unique_supply_line UNIQUE (supervisorynodeid, programid);


--
-- Name: user_password_reset_tokens_userid_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_password_reset_tokens
    ADD CONSTRAINT user_password_reset_tokens_userid_token_key UNIQUE (userid, token);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vaccination_adult_coverage_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccination_adult_coverage_line_items
    ADD CONSTRAINT vaccination_adult_coverage_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccination_child_coverage_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccination_child_coverage_line_items
    ADD CONSTRAINT vaccination_child_coverage_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccination_full_coverages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY full_coverages
    ADD CONSTRAINT vaccination_full_coverages_pkey PRIMARY KEY (id);


--
-- Name: i_comments_rnrid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_comments_rnrid ON comments USING btree (rnrid);


--
-- Name: i_delivery_zone_members_facilityid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_delivery_zone_members_facilityid ON delivery_zone_members USING btree (facilityid);


--
-- Name: i_delivery_zone_program_schedules_deliveryzoneid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_delivery_zone_program_schedules_deliveryzoneid ON delivery_zone_program_schedules USING btree (deliveryzoneid);


--
-- Name: i_delivery_zone_warehouses_deliveryzoneid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_delivery_zone_warehouses_deliveryzoneid ON delivery_zone_warehouses USING btree (deliveryzoneid);


--
-- Name: i_facility_approved_product_programproductid_facilitytypeid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_facility_approved_product_programproductid_facilitytypeid ON facility_approved_products USING btree (programproductid, facilitytypeid);


--
-- Name: i_facility_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_facility_name ON facilities USING btree (name);


--
-- Name: i_processing_period_startdate_enddate; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_processing_period_startdate_enddate ON processing_periods USING btree (startdate, enddate);


--
-- Name: i_program_product_isa_programproductid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX i_program_product_isa_programproductid ON program_product_isa USING btree (programproductid);


--
-- Name: i_program_product_price_history_programproductid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_program_product_price_history_programproductid ON program_product_price_history USING btree (programproductid);


--
-- Name: i_program_product_programid_productid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_program_product_programid_productid ON program_products USING btree (programid, productid);


--
-- Name: i_program_regimens_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX i_program_regimens_name ON program_regimen_columns USING btree (programid, name);


--
-- Name: i_program_supported_facilityid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_program_supported_facilityid ON programs_supported USING btree (facilityid);


--
-- Name: i_regimens_code_programid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX i_regimens_code_programid ON regimens USING btree (code, programid);


--
-- Name: i_requisition_group_member_facilityid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_group_member_facilityid ON requisition_group_members USING btree (facilityid);


--
-- Name: i_requisition_group_program_schedules_requisitiongroupid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_group_program_schedules_requisitiongroupid ON requisition_group_program_schedules USING btree (requisitiongroupid);


--
-- Name: i_requisition_group_supervisorynodeid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_group_supervisorynodeid ON requisition_groups USING btree (supervisorynodeid);


--
-- Name: i_requisition_line_item_losses_adjustments_lineitemid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_line_item_losses_adjustments_lineitemid ON requisition_line_item_losses_adjustments USING btree (requisitionlineitemid);


--
-- Name: i_requisition_line_items_rnrid_fullsupply_f; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_line_items_rnrid_fullsupply_f ON requisition_line_items USING btree (rnrid) WHERE (fullsupply = false);


--
-- Name: i_requisition_line_items_rnrid_fullsupply_t; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisition_line_items_rnrid_fullsupply_t ON requisition_line_items USING btree (rnrid) WHERE (fullsupply = true);


--
-- Name: i_requisitions_programid_supervisorynodeid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisitions_programid_supervisorynodeid ON requisitions USING btree (programid, supervisorynodeid);


--
-- Name: i_requisitions_status; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_requisitions_status ON requisitions USING btree (lower((status)::text));


--
-- Name: i_supervisory_node_parentid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_supervisory_node_parentid ON supervisory_nodes USING btree (parentid);


--
-- Name: i_users_firstname_lastname_email; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_users_firstname_lastname_email ON users USING btree (lower((firstname)::text), lower((lastname)::text), lower((email)::text));


--
-- Name: program_id_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX program_id_index ON program_rnr_columns USING btree (programid);


--
-- Name: schema_version_current_version_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX schema_version_current_version_index ON schema_version USING btree (current_version);


--
-- Name: uc_budget_line_items_facilityid_programid_periodid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_budget_line_items_facilityid_programid_periodid ON budget_line_items USING btree (facilityid, programid, periodid);


--
-- Name: uc_delivery_zones_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_delivery_zones_lower_code ON delivery_zones USING btree (lower((code)::text));


--
-- Name: uc_dosage_units_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_dosage_units_lower_code ON dosage_units USING btree (lower((code)::text));


--
-- Name: uc_dz_program_period; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_dz_program_period ON distributions USING btree (deliveryzoneid, programid, periodid);


--
-- Name: uc_facilities_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_facilities_lower_code ON facilities USING btree (lower((code)::text));


--
-- Name: uc_facility_operators_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_facility_operators_lower_code ON facility_operators USING btree (lower((code)::text));


--
-- Name: uc_facility_program_products_overriddenisa_programproductid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_facility_program_products_overriddenisa_programproductid ON facility_program_products USING btree (facilityid, programproductid);


--
-- Name: uc_facility_types_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_facility_types_lower_code ON facility_types USING btree (lower((code)::text));


--
-- Name: uc_geographic_levels_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_geographic_levels_lower_code ON geographic_levels USING btree (lower((code)::text));


--
-- Name: uc_geographic_zones_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_geographic_zones_lower_code ON geographic_zones USING btree (lower((code)::text));


--
-- Name: uc_processing_period_name_scheduleid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_processing_period_name_scheduleid ON processing_periods USING btree (lower((name)::text), scheduleid);


--
-- Name: uc_processing_schedules_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_processing_schedules_lower_code ON processing_schedules USING btree (lower((code)::text));


--
-- Name: uc_product_categories_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_product_categories_lower_code ON product_categories USING btree (lower((code)::text));


--
-- Name: uc_product_forms_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_product_forms_lower_code ON product_forms USING btree (lower((code)::text));


--
-- Name: uc_product_groups_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_product_groups_lower_code ON product_groups USING btree (lower((code)::text));


--
-- Name: uc_products_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_products_lower_code ON products USING btree (lower((code)::text));


--
-- Name: uc_programs_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_programs_lower_code ON programs USING btree (lower((code)::text));


--
-- Name: uc_report_templates_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_report_templates_name ON templates USING btree (lower((name)::text));


--
-- Name: uc_requisition_groups_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_requisition_groups_lower_code ON requisition_groups USING btree (lower((code)::text));


--
-- Name: uc_roles_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_roles_lower_name ON roles USING btree (lower((name)::text));


--
-- Name: uc_supervisory_nodes_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_supervisory_nodes_lower_code ON supervisory_nodes USING btree (lower((code)::text));


--
-- Name: uc_users_email; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_users_email ON users USING btree (lower((email)::text));


--
-- Name: uc_users_employeeid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_users_employeeid ON users USING btree (lower((employeeid)::text));


--
-- Name: uc_users_username; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_users_username ON users USING btree (lower((username)::text));


--
-- Name: adult_coverage_opened_vial_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY adult_coverage_opened_vial_line_items
    ADD CONSTRAINT adult_coverage_opened_vial_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: budget_line_items_budgetfileid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_line_items
    ADD CONSTRAINT budget_line_items_budgetfileid_fkey FOREIGN KEY (budgetfileid) REFERENCES budget_file_info(id);


--
-- Name: budget_line_items_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_line_items
    ADD CONSTRAINT budget_line_items_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: budget_line_items_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_line_items
    ADD CONSTRAINT budget_line_items_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: budget_line_items_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budget_line_items
    ADD CONSTRAINT budget_line_items_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: comments_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: comments_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: comments_rnrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: coverage_product_vials_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY coverage_product_vials
    ADD CONSTRAINT coverage_product_vials_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: coverage_vaccination_products_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY coverage_target_group_products
    ADD CONSTRAINT coverage_vaccination_products_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: delivery_zone_members_deliveryzoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_members
    ADD CONSTRAINT delivery_zone_members_deliveryzoneid_fkey FOREIGN KEY (deliveryzoneid) REFERENCES delivery_zones(id);


--
-- Name: delivery_zone_members_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_members
    ADD CONSTRAINT delivery_zone_members_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: delivery_zone_program_schedules_deliveryzoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_program_schedules
    ADD CONSTRAINT delivery_zone_program_schedules_deliveryzoneid_fkey FOREIGN KEY (deliveryzoneid) REFERENCES delivery_zones(id);


--
-- Name: delivery_zone_program_schedules_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_program_schedules
    ADD CONSTRAINT delivery_zone_program_schedules_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: delivery_zone_program_schedules_scheduleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_program_schedules
    ADD CONSTRAINT delivery_zone_program_schedules_scheduleid_fkey FOREIGN KEY (scheduleid) REFERENCES processing_schedules(id);


--
-- Name: delivery_zone_warehouses_deliveryzoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_warehouses
    ADD CONSTRAINT delivery_zone_warehouses_deliveryzoneid_fkey FOREIGN KEY (deliveryzoneid) REFERENCES delivery_zones(id);


--
-- Name: delivery_zone_warehouses_warehouseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY delivery_zone_warehouses
    ADD CONSTRAINT delivery_zone_warehouses_warehouseid_fkey FOREIGN KEY (warehouseid) REFERENCES facilities(id);


--
-- Name: distributions_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: distributions_deliveryzoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_deliveryzoneid_fkey FOREIGN KEY (deliveryzoneid) REFERENCES delivery_zones(id);


--
-- Name: distributions_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: distributions_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: distributions_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: epi_inventory_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_inventory_line_items
    ADD CONSTRAINT epi_inventory_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: epi_inventory_line_items_programproductid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_inventory_line_items
    ADD CONSTRAINT epi_inventory_line_items_programproductid_fkey FOREIGN KEY (programproductid) REFERENCES program_products(id);


--
-- Name: epi_use_line_items_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT epi_use_line_items_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: epi_use_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT epi_use_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: epi_use_line_items_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT epi_use_line_items_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: epi_use_line_items_productgroupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY epi_use_line_items
    ADD CONSTRAINT epi_use_line_items_productgroupid_fkey FOREIGN KEY (productgroupid) REFERENCES product_groups(id);


--
-- Name: facilities_geographiczoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_geographiczoneid_fkey FOREIGN KEY (geographiczoneid) REFERENCES geographic_zones(id);


--
-- Name: facilities_operatedbyid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_operatedbyid_fkey FOREIGN KEY (operatedbyid) REFERENCES facility_operators(id);


--
-- Name: facilities_parentfacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_parentfacilityid_fkey FOREIGN KEY (parentfacilityid) REFERENCES facilities(id);


--
-- Name: facilities_typeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_typeid_fkey FOREIGN KEY (typeid) REFERENCES facility_types(id);


--
-- Name: facility_approved_products_facilitytypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_approved_products
    ADD CONSTRAINT facility_approved_products_facilitytypeid_fkey FOREIGN KEY (facilitytypeid) REFERENCES facility_types(id);


--
-- Name: facility_approved_products_programproductid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_approved_products
    ADD CONSTRAINT facility_approved_products_programproductid_fkey FOREIGN KEY (programproductid) REFERENCES program_products(id);


--
-- Name: facility_ftp_details_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_ftp_details
    ADD CONSTRAINT facility_ftp_details_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: facility_program_products_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_products
    ADD CONSTRAINT facility_program_products_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: facility_program_products_programproductid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_products
    ADD CONSTRAINT facility_program_products_programproductid_fkey FOREIGN KEY (programproductid) REFERENCES program_products(id);


--
-- Name: facility_visits_distributionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_visits
    ADD CONSTRAINT facility_visits_distributionid_fkey FOREIGN KEY (distributionid) REFERENCES distributions(id);


--
-- Name: facility_visits_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_visits
    ADD CONSTRAINT facility_visits_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: fulfillment_role_assignments_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fulfillment_role_assignments
    ADD CONSTRAINT fulfillment_role_assignments_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: fulfillment_role_assignments_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fulfillment_role_assignments
    ADD CONSTRAINT fulfillment_role_assignments_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: fulfillment_role_assignments_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fulfillment_role_assignments
    ADD CONSTRAINT fulfillment_role_assignments_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: full_coverages_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY full_coverages
    ADD CONSTRAINT full_coverages_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: geographic_zones_levelid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_levelid_fkey FOREIGN KEY (levelid) REFERENCES geographic_levels(id);


--
-- Name: geographic_zones_parentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_parentid_fkey FOREIGN KEY (parentid) REFERENCES geographic_zones(id);


--
-- Name: master_rnr_column_options_masterrnrcolumnid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY master_rnr_column_options
    ADD CONSTRAINT master_rnr_column_options_masterrnrcolumnid_fkey FOREIGN KEY (masterrnrcolumnid) REFERENCES master_rnr_columns(id);


--
-- Name: master_rnr_column_options_rnroptionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY master_rnr_column_options
    ADD CONSTRAINT master_rnr_column_options_rnroptionid_fkey FOREIGN KEY (rnroptionid) REFERENCES configurable_rnr_options(id);


--
-- Name: opened_vial_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY child_coverage_opened_vial_line_items
    ADD CONSTRAINT opened_vial_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: orders_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: orders_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_id_fkey FOREIGN KEY (id) REFERENCES requisitions(id);


--
-- Name: orders_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: orders_shipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_shipmentid_fkey FOREIGN KEY (shipmentid) REFERENCES shipment_file_info(id);


--
-- Name: orders_supplylineid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_supplylineid_fkey FOREIGN KEY (supplylineid) REFERENCES supply_lines(id);


--
-- Name: pod_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: pod_line_items_podid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod_line_items
    ADD CONSTRAINT pod_line_items_podid_fkey FOREIGN KEY (podid) REFERENCES pod(id);


--
-- Name: pod_line_items_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod_line_items
    ADD CONSTRAINT pod_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: pod_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_orderid_fkey FOREIGN KEY (orderid) REFERENCES orders(id);


--
-- Name: pod_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: pod_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY pod
    ADD CONSTRAINT pod_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: processing_periods_scheduleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY processing_periods
    ADD CONSTRAINT processing_periods_scheduleid_fkey FOREIGN KEY (scheduleid) REFERENCES processing_schedules(id);


--
-- Name: products_dosageunitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_dosageunitid_fkey FOREIGN KEY (dosageunitid) REFERENCES dosage_units(id);


--
-- Name: products_formid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_formid_fkey FOREIGN KEY (formid) REFERENCES product_forms(id);


--
-- Name: products_productgroupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_productgroupid_fkey FOREIGN KEY (productgroupid) REFERENCES product_groups(id);


--
-- Name: program_product_isa_programproductid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_product_isa
    ADD CONSTRAINT program_product_isa_programproductid_fkey FOREIGN KEY (programproductid) REFERENCES program_products(id);


--
-- Name: program_product_price_history_programproductid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_product_price_history
    ADD CONSTRAINT program_product_price_history_programproductid_fkey FOREIGN KEY (programproductid) REFERENCES program_products(id);


--
-- Name: program_products_productcategoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_products
    ADD CONSTRAINT program_products_productcategoryid_fkey FOREIGN KEY (productcategoryid) REFERENCES product_categories(id);


--
-- Name: program_products_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_products
    ADD CONSTRAINT program_products_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: program_products_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_products
    ADD CONSTRAINT program_products_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: program_regimen_columns_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_regimen_columns
    ADD CONSTRAINT program_regimen_columns_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: program_rnr_columns_mastercolumnid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_rnr_columns
    ADD CONSTRAINT program_rnr_columns_mastercolumnid_fkey FOREIGN KEY (mastercolumnid) REFERENCES master_rnr_columns(id);


--
-- Name: program_rnr_columns_rnroptionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_rnr_columns
    ADD CONSTRAINT program_rnr_columns_rnroptionid_fkey FOREIGN KEY (rnroptionid) REFERENCES configurable_rnr_options(id);


--
-- Name: programs_supported_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY programs_supported
    ADD CONSTRAINT programs_supported_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: programs_supported_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY programs_supported
    ADD CONSTRAINT programs_supported_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: refrigerator_problems_readingid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerator_problems
    ADD CONSTRAINT refrigerator_problems_readingid_fkey FOREIGN KEY (readingid) REFERENCES refrigerator_readings(id);


--
-- Name: refrigerator_readings_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerator_readings
    ADD CONSTRAINT refrigerator_readings_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: refrigerator_readings_refrigeratorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerator_readings
    ADD CONSTRAINT refrigerator_readings_refrigeratorid_fkey FOREIGN KEY (refrigeratorid) REFERENCES refrigerators(id);


--
-- Name: refrigerators_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerators
    ADD CONSTRAINT refrigerators_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: refrigerators_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerators
    ADD CONSTRAINT refrigerators_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: refrigerators_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY refrigerators
    ADD CONSTRAINT refrigerators_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: regimen_line_items_rnrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimen_line_items
    ADD CONSTRAINT regimen_line_items_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: regimens_categoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimens
    ADD CONSTRAINT regimens_categoryid_fkey FOREIGN KEY (categoryid) REFERENCES regimen_categories(id);


--
-- Name: regimens_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY regimens
    ADD CONSTRAINT regimens_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: report_rights_rightname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY report_rights
    ADD CONSTRAINT report_rights_rightname_fkey FOREIGN KEY (rightname) REFERENCES rights(name);


--
-- Name: report_rights_templateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY report_rights
    ADD CONSTRAINT report_rights_templateid_fkey FOREIGN KEY (templateid) REFERENCES templates(id);


--
-- Name: requisition_group_members_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT requisition_group_members_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: requisition_group_members_requisitiongroupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT requisition_group_members_requisitiongroupid_fkey FOREIGN KEY (requisitiongroupid) REFERENCES requisition_groups(id);


--
-- Name: requisition_group_program_schedules_dropofffacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_dropofffacilityid_fkey FOREIGN KEY (dropofffacilityid) REFERENCES facilities(id);


--
-- Name: requisition_group_program_schedules_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: requisition_group_program_schedules_requisitiongroupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_requisitiongroupid_fkey FOREIGN KEY (requisitiongroupid) REFERENCES requisition_groups(id);


--
-- Name: requisition_group_program_schedules_scheduleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_scheduleid_fkey FOREIGN KEY (scheduleid) REFERENCES processing_schedules(id);


--
-- Name: requisition_groups_supervisorynodeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT requisition_groups_supervisorynodeid_fkey FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: requisition_line_item_losses_adjustm_requisitionlineitemid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_line_item_losses_adjustments
    ADD CONSTRAINT requisition_line_item_losses_adjustm_requisitionlineitemid_fkey FOREIGN KEY (requisitionlineitemid) REFERENCES requisition_line_items(id);


--
-- Name: requisition_line_item_losses_adjustments_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_line_item_losses_adjustments
    ADD CONSTRAINT requisition_line_item_losses_adjustments_type_fkey FOREIGN KEY (type) REFERENCES losses_adjustments_types(name);


--
-- Name: requisition_line_items_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_line_items
    ADD CONSTRAINT requisition_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: requisition_line_items_rnrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_line_items
    ADD CONSTRAINT requisition_line_items_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: requisition_status_changes_createdby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_status_changes
    ADD CONSTRAINT requisition_status_changes_createdby_fkey FOREIGN KEY (createdby) REFERENCES users(id);


--
-- Name: requisition_status_changes_modifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_status_changes
    ADD CONSTRAINT requisition_status_changes_modifiedby_fkey FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: requisition_status_changes_rnrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisition_status_changes
    ADD CONSTRAINT requisition_status_changes_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: requisitions_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: requisitions_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: requisitions_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: requisitions_supervisorynodeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_supervisorynodeid_fkey FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: role_assignments_deliveryzoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_deliveryzoneid_fkey FOREIGN KEY (deliveryzoneid) REFERENCES delivery_zones(id);


--
-- Name: role_assignments_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: role_assignments_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: role_assignments_supervisorynodeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_supervisorynodeid_fkey FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: role_assignments_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: role_rights_rightname_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT role_rights_rightname_fkey FOREIGN KEY (rightname) REFERENCES rights(name);


--
-- Name: role_rights_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT role_rights_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: shipment_line_items_orderid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shipment_line_items
    ADD CONSTRAINT shipment_line_items_orderid_fkey FOREIGN KEY (orderid) REFERENCES orders(id);


--
-- Name: shipment_line_items_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shipment_line_items
    ADD CONSTRAINT shipment_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: supervisory_nodes_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: supervisory_nodes_parentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_parentid_fkey FOREIGN KEY (parentid) REFERENCES supervisory_nodes(id);


--
-- Name: supply_lines_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: supply_lines_supervisorynodeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_supervisorynodeid_fkey FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: supply_lines_supplyingfacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_supplyingfacilityid_fkey FOREIGN KEY (supplyingfacilityid) REFERENCES facilities(id);


--
-- Name: template_parameters_templateid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_templateid_fkey FOREIGN KEY (templateid) REFERENCES templates(id);


--
-- Name: user_password_reset_tokens_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_password_reset_tokens
    ADD CONSTRAINT user_password_reset_tokens_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: users_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: users_supervisorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_supervisorid_fkey FOREIGN KEY (supervisorid) REFERENCES users(id);


--
-- Name: vaccination_adult_coverage_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccination_adult_coverage_line_items
    ADD CONSTRAINT vaccination_adult_coverage_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: vaccination_child_coverage_line_items_facilityvisitid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccination_child_coverage_line_items
    ADD CONSTRAINT vaccination_child_coverage_line_items_facilityvisitid_fkey FOREIGN KEY (facilityvisitid) REFERENCES facility_visits(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: Josh-LT
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM "Josh-LT";
GRANT ALL ON SCHEMA public TO "Josh-LT";
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

