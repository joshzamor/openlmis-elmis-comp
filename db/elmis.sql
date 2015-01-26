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
-- Name: fn_changeproductcodes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_changeproductcodes() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
message character varying(200);
BEGIN
message = 'ok';
EXECUTE 'ALTER TABLE pod_line_items DROP CONSTRAINT IF EXISTS pod_line_items_productcode_fkey';
EXECUTE 'ALTER TABLE requisition_line_items DROP CONSTRAINT IF EXISTS requisition_line_items_productcode_fkey';
EXECUTE 'ALTER TABLE shipment_line_items DROP CONSTRAINT IF EXISTS shipment_line_items_productcode_fkey';
update products p set code=m.new_code from product_code_change_log m where p.code=m.old_code and m.migrated = false;
update requisition_line_items p set productcode=m.new_code from product_code_change_log m where p.productcode=m.old_code and m.migrated = false;
update pod_line_items p set productcode=m.new_code from product_code_change_log m where p.productcode=m.old_code and m.migrated = false;
update shipment_line_items p set productcode=m.new_code from product_code_change_log m where p.productcode=m.old_code and m.migrated = false;
update product_code_change_log c set changeddate=now(), migrated = true from products p where c.new_code=p.code and c.migrated = false;
EXECUTE 'ALTER TABLE pod_line_items ADD  CONSTRAINT pod_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products (code) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION';
EXECUTE 'ALTER TABLE requisition_line_items ADD  CONSTRAINT requisition_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products (code) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION';
EXECUTE 'ALTER TABLE shipment_line_items ADD  CONSTRAINT shipment_line_items_productcode_fkey FOREIGN KEY (productcode) REFERENCES products (code) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION';
RETURN message;
EXCEPTION WHEN OTHERS THEN RETURN SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_changeproductcodes() OWNER TO postgres;

--
-- Name: fn_current_pd(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_current_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
v_rnr_id integer;
BEGIN
select id into v_rnr_id from requisitions where periodid > v_period_id order by periodid asc limit 1;
v_rnr_id = COALESCE(v_rnr_id,0);
if v_rnr_id > 0 then
select quantityreceived into v_ret from requisition_line_items where rnrid = v_rnr_id and productcode = v_productcode;
end if;
v_ret = COALESCE(v_ret,0);
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_current_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_delete_rnr(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_delete_rnr(in_rnrid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE i RECORD;
DECLARE j RECORD;
DECLARE li integer;
DECLARE v_rnr_id integer;
DECLARE v_rli_id integer;
DECLARE msg character varying(2000);
BEGIN
li := 0;
msg := 'Requisition id ' || in_rnrid || ' not found. No record deleted.';
select id into v_rnr_id from requisitions where id = in_rnrid;
if v_rnr_id > 0 then
msg = 'Requisition id ' || in_rnrid || ' deleted successfully.';
DELETE  FROM  requisition_line_item_losses_adjustments where requisitionlineitemid in (select id from requisition_line_items where rnrid in (select id from requisitions where id = v_rnr_id));
select id into li from requisition_line_items where rnrid = in_rnrid limit 1;
if li > 0 then
DELETE FROM requisition_line_items WHERE rnrid= in_rnrid;
end if;
DELETE FROM requisition_status_changes where rnrid = v_rnr_id;
DELETE FROM regimen_line_items where rnrid = v_rnr_id;
DELETE FROM orders where id = v_rnr_id;
DELETE FROM comments where rnrid = v_rnr_id;
DELETE FROM requisitions WHERE id= in_rnrid;
end if;
RETURN msg;
EXCEPTION WHEN OTHERS THEN
RETURN 'Error in deleting requisition id ' || in_rnrid || '. Please consult database administrtor.';
END;
$$;


ALTER FUNCTION public.fn_delete_rnr(in_rnrid integer) OWNER TO postgres;

--
-- Name: fn_dw_scheduler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_dw_scheduler() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE msg character varying(2000);
BEGIN
msg := 'Procedure completed successfully.';
delete from alert_summary;
select fn_populate_alert_facility_stockedout();
select fn_populate_alert_requisition_approved();
select fn_populate_alert_requisition_pending();
select fn_populate_alert_requisition_rejected();
select fn_populate_alert_requisition_emergency();
RETURN msg;
EXCEPTION WHEN OTHERS THEN
return SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_dw_scheduler() OWNER TO postgres;

--
-- Name: fn_get_geozonetree(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_geozonetree(in_facilityid integer) RETURNS TABLE(districtid integer, regionid integer, zoneid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
finalQuery            VARCHAR;
v_geographiczoneid integer;
v_districtid  integer;
v_regionid    integer;
v_zoneid      integer;
BEGIN
v_geographiczoneid = 0;
v_districtid = 0;
v_regionid = 0;
v_zoneid = 0;
select facilities.geographiczoneid into v_geographiczoneid from facilities where facilities.id = in_facilityid;
if coalesce(v_geographiczoneid, 0)  <> 0 THEN
v_districtid = v_geographiczoneid;
end if;
if coalesce(v_districtid, 0)  <> 0 THEN
select geographic_zones.parentid into v_regionid from geographic_zones where geographic_zones.id = v_districtid;
end if;
if coalesce(v_regionid, 0)  <> 0 THEN
select geographic_zones.parentid into v_zoneid from geographic_zones where geographic_zones.id = v_regionid;
end if;
finalQuery := 'SELECT '|| v_districtid ||','||v_regionid||','||v_zoneid;
RETURN QUERY EXECUTE finalQuery;
END;
$$;


ALTER FUNCTION public.fn_get_geozonetree(in_facilityid integer) OWNER TO postgres;

--
-- Name: fn_get_max_mos(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_max_mos(v_program integer, v_facility integer, v_product character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_programproductid integer;
v_facilitytypeid integer;
v_productid integer;
BEGIN
select id into v_productid from products where code =  v_product;
v_programproductid := fn_get_program_product_id(v_program, v_productid);
select typeid into v_facilitytypeid from facilities where id =  v_facility;
select maxmonthsofstock into v_ret from facility_approved_products where programproductid = v_programproductid and facilitytypeid = v_facilitytypeid;
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_get_max_mos(v_program integer, v_facility integer, v_product character varying) OWNER TO postgres;

--
-- Name: fn_get_notification_details(anyelement, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_notification_details(_tbl_name anyelement, id integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) || ' where alertsummaryid = '||id;
END
$$;


ALTER FUNCTION public.fn_get_notification_details(_tbl_name anyelement, id integer) OWNER TO postgres;

--
-- Name: fn_get_notification_details(anyelement, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) ||
' where programId = '||programId ||' and periodId= '||periodId||
'and geographiczoneid in (select geographiczoneid from fn_get_user_geographiczone_children('||userId||', '||zoneId||'))';
END
$$;


ALTER FUNCTION public.fn_get_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer) OWNER TO postgres;

--
-- Name: fn_get_parent_geographiczone(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_parent_geographiczone(v_geographiczoneid integer, v_level integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
v_highest_parent_id integer;
v_highest_parent_name geographic_zones.name%TYPE;
v_this_parent_id integer;
v_this_parent_name geographic_zones.name%TYPE;
v_current_parent_id integer;
v_current_parent_name geographic_zones.name%TYPE;
v_parent_geographizone_name geographic_zones.name%TYPE;
BEGIN
select id, name into v_highest_parent_id, v_highest_parent_name from geographic_zones where parentid is null;
select parentid, name into v_this_parent_id, v_this_parent_name from geographic_zones where id = v_geographiczoneid;
IF (v_geographiczoneid = v_highest_parent_id) THEN
v_parent_geographizone_name := v_highest_parent_name;
RETURN v_parent_geographizone_name;
END IF;
IF v_level = 0 THEN
v_parent_geographizone_name = v_this_parent_name;
RETURN v_parent_geographizone_name;
END IF;
FOR i IN 1..v_level LOOP
select parentid,name into v_this_parent_id, v_parent_geographizone_name from geographic_zones where id = v_this_parent_id;
END LOOP;
v_parent_geographizone_name := coalesce(v_parent_geographizone_name, 'Unknown');
return v_parent_geographizone_name;
END;
$$;


ALTER FUNCTION public.fn_get_parent_geographiczone(v_geographiczoneid integer, v_level integer) OWNER TO postgres;

--
-- Name: fn_get_program_product_id(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_program_product_id(v_program integer, v_product integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
BEGIN
SELECT id into v_ret FROM program_products where programid = v_program and productid = v_product;
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_get_program_product_id(v_program integer, v_product integer) OWNER TO postgres;

--
-- Name: fn_get_reporting_status_by_facilityid_programid_and_periodid(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_reporting_status_by_facilityid_programid_and_periodid(v_facilityid integer, v_programid integer, v_periodid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret TEXT;
v_reporting_date INTEGER;
v_late_days INTEGER;
v_req_facilityid INTEGER;
BEGIN
select facilityid from requisitions where facilityid = v_facilityid and programid = v_programid and periodid = v_periodid INTO v_req_facilityid;
IF v_req_facilityid IS NULL THEN RETURN 'non_reporting'; END IF;
SELECT value from configuration_settings where key='LATE_REPORTING_DAYS' INTO v_late_days;
SELECT date_part('day', (select createddate from requisitions r where r.programId = v_programid and r.periodId = v_periodid and facilityid = v_facilityid)-
(select startdate from processing_periods where id = v_periodid))::integer INTO v_reporting_date;
SELECT CASE WHEN
COALESCE(v_reporting_date,0) > COALESCE(v_late_days,10)
THEN 'late_reporting'
ELSE 'reporting' END INTO v_ret;
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_get_reporting_status_by_facilityid_programid_and_periodid(v_facilityid integer, v_programid integer, v_periodid integer) OWNER TO postgres;

--
-- Name: fn_get_stocked_out_notification_details(anyelement, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_stocked_out_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer, productid integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) ||
' where programId = '||programId ||' and periodId= '||periodId||' and productId= '||productId||
'and geographiczoneid in (select geographiczoneid from fn_get_user_geographiczone_children('||userId||', '||zoneId||'))';
END
$$;


ALTER FUNCTION public.fn_get_stocked_out_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer, productid integer) OWNER TO postgres;

--
-- Name: fn_get_supervisorynodeid_by_facilityid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_supervisorynodeid_by_facilityid(v_facilityid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
BEGIN
SELECT
requisition_groups.supervisorynodeid into v_ret
FROM
requisition_groups
INNER JOIN requisition_group_members ON requisition_groups.id = requisition_group_members.requisitiongroupid
where requisition_group_members.facilityid = v_facilityid LIMIT 1;
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_get_supervisorynodeid_by_facilityid(v_facilityid integer) OWNER TO postgres;

--
-- Name: fn_get_supplying_facility_name(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_supplying_facility_name(v_supervisorynode_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
v_supplying_facility_id integer;
v_supplying_facility_name facilities.name%TYPE;
BEGIN
select supplyingfacilityid into v_supplying_facility_id from supply_lines where supervisorynodeid = v_supervisorynode_id;
select name into v_supplying_facility_name from facilities where id =  v_supplying_facility_id;
v_supplying_facility_name = coalesce(v_supplying_facility_name, 'Unknown');
return v_supplying_facility_name;
END;
$$;


ALTER FUNCTION public.fn_get_supplying_facility_name(v_supervisorynode_id integer) OWNER TO postgres;

--
-- Name: fn_get_user_default_settings(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_user_default_settings(in_programid integer, in_facilityid integer) RETURNS TABLE(programid integer, facilityid integer, scheduleid integer, periodid integer, geographiczoneid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
_query VARCHAR;
finalQuery            VARCHAR;
rowrec                 RECORD;
BEGIN
_query := 'SELECT
programid, facilityid, scheduleid, periodid, geographiczoneid
FROM
vw_expected_facilities
WHERE
facilityid = ' || in_facilityid || '
AND programid = ' || in_programid || '
AND periodid IN (
SELECT
MAX (periodid) periodid
FROM
requisitions
WHERE
programid = ' || in_programid || '
AND facilityid = '|| in_facilityid || '
)';
RETURN QUERY EXECUTE _query;
END;
$$;


ALTER FUNCTION public.fn_get_user_default_settings(in_programid integer, in_facilityid integer) OWNER TO postgres;

--
-- Name: fn_get_user_geographiczone_children(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_get_user_geographiczone_children(in_userid integer, in_parentid integer) RETURNS TABLE(geographiczoneid integer, levelid integer, parentid integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
finalQuery            VARCHAR;
v_parents character varying;
v_current_parentid integer;
v_parentid integer;
v_result INTEGER = 0;
BEGIN
finalQuery :=
'WITH  recursive  userGeographicZonesRec AS
(SELECT *
FROM geographic_zones
WHERE id = '||in_parentid||'
UNION
SELECT gz.*
FROM geographic_zones gz
JOIN userGeographicZonesRec  ON gz.parentId = userGeographicZonesRec.id )
SELECT rec.id,rec.levelid,rec.parentid from userGeographicZonesRec rec
INNER JOIN vw_user_geographic_zones uz on uz.geographiczoneid = rec.id
where userid = '||in_userid;
RETURN QUERY EXECUTE finalQuery;
END;
$$;


ALTER FUNCTION public.fn_get_user_geographiczone_children(in_userid integer, in_parentid integer) OWNER TO postgres;

--
-- Name: fn_getstockstatusgraphdata(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_getstockstatusgraphdata(in_programid integer, in_geographiczoneid integer, in_periodid integer, in_productid character varying) RETURNS TABLE(productid integer, productname text, periodid integer, periodname text, periodyear integer, quantityonhand integer, quantityconsumed integer, amc integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
stockStatusQuery VARCHAR;
finalQuery            VARCHAR;
rowSS                 RECORD;
v_scheduleid integer;
v_check_id integer;
rec RECORD;
BEGIN
SELECT scheduleid INTO v_scheduleid FROM processing_periods WHERE id = in_periodid;
v_scheduleid = COALESCE(v_scheduleid,0);
EXECUTE 'CREATE TEMP TABLE _stock_status (
productid integer,
productname text,
periodid integer,
periodname text,
periodyear integer,
quantityonhand integer,
quantityconsumed integer,
amc integer
) ON COMMIT DROP';
stockStatusQuery :=
'SELECT
product_id productid,
product_primaryname productname,
processing_periods_id periodid,
processing_periods_name periodname,
EXTRACT (
''year''
FROM
processing_periods_start_date
) periodyear,
SUM (stockinhand) quantityonhand,
SUM (quantitydispensed) quantityconsumed,
SUM (amc) amc
FROM
vw_requisition_detail_2
WHERE
program_id = '|| in_programid ||'
AND (zone_id = '|| in_geographiczoneid || ' OR ' || in_geographiczoneid ||' = 0)
AND product_id IN ('|| in_productid ||')
AND processing_periods_id IN (select id from processing_periods where scheduleid = '|| v_scheduleid || ' AND id <= '|| in_periodid || ' order by id desc limit 4)
GROUP BY
product_id,
product_primaryname,
processing_periods_id,
processing_periods_name,
EXTRACT (
''year''
FROM
processing_periods_start_date
)';
FOR rowSS IN EXECUTE stockStatusQuery
LOOP
EXECUTE
'INSERT INTO _stock_status VALUES (' ||
COALESCE(rowSS.productid,0) || ',' ||
quote_literal(rowSS.productname::text) || ',' ||
COALESCE(rowSS.periodid,0) || ',' ||
quote_literal(rowSS.periodname::text) || ',' ||
COALESCE(rowSS.periodyear,0) || ',' ||
COALESCE(rowSS.quantityonhand,0) || ',' ||
COALESCE(rowSS.quantityconsumed,0) || ',' ||
COALESCE(rowSS.amc,0) || ')';
END LOOP;
FOR rec IN
select distinct ss.productid, ss.productname, s.id periodid, s.name periodname, EXTRACT ('year' FROM startdate) periodyear from _stock_status ss
cross join (select * from processing_periods
where scheduleid = v_scheduleid and id <= in_periodid order by id desc
limit 4) s order by ss.productid, s.id desc LOOP
select t.productid into v_check_id from _stock_status t where t.productid = rec.productid and t.periodid = rec.periodid;
v_check_id = COALESCE(v_check_id,0);
if v_check_id = 0 THEN
insert into _stock_status values (rec.productid, rec.productname, rec.periodid, rec.periodname, rec.periodyear, 0, 0, 0);
end if;
END LOOP;
finalQuery := 'SELECT productid, productname, periodid, periodname, periodyear, quantityonhand, quantityconsumed, amc FROM  _stock_status';
RETURN QUERY EXECUTE finalQuery;
END;
$$;


ALTER FUNCTION public.fn_getstockstatusgraphdata(in_programid integer, in_geographiczoneid integer, in_periodid integer, in_productid character varying) OWNER TO postgres;

--
-- Name: fn_populate_alert_facility_stockedout(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_alert_facility_stockedout() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_summary RECORD ;
rec_detail RECORD ;
msg CHARACTER VARYING (2000) ;
v_summaryid integer;
BEGIN
msg := 'fn_populate_alert_facility_stockedout- Data saved successfully' ;
delete from alert_summary where alerttypeid = 'FACILITY_STOCKED_OUT_OF_TRACER_PRODUCT';
FOR rec_summary IN
SELECT
vw_stock_status_2.programid,
vw_stock_status_2.periodid,
vw_stock_status_2.gz_id as geoid,
vw_stock_status_2.productid,
vw_stock_status_2.product,
Count(vw_stock_status_2.facility_id) AS facility_count
FROM
vw_stock_status_2
WHERE
vw_stock_status_2.indicator_product = true AND
vw_stock_status_2.status = 'SO'
GROUP BY
1, 2, 3, 4, 5
LOOP
INSERT INTO alert_summary(
statics_value, description, geographiczoneid, alerttypeid,programid, periodid, productid)
VALUES (rec_summary.facility_count,'Facilities stocked out of ' ||rec_summary.product, rec_summary.geoid, 'FACILITY_STOCKED_OUT_OF_TRACER_PRODUCT', rec_summary.programid, rec_summary.periodid, rec_summary.productid);
end loop;
DELETE FROM alert_facility_stockedout;
FOR rec_detail IN
SELECT
vw_stock_status_2.programid,
vw_stock_status_2.periodid,
vw_stock_status_2.gz_id as geoid,
vw_stock_status_2.location as geographiczonename,
vw_stock_status_2.facility_id,
vw_stock_status_2.facility,
vw_stock_status_2.productid,
vw_stock_status_2.product,
vw_stock_status_2.stockoutdays,
vw_stock_status_2.amc
FROM
vw_stock_status_2
WHERE
vw_stock_status_2.indicator_product = true AND
vw_stock_status_2.status = 'SO'
LOOP --fetch the table row inside the loop
select id into v_summaryid from alert_summary where programid = rec_detail.programid and geographiczoneid = rec_detail.geoid and productid = rec_detail.productid and alerttypeid = 'FACILITY_STOCKED_OUT_OF_TRACER_PRODUCT';
INSERT INTO alert_facility_stockedout(
alertsummaryid, programid, periodid, geographiczoneid, geographiczonename, facilityid, facilityname, productid, productname, stockoutdays, amc)
VALUES (v_summaryid, rec_detail.programid, rec_detail.periodid, rec_detail.geoid, rec_detail.geographiczonename, rec_detail.facility_id, rec_detail.facility, rec_detail.productid, rec_detail.product, rec_detail.stockoutdays, rec_detail.amc);
END LOOP;
RETURN msg ;
EXCEPTION
WHEN OTHERS THEN
RETURN 'fn_populate_alert_facility_stockedout - Error populating data. Please consult database administrtor. ' || SQLERRM ;
END ;
$$;


ALTER FUNCTION public.fn_populate_alert_facility_stockedout() OWNER TO postgres;

--
-- Name: fn_populate_alert_requisition_approved(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_alert_requisition_approved() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_summary RECORD ;
rec_detail RECORD ;
msg CHARACTER VARYING (2000) ;
v_summaryid integer;
BEGIN
msg := 'fn_populate_alert_requisition_approved - Data saved successfully' ;
delete from alert_summary where alerttypeid = 'REQUISITION_APPROVED';
FOR rec_summary IN
SELECT
geographiczoneid, programid, periodid, count(rnrid) rnr_summary_count
FROM
vw_facility_requisitions
where  status = 'APPROVED'
group by 1,2,3
LOOP
INSERT INTO alert_summary(
statics_value, description, geographiczoneid, alerttypeid,programid,periodid)
VALUES (rec_summary.rnr_summary_count, 'Requisition Approved', rec_summary.geographiczoneid, 'REQUISITION_APPROVED', rec_summary.programid,rec_summary.periodid);
end loop;
DELETE FROM alert_requisition_approved;
FOR rec_detail IN
SELECT
rnrid,
CASE emergency WHEN true then 'Emergency' else 'Regular' end as req_type,
facilityname,
facilityid,
periodid,
programid,
geographiczoneid,
geographiczonename
FROM
vw_facility_requisitions
where status = 'APPROVED'
LOOP --fetch the table row inside the loop
select id into v_summaryid from alert_summary where geographiczoneid = rec_detail.geographiczoneid and programid = rec_detail.programid  and periodid = rec_detail.periodid and alerttypeid = 'REQUISITION_APPROVED';
INSERT INTO alert_requisition_approved(
alertsummaryid, programid, periodid, geographiczoneid, geographiczonename,rnrid, rnrtype, facilityid, facilityname)
VALUES (v_summaryid, rec_detail.programid, rec_detail.periodid, rec_detail.geographiczoneid, rec_detail.geographiczonename,  rec_detail.rnrid, rec_detail.req_type, rec_detail.facilityid, rec_detail.facilityname);
END LOOP;
RETURN msg ;
EXCEPTION
WHEN OTHERS THEN
RETURN 'fn_populate_alert_requisition_approved - Error populating data. Please consult database administrtor. ' || SQLERRM ;
END ;
$$;


ALTER FUNCTION public.fn_populate_alert_requisition_approved() OWNER TO postgres;

--
-- Name: fn_populate_alert_requisition_emergency(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_alert_requisition_emergency() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_summary RECORD ;
rec_detail RECORD ;
msg CHARACTER VARYING (2000) ;
v_summaryid integer;
BEGIN
msg := 'fn_populate_alert_requisition_emergency - Data saved successfully' ;
delete from alert_summary where alerttypeid = 'EMERGENCY_REQUISITION';
FOR rec_summary IN
SELECT
geographiczoneid, programid, periodid, count(rnrid) rec_count
FROM
vw_facility_requisitions
where emergency = true
group by 1,2,3
LOOP
INSERT INTO alert_summary(
statics_value, description, geographiczoneid, alerttypeid,
programid, periodid)
VALUES (rec_summary.rec_count, ' Emergency Requisitions', rec_summary.geographiczoneid, 'EMERGENCY_REQUISITION', rec_summary.programid, rec_summary.periodid);
end loop;
DELETE FROM alert_requisition_emergency;
FOR rec_detail IN
SELECT
rnrid,
CASE emergency WHEN true then 'Emergency' else 'Regular' end as req_type,
facilityname,
facilityid,
periodid,
programid,
geographiczoneid,
geographiczonename,
status
FROM
vw_facility_requisitions
where emergency = true
LOOP --fetch the table row inside the loop
select id into v_summaryid from alert_summary where geographiczoneid = rec_detail.geographiczoneid and programid = rec_detail.programid and periodid = rec_detail.periodid and alerttypeid = 'EMERGENCY_REQUISITION';
INSERT INTO alert_requisition_emergency(
alertsummaryid,programid, periodid, geographiczoneid, geographiczonename, rnrid, rnrtype, facilityid, status, facilityname)
VALUES (v_summaryid, rec_detail.programid, rec_detail.periodid, rec_detail.geographiczoneid, rec_detail.geographiczonename, rec_detail.rnrid, 'Emergency', rec_detail.facilityid, rec_detail.status, rec_detail.facilityname);
END LOOP;
RETURN msg ;
EXCEPTION
WHEN OTHERS THEN
RETURN 'fn_populate_alert_requisition_emergency - Error populating data. Please consult database administrtor. ' || SQLERRM ;
END ;
$$;


ALTER FUNCTION public.fn_populate_alert_requisition_emergency() OWNER TO postgres;

--
-- Name: fn_populate_alert_requisition_pending(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_alert_requisition_pending() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_summary RECORD ;
rec_detail RECORD ;
msg CHARACTER VARYING (2000) ;
v_summaryid integer;
BEGIN
msg := 'fn_populate_alert_requisition_pending - Data saved successfully' ;
delete from alert_summary where alerttypeid = 'REQUISITION_PENDING';
FOR rec_summary IN
SELECT
geographiczoneid, programid, periodid, count(rnrid) rec_count
FROM
vw_facility_requisitions
where  status = 'IN_APPROVAL'
group by 1,2, 3
LOOP
INSERT INTO alert_summary(
statics_value, description, geographiczoneid, alerttypeid, programid, periodid)
VALUES (rec_summary.rec_count, ' Requisitions Pending', rec_summary.geographiczoneid, 'REQUISITION_PENDING', rec_summary.programid, rec_summary.periodid);
end loop;
DELETE FROM alert_requisition_pending;
FOR rec_detail IN
SELECT
rnrid,
CASE emergency WHEN true then 'Emergency' else 'Regular' end as req_type,
facilityname,
facilityid,
periodid,
programid,
geographiczoneid,
geographiczonename
FROM
vw_facility_requisitions
where status = 'IN_APPROVAL'
LOOP --fetch the table row inside the loop
select id into v_summaryid from alert_summary where geographiczoneid = rec_detail.geographiczoneid and programid = rec_detail.programid and  periodid = rec_detail.periodid and alerttypeid = 'REQUISITION_PENDING';
INSERT INTO alert_requisition_pending(
alertsummaryid, programid, periodid, geographiczoneid, geographiczonename,rnrid, rnrtype, facilityid, facilityname)
VALUES (v_summaryid, rec_detail.programid, rec_detail.periodid, rec_detail.geographiczoneid, rec_detail.geographiczonename, rec_detail.rnrid, rec_detail.req_type, rec_detail.facilityid, rec_detail.facilityname);
END LOOP;
RETURN msg ;
EXCEPTION
WHEN OTHERS THEN
RETURN 'fn_populate_alert_requisition_pending - Error populating data. Please consult database administrtor. ' || SQLERRM ;
END ;
$$;


ALTER FUNCTION public.fn_populate_alert_requisition_pending() OWNER TO postgres;

--
-- Name: fn_populate_alert_requisition_rejected(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_alert_requisition_rejected() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec_summary RECORD ;
rec_detail RECORD ;
msg CHARACTER VARYING (2000) ;
v_summaryid integer;
BEGIN
msg := 'fn_populate_alert_requisition_rejected - Data saved successfully' ;
delete from alert_summary where alerttypeid = 'REQUISITION_REJECTED';
FOR rec_summary IN
SELECT
geographiczoneid, programid, periodid, count(rnrid) rec_count
FROM
vw_facility_requisitions
where  status = 'IN_APPROVAL'
group by 1,2, 3
LOOP
INSERT INTO alert_summary(
statics_value, description, geographiczoneid, alerttypeid, programid, periodid)
VALUES (rec_summary.rec_count, ' Requisitions Rejected', rec_summary.geographiczoneid, 'REQUISITION_REJECTED', rec_summary.programid, rec_summary.periodid);
end loop;
DELETE FROM alert_requisition_rejected;
FOR rec_detail IN
SELECT
rnrid,
CASE emergency WHEN true then 'Emergency' else 'Regular' end as req_type,
facilityname,
facilityid,
periodid,
programid,
geographiczoneid,
geographiczonename
FROM
vw_facility_requisitions
where status = 'REJECTED'
LOOP --fetch the table row inside the loop
select id into v_summaryid from alert_summary where geographiczoneid = rec_detail.geographiczoneid and programid = rec_detail.programid and  periodid = rec_detail.periodid and alerttypeid = 'REQUISITION_REJECTED';
INSERT INTO alert_requisition_rejected(
alertsummaryid, programid, periodid, geographiczoneid, geographiczonename,rnrid, rnrtype, facilityid, facilityname)
VALUES (v_summaryid, rec_detail.programid, rec_detail.periodid, rec_detail.geographiczoneid, rec_detail.geographiczonename, rec_detail.rnrid, rec_detail.req_type, rec_detail.facilityid, rec_detail.facilityname);
END LOOP;
RETURN msg ;
EXCEPTION
WHEN OTHERS THEN
RETURN 'fn_populate_alert_requisition_rejected - Error populating data. Please consult database administrtor. ' || SQLERRM ;
END ;
$$;


ALTER FUNCTION public.fn_populate_alert_requisition_rejected() OWNER TO postgres;

--
-- Name: fn_populate_dw_orders(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_dw_orders(in_flag integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
rec RECORD ;
rec2 RECORD ;
li INTEGER ;
msg CHARACTER VARYING (2000) ;
v_programid INTEGER ;
v_geographiczoneid INTEGER ;
v_facilityid INTEGER ;
v_facilitycode CHARACTER VARYING (50) ;
v_periodid INTEGER ;
v_rnrid INTEGER ;
v_status CHARACTER VARYING (20) ;
v_productid INTEGER ;
v_productcode CHARACTER VARYING (50) ;
v_quantityrequested INTEGER ;
v_quantityapproved INTEGER ;
v_quantityapprovedprev INTEGER ;
v_quantityshipped INTEGER ;
v_quantityreceived INTEGER ;
v_createddate TIMESTAMP ;
v_approveddate TIMESTAMP ;
v_shippeddate TIMESTAMP ;
v_receiveddate TIMESTAMP ;
v_stocking CHARACTER (1) ;
v_reporting CHARACTER (1) ;
v_programname CHARACTER VARYING (50) ;
v_facilityname CHARACTER VARYING (50) ;
v_productprimaryname CHARACTER VARYING (150) ;
v_productfullname CHARACTER VARYING (250) ;
v_geographiczonename CHARACTER VARYING (250) ;
v_processingperiodname CHARACTER VARYING (250) ;
v_soh INTEGER;
v_amc  INTEGER;
v_mos numeric(6,1);
v_previousstockinhand integer;
v_emergency boolean;
v_supervisorynodeid INTEGER;
v_requisitiongroupid integer;
v_requisitiongroupname character varying(50);
v_facilitytypeid integer;
v_facilitytypename character varying(50);
v_scheduleid integer;
v_schedulename character varying(50);
v_productcategoryid integer;
v_productcategoryname character varying(150);
v_productgroupid integer;
v_productgroupname character varying(250);
v_stockedoutinpast boolean;
v_suppliedinpast boolean;
v_mossuppliedinpast numeric(6,1);
v_late_days integer;
p1 RECORD;
p2 RECORD;
previous_periodid integer;
v_totalsuppliedinpast integer;
v_mossuppliedinpast_denominator integer;
v_previousrnrid integer;
v_lastupdatedate TIMESTAMP ;
v_tracer boolean;
v_skipped boolean;
v_stockoutdays integer;
BEGIN
li := 0 ;
msg := 'Data saved successfully' ;
DELETE FROM dw_orders ;
FOR rec IN
SELECT
vw_requisition_detail_2.*
FROM
vw_requisition_detail_2 where skipped = FALSE
LOOP --fetch the table row inside the loop
v_programid = rec.program_id ;
v_geographiczoneid = rec.zone_id ;
v_facilityid = rec.facility_id ;
v_facilitycode = rec.facility_code ;
v_periodid = rec.processing_periods_id ;
v_rnrid = rec.req_id ;
v_status = rec.req_status ;
v_productid = rec.product_id ;
v_productcode = rec.product_code ;
v_quantityrequested = rec.quantityrequested ;
v_quantityapproved = rec.quantityapproved ;
v_quantityshipped = 1 ;
v_quantityreceived = rec.quantityreceived ; -- will set the date later
v_createddate = NULL ;
v_approveddate = NULL ;
v_shippeddate = NULL ;
v_receiveddate = NULL ;
v_programname = rec.program_name ;
v_facilityname = rec.facility_name ;
v_productprimaryname = rec.product_primaryname ;
v_productfullname = rec.product ;
v_processingperiodname = rec.processing_periods_name ;
v_soh = rec.stockinhand;
v_amc = rec.amc;
v_mos = CASE WHEN v_amc > 0 THEN v_soh / v_amc ELSE 0 END;
v_emergency = rec.emergency;
v_supervisorynodeid = NULL;
v_requisitiongroupid = NULL;
v_requisitiongroupname = NULL;
v_facilitytypeid = rec.facility_type_id;
v_facilitytypename = rec.facility_type_name;
v_scheduleid = rec.scheduleid;
v_schedulename = rec.schedulename;
v_productcategoryid = rec.categoryid;
v_productcategoryname = rec.categoryname;
v_productgroupid = rec.productgroupid;
v_productgroupname = rec.productgroupid;
v_stockedoutinpast = 'N';
v_suppliedinpast = 'N';
v_mossuppliedinpast = 1;
v_geographiczonename =  rec.region;
v_previousstockinhand =  rec.previousstockinhand;
v_tracer =  rec.tracer;
v_skipped =  rec.skipped;
v_stockoutdays =  rec.stockoutdays;
v_totalsuppliedinpast = 0;
if v_previousstockinhand = 0 then
v_stockedoutinpast = 'Y';
end if;
select * from fn_previous_rnr_detail(v_programid, v_periodid,v_facilityid,v_productcode) into p1;
v_previousrnrid = COALESCE(p1.rnrid,0);
select periodid into previous_periodid from requisitions where requisitions.id = p1.rnrid;
previous_periodid = COALESCE(previous_periodid,0);
select * from fn_previous_rnr_detail(v_programid, previous_periodid,v_facilityid,v_productcode) into p2;
v_mossuppliedinpast_denominator = 0;
if COALESCE(v_soh,0) > 0 then
v_mossuppliedinpast_denominator  = v_amc;
elsif COALESCE(p1.stockinhand,0) > 0 then
v_mossuppliedinpast_denominator  = p1.amc;
elsif COALESCE(p2.stockinhand,0) > 0 then
v_mossuppliedinpast_denominator  = p2.amc;
end if;
if p1.stockinhand = 0 and p2.stockinhand = 0 then
v_stockedoutinpast = 'Y';
end if;
if p1.quantityreceived > 0 or p2.quantityreceived > 0 then
v_suppliedinpast = 'Y';
v_totalsuppliedinpast = COALESCE(p1.quantityreceived,0) + COALESCE(p2.quantityreceived,0);
end if;
v_mossuppliedinpast = 0;
if v_mossuppliedinpast_denominator > 0 then
v_mossuppliedinpast = v_totalsuppliedinpast /  v_mossuppliedinpast_denominator;
end if;
v_quantityapprovedprev = COALESCE(p1.quantityapproved,0);
IF rec.stockinhand = 0 THEN
v_stocking = 'S' ;
ELSEIF rec.stockinhand > 0
AND rec.stockinhand <= (
COALESCE (rec.amc, 0) * rec.nominaleop
) THEN
v_stocking = 'U' ;
ELSEIF rec.stockinhand > 0
AND rec.stockinhand >= (
COALESCE (rec.amc, 0) * rec.nominaleop
) THEN
v_stocking = 'O' ;
ELSE
v_stocking = 'A' ;
END IF ;
INSERT INTO dw_orders (
programid,
geographiczoneid,
facilityid,
facilitycode,
periodid,
rnrid,
emergency,
status,
productid,
productcode,
quantityrequested,
quantityapproved,
quantityshipped,
quantityreceived,
quantityapprovedprev,
createddate,
approveddate,
shippeddate,
receiveddate,
stocking,
reporting,
programname,
facilityname,
productprimaryname,
productfullname,
geographiczonename,
processingperiodname,
soh,
amc,
mos,
requisitiongroupid,
requisitiongroupname,
facilitytypeid,
facilitytypename,
scheduleid,
schedulename,
productcategoryid,
productcategoryname,
productgroupid,
productgroupname,
stockedoutinpast,
suppliedinpast,
mossuppliedinpast,
supervisorynodeid,
modifieddate,
tracer,
skipped,
stockoutdays
)
VALUES
(
v_programid,
v_geographiczoneid,
v_facilityid,
v_facilitycode,
v_periodid,
v_rnrid,
v_emergency,
v_status,
v_productid,
v_productcode,
v_quantityrequested,
v_quantityapproved,
v_quantityshipped,
v_quantityreceived,
v_quantityapprovedprev,
v_createddate,
v_approveddate,
v_shippeddate,
v_receiveddate,
v_stocking,
v_reporting,
v_programname,
v_facilityname,
v_productprimaryname,
v_productfullname,
v_geographiczonename,
v_processingperiodname,
v_soh,
v_amc,
v_mos,
v_requisitiongroupid,
v_requisitiongroupname,
v_facilitytypeid,
v_facilitytypename,
v_scheduleid,
v_schedulename,
v_productcategoryid,
v_productcategoryname,
v_productgroupid,
v_productgroupname,
v_stockedoutinpast,
v_suppliedinpast,
v_mossuppliedinpast,
v_supervisorynodeid,
now(),
v_tracer,
v_skipped,
v_stockoutdays
) ;
END loop ; -- update rnr create date
UPDATE dw_orders o
SET createddate = r.createddate
FROM
requisitions r
WHERE
o.rnrid = r. ID ;
UPDATE dw_orders o
SET initiateddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'INITIATED';
UPDATE dw_orders o
SET submitteddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'SUBMITTED';
UPDATE dw_orders o
SET authorizeddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'AUTHORIZED';
UPDATE dw_orders o
SET inapprovaldate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'IN_APPROVAL';
UPDATE dw_orders o
SET approveddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'APPROVED';
UPDATE dw_orders o
SET releaseddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'RELEASED';
SELECT value from configuration_settings where key='LATE_REPORTING_DAYS' INTO v_late_days;
v_late_days = COALESCE(v_late_days,10);
UPDATE dw_orders o
SET reporting = CASE
WHEN (EXTRACT (DAY FROM r.createddate) - (select EXTRACT (DAY FROM startdate) from processing_periods where id = r.periodid)) > v_late_days THEN
'L'
ELSE
'O'
END
FROM
requisitions r
WHERE
o.rnrid = r. ID ; -- update rnr approved date
UPDATE dw_orders o
SET shippeddate = s.shippeddate,
quantityshipped = s.quantityshipped
FROM
shipment_line_items s
WHERE
o.rnrid = s.orderid
AND o.productcode = s.productcode ; -- update rnr received date from pod
UPDATE dw_orders o
SET receiveddate = P .receiveddate
FROM
pod P
WHERE
o.rnrid = P .orderid ;
delete from alert_summary;
msg = fn_populate_alert_facility_stockedout();
msg = fn_populate_alert_requisition_approved();
msg = fn_populate_alert_requisition_pending();
msg = fn_populate_alert_requisition_rejected();
msg = fn_populate_alert_requisition_emergency();
RETURN msg ; EXCEPTION
WHEN OTHERS THEN
RETURN 'Error populating data. Please consult database administrtor. ' || SQLERRM;
END ; $$;


ALTER FUNCTION public.fn_populate_dw_orders(in_flag integer) OWNER TO postgres;

--
-- Name: FUNCTION fn_populate_dw_orders(in_flag integer); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION fn_populate_dw_orders(in_flag integer) IS 'populated data in dw_orders table - a flat table to store requisition, stock status, reporting status
References:
dw_orders - table
pod - table
vw_requisition_detail - view
shipment_line_items - table
returns success message on success
returns error message on failure
';


--
-- Name: fn_populate_dw_rnr(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_populate_dw_rnr() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
rec RECORD ;
rec2 RECORD ;
li INTEGER ;
msg CHARACTER VARYING (2000) ;
v_programid INTEGER ;
v_geographiczoneid INTEGER ;
v_facilityid INTEGER ;
v_facilitycode CHARACTER VARYING (50) ;
v_periodid INTEGER ;
v_rnrid INTEGER ;
v_status CHARACTER VARYING (20) ;
v_productid INTEGER ;
v_productcode CHARACTER VARYING (50) ;
v_quantityrequested INTEGER ;
v_quantityapproved INTEGER ;
v_quantityshipped INTEGER ;
v_quantityreceived INTEGER ;
v_createddate TIMESTAMP ;
v_approveddate TIMESTAMP ;
v_shippeddate TIMESTAMP ;
v_receiveddate TIMESTAMP ;
v_stocking CHARACTER (1) ;
v_reporting CHARACTER (1) ;
v_programname CHARACTER VARYING (50) ;
v_facilityname CHARACTER VARYING (50) ;
v_productprimaryname CHARACTER VARYING (150) ;
v_productfullname CHARACTER VARYING (250) ;
v_geographiczonename CHARACTER VARYING (250) ;
v_processingperiodname CHARACTER VARYING (250) ;
v_soh INTEGER;
v_amc  INTEGER;
v_mos numeric(6,1);
v_previousstockinhand integer;
v_emergency boolean;
v_supervisorynodeid INTEGER;
v_requisitiongroupid integer;
v_requisitiongroupname character varying(50);
v_facilitytypeid integer;
v_facilitytypename character varying(50);
v_scheduleid integer;
v_schedulename character varying(50);
v_productcategoryid integer;
v_productcategoryname character varying(150);
v_productgroupid integer;
v_productgroupname character varying(250);
v_stockedoutinpast boolean;
v_suppliedinpast boolean;
v_mossuppliedinpast numeric(6,1);
v_late_days integer;
p1 RECORD;
p2 RECORD;
previous_periodid integer;
v_totalsuppliedinpast integer;
v_mossuppliedinpast_denominator integer;
v_previousrnrid integer;
v_lastupdatedate TIMESTAMP ;
v_tracer boolean;
v_skipped boolean;
v_stockoutdays integer;
BEGIN
li := 0 ;
IF (TG_OP = 'INSERT') THEN
DELETE FROM dw_orders where rnrid = NEW.rnrid; -- OLD.rnrid is null
ELSEIF (TG_OP = 'UPDATE') THEN
DELETE FROM dw_orders where rnrid = NEW.rnrid; -- OLD.rnrid = NEW.rnrid
ELSEIF (TG_OP = 'DELETE') THEN
DELETE FROM dw_orders where rnrid = OLD.rnrid; -- OLD.rnrid = NEW.rnrid
RETURN NULL; -- exist from procedure
ELSE
RETURN NULL; -- exist not a valid CRUD op
END IF;
FOR rec IN
SELECT
vw_requisition_detail_2.*
FROM
vw_requisition_detail_2
where (req_id = NEW.rnrid)
LOOP --fetch the table row inside the loop
v_programid = rec.program_id ;
v_geographiczoneid = rec.zone_id ;
v_facilityid = rec.facility_id ;
v_facilitycode = rec.facility_code ;
v_periodid = rec.processing_periods_id ;
v_rnrid = rec.req_id ;
v_status = rec.req_status ;
v_productid = rec.product_id ;
v_productcode = rec.product_code ;
v_quantityrequested = rec.quantityrequested ;
v_quantityapproved = rec.quantityapproved ;
v_quantityshipped = 1 ;
v_quantityreceived = rec.quantityreceived ; -- will set the date later
v_createddate = NULL ;
v_approveddate = NULL ;
v_shippeddate = NULL ;
v_receiveddate = NULL ;
v_programname = rec.program_name ;
v_facilityname = rec.facility_name ;
v_productprimaryname = rec.product_primaryname ;
v_productfullname = rec.product ;
v_processingperiodname = rec.processing_periods_name ;
v_soh = rec.stockinhand;
v_amc = rec.amc;
v_mos = CASE WHEN v_amc > 0 THEN v_soh / v_amc ELSE 0 END;
v_emergency = rec.emergency;
v_supervisorynodeid = NULL;
v_requisitiongroupid = NULL;
v_requisitiongroupname = NULL;
v_facilitytypeid = rec.facility_type_id;
v_facilitytypename = rec.facility_type_name;
v_scheduleid = rec.scheduleid;
v_schedulename = rec.schedulename;
v_productcategoryid = rec.categoryid;
v_productcategoryname = rec.categoryname;
v_productgroupid = rec.productgroupid;
v_productgroupname = rec.productgroupid;
v_stockedoutinpast = 'N';
v_suppliedinpast = 'N';
v_mossuppliedinpast = 1;
v_geographiczonename =  rec.region;
v_tracer =  rec.tracer;
v_skipped =  rec.skipped;
v_stockoutdays = rec.stockoutdays;
if v_previousstockinhand = 0 then
v_stockedoutinpast = 'Y';
end if;
select * from fn_previous_rnr_detail(v_programid, v_periodid,v_facilityid,v_productcode) into p1;
v_previousrnrid = COALESCE(p1.rnrid,0);
select periodid into previous_periodid from requisitions where requisitions.id = p1.rnrid;
previous_periodid = COALESCE(previous_periodid,0);
select * from fn_previous_rnr_detail(v_programid, previous_periodid,v_facilityid,v_productcode) into p2;
v_mossuppliedinpast_denominator = 0;
if COALESCE(v_soh,0) > 0 then
v_mossuppliedinpast_denominator  = v_amc;
elsif COALESCE(p1.stockinhand,0) > 0 then
v_mossuppliedinpast_denominator  = p1.amc;
elsif COALESCE(p2.stockinhand,0) > 0 then
v_mossuppliedinpast_denominator  = p2.amc;
end if;
if p1.stockinhand = 0 and p2.stockinhand = 0 then
v_stockedoutinpast = 'Y';
end if;
if p1.quantityreceived > 0 or p2.quantityreceived > 0 then
v_suppliedinpast = 'Y';
v_totalsuppliedinpast = COALESCE(p1.quantityreceived,0) + COALESCE(p2.quantityreceived,0);
end if;
v_mossuppliedinpast = 0;
if v_mossuppliedinpast_denominator > 0 then
v_mossuppliedinpast = v_totalsuppliedinpast /  v_mossuppliedinpast_denominator;
end if;
IF rec.stockinhand = 0 THEN
v_stocking = 'S' ;
ELSEIF rec.stockinhand > 0
AND rec.stockinhand <= (
COALESCE (rec.amc, 0) * rec.nominaleop
) THEN
v_stocking = 'U' ;
ELSEIF rec.stockinhand > 0
AND rec.stockinhand >= (
COALESCE (rec.amc, 0) * rec.nominaleop
) THEN
v_stocking = 'O' ;
ELSE
v_stocking = 'A' ;
END IF ;
INSERT INTO dw_orders (
programid,
geographiczoneid,
facilityid,
facilitycode,
periodid,
rnrid,
emergency,
status,
productid,
productcode,
quantityrequested,
quantityapproved,
quantityshipped,
quantityreceived,
createddate,
approveddate,
shippeddate,
receiveddate,
stocking,
reporting,
programname,
facilityname,
productprimaryname,
productfullname,
geographiczonename,
processingperiodname,
soh,
amc,
mos,
requisitiongroupid,
requisitiongroupname,
facilitytypeid,
facilitytypename,
scheduleid,
schedulename,
productcategoryid,
productcategoryname,
productgroupid,
productgroupname,
stockedoutinpast,
suppliedinpast,
mossuppliedinpast,
supervisorynodeid,
modifieddate,
tracer,
skipped,
stockoutdays
)
VALUES
(
v_programid,
v_geographiczoneid,
v_facilityid,
v_facilitycode,
v_periodid,
v_rnrid,
v_emergency,
v_status,
v_productid,
v_productcode,
v_quantityrequested,
v_quantityapproved,
v_quantityshipped,
v_quantityreceived,
v_createddate,
v_approveddate,
v_shippeddate,
v_receiveddate,
v_stocking,
v_reporting,
v_programname,
v_facilityname,
v_productprimaryname,
v_productfullname,
v_geographiczonename,
v_processingperiodname,
v_soh,
v_amc,
v_mos,
v_requisitiongroupid,
v_requisitiongroupname,
v_facilitytypeid,
v_facilitytypename,
v_scheduleid,
v_schedulename,
v_productcategoryid,
v_productcategoryname,
v_productgroupid,
v_productgroupname,
v_stockedoutinpast,
v_suppliedinpast,
v_mossuppliedinpast,
v_supervisorynodeid,
now(),
v_tracer,
v_skipped,
v_stockoutdays
) ;
END loop ; -- update rnr create date
UPDATE dw_orders o
SET createddate = r.createddate
FROM
requisitions r
WHERE
o.rnrid = r. ID
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET initiateddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'INITIATED'
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET submitteddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'SUBMITTED'
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET authorizeddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'AUTHORIZED'
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET inapprovaldate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'IN_APPROVAL'
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET approveddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'APPROVED'
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET releaseddate = r.createddate
FROM
requisition_status_changes r
WHERE
o.rnrid = r.rnrid
AND r.status = 'RELEASED'
and r.id = NEW.rnrid;
SELECT value from configuration_settings where key='LATE_REPORTING_DAYS' INTO v_late_days;
v_late_days = COALESCE(v_late_days,10);
UPDATE dw_orders o
SET reporting = CASE
WHEN (EXTRACT (DAY FROM r.createddate) - (select EXTRACT (DAY FROM startdate) from processing_periods where id = r.periodid)) > v_late_days THEN
'L'
ELSE
'O'
END
FROM
requisitions r
WHERE
o.rnrid = r. ID
and r.id = NEW.rnrid;
UPDATE dw_orders o
SET shippeddate = s.shippeddate,
quantityshipped = s.quantityshipped
FROM
shipment_line_items s
WHERE
o.rnrid = s.orderid
AND o.productcode = s.productcode
and s.orderid = NEW.rnrid;
UPDATE dw_orders o
SET receiveddate = P .receiveddate
FROM
pod P
WHERE
o.rnrid = P .orderid
and o.rnrid = NEW.rnrid;
RETURN NULL;
END ;
$$;


ALTER FUNCTION public.fn_populate_dw_rnr() OWNER TO postgres;

--
-- Name: fn_previous_cb(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_previous_cb(v_rnr_id integer, v_productcode character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
BEGIN
select stockinhand  into v_ret from requisition_line_items where id < v_rnr_id and productcode = v_productcode;
v_ret = COALESCE(v_ret,0);
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_previous_cb(v_rnr_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_previous_cb(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_previous_cb(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
v_rnr_id integer;
BEGIN
select id into v_rnr_id from requisitions where periodid < v_period_id and facilityid = v_facility_id and programid = v_program_id order by periodid desc limit 1;
v_rnr_id = COALESCE(v_rnr_id,0);
if v_rnr_id > 0 then
select stockinhand into v_ret from requisition_line_items where rnrid = v_rnr_id and productcode = v_productcode;
end if;
v_ret = COALESCE(v_ret,0);
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_previous_cb(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_previous_pd(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_previous_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
v_rnr_id integer;
BEGIN
select id into v_rnr_id from requisitions where periodid < v_period_id order by periodid desc limit 1;
v_rnr_id = COALESCE(v_rnr_id,0);
if v_rnr_id > 0 then
select quantityreceived into v_ret from requisition_line_items where rnrid = v_rnr_id and productcode = v_productcode;
end if;
v_ret = COALESCE(v_ret,0);
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_previous_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_previous_period(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_previous_period(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
v_rnr_id integer;
BEGIN
select id into v_rnr_id from requisitions where periodid < v_period_id and facilityid = v_facility_id and programid = v_program_id order by periodid desc limit 1;
v_rnr_id = COALESCE(v_rnr_id,0);
if v_rnr_id > 0 then
select quantityapproved into v_ret from requisition_line_items where rnrid = v_rnr_id and productcode = v_productcode;
end if;
v_ret = COALESCE(v_ret,0);
return v_ret;
END;
$$;


ALTER FUNCTION public.fn_previous_period(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_previous_rnr_detail(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_previous_rnr_detail(v_program_id integer, v_period_id integer, v_facility_id integer, v_productcode character varying) RETURNS TABLE(rnrid integer, productcode character varying, beginningbalance integer, quantityreceived integer, quantitydispensed integer, stockinhand integer, quantityrequested integer, calculatedorderquantity integer, quantityapproved integer, totallossesandadjustments integer, reportingdays integer, previousstockinhand integer, periodnormalizedconsumption integer, amc integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
v_prev_id integer;
v_rnr_id integer;
finalQuery            VARCHAR;
BEGIN
select id into v_rnr_id from requisitions where requisitions.periodid < v_period_id and facilityid = v_facility_id and requisitions.programid = v_program_id order by requisitions.periodid desc limit 1;
v_rnr_id = COALESCE(v_rnr_id,0);
finalQuery :=
'select
rnrid,
productcode,
beginningbalance,
quantityreceived,
quantitydispensed,
stockinhand,
quantityrequested,
calculatedorderquantity,
quantityapproved,
totallossesandadjustments,
reportingdays,
previousstockinhand,
periodnormalizedconsumption,
amc
from requisition_line_items where rnrid = '||v_rnr_id || ' and productcode = '||chr(39)||v_productcode||chr(39);
RETURN QUERY EXECUTE finalQuery;
END;
$$;


ALTER FUNCTION public.fn_previous_rnr_detail(v_program_id integer, v_period_id integer, v_facility_id integer, v_productcode character varying) OWNER TO postgres;

--
-- Name: fn_save_user_preference(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_save_user_preference(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE msg character varying(2000);
DECLARE msg2 character varying(2000);
v_scheduleid integer;
v_periodid integer;
v_zoneid integer;
BEGIN
msg := 'ERROR';
select  u.scheduleid, u.periodid, u.geographiczoneid into v_scheduleid, v_periodid, v_zoneid from fn_get_user_default_settings(in_programid,in_facilityid) u;
msg := fn_set_user_preference(in_userid, 'DEFAULT_PROGRAM', in_programid::text);
msg := fn_set_user_preference(in_userid, 'DEFAULT_SCHEDULE', v_scheduleid::text);
msg := fn_set_user_preference(in_userid, 'DEFAULT_PERIOD',   v_periodid::text);
msg := fn_set_user_preference(in_userid, 'DEFAULT_GEOGRAPHIC_ZONE',  v_zoneid::text);
msg := fn_set_user_preference(in_userid, 'DEFAULT_FACILITY',  in_facilityid::text);
msg := fn_set_user_preference(in_userid, 'DEFAULT_PRODUCTS',  in_productid::text);
RETURN msg;
EXCEPTION WHEN OTHERS THEN
return SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_save_user_preference(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) OWNER TO postgres;

--
-- Name: fn_save_user_preference2(integer, integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_save_user_preference2(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE msg character varying(2000);
DECLARE msg2 character varying(2000);
v_scheduleid integer;
v_periodid integer;
v_zoneid integer;
BEGIN
msg := 'ERROR';
select  u.scheduleid, u.periodid, u.geographiczoneid into v_scheduleid, v_periodid, v_zoneid from fn_get_user_default_settings(in_programid,in_facilityid) u;
msg = v_scheduleid::text || '*' || v_periodid::text || '*' || v_zoneid::text;
RETURN msg;
EXCEPTION WHEN OTHERS THEN
return SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_save_user_preference2(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) OWNER TO postgres;

--
-- Name: fn_set_user_preference(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_set_user_preference(in_userid integer, in_key character varying, in_value character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE msg character varying(2000);
check_id integer;
productids int[];
i integer;
valid_list integer;
BEGIN
msg := 'ERROR';
IF in_key != ANY(ARRAY['DEFAULT_PROGRAM','DEFAULT_SCHEDULE','DEFAULT_PERIOD','DEFAULT_GEOGRAPHIC_ZONE','DEFAULT_FACILITY','DEFAULT_PRODUCTS']) THEN
msg := 'Invalid key';
END IF;
if in_key = 'DEFAULT_PROGRAM' THEN
select id into check_id from programs where id = in_value::int;
check_id = COALESCE(check_id,0);
if check_id > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_PROGRAM' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_PROGRAM', in_value, 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid program value. Aborting';
end if;
end if;
if in_key = 'DEFAULT_SCHEDULE' THEN
select id into check_id from processing_schedules where id = in_value::int;
check_id = COALESCE(check_id,0);
if check_id > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_SCHEDULE' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_SCHEDULE', in_value, 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid schedule value. Aborting';
end if;
end if;
if in_key = 'DEFAULT_PERIOD' THEN
select id into check_id from processing_periods where id = in_value::int;
check_id = COALESCE(check_id,0);
if check_id > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_PERIOD' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_PERIOD', in_value, 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid period value. Aborting';
end if;
end if;
if in_key = 'DEFAULT_GEOGRAPHIC_ZONE' THEN
select id into check_id from geographic_zones where id = in_value::int;
check_id = COALESCE(check_id,0);
if check_id > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_GEOGRAPHIC_ZONE' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_GEOGRAPHIC_ZONE', in_value, 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid geographic zone value. Aborting';
end if;
end if;
if in_key = 'DEFAULT_FACILITY' THEN
select id into check_id from facilities where id = in_value::int;
check_id = COALESCE(check_id,0);
if check_id > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_FACILITY' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_FACILITY', in_value, 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid facility value. Aborting';
end if;
end if;
valid_list = 1;
if in_key = 'DEFAULT_PRODUCTS' THEN
productids = '{'||in_value||'}';
FOREACH i IN ARRAY productids
LOOP
select id into check_id from products where id = i::int;
check_id = COALESCE(check_id,0);
if check_id = 0 then
valid_list = 0;
end if;
END LOOP;
if valid_list > 0 then
delete from user_preferences where userpreferencekey = 'DEFAULT_PRODUCTS' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_PRODUCTS', in_value, 2, now(), 2, now());
delete from user_preferences where userpreferencekey = 'DEFAULT_PRODUCT' and userid = in_userid;
insert into user_preferences values (in_userid, 'DEFAULT_PRODUCT', productids[1], 2, now(), 2, now());
msg := 'user.preference.set.successfully';
else
msg := 'Invalid product values. Aborting';
end if;
end if;
RETURN msg;
EXCEPTION WHEN OTHERS THEN
return SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_set_user_preference(in_userid integer, in_key character varying, in_value character varying) OWNER TO postgres;

--
-- Name: fn_tbl_user_attributes(integer, character varying, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fn_tbl_user_attributes(in_user_id integer DEFAULT NULL::integer, in_user_name character varying DEFAULT NULL::character varying, in_program_id integer DEFAULT NULL::integer, in_output text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
rg_cursor CURSOR FOR
SELECT distinct on (user_id,rg_id) user_id, rg_id, rg_code, role_id
FROM vw_user_role_program_rg
where (user_id = in_user_id or in_user_id is null)
and (username = in_user_name or in_user_name is null)
and (program_id = in_program_id or in_program_id is null);
fac_cursor CURSOR FOR
SELECT distinct on (user_id,facility_id) user_id, facility_id, facility_code, role_id
FROM vw_user_program_facilities
where (user_id = in_user_id or in_user_id is null)
and (username = in_user_name or in_user_name is null)
and (program_id = in_program_id or in_program_id is null);
user_cursor CURSOR FOR
SELECT role_assignments.roleid
FROM  users
INNER JOIN role_assignments ON role_assignments.userid = users.id
where (users.id = in_user_id or in_user_id is null)
and (users.username = in_user_name or in_user_name is null)
and role_assignments.roleid = 1;
rec RECORD;
delim character(1);
ret_val TEXT;
BEGIN
delim = '';
ret_val = '';
open user_cursor;
FETCH user_cursor INTO rec;
IF FOUND THEN
ret_val = '*';
RETURN ret_val;
end if;
close user_cursor;
IF upper(in_output) = 'FACCODE' OR upper(in_output) = 'FACID' THEN
OPEN fac_cursor;
LOOP
FETCH fac_cursor INTO rec;
EXIT WHEN NOT FOUND;
if upper(in_output) = 'FACID' THEN
ret_val = ret_val || delim ||rec.facility_id;
elsif upper(in_output) = 'FACCODe' THEN
ret_val = ret_val || delim ||chr(39)||rec.facility_code||chr(39);
else
ret_val = '';
END IF;
delim = ',';
END LOOP;
CLOSE fac_cursor;
ELSIF upper(in_output) = 'RGID' OR upper(in_output) = 'RGCODE' OR upper(in_output) = 'SNODE' THEN
OPEN rg_cursor;
LOOP
FETCH rg_cursor INTO rec;
EXIT WHEN NOT FOUND;
if upper(in_output) = 'RGID' THEN
ret_val = ret_val || delim ||rec.rg_id;
elsif upper(in_output) = 'RGCODE' THEN
ret_val = ret_val || delim ||chr(39)||rec.rg_code||chr(39);
elsif upper(in_output) = 'SNODE' THEN
ret_val = ret_val || delim ||rec.supervisorynodeid;
else
ret_val = '';
END IF;
delim = ',';
END LOOP;
CLOSE rg_cursor;
END IF;
ret_val = coalesce(ret_val, 'none');
RETURN ret_val;
EXCEPTION WHEN OTHERS THEN RETURN SQLERRM;
END;
$$;


ALTER FUNCTION public.fn_tbl_user_attributes(in_user_id integer, in_user_name character varying, in_program_id integer, in_output text) OWNER TO postgres;

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
-- Name: alert_facility_stockedout; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_facility_stockedout (
    id integer NOT NULL,
    alertsummaryid integer,
    programid integer,
    periodid integer,
    geographiczoneid integer,
    geographiczonename character varying(250),
    facilityid integer,
    facilityname character varying(50),
    productid integer,
    productname character varying(150),
    stockoutdays integer,
    amc integer
);


ALTER TABLE public.alert_facility_stockedout OWNER TO postgres;

--
-- Name: alert_facility_stockedout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_facility_stockedout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_facility_stockedout_id_seq OWNER TO postgres;

--
-- Name: alert_facility_stockedout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_facility_stockedout_id_seq OWNED BY alert_facility_stockedout.id;


--
-- Name: alert_requisition_approved; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_requisition_approved (
    id integer NOT NULL,
    alertsummaryid integer,
    programid integer,
    periodid integer,
    geographiczoneid integer,
    geographiczonename character varying(250),
    rnrid integer,
    rnrtype character varying(50),
    facilityid integer,
    facilityname character varying(50)
);


ALTER TABLE public.alert_requisition_approved OWNER TO postgres;

--
-- Name: alert_requisition_approved_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_requisition_approved_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_requisition_approved_id_seq OWNER TO postgres;

--
-- Name: alert_requisition_approved_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_requisition_approved_id_seq OWNED BY alert_requisition_approved.id;


--
-- Name: alert_requisition_emergency; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_requisition_emergency (
    id integer NOT NULL,
    alertsummaryid integer,
    programid integer,
    periodid integer,
    geographiczoneid integer,
    geographiczonename character varying(250),
    rnrid integer,
    rnrtype character varying(50),
    facilityid integer,
    status character varying(50),
    facilityname character varying(50)
);


ALTER TABLE public.alert_requisition_emergency OWNER TO postgres;

--
-- Name: alert_requisition_emergency_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_requisition_emergency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_requisition_emergency_id_seq OWNER TO postgres;

--
-- Name: alert_requisition_emergency_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_requisition_emergency_id_seq OWNED BY alert_requisition_emergency.id;


--
-- Name: alert_requisition_pending; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_requisition_pending (
    id integer NOT NULL,
    alertsummaryid integer,
    programid integer,
    periodid integer,
    geographiczoneid integer,
    geographiczonename character varying(250),
    rnrid integer,
    rnrtype character varying(50),
    facilityid integer,
    facilityname character varying(50)
);


ALTER TABLE public.alert_requisition_pending OWNER TO postgres;

--
-- Name: alert_requisition_pending_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_requisition_pending_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_requisition_pending_id_seq OWNER TO postgres;

--
-- Name: alert_requisition_pending_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_requisition_pending_id_seq OWNED BY alert_requisition_pending.id;


--
-- Name: alert_requisition_rejected; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_requisition_rejected (
    id integer NOT NULL,
    alertsummaryid integer,
    programid integer,
    periodid integer,
    geographiczoneid integer,
    geographiczonename character varying(250),
    rnrid integer,
    rnrtype character varying(50),
    facilityid integer,
    facilityname character varying(50)
);


ALTER TABLE public.alert_requisition_rejected OWNER TO postgres;

--
-- Name: alert_requisition_rejected_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_requisition_rejected_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_requisition_rejected_id_seq OWNER TO postgres;

--
-- Name: alert_requisition_rejected_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_requisition_rejected_id_seq OWNED BY alert_requisition_rejected.id;


--
-- Name: alert_stockedout; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_stockedout (
    id integer NOT NULL,
    alertsummaryid integer,
    facilityid integer,
    facilityname character varying(50),
    stockoutdays integer,
    amc integer,
    productid integer
);


ALTER TABLE public.alert_stockedout OWNER TO postgres;

--
-- Name: alert_stockedout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_stockedout_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_stockedout_id_seq OWNER TO postgres;

--
-- Name: alert_stockedout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_stockedout_id_seq OWNED BY alert_stockedout.id;


--
-- Name: alert_summary; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alert_summary (
    id integer NOT NULL,
    statics_value integer,
    description character varying(2000),
    geographiczoneid integer,
    alerttypeid character varying(50),
    programid integer,
    periodid integer,
    productid integer
);


ALTER TABLE public.alert_summary OWNER TO postgres;

--
-- Name: alert_summary_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE alert_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.alert_summary_id_seq OWNER TO postgres;

--
-- Name: alert_summary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE alert_summary_id_seq OWNED BY alert_summary.id;


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE alerts (
    alerttype character varying(50) NOT NULL,
    display_section character varying(50),
    email boolean,
    sms boolean,
    detail_table character varying(50),
    sms_msg_template_key character varying(250),
    email_msg_template_key character varying(250)
);


ALTER TABLE public.alerts OWNER TO postgres;

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
-- Name: budgets; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE budgets (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    periodid integer NOT NULL,
    programid integer NOT NULL,
    netbudgetamount numeric(20,2) NOT NULL,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.budgets OWNER TO postgres;

--
-- Name: budgets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE budgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budgets_id_seq OWNER TO postgres;

--
-- Name: budgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE budgets_id_seq OWNED BY budgets.id;


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
-- Name: configuration_settings; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE configuration_settings (
    id integer NOT NULL,
    key character varying(250) NOT NULL,
    value character varying(250),
    name character varying(250) NOT NULL,
    description character varying(1000),
    groupname character varying(250) DEFAULT 'General'::character varying NOT NULL,
    displayorder integer DEFAULT 1 NOT NULL,
    valuetype character varying(250) DEFAULT 'TEXT'::character varying NOT NULL,
    valueoptions character varying(1000)
);


ALTER TABLE public.configuration_settings OWNER TO postgres;

--
-- Name: configuration_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE configuration_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configuration_settings_id_seq OWNER TO postgres;

--
-- Name: configuration_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE configuration_settings_id_seq OWNED BY configuration_settings.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    longname character varying(250),
    isocode2 character varying(2),
    isocode3 character varying(3),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: TABLE countries; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE countries IS 'Countries';


--
-- Name: COLUMN countries.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.id IS 'ID';


--
-- Name: COLUMN countries.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.name IS 'Name';


--
-- Name: COLUMN countries.longname; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.longname IS 'Long name';


--
-- Name: COLUMN countries.isocode2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.isocode2 IS 'ISO code (2 digit)';


--
-- Name: COLUMN countries.isocode3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.isocode3 IS 'ISO code (3 digit)';


--
-- Name: COLUMN countries.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.createdby IS 'Created by';


--
-- Name: COLUMN countries.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.createddate IS 'Created on';


--
-- Name: COLUMN countries.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.modifiedby IS 'Modified by';


--
-- Name: COLUMN countries.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN countries.modifieddate IS 'Modified on';


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.countries_id_seq OWNER TO postgres;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


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
-- Name: custom_reports; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE custom_reports (
    id integer NOT NULL,
    reportkey character varying(50) NOT NULL,
    name character varying(50),
    description character varying(50),
    active boolean,
    createdby integer,
    help character varying(5000),
    filters character varying(5000),
    query character varying(5000),
    category character varying(5000),
    columnoptions character varying(5000),
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.custom_reports OWNER TO postgres;

--
-- Name: custom_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE custom_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_reports_id_seq OWNER TO postgres;

--
-- Name: custom_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE custom_reports_id_seq OWNED BY custom_reports.id;


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
-- Name: distribution_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE distribution_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.distribution_types OWNER TO postgres;

--
-- Name: TABLE distribution_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE distribution_types IS 'Vaccine storage types';


--
-- Name: COLUMN distribution_types.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.id IS 'ID';


--
-- Name: COLUMN distribution_types.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.name IS 'Distribution type';


--
-- Name: COLUMN distribution_types.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.createdby IS 'Created by';


--
-- Name: COLUMN distribution_types.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.createddate IS 'Created on';


--
-- Name: COLUMN distribution_types.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.modifiedby IS 'Modified by';


--
-- Name: COLUMN distribution_types.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN distribution_types.modifieddate IS 'Modified on';


--
-- Name: distribution_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE distribution_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.distribution_types_id_seq OWNER TO postgres;

--
-- Name: distribution_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE distribution_types_id_seq OWNED BY distribution_types.id;


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
-- Name: donors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE donors (
    id integer NOT NULL,
    shortname character varying(200) NOT NULL,
    longname character varying(200) NOT NULL,
    code character varying(50),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.donors OWNER TO postgres;

--
-- Name: donors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE donors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donors_id_seq OWNER TO postgres;

--
-- Name: donors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE donors_id_seq OWNED BY donors.id;


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
-- Name: dw_orders; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dw_orders (
    programid integer,
    programname character varying(50),
    scheduleid integer,
    schedulename character varying(50),
    periodid integer NOT NULL,
    processingperiodname character varying(250),
    geographiczoneid integer NOT NULL,
    geographiczonename character varying(250),
    supervisorynodeid integer,
    requisitiongroupid integer,
    requisitiongroupname character varying(50),
    facilitytypeid integer,
    facilitytypename character varying(50),
    facilityid integer NOT NULL,
    facilitycode character varying(50) NOT NULL,
    facilityname character varying(50),
    productcategoryid integer,
    productcategoryname character varying(150),
    productgroupid integer,
    productgroupname character varying(250),
    rnrid integer NOT NULL,
    emergency boolean,
    status character varying(20) NOT NULL,
    createddate timestamp without time zone,
    approveddate timestamp without time zone,
    shippeddate timestamp without time zone,
    receiveddate timestamp without time zone,
    initiateddate timestamp without time zone,
    submitteddate timestamp without time zone,
    authorizeddate timestamp without time zone,
    inapprovaldate timestamp without time zone,
    releaseddate timestamp without time zone,
    productid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    productprimaryname character varying(150),
    productfullname character varying(250),
    quantityrequested integer,
    quantityapproved integer,
    quantityshipped integer,
    quantityreceived integer,
    soh integer,
    amc integer,
    mos numeric(6,1),
    stockedoutinpast boolean,
    suppliedinpast boolean,
    mossuppliedinpast numeric(6,1),
    stocking character(1),
    reporting character(1),
    modifieddate timestamp without time zone DEFAULT now(),
    tracer boolean,
    skipped boolean,
    stockoutdays integer DEFAULT 0,
    quantityapprovedprev integer
);


ALTER TABLE public.dw_orders OWNER TO postgres;

--
-- Name: TABLE dw_orders; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE dw_orders IS 'stores data to calculate order fill rate and item fill rate
Definitions:
ORDER FILL RATE: Total number of products received / Total number of products approved Parameters: geograhic zone, facility, period
ITEM FILL RATE: Total qty received / Total qty approved. Parameter: geograhic zone, product, period
Joins:
requisitions, facilitities, products, requision_line_items, shipment_line_items,requisition_status_changes,pod
Fields and source:
geographic zone id - facilities table
facility id -- facilities table
period id -- requisitions tables
rnr id - requisitions
product id - requisition_line_items
quantity requested -- requisition_line_items
quantity approved -- requisition_line_items
quantity received -- requisition_line_items
date requisition created -
date requisition approved -
date requisition (order) shipped';


--
-- Name: dw_order_fill_rate_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dw_order_fill_rate_vw AS
 SELECT dw_orders.programid,
    dw_orders.periodid,
    dw_orders.geographiczoneid,
    dw_orders.facilityid,
    sum(
        CASE
            WHEN (COALESCE(dw_orders.quantityapproved, 0) = 0) THEN (0)::numeric
            ELSE
            CASE
                WHEN (dw_orders.quantityapproved > 0) THEN (1)::numeric
                ELSE (0)::numeric
            END
        END) AS totalproductsapproved,
    sum(
        CASE
            WHEN (COALESCE(dw_orders.quantityreceived, 0) = 0) THEN (0)::numeric
            ELSE
            CASE
                WHEN (dw_orders.quantityreceived > 0) THEN (1)::numeric
                ELSE (0)::numeric
            END
        END) AS totalproductsreceived,
        CASE
            WHEN (COALESCE(sum(
            CASE
                WHEN (COALESCE(dw_orders.quantityapproved, 0) = 0) THEN (0)::numeric
                ELSE
                CASE
                    WHEN (dw_orders.quantityapproved > 0) THEN (1)::numeric
                    ELSE (0)::numeric
                END
            END), (0)::numeric) = (0)::numeric) THEN (0)::numeric
            ELSE ((sum(
            CASE
                WHEN (COALESCE(dw_orders.quantityreceived, 0) = 0) THEN (0)::numeric
                ELSE
                CASE
                    WHEN (dw_orders.quantityreceived > 0) THEN (1)::numeric
                    ELSE (0)::numeric
                END
            END) / sum(
            CASE
                WHEN (COALESCE(dw_orders.quantityapproved, 0) = 0) THEN (0)::numeric
                ELSE
                CASE
                    WHEN (dw_orders.quantityapproved > 0) THEN (1)::numeric
                    ELSE (0)::numeric
                END
            END)) * (100)::numeric)
        END AS order_fill_rate
   FROM dw_orders
  WHERE ((dw_orders.status)::text = ANY (ARRAY[('APPROVED'::character varying)::text, ('RELEASED'::character varying)::text]))
  GROUP BY dw_orders.programid, dw_orders.periodid, dw_orders.geographiczoneid, dw_orders.facilityid;


ALTER TABLE public.dw_order_fill_rate_vw OWNER TO postgres;

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
    displayorder integer,
    fullsupply boolean
);


ALTER TABLE public.program_products OWNER TO postgres;

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
    modifieddate timestamp without time zone DEFAULT now(),
    isequipmentconfigured boolean DEFAULT false
);


ALTER TABLE public.programs OWNER TO postgres;

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
    maxmonthsofstock integer NOT NULL,
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
-- Name: vw_stock_status_2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_stock_status_2 AS
 SELECT facilities.code AS facilitycode,
    products.code AS productcode,
    facilities.name AS facility,
    requisitions.status AS req_status,
    requisition_line_items.product,
    requisition_line_items.stockinhand,
    ((((requisition_line_items.stockinhand + requisition_line_items.beginningbalance) + requisition_line_items.quantitydispensed) + requisition_line_items.quantityreceived) + abs(requisition_line_items.totallossesandadjustments)) AS reported_figures,
    requisitions.id AS rnrid,
    requisition_line_items.amc,
        CASE
            WHEN (COALESCE(requisition_line_items.amc, 0) = 0) THEN (0)::numeric
            ELSE round((((requisition_line_items.stockinhand)::double precision / (requisition_line_items.amc)::double precision))::numeric, 2)
        END AS mos,
    COALESCE(
        CASE
            WHEN (((COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth) - requisition_line_items.stockinhand) < 0) THEN 0
            ELSE ((COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth) - requisition_line_items.stockinhand)
        END, 0) AS required,
        CASE
            WHEN (requisition_line_items.stockinhand = 0) THEN 'SO'::text
            ELSE
            CASE
                WHEN ((requisition_line_items.stockinhand > 0) AND ((requisition_line_items.stockinhand)::numeric <= ((COALESCE(requisition_line_items.amc, 0))::numeric * facility_types.nominaleop))) THEN 'US'::text
                ELSE
                CASE
                    WHEN (requisition_line_items.stockinhand > (COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth)) THEN 'OS'::text
                    ELSE 'SP'::text
                END
            END
        END AS status,
    facility_types.name AS facilitytypename,
    geographic_zones.id AS gz_id,
    geographic_zones.name AS location,
    products.id AS productid,
    processing_periods.startdate,
    programs.id AS programid,
    processing_schedules.id AS psid,
    processing_periods.enddate,
    processing_periods.id AS periodid,
    facility_types.id AS facilitytypeid,
    program_products.productcategoryid AS categoryid,
    products.tracer AS indicator_product,
    facilities.id AS facility_id,
    processing_periods.name AS processing_period_name,
    requisition_line_items.stockoutdays,
    0 AS supervisorynodeid
   FROM ((((((((((requisition_line_items
   JOIN requisitions ON ((requisitions.id = requisition_line_items.rnrid)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN processing_periods ON ((processing_periods.id = requisitions.periodid)))
   JOIN processing_schedules ON ((processing_schedules.id = processing_periods.scheduleid)))
   JOIN products ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN program_products ON (((requisitions.programid = program_products.programid) AND (products.id = program_products.productid))))
   JOIN product_categories ON ((product_categories.id = program_products.productcategoryid)))
   JOIN programs ON ((programs.id = requisitions.programid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
  WHERE ((requisition_line_items.stockinhand IS NOT NULL) AND (requisition_line_items.skipped = false));


ALTER TABLE public.vw_stock_status_2 OWNER TO postgres;

--
-- Name: dw_product_facility_stock_info_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dw_product_facility_stock_info_vw AS
 SELECT 0 AS requisitiongroupid,
    vw_stock_status_2.programid,
    vw_stock_status_2.periodid,
    vw_stock_status_2.gz_id AS geographiczoneid,
    vw_stock_status_2.location AS geographiczonename,
    vw_stock_status_2.facility_id AS facilityid,
    vw_stock_status_2.facility AS facilityname,
    vw_stock_status_2.facilitycode,
    vw_stock_status_2.productid,
    vw_stock_status_2.product AS primaryname,
    vw_stock_status_2.amc,
    vw_stock_status_2.stockinhand AS soh,
    vw_stock_status_2.mos,
    vw_stock_status_2.status,
        CASE vw_stock_status_2.status
            WHEN 'SP'::text THEN 'A'::text
            WHEN 'OS'::text THEN 'O'::text
            WHEN 'US'::text THEN 'U'::text
            WHEN 'SO'::text THEN 'S'::text
            ELSE NULL::text
        END AS stocking
   FROM vw_stock_status_2
  ORDER BY vw_stock_status_2.gz_id, vw_stock_status_2.programid, vw_stock_status_2.periodid, vw_stock_status_2.productid, vw_stock_status_2.product, vw_stock_status_2.status;


ALTER TABLE public.dw_product_facility_stock_info_vw OWNER TO postgres;

--
-- Name: dw_product_fill_rate_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dw_product_fill_rate_vw AS
 SELECT dw_orders.programid,
    dw_orders.periodid,
    dw_orders.geographiczoneid,
    dw_orders.facilityid,
    dw_orders.productid,
    products.primaryname,
    sum((COALESCE(dw_orders.quantityapproved, 0))::numeric) AS quantityapproved,
    sum(
        CASE
            WHEN (COALESCE(dw_orders.quantityreceived, 0) = 0) THEN (dw_orders.quantityshipped)::numeric
            ELSE (COALESCE(dw_orders.quantityreceived, 0))::numeric
        END) AS quantityreceived,
        CASE
            WHEN (COALESCE(sum((COALESCE(dw_orders.quantityapproved, 0))::numeric), (0)::numeric) = (0)::numeric) THEN (0)::numeric
            ELSE round(((sum(
            CASE
                WHEN (COALESCE(dw_orders.quantityreceived, 0) = 0) THEN (dw_orders.quantityshipped)::numeric
                ELSE (COALESCE(dw_orders.quantityreceived, 0))::numeric
            END) / sum((COALESCE(dw_orders.quantityapproved, 0))::numeric)) * (100)::numeric), 2)
        END AS order_fill_rate
   FROM (dw_orders
   JOIN products ON ((products.id = dw_orders.productid)))
  WHERE ((dw_orders.status)::text = ANY (ARRAY[('APPROVED'::character varying)::text, ('RELEASED'::character varying)::text]))
  GROUP BY dw_orders.programid, dw_orders.periodid, dw_orders.geographiczoneid, dw_orders.facilityid, dw_orders.productid, products.primaryname;


ALTER TABLE public.dw_product_fill_rate_vw OWNER TO postgres;

--
-- Name: dw_product_lead_time_vw; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW dw_product_lead_time_vw AS
 SELECT dw_orders.programid,
    dw_orders.geographiczoneid,
    dw_orders.periodid,
    facilities.name,
    facilities.code,
    dw_orders.facilityid,
    sum(date_part('day'::text, age(dw_orders.authorizeddate, dw_orders.submitteddate))) AS subtoauth,
    sum(date_part('day'::text, age(dw_orders.inapprovaldate, dw_orders.authorizeddate))) AS authtoinapproval,
    sum(date_part('day'::text, age(dw_orders.approveddate, dw_orders.inapprovaldate))) AS inapprovaltoapproved,
    sum(date_part('day'::text, age(dw_orders.releaseddate, dw_orders.approveddate))) AS approvedtoreleased
   FROM (dw_orders
   JOIN facilities ON ((facilities.id = dw_orders.facilityid)))
  WHERE ((dw_orders.status)::text = ('RELEASED'::character varying)::text)
  GROUP BY dw_orders.programid, dw_orders.geographiczoneid, dw_orders.periodid, facilities.name, facilities.code, dw_orders.facilityid;


ALTER TABLE public.dw_product_lead_time_vw OWNER TO postgres;

--
-- Name: VIEW dw_product_lead_time_vw; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW dw_product_lead_time_vw IS 'dw_product_lead_time_vw-
calculate product shipping lead time - Total days from the day order submitted to received
Filters: Geographic zone id (district), periodid, program
created March 14, 2014 wolde';


--
-- Name: elmis_help; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE elmis_help (
    name character varying(500),
    modifiedby integer,
    htmlcontent character varying(2000),
    imagelink character varying(100),
    createddate date,
    id integer NOT NULL,
    createdby integer,
    modifieddate date,
    helptopicid integer
);


ALTER TABLE public.elmis_help OWNER TO postgres;

--
-- Name: elmis_help_document; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE elmis_help_document (
    id integer NOT NULL,
    document_type character varying(20),
    url character varying(100),
    created_date date,
    modified_date date,
    created_by integer,
    modified_by integer
);


ALTER TABLE public.elmis_help_document OWNER TO postgres;

--
-- Name: elmis_help_document_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE elmis_help_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elmis_help_document_id_seq OWNER TO postgres;

--
-- Name: elmis_help_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE elmis_help_document_id_seq OWNED BY elmis_help_document.id;


--
-- Name: elmis_help_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE elmis_help_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elmis_help_id_seq OWNER TO postgres;

--
-- Name: elmis_help_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE elmis_help_id_seq OWNED BY elmis_help.id;


--
-- Name: elmis_help_topic; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE elmis_help_topic (
    level integer,
    name character varying(200),
    created_by integer,
    createddate date,
    modifiedby integer,
    modifieddate date,
    id integer NOT NULL,
    parent_help_topic_id integer,
    is_category boolean DEFAULT true,
    html_content character varying(50000)
);


ALTER TABLE public.elmis_help_topic OWNER TO postgres;

--
-- Name: elmis_help_topic_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE elmis_help_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elmis_help_topic_id_seq OWNER TO postgres;

--
-- Name: elmis_help_topic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE elmis_help_topic_id_seq OWNED BY elmis_help_topic.id;


--
-- Name: elmis_help_topic_roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE elmis_help_topic_roles (
    id integer NOT NULL,
    help_topic_id integer,
    role_id integer,
    is_asigned boolean DEFAULT true,
    was_previosly_assigned boolean DEFAULT true,
    created_by integer,
    createddate date,
    modifiedby integer,
    modifieddate date
);


ALTER TABLE public.elmis_help_topic_roles OWNER TO postgres;

--
-- Name: elmis_help_topic_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE elmis_help_topic_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.elmis_help_topic_roles_id_seq OWNER TO postgres;

--
-- Name: elmis_help_topic_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE elmis_help_topic_roles_id_seq OWNED BY elmis_help_topic_roles.id;


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
-- Name: emergency_requisitions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE emergency_requisitions (
    id integer NOT NULL,
    alertsummaryid integer,
    rnrid integer,
    facilityid integer,
    status character varying(50)
);


ALTER TABLE public.emergency_requisitions OWNER TO postgres;

--
-- Name: emergency_requisitions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE emergency_requisitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.emergency_requisitions_id_seq OWNER TO postgres;

--
-- Name: emergency_requisitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE emergency_requisitions_id_seq OWNED BY emergency_requisitions.id;


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
-- Name: equipment_contract_service_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_contract_service_types (
    id integer NOT NULL,
    contractid integer,
    servicetypeid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_contract_service_types OWNER TO postgres;

--
-- Name: equipment_contract_service_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_contract_service_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_contract_service_types_id_seq OWNER TO postgres;

--
-- Name: equipment_contract_service_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_contract_service_types_id_seq OWNED BY equipment_contract_service_types.id;


--
-- Name: equipment_maintenance_logs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_maintenance_logs (
    id integer NOT NULL,
    userid integer NOT NULL,
    vendorid integer NOT NULL,
    contractid integer NOT NULL,
    facilityid integer NOT NULL,
    equipmentid integer,
    maintenancedate date,
    serviceperformed character varying(2000),
    finding character varying(2000),
    recommendation character varying(2000),
    requestid integer,
    nextvisitdate date,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_maintenance_logs OWNER TO postgres;

--
-- Name: equipment_maintenance_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_maintenance_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_maintenance_logs_id_seq OWNER TO postgres;

--
-- Name: equipment_maintenance_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_maintenance_logs_id_seq OWNED BY equipment_maintenance_logs.id;


--
-- Name: equipment_maintenance_requests; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_maintenance_requests (
    id integer NOT NULL,
    userid integer NOT NULL,
    facilityid integer NOT NULL,
    inventoryid integer NOT NULL,
    vendorid integer,
    requestdate date,
    reason character varying(2000),
    recommendeddate date,
    comment character varying(2000),
    resolved boolean DEFAULT false NOT NULL,
    vendorcomment character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_maintenance_requests OWNER TO postgres;

--
-- Name: equipment_maintenance_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_maintenance_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_maintenance_requests_id_seq OWNER TO postgres;

--
-- Name: equipment_maintenance_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_maintenance_requests_id_seq OWNED BY equipment_maintenance_requests.id;


--
-- Name: equipment_operational_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_operational_status (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    displayorder integer DEFAULT 0 NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_operational_status OWNER TO postgres;

--
-- Name: equipment_operational_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_operational_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_operational_status_id_seq OWNER TO postgres;

--
-- Name: equipment_operational_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_operational_status_id_seq OWNED BY equipment_operational_status.id;


--
-- Name: equipment_service_contract_equipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_contract_equipments (
    id integer NOT NULL,
    contractid integer NOT NULL,
    equipmentid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_contract_equipments OWNER TO postgres;

--
-- Name: equipment_service_contract_equipments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_contract_equipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_contract_equipments_id_seq OWNER TO postgres;

--
-- Name: equipment_service_contract_equipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_contract_equipments_id_seq OWNED BY equipment_service_contract_equipments.id;


--
-- Name: equipment_service_contract_facilities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_contract_facilities (
    id integer NOT NULL,
    contractid integer,
    facilityid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_contract_facilities OWNER TO postgres;

--
-- Name: equipment_service_contract_facilities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_contract_facilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_contract_facilities_id_seq OWNER TO postgres;

--
-- Name: equipment_service_contract_facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_contract_facilities_id_seq OWNED BY equipment_service_contract_facilities.id;


--
-- Name: equipment_service_contracts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_contracts (
    id integer NOT NULL,
    vendorid integer NOT NULL,
    identifier character varying(1000) NOT NULL,
    startdate date,
    enddate date,
    description character varying(2000),
    terms character varying(2000),
    coverage character varying(2000),
    contractdate date,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_contracts OWNER TO postgres;

--
-- Name: equipment_service_contracts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_contracts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_contracts_id_seq OWNER TO postgres;

--
-- Name: equipment_service_contracts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_contracts_id_seq OWNED BY equipment_service_contracts.id;


--
-- Name: equipment_service_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_types (
    id integer NOT NULL,
    name character varying(1000) NOT NULL,
    description character varying(2000) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_types OWNER TO postgres;

--
-- Name: equipment_service_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_types_id_seq OWNER TO postgres;

--
-- Name: equipment_service_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_types_id_seq OWNED BY equipment_service_types.id;


--
-- Name: equipment_service_vendor_users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_vendor_users (
    id integer NOT NULL,
    userid integer NOT NULL,
    vendorid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_vendor_users OWNER TO postgres;

--
-- Name: equipment_service_vendor_users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_vendor_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_vendor_users_id_seq OWNER TO postgres;

--
-- Name: equipment_service_vendor_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_vendor_users_id_seq OWNED BY equipment_service_vendor_users.id;


--
-- Name: equipment_service_vendors; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_service_vendors (
    id integer NOT NULL,
    name character varying(1000) NOT NULL,
    website character varying(1000) NOT NULL,
    contactperson character varying(200),
    primaryphone character varying(20),
    email character varying(200),
    description character varying(2000),
    specialization character varying(2000),
    geographiccoverage character varying(2000),
    registrationdate date,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_service_vendors OWNER TO postgres;

--
-- Name: equipment_service_vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_service_vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_service_vendors_id_seq OWNER TO postgres;

--
-- Name: equipment_service_vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_service_vendors_id_seq OWNED BY equipment_service_vendors.id;


--
-- Name: equipment_status_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_status_line_items (
    id integer NOT NULL,
    rnrid integer NOT NULL,
    code character varying(200) NOT NULL,
    equipmentname character varying(200) NOT NULL,
    equipmentcategory character varying(200) NOT NULL,
    equipmentmodel character varying(200),
    equipmentserial character varying(200),
    equipmentinventoryid integer NOT NULL,
    operationalstatusid integer NOT NULL,
    testcount integer,
    totalcount integer,
    daysoutofuse integer NOT NULL,
    remarks character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_status_line_items OWNER TO postgres;

--
-- Name: equipment_status_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_status_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_status_line_items_id_seq OWNER TO postgres;

--
-- Name: equipment_status_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_status_line_items_id_seq OWNED BY equipment_status_line_items.id;


--
-- Name: equipment_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipment_types (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(200),
    displayorder integer DEFAULT 0 NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipment_types OWNER TO postgres;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipment_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipment_types_id_seq OWNER TO postgres;

--
-- Name: equipment_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipment_types_id_seq OWNED BY equipment_types.id;


--
-- Name: equipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE equipments (
    id integer NOT NULL,
    code character varying(200) NOT NULL,
    name character varying(200) NOT NULL,
    equipmenttypeid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.equipments OWNER TO postgres;

--
-- Name: equipments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE equipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.equipments_id_seq OWNER TO postgres;

--
-- Name: equipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE equipments_id_seq OWNED BY equipments.id;


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
    maxmonthsofstock integer NOT NULL,
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
-- Name: facility_program_equipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_program_equipments (
    id integer NOT NULL,
    facilityid integer NOT NULL,
    programid integer NOT NULL,
    equipmentid integer NOT NULL,
    operationalstatusid integer NOT NULL,
    serialnumber character varying(200) NOT NULL,
    manufacturername character varying(200),
    model character varying(200),
    energysource character varying(200),
    yearofinstallation integer DEFAULT 1900 NOT NULL,
    purchaseprice numeric(18,3) DEFAULT 0 NOT NULL,
    sourceoffund character varying(200),
    replacementrecommended boolean DEFAULT false NOT NULL,
    reasonforreplacement character varying(2000),
    nameofassessor character varying(200),
    datelastassessed date DEFAULT now() NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    isactive boolean DEFAULT true NOT NULL,
    datedecommissioned date,
    hasservicecontract boolean DEFAULT false NOT NULL,
    servicecontractenddate date,
    primarydonorid integer
);


ALTER TABLE public.facility_program_equipments OWNER TO postgres;

--
-- Name: facility_program_equipments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE facility_program_equipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.facility_program_equipments_id_seq OWNER TO postgres;

--
-- Name: facility_program_equipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE facility_program_equipments_id_seq OWNED BY facility_program_equipments.id;


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
-- Name: geographic_zone_geojson; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE geographic_zone_geojson (
    id integer NOT NULL,
    zoneid integer,
    geojsonid integer,
    geometry text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.geographic_zone_geojson OWNER TO postgres;

--
-- Name: geographic_zone_geojson_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE geographic_zone_geojson_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.geographic_zone_geojson_id_seq OWNER TO postgres;

--
-- Name: geographic_zone_geojson_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE geographic_zone_geojson_id_seq OWNED BY geographic_zone_geojson.id;


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
-- Name: inventory_batches; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_batches (
    id integer NOT NULL,
    transactionid integer NOT NULL,
    batchnumber character varying(250) NOT NULL,
    manufacturedate date,
    expirydate date NOT NULL,
    quantity integer NOT NULL,
    vvm1_qty integer,
    vvm2_qty integer,
    vvm3_qty integer,
    vvm4_qty integer,
    note character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inventory_batches OWNER TO postgres;

--
-- Name: TABLE inventory_batches; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_batches IS 'On hand of inventory';


--
-- Name: COLUMN inventory_batches.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.id IS 'ID';


--
-- Name: COLUMN inventory_batches.transactionid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.transactionid IS 'Inventory trasaction ID';


--
-- Name: COLUMN inventory_batches.batchnumber; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.batchnumber IS 'Batch/Lot number';


--
-- Name: COLUMN inventory_batches.manufacturedate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.manufacturedate IS 'Manufacturing date';


--
-- Name: COLUMN inventory_batches.expirydate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.expirydate IS 'Expiry date';


--
-- Name: COLUMN inventory_batches.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.quantity IS 'Batch quantity';


--
-- Name: COLUMN inventory_batches.vvm1_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.vvm1_qty IS 'VVM 1 quantity';


--
-- Name: COLUMN inventory_batches.vvm2_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.vvm2_qty IS 'VVM 2 quantity';


--
-- Name: COLUMN inventory_batches.vvm3_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.vvm3_qty IS 'VVM 3 quantity';


--
-- Name: COLUMN inventory_batches.vvm4_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.vvm4_qty IS 'VVM 4 quantity';


--
-- Name: COLUMN inventory_batches.note; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.note IS 'Note';


--
-- Name: COLUMN inventory_batches.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.createdby IS 'Created by';


--
-- Name: COLUMN inventory_batches.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.createddate IS 'Created on';


--
-- Name: COLUMN inventory_batches.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.modifiedby IS 'Modified by';


--
-- Name: COLUMN inventory_batches.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_batches.modifieddate IS 'Modified on';


--
-- Name: inventory_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_batches_id_seq OWNER TO postgres;

--
-- Name: inventory_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_batches_id_seq OWNED BY inventory_batches.id;


--
-- Name: inventory_transactions; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE inventory_transactions (
    id integer NOT NULL,
    transactiontypeid integer NOT NULL,
    fromfacilityid integer NOT NULL,
    tofacilityid integer NOT NULL,
    productid integer NOT NULL,
    dispatchreference character varying(200) NOT NULL,
    dispatchdate date DEFAULT now(),
    bol character varying(200),
    donorid integer,
    origincountryid integer,
    manufacturerid integer,
    statusid integer,
    purpose character varying(30),
    vvmtracked boolean DEFAULT true,
    barcoded boolean,
    gs1 boolean,
    quantity integer,
    packsize integer,
    unitprice numeric(12,4),
    totalcost numeric(12,4),
    locationid integer,
    expecteddate date,
    today date DEFAULT now(),
    receivedat integer NOT NULL,
    distributedto integer,
    arrivaldate date,
    confirmedby integer,
    note text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inventory_transactions OWNER TO postgres;

--
-- Name: TABLE inventory_transactions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE inventory_transactions IS 'Inventory transactions';


--
-- Name: COLUMN inventory_transactions.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.id IS 'ID';


--
-- Name: COLUMN inventory_transactions.transactiontypeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.transactiontypeid IS 'Transaction type';


--
-- Name: COLUMN inventory_transactions.fromfacilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.fromfacilityid IS 'Received from';


--
-- Name: COLUMN inventory_transactions.tofacilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.tofacilityid IS 'Send to';


--
-- Name: COLUMN inventory_transactions.productid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.productid IS 'Product';


--
-- Name: COLUMN inventory_transactions.dispatchreference; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.dispatchreference IS 'Dispatch reference';


--
-- Name: COLUMN inventory_transactions.dispatchdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.dispatchdate IS 'Dispatch date';


--
-- Name: COLUMN inventory_transactions.bol; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.bol IS 'Bill of lading';


--
-- Name: COLUMN inventory_transactions.donorid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.donorid IS 'Donor';


--
-- Name: COLUMN inventory_transactions.origincountryid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.origincountryid IS 'Country of origin';


--
-- Name: COLUMN inventory_transactions.manufacturerid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.manufacturerid IS 'Manufacturer';


--
-- Name: COLUMN inventory_transactions.statusid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.statusid IS 'Received status';


--
-- Name: COLUMN inventory_transactions.purpose; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.purpose IS 'Purpose for the vaccine';


--
-- Name: COLUMN inventory_transactions.vvmtracked; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.vvmtracked IS 'Consignment temperature monitored through VVM';


--
-- Name: COLUMN inventory_transactions.barcoded; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.barcoded IS 'Consignment is bar coded';


--
-- Name: COLUMN inventory_transactions.gs1; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.gs1 IS 'GS1 bar coded';


--
-- Name: COLUMN inventory_transactions.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.quantity IS 'Quantity';


--
-- Name: COLUMN inventory_transactions.packsize; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.packsize IS 'Pack size';


--
-- Name: COLUMN inventory_transactions.unitprice; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.unitprice IS 'Unit price';


--
-- Name: COLUMN inventory_transactions.totalcost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.totalcost IS 'Total cost';


--
-- Name: COLUMN inventory_transactions.locationid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.locationid IS 'Storage location ';


--
-- Name: COLUMN inventory_transactions.expecteddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.expecteddate IS 'Date the shipment expected';


--
-- Name: COLUMN inventory_transactions.arrivaldate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.arrivaldate IS 'Date the shipment arrived at destination';


--
-- Name: COLUMN inventory_transactions.confirmedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.confirmedby IS 'Proof-of-receipt confirmed by';


--
-- Name: COLUMN inventory_transactions.note; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.note IS 'Notes';


--
-- Name: COLUMN inventory_transactions.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.createdby IS 'Created by';


--
-- Name: COLUMN inventory_transactions.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.createddate IS 'Created on';


--
-- Name: COLUMN inventory_transactions.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.modifiedby IS 'Modified by';


--
-- Name: COLUMN inventory_transactions.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN inventory_transactions.modifieddate IS 'Modified on';


--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE inventory_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_transactions_id_seq OWNER TO postgres;

--
-- Name: inventory_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE inventory_transactions_id_seq OWNED BY inventory_transactions.id;


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
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE manufacturers (
    id integer NOT NULL,
    name character varying(1000) NOT NULL,
    website character varying(1000) NOT NULL,
    contactperson character varying(200),
    primaryphone character varying(20),
    email character varying(200),
    description character varying(2000),
    specialization character varying(2000),
    geographiccoverage character varying(2000),
    registrationdate date,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.manufacturers OWNER TO postgres;

--
-- Name: TABLE manufacturers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE manufacturers IS 'Manufacturers';


--
-- Name: COLUMN manufacturers.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.id IS 'id';


--
-- Name: COLUMN manufacturers.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.name IS 'name';


--
-- Name: COLUMN manufacturers.website; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.website IS 'website';


--
-- Name: COLUMN manufacturers.contactperson; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.contactperson IS 'contactPerson';


--
-- Name: COLUMN manufacturers.primaryphone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.primaryphone IS 'primaryPhone';


--
-- Name: COLUMN manufacturers.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.email IS 'email';


--
-- Name: COLUMN manufacturers.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.description IS 'description';


--
-- Name: COLUMN manufacturers.specialization; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.specialization IS 'specialization';


--
-- Name: COLUMN manufacturers.geographiccoverage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.geographiccoverage IS 'geographicCoverage';


--
-- Name: COLUMN manufacturers.registrationdate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.registrationdate IS 'registrationDate';


--
-- Name: COLUMN manufacturers.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.createdby IS 'createdBy';


--
-- Name: COLUMN manufacturers.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.createddate IS 'createdDate';


--
-- Name: COLUMN manufacturers.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.modifiedby IS 'modifiedBy';


--
-- Name: COLUMN manufacturers.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN manufacturers.modifieddate IS 'modifiedDate';


--
-- Name: manufacturers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.manufacturers_id_seq OWNER TO postgres;

--
-- Name: manufacturers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE manufacturers_id_seq OWNED BY manufacturers.id;


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
    createddate timestamp without time zone DEFAULT now(),
    calculationoption character varying(200) DEFAULT 'DEFAULT'::character varying
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
-- Name: migration_schema_version; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE migration_schema_version (
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


ALTER TABLE public.migration_schema_version OWNER TO postgres;

--
-- Name: odk_account; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_account (
    id integer NOT NULL,
    userid integer,
    deviceid character varying(30) NOT NULL,
    simserial character varying(30),
    phonenumber character varying(15),
    subscriberid character varying(20),
    odkusername character varying(20),
    odkemail character varying(30),
    active boolean NOT NULL,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_account OWNER TO postgres;

--
-- Name: odk_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_account_id_seq OWNER TO postgres;

--
-- Name: odk_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_account_id_seq OWNED BY odk_account.id;


--
-- Name: odk_proof_of_delivery_submission_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_proof_of_delivery_submission_data (
    id integer NOT NULL,
    rnrid integer NOT NULL,
    productid integer NOT NULL,
    productcode text NOT NULL,
    quantityreceived integer,
    allquantitydelivered boolean NOT NULL,
    discrepancyamount integer,
    commentforshortfallitem text,
    firstpicture bytea,
    secondpicture bytea,
    thirdpicture bytea,
    receivedby text NOT NULL,
    active boolean,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_proof_of_delivery_submission_data OWNER TO postgres;

--
-- Name: odk_proof_of_delivery_submission_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_proof_of_delivery_submission_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_proof_of_delivery_submission_data_id_seq OWNER TO postgres;

--
-- Name: odk_proof_of_delivery_submission_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_proof_of_delivery_submission_data_id_seq OWNED BY odk_proof_of_delivery_submission_data.id;


--
-- Name: odk_proof_of_delivery_xform; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_proof_of_delivery_xform (
    id integer NOT NULL,
    odkxformid integer NOT NULL,
    facilityid integer NOT NULL,
    programid integer NOT NULL,
    districtid integer NOT NULL,
    periodid integer NOT NULL,
    rnrid integer NOT NULL,
    active boolean,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_proof_of_delivery_xform OWNER TO postgres;

--
-- Name: odk_proof_of_delivery_xform_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_proof_of_delivery_xform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_proof_of_delivery_xform_id_seq OWNER TO postgres;

--
-- Name: odk_proof_of_delivery_xform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_proof_of_delivery_xform_id_seq OWNED BY odk_proof_of_delivery_xform.id;


--
-- Name: odk_stock_status_submission; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_stock_status_submission (
    id integer NOT NULL,
    odksubmissionid integer NOT NULL,
    msdcode character varying(50) NOT NULL,
    commodityname character varying(400) NOT NULL,
    managed boolean NOT NULL,
    physicalinventory numeric(10,2) NOT NULL,
    quantityexpiredtoday integer NOT NULL,
    stockcardavailable boolean NOT NULL,
    stockdatathreemonths boolean NOT NULL,
    sosevendays boolean NOT NULL,
    totaldaysstockedoutthreemonths integer NOT NULL,
    issuedthreemonths numeric(10,2) NOT NULL,
    daysdataavailable integer NOT NULL,
    active boolean NOT NULL,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_stock_status_submission OWNER TO postgres;

--
-- Name: odk_stock_status_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_stock_status_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_stock_status_submission_id_seq OWNER TO postgres;

--
-- Name: odk_stock_status_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_stock_status_submission_id_seq OWNED BY odk_stock_status_submission.id;


--
-- Name: odk_submission; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_submission (
    id integer NOT NULL,
    odkaccountid integer,
    formbuildid character varying(40) NOT NULL,
    instanceid character varying(45) NOT NULL,
    active boolean NOT NULL,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_submission OWNER TO postgres;

--
-- Name: odk_submission_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_submission_data (
    id integer NOT NULL,
    odksubmissionid integer NOT NULL,
    facilityid integer NOT NULL,
    gpslatitude numeric(20,10),
    gpslongitude numeric(20,10),
    gpsaltitude numeric(20,10),
    gpsaccuracy numeric(20,10),
    firstpicture bytea,
    secondpicture bytea,
    thirdpicture bytea,
    fourthpicture bytea,
    fifthpicture bytea,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_submission_data OWNER TO postgres;

--
-- Name: odk_submission_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_submission_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_submission_data_id_seq OWNER TO postgres;

--
-- Name: odk_submission_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_submission_data_id_seq OWNED BY odk_submission_data.id;


--
-- Name: odk_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_submission_id_seq OWNER TO postgres;

--
-- Name: odk_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_submission_id_seq OWNED BY odk_submission.id;


--
-- Name: odk_xform; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_xform (
    id integer NOT NULL,
    formid character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    version character varying(10) NOT NULL,
    hash character varying(50),
    descriptiontext character varying(400),
    downloadurl character varying(150) NOT NULL,
    xmlstring text NOT NULL,
    active boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    odkxformsurveytypeid integer NOT NULL
);


ALTER TABLE public.odk_xform OWNER TO postgres;

--
-- Name: odk_xform_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_xform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_xform_id_seq OWNER TO postgres;

--
-- Name: odk_xform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_xform_id_seq OWNED BY odk_xform.id;


--
-- Name: odk_xform_survey_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE odk_xform_survey_type (
    id integer NOT NULL,
    surveyname character varying(400) NOT NULL,
    numberofquestions integer NOT NULL,
    active boolean NOT NULL,
    comment text,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.odk_xform_survey_type OWNER TO postgres;

--
-- Name: odk_xform_survey_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE odk_xform_survey_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odk_xform_survey_type_id_seq OWNER TO postgres;

--
-- Name: odk_xform_survey_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE odk_xform_survey_type_id_seq OWNED BY odk_xform_survey_type.id;


--
-- Name: on_hand; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE on_hand (
    id integer NOT NULL,
    transactionid integer NOT NULL,
    transactiontypeid integer NOT NULL,
    productid integer NOT NULL,
    facilityid integer NOT NULL,
    batchnumber integer NOT NULL,
    quantity integer NOT NULL,
    vvm1_qty integer,
    vvm2_qty integer,
    vvm3_qty integer,
    vvm4_qty integer,
    note character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.on_hand OWNER TO postgres;

--
-- Name: TABLE on_hand; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE on_hand IS 'On hand of inventory';


--
-- Name: COLUMN on_hand.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.id IS 'ID';


--
-- Name: COLUMN on_hand.transactionid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.transactionid IS 'Trasaction reference';


--
-- Name: COLUMN on_hand.transactiontypeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.transactiontypeid IS 'Transaction Type';


--
-- Name: COLUMN on_hand.productid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.productid IS 'Product code';


--
-- Name: COLUMN on_hand.facilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.facilityid IS 'Facility ID';


--
-- Name: COLUMN on_hand.batchnumber; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.batchnumber IS 'Batch number';


--
-- Name: COLUMN on_hand.quantity; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.quantity IS 'Quantity';


--
-- Name: COLUMN on_hand.vvm1_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.vvm1_qty IS 'VVM1';


--
-- Name: COLUMN on_hand.vvm2_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.vvm2_qty IS 'VVM2';


--
-- Name: COLUMN on_hand.vvm3_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.vvm3_qty IS 'VVM3';


--
-- Name: COLUMN on_hand.vvm4_qty; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.vvm4_qty IS 'VVM4';


--
-- Name: COLUMN on_hand.note; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.note IS 'Notes';


--
-- Name: COLUMN on_hand.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.createdby IS 'Created by';


--
-- Name: COLUMN on_hand.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.createddate IS 'Created on';


--
-- Name: COLUMN on_hand.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.modifiedby IS 'Modified by';


--
-- Name: COLUMN on_hand.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN on_hand.modifieddate IS 'Modified on';


--
-- Name: on_hand_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE on_hand_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.on_hand_id_seq OWNER TO postgres;

--
-- Name: on_hand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE on_hand_id_seq OWNED BY on_hand.id;


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
    ordernumber character varying(100) DEFAULT 0 NOT NULL
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
    ordernumber character varying(100) DEFAULT 0 NOT NULL
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
-- Name: product_code_change_log; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_code_change_log (
    program character varying(4),
    old_code character varying(12),
    new_code character varying(12),
    product character varying(200),
    unit character varying(200),
    changeddate timestamp without time zone,
    migrated boolean DEFAULT false
);


ALTER TABLE public.product_code_change_log OWNER TO postgres;

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
-- Name: product_mapping; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE product_mapping (
    id integer NOT NULL,
    productcode character varying(255) NOT NULL,
    manufacturerid integer NOT NULL,
    gtin character varying(255),
    elmis character varying(255),
    rhi character varying(255),
    ppmr character varying(255),
    who character varying(255),
    other1 character varying(255),
    other2 character varying(255),
    other3 character varying(255),
    other4 character varying(255),
    other5 character varying(255),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.product_mapping OWNER TO postgres;

--
-- Name: TABLE product_mapping; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE product_mapping IS 'product mapping';


--
-- Name: COLUMN product_mapping.productcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.productcode IS 'productCode';


--
-- Name: COLUMN product_mapping.gtin; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.gtin IS 'gtin';


--
-- Name: COLUMN product_mapping.elmis; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.elmis IS 'elmis';


--
-- Name: COLUMN product_mapping.rhi; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.rhi IS 'rhi';


--
-- Name: COLUMN product_mapping.ppmr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.ppmr IS 'ppmr';


--
-- Name: COLUMN product_mapping.who; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.who IS 'who';


--
-- Name: COLUMN product_mapping.other1; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.other1 IS 'other1';


--
-- Name: COLUMN product_mapping.other2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.other2 IS 'other2';


--
-- Name: COLUMN product_mapping.other3; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.other3 IS 'other3';


--
-- Name: COLUMN product_mapping.other4; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.other4 IS 'other4';


--
-- Name: COLUMN product_mapping.other5; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN product_mapping.other5 IS 'other5';


--
-- Name: product_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE product_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_mapping_id_seq OWNER TO postgres;

--
-- Name: product_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE product_mapping_id_seq OWNED BY product_mapping.id;


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
-- Name: program_equipment_products; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_equipment_products (
    id integer NOT NULL,
    programequipmentid integer NOT NULL,
    productid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_equipment_products OWNER TO postgres;

--
-- Name: program_equipment_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_equipment_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_equipment_products_id_seq OWNER TO postgres;

--
-- Name: program_equipment_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_equipment_products_id_seq OWNED BY program_equipment_products.id;


--
-- Name: program_equipments; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE program_equipments (
    id integer NOT NULL,
    programid integer NOT NULL,
    equipmentid integer NOT NULL,
    displayorder integer NOT NULL,
    enabletestcount boolean DEFAULT false,
    enabletotalcolumn boolean DEFAULT false,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.program_equipments OWNER TO postgres;

--
-- Name: program_equipments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE program_equipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.program_equipments_id_seq OWNER TO postgres;

--
-- Name: program_equipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE program_equipments_id_seq OWNED BY program_equipments.id;


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
    rnroptionid integer,
    calculationoption character varying(200) DEFAULT 'DEFAULT'::character varying
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
-- Name: received_status; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE received_status (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    transactiontypeid integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.received_status OWNER TO postgres;

--
-- Name: TABLE received_status; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE received_status IS 'Shipment received status';


--
-- Name: COLUMN received_status.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.id IS 'ID';


--
-- Name: COLUMN received_status.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.name IS 'Name';


--
-- Name: COLUMN received_status.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.createdby IS 'Created by';


--
-- Name: COLUMN received_status.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.createddate IS 'Created on';


--
-- Name: COLUMN received_status.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.modifiedby IS 'Modified by';


--
-- Name: COLUMN received_status.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN received_status.modifieddate IS 'Modified on';


--
-- Name: received_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE received_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.received_status_id_seq OWNER TO postgres;

--
-- Name: received_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE received_status_id_seq OWNED BY received_status.id;


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
    modifieddate timestamp without time zone DEFAULT now(),
    skipped boolean DEFAULT false NOT NULL
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
    concatenatedorderid character varying(50),
    facilitycode character varying(50),
    programcode character varying(50),
    productcode character varying(50) NOT NULL,
    quantityordered integer,
    quantityshipped integer NOT NULL,
    cost numeric(15,2),
    packeddate timestamp without time zone,
    shippeddate timestamp without time zone,
    substitutedproductcode character varying(50),
    substitutedproductname character varying(200),
    substitutedproductquantityshipped integer,
    packsize integer,
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
-- Name: sms; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sms (
    id integer NOT NULL,
    message character varying(250),
    phonenumber character varying(20),
    direction character varying(40),
    sent boolean DEFAULT false,
    datesaved date
);


ALTER TABLE public.sms OWNER TO postgres;

--
-- Name: sms_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE sms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sms_id_seq OWNER TO postgres;

--
-- Name: sms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE sms_id_seq OWNED BY sms.id;


--
-- Name: storage_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE storage_types (
    id integer NOT NULL,
    storagetypename character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.storage_types OWNER TO postgres;

--
-- Name: TABLE storage_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE storage_types IS 'Vaccine storage types';


--
-- Name: COLUMN storage_types.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.id IS 'ID';


--
-- Name: COLUMN storage_types.storagetypename; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.storagetypename IS 'Storage type';


--
-- Name: COLUMN storage_types.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.createdby IS 'Created by';


--
-- Name: COLUMN storage_types.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.createddate IS 'Created on';


--
-- Name: COLUMN storage_types.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.modifiedby IS 'Modified by';


--
-- Name: COLUMN storage_types.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN storage_types.modifieddate IS 'Modified on';


--
-- Name: storage_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE storage_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.storage_types_id_seq OWNER TO postgres;

--
-- Name: storage_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE storage_types_id_seq OWNED BY storage_types.id;


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
    supervisorynodeid integer,
    programid integer NOT NULL,
    supplyingfacilityid integer NOT NULL,
    exportorders boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    parentid integer
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
-- Name: temperature; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE temperature (
    id integer NOT NULL,
    temperaturename character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.temperature OWNER TO postgres;

--
-- Name: TABLE temperature; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE temperature IS 'Vaccine storage temperature';


--
-- Name: COLUMN temperature.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.id IS 'ID';


--
-- Name: COLUMN temperature.temperaturename; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.temperaturename IS 'Temperature';


--
-- Name: COLUMN temperature.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.createdby IS 'Created by';


--
-- Name: COLUMN temperature.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.createddate IS 'Created on';


--
-- Name: COLUMN temperature.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.modifiedby IS 'Modified by';


--
-- Name: COLUMN temperature.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN temperature.modifieddate IS 'Modified on';


--
-- Name: temperature_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE temperature_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.temperature_id_seq OWNER TO postgres;

--
-- Name: temperature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE temperature_id_seq OWNED BY temperature.id;


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
-- Name: transaction_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.transaction_types OWNER TO postgres;

--
-- Name: TABLE transaction_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE transaction_types IS 'Inventory transaction types';


--
-- Name: COLUMN transaction_types.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.id IS 'ID';


--
-- Name: COLUMN transaction_types.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.name IS 'Transaction Name';


--
-- Name: COLUMN transaction_types.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.createdby IS 'Created by';


--
-- Name: COLUMN transaction_types.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.createddate IS 'Created on';


--
-- Name: COLUMN transaction_types.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.modifiedby IS 'Modified by';


--
-- Name: COLUMN transaction_types.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN transaction_types.modifieddate IS 'Modified on';


--
-- Name: transaction_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE transaction_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transaction_types_id_seq OWNER TO postgres;

--
-- Name: transaction_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE transaction_types_id_seq OWNED BY transaction_types.id;


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
-- Name: user_preference_master; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_preference_master (
    id integer NOT NULL,
    key character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    groupname character varying(50),
    groupdisplayorder integer DEFAULT 1,
    displayorder integer,
    description character varying(2000),
    entitytype character varying(50),
    inputtype character varying(50),
    datatype character varying(50),
    defaultvalue character varying(2000),
    isactive boolean DEFAULT true,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_preference_master OWNER TO postgres;

--
-- Name: user_preference_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_preference_master_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_preference_master_id_seq OWNER TO postgres;

--
-- Name: user_preference_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE user_preference_master_id_seq OWNED BY user_preference_master.id;


--
-- Name: user_preference_roles; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_preference_roles (
    roleid integer NOT NULL,
    userpreferencekey character varying(50),
    isapplicable boolean,
    defaultvalue character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_preference_roles OWNER TO postgres;

--
-- Name: user_preferences; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE user_preferences (
    userid integer NOT NULL,
    userpreferencekey character varying(50),
    value character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_preferences OWNER TO postgres;

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


--
-- Name: vaccination_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccination_types (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccination_types OWNER TO postgres;

--
-- Name: TABLE vaccination_types; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccination_types IS 'Vaccine storage types';


--
-- Name: COLUMN vaccination_types.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.id IS 'ID';


--
-- Name: COLUMN vaccination_types.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.name IS 'Vaccination type';


--
-- Name: COLUMN vaccination_types.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.createdby IS 'Created by';


--
-- Name: COLUMN vaccination_types.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.createddate IS 'Created on';


--
-- Name: COLUMN vaccination_types.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.modifiedby IS 'Modified by';


--
-- Name: COLUMN vaccination_types.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccination_types.modifieddate IS 'Modified on';


--
-- Name: vaccination_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccination_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccination_types_id_seq OWNER TO postgres;

--
-- Name: vaccination_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccination_types_id_seq OWNED BY vaccination_types.id;


--
-- Name: vaccine_administration_mode; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_administration_mode (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_administration_mode OWNER TO postgres;

--
-- Name: TABLE vaccine_administration_mode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_administration_mode IS 'administration_mode';


--
-- Name: COLUMN vaccine_administration_mode.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.id IS 'ID';


--
-- Name: COLUMN vaccine_administration_mode.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.name IS 'Administration mode';


--
-- Name: COLUMN vaccine_administration_mode.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.createdby IS 'Created by';


--
-- Name: COLUMN vaccine_administration_mode.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.createddate IS 'Created on';


--
-- Name: COLUMN vaccine_administration_mode.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.modifiedby IS 'Modified by';


--
-- Name: COLUMN vaccine_administration_mode.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_administration_mode.modifieddate IS 'Modified on';


--
-- Name: vaccine_administration_mode_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_administration_mode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_administration_mode_id_seq OWNER TO postgres;

--
-- Name: vaccine_administration_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_administration_mode_id_seq OWNED BY vaccine_administration_mode.id;


--
-- Name: vaccine_dilution; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_dilution (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_dilution OWNER TO postgres;

--
-- Name: TABLE vaccine_dilution; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_dilution IS 'dilution';


--
-- Name: COLUMN vaccine_dilution.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.id IS 'ID';


--
-- Name: COLUMN vaccine_dilution.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.name IS 'Diluation';


--
-- Name: COLUMN vaccine_dilution.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.createdby IS 'Created by';


--
-- Name: COLUMN vaccine_dilution.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.createddate IS 'Created on';


--
-- Name: COLUMN vaccine_dilution.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.modifiedby IS 'Modified by';


--
-- Name: COLUMN vaccine_dilution.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_dilution.modifieddate IS 'Modified on';


--
-- Name: vaccine_dilution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_dilution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_dilution_id_seq OWNER TO postgres;

--
-- Name: vaccine_dilution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_dilution_id_seq OWNED BY vaccine_dilution.id;


--
-- Name: vaccine_diseases; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_diseases (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(200),
    displayorder integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_diseases OWNER TO postgres;

--
-- Name: vaccine_diseases_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_diseases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_diseases_id_seq OWNER TO postgres;

--
-- Name: vaccine_diseases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_diseases_id_seq OWNED BY vaccine_diseases.id;


--
-- Name: vaccine_distribution_batches; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_distribution_batches (
    id integer NOT NULL,
    batchid integer,
    dispatchid character varying(100),
    expirydate timestamp without time zone,
    productiondate timestamp without time zone,
    manufacturerid integer NOT NULL,
    donorid integer NOT NULL,
    receivedate date,
    recalldate date,
    productcode character varying(50) NOT NULL,
    vouchernumber integer,
    originid integer,
    fromfacilityid integer NOT NULL,
    tofacilityid integer NOT NULL,
    distributiontypeid character varying(100),
    vialsperbox integer,
    boxlength integer,
    boxwidth integer,
    boxheight integer,
    unitcost integer,
    totalcost integer,
    purposeid integer,
    freight integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_distribution_batches OWNER TO postgres;

--
-- Name: TABLE vaccine_distribution_batches; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_distribution_batches IS 'vaccine distribution batches';


--
-- Name: COLUMN vaccine_distribution_batches.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.id IS 'id';


--
-- Name: COLUMN vaccine_distribution_batches.batchid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.batchid IS 'batchId';


--
-- Name: COLUMN vaccine_distribution_batches.expirydate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.expirydate IS 'expiryDate';


--
-- Name: COLUMN vaccine_distribution_batches.productiondate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.productiondate IS 'productionDate';


--
-- Name: COLUMN vaccine_distribution_batches.manufacturerid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.manufacturerid IS 'manufacturerId';


--
-- Name: COLUMN vaccine_distribution_batches.donorid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.donorid IS 'donorId';


--
-- Name: COLUMN vaccine_distribution_batches.receivedate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.receivedate IS 'receiveDate';


--
-- Name: COLUMN vaccine_distribution_batches.productcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.productcode IS 'productCode';


--
-- Name: COLUMN vaccine_distribution_batches.fromfacilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.fromfacilityid IS 'fromFacilityId';


--
-- Name: COLUMN vaccine_distribution_batches.tofacilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.tofacilityid IS 'toFacilityId';


--
-- Name: COLUMN vaccine_distribution_batches.distributiontypeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.distributiontypeid IS 'distributionType';


--
-- Name: COLUMN vaccine_distribution_batches.vialsperbox; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.vialsperbox IS 'vialsPerBox';


--
-- Name: COLUMN vaccine_distribution_batches.boxlength; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.boxlength IS 'boxLength';


--
-- Name: COLUMN vaccine_distribution_batches.boxwidth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.boxwidth IS 'boxWidth';


--
-- Name: COLUMN vaccine_distribution_batches.boxheight; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.boxheight IS 'boxHeight';


--
-- Name: COLUMN vaccine_distribution_batches.unitcost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.unitcost IS 'unitCost';


--
-- Name: COLUMN vaccine_distribution_batches.totalcost; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.totalcost IS 'totalCost';


--
-- Name: COLUMN vaccine_distribution_batches.purposeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.purposeid IS 'purposeId';


--
-- Name: COLUMN vaccine_distribution_batches.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.createdby IS 'createdBy';


--
-- Name: COLUMN vaccine_distribution_batches.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.createddate IS 'createdDate';


--
-- Name: COLUMN vaccine_distribution_batches.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.modifiedby IS 'modifiedBy';


--
-- Name: COLUMN vaccine_distribution_batches.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_batches.modifieddate IS 'modifiedDate';


--
-- Name: vaccine_distribution_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_distribution_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_distribution_batches_id_seq OWNER TO postgres;

--
-- Name: vaccine_distribution_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_distribution_batches_id_seq OWNED BY vaccine_distribution_batches.id;


--
-- Name: vaccine_distribution_demographics; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_distribution_demographics (
    id integer NOT NULL,
    geographiczoneid integer,
    population integer,
    expected_births integer,
    expected_pregnancies integer,
    serving_infants integer,
    surviving_infants integer
);


ALTER TABLE public.vaccine_distribution_demographics OWNER TO postgres;

--
-- Name: vaccine_distribution_demographics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_distribution_demographics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_distribution_demographics_id_seq OWNER TO postgres;

--
-- Name: vaccine_distribution_demographics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_distribution_demographics_id_seq OWNED BY vaccine_distribution_demographics.id;


--
-- Name: vaccine_distribution_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_distribution_line_items (
    id integer NOT NULL,
    distributionbatchid integer NOT NULL,
    quantityreceived double precision,
    vvmstage integer,
    confirmed boolean,
    comments character varying(250),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_distribution_line_items OWNER TO postgres;

--
-- Name: TABLE vaccine_distribution_line_items; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_distribution_line_items IS 'vaccine distribution line items';


--
-- Name: COLUMN vaccine_distribution_line_items.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.id IS 'id';


--
-- Name: COLUMN vaccine_distribution_line_items.distributionbatchid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.distributionbatchid IS 'distributionBatchId';


--
-- Name: COLUMN vaccine_distribution_line_items.quantityreceived; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.quantityreceived IS 'quantityReceived';


--
-- Name: COLUMN vaccine_distribution_line_items.vvmstage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.vvmstage IS 'vvmStage';


--
-- Name: COLUMN vaccine_distribution_line_items.confirmed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.confirmed IS 'confirmed';


--
-- Name: COLUMN vaccine_distribution_line_items.comments; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_distribution_line_items.comments IS 'comments';


--
-- Name: vaccine_distribution_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_distribution_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_distribution_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_distribution_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_distribution_line_items_id_seq OWNED BY vaccine_distribution_line_items.id;


--
-- Name: vaccine_distribution_parameters; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_distribution_parameters (
    id integer NOT NULL,
    programid integer,
    productcode character varying(60),
    dosespertarget integer,
    targetpopulationpercent integer,
    expectedcoverage integer,
    presentation integer,
    wastagerate integer,
    administrationmodeid character varying,
    dilutionid character varying,
    supplyinterval integer,
    safetystock integer,
    leadtime integer
);


ALTER TABLE public.vaccine_distribution_parameters OWNER TO postgres;

--
-- Name: vaccine_distribution_parameters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_distribution_parameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_distribution_parameters_id_seq OWNER TO postgres;

--
-- Name: vaccine_distribution_parameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_distribution_parameters_id_seq OWNED BY vaccine_distribution_parameters.id;


--
-- Name: vaccine_distribution_types; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_distribution_types (
    id integer NOT NULL,
    colde character varying(50),
    name character varying(250),
    nature character varying(2)
);


ALTER TABLE public.vaccine_distribution_types OWNER TO postgres;

--
-- Name: vaccine_doses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_doses (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(200),
    displayorder integer NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_doses OWNER TO postgres;

--
-- Name: vaccine_doses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_doses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_doses_id_seq OWNER TO postgres;

--
-- Name: vaccine_doses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_doses_id_seq OWNED BY vaccine_doses.id;


--
-- Name: vaccine_logistics_master_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_logistics_master_columns (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(200) NOT NULL,
    label character varying(200) NOT NULL,
    indicator character varying(20) NOT NULL,
    displayorder integer NOT NULL,
    mandatory boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_logistics_master_columns OWNER TO postgres;

--
-- Name: vaccine_logistics_master_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_logistics_master_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_logistics_master_columns_id_seq OWNER TO postgres;

--
-- Name: vaccine_logistics_master_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_logistics_master_columns_id_seq OWNED BY vaccine_logistics_master_columns.id;


--
-- Name: vaccine_product_doses; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_product_doses (
    id integer NOT NULL,
    doseid integer NOT NULL,
    programid integer NOT NULL,
    productid integer NOT NULL,
    isactive boolean,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_product_doses OWNER TO postgres;

--
-- Name: vaccine_product_doses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_product_doses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_product_doses_id_seq OWNER TO postgres;

--
-- Name: vaccine_product_doses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_product_doses_id_seq OWNED BY vaccine_product_doses.id;


--
-- Name: vaccine_program_logistics_columns; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_program_logistics_columns (
    id integer NOT NULL,
    programid integer NOT NULL,
    mastercolumnid integer NOT NULL,
    label character varying(200) NOT NULL,
    displayorder integer NOT NULL,
    visible boolean NOT NULL,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_program_logistics_columns OWNER TO postgres;

--
-- Name: vaccine_program_logistics_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_program_logistics_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_program_logistics_columns_id_seq OWNER TO postgres;

--
-- Name: vaccine_program_logistics_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_program_logistics_columns_id_seq OWNED BY vaccine_program_logistics_columns.id;


--
-- Name: vaccine_quantifications; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_quantifications (
    id integer NOT NULL,
    programid integer NOT NULL,
    quantificationyear integer NOT NULL,
    vaccinetypeid integer NOT NULL,
    productcode character varying(50) NOT NULL,
    targetpopulation integer NOT NULL,
    targetpopulationpercent integer NOT NULL,
    dosespertarget numeric(8,4),
    presentation integer,
    expectedcoverage integer,
    wastagerate integer,
    administrationmodeid integer,
    dilutionid integer,
    supplyinterval numeric(4,2),
    safetystock numeric(4,2),
    leadtime numeric(4,2),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_quantifications OWNER TO postgres;

--
-- Name: TABLE vaccine_quantifications; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_quantifications IS 'Parameters to be used for vaccine quantifications';


--
-- Name: COLUMN vaccine_quantifications.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.id IS 'ID';


--
-- Name: COLUMN vaccine_quantifications.programid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.programid IS 'Program';


--
-- Name: COLUMN vaccine_quantifications.quantificationyear; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.quantificationyear IS 'Year';


--
-- Name: COLUMN vaccine_quantifications.vaccinetypeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.vaccinetypeid IS 'Vaccine type';


--
-- Name: COLUMN vaccine_quantifications.productcode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.productcode IS 'Product';


--
-- Name: COLUMN vaccine_quantifications.targetpopulation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.targetpopulation IS 'Target population';


--
-- Name: COLUMN vaccine_quantifications.targetpopulationpercent; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.targetpopulationpercent IS 'Target population percentage';


--
-- Name: COLUMN vaccine_quantifications.dosespertarget; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.dosespertarget IS 'Doses per target';


--
-- Name: COLUMN vaccine_quantifications.presentation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.presentation IS 'Presentation';


--
-- Name: COLUMN vaccine_quantifications.expectedcoverage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.expectedcoverage IS 'Expected coverage';


--
-- Name: COLUMN vaccine_quantifications.wastagerate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.wastagerate IS 'Wastage rate';


--
-- Name: COLUMN vaccine_quantifications.administrationmodeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.administrationmodeid IS 'Administration mode';


--
-- Name: COLUMN vaccine_quantifications.dilutionid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.dilutionid IS 'Diluation';


--
-- Name: COLUMN vaccine_quantifications.supplyinterval; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.supplyinterval IS 'Supply interval (months)';


--
-- Name: COLUMN vaccine_quantifications.safetystock; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.safetystock IS 'Safety stock';


--
-- Name: COLUMN vaccine_quantifications.leadtime; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.leadtime IS 'Lead time';


--
-- Name: COLUMN vaccine_quantifications.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.createdby IS 'Created by';


--
-- Name: COLUMN vaccine_quantifications.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.createddate IS 'Created on';


--
-- Name: COLUMN vaccine_quantifications.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.modifiedby IS 'Modified by';


--
-- Name: COLUMN vaccine_quantifications.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_quantifications.modifieddate IS 'Modified on';


--
-- Name: vaccine_quantifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_quantifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_quantifications_id_seq OWNER TO postgres;

--
-- Name: vaccine_quantifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_quantifications_id_seq OWNED BY vaccine_quantifications.id;


--
-- Name: vaccine_report_adverse_effect_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_adverse_effect_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    productid integer NOT NULL,
    date date,
    manufacturerid integer,
    batch character varying(100) NOT NULL,
    expiry date,
    cases integer NOT NULL,
    investigation character varying(2000),
    notes character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_report_adverse_effect_line_items OWNER TO postgres;

--
-- Name: vaccine_report_adverse_effect_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_adverse_effect_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_adverse_effect_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_adverse_effect_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_adverse_effect_line_items_id_seq OWNED BY vaccine_report_adverse_effect_line_items.id;


--
-- Name: vaccine_report_campaign_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_campaign_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    name character varying(200) NOT NULL,
    venue character varying(200),
    startdate date,
    enddate date,
    childrenvaccinated integer,
    pregnantwomanvaccinated integer,
    otherobjectives character varying(2000),
    vaccinated character varying(200),
    remarks character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_report_campaign_line_items OWNER TO postgres;

--
-- Name: vaccine_report_campaign_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_campaign_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_campaign_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_campaign_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_campaign_line_items_id_seq OWNED BY vaccine_report_campaign_line_items.id;


--
-- Name: vaccine_report_cold_chain_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_cold_chain_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    equipmentinventoryid integer NOT NULL,
    mintemp numeric,
    maxtemp numeric,
    minepisodetemp numeric,
    maxepisodetemp numeric,
    remarks character varying(2000),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_report_cold_chain_line_items OWNER TO postgres;

--
-- Name: vaccine_report_cold_chain_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_cold_chain_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_cold_chain_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_cold_chain_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_cold_chain_line_items_id_seq OWNED BY vaccine_report_cold_chain_line_items.id;


--
-- Name: vaccine_report_coverage_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_coverage_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    productid integer NOT NULL,
    doseid integer NOT NULL,
    isactive boolean DEFAULT false NOT NULL,
    regular integer,
    outreach integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_report_coverage_line_items OWNER TO postgres;

--
-- Name: vaccine_report_coverage_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_coverage_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_coverage_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_coverage_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_coverage_line_items_id_seq OWNED BY vaccine_report_coverage_line_items.id;


--
-- Name: vaccine_report_disease_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_disease_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    diseaseid integer NOT NULL,
    diseasename character varying(200) NOT NULL,
    displayorder integer NOT NULL,
    cases integer,
    death integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_report_disease_line_items OWNER TO postgres;

--
-- Name: vaccine_report_disease_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_disease_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_disease_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_disease_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_disease_line_items_id_seq OWNED BY vaccine_report_disease_line_items.id;


--
-- Name: vaccine_report_logistics_line_items; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_report_logistics_line_items (
    id integer NOT NULL,
    reportid integer NOT NULL,
    productid integer NOT NULL,
    productcode character varying(100) NOT NULL,
    productname character varying(200) NOT NULL,
    displayorder integer NOT NULL,
    openingbalance integer,
    quantityreceived integer,
    quantityissued integer,
    quantityvvmalerted integer,
    quantityfreezed integer,
    quantityexpired integer,
    quantitydiscardedunopened integer,
    quantitydiscardedopened integer,
    quantitywastedother integer,
    endingbalance integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now(),
    productcategory character varying(200),
    closingbalance integer
);


ALTER TABLE public.vaccine_report_logistics_line_items OWNER TO postgres;

--
-- Name: vaccine_report_logistics_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_report_logistics_line_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_report_logistics_line_items_id_seq OWNER TO postgres;

--
-- Name: vaccine_report_logistics_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_report_logistics_line_items_id_seq OWNED BY vaccine_report_logistics_line_items.id;


--
-- Name: vaccine_reports; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_reports (
    id integer NOT NULL,
    periodid integer NOT NULL,
    programid integer NOT NULL,
    facilityid integer NOT NULL,
    status character varying(100) NOT NULL,
    supervisorynodeid integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_reports OWNER TO postgres;

--
-- Name: vaccine_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_reports_id_seq OWNER TO postgres;

--
-- Name: vaccine_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_reports_id_seq OWNED BY vaccine_reports.id;


--
-- Name: vaccine_storage; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_storage (
    id integer NOT NULL,
    storagetypeid integer NOT NULL,
    facilityid integer NOT NULL,
    loccode character varying(100) NOT NULL,
    name character varying(250) NOT NULL,
    temperatureid integer NOT NULL,
    grosscapacity integer,
    netcapacity integer,
    dimension character varying(100),
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_storage OWNER TO postgres;

--
-- Name: TABLE vaccine_storage; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_storage IS 'Vaccine storage capacity';


--
-- Name: COLUMN vaccine_storage.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.id IS 'ID';


--
-- Name: COLUMN vaccine_storage.storagetypeid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.storagetypeid IS 'Storage type';


--
-- Name: COLUMN vaccine_storage.facilityid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.facilityid IS 'Facility';


--
-- Name: COLUMN vaccine_storage.loccode; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.loccode IS 'Storage location code';


--
-- Name: COLUMN vaccine_storage.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.name IS 'Storage name';


--
-- Name: COLUMN vaccine_storage.temperatureid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_storage.temperatureid IS 'Temperature';


--
-- Name: vaccine_storage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_storage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_storage_id_seq OWNER TO postgres;

--
-- Name: vaccine_storage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_storage_id_seq OWNED BY vaccine_storage.id;


--
-- Name: vaccine_targets; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vaccine_targets (
    id integer NOT NULL,
    geographiczoneid integer NOT NULL,
    targetyear integer NOT NULL,
    population integer NOT NULL,
    expectedbirths integer,
    expectedpregnancies integer,
    servinginfants integer,
    survivinginfants integer,
    children1yr integer,
    children2yr integer,
    girls9_13yr integer,
    createdby integer,
    createddate timestamp without time zone DEFAULT now(),
    modifiedby integer,
    modifieddate timestamp without time zone DEFAULT now()
);


ALTER TABLE public.vaccine_targets OWNER TO postgres;

--
-- Name: TABLE vaccine_targets; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE vaccine_targets IS 'Demographics and targets for the vaccine program';


--
-- Name: COLUMN vaccine_targets.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.id IS 'ID';


--
-- Name: COLUMN vaccine_targets.geographiczoneid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.geographiczoneid IS 'Zone ID';


--
-- Name: COLUMN vaccine_targets.targetyear; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.targetyear IS 'Year';


--
-- Name: COLUMN vaccine_targets.population; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.population IS 'Population';


--
-- Name: COLUMN vaccine_targets.expectedbirths; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.expectedbirths IS 'Expected births';


--
-- Name: COLUMN vaccine_targets.expectedpregnancies; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.expectedpregnancies IS 'Expected pregnancies';


--
-- Name: COLUMN vaccine_targets.servinginfants; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.servinginfants IS 'Serving infants';


--
-- Name: COLUMN vaccine_targets.survivinginfants; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.survivinginfants IS 'Surviving infants';


--
-- Name: COLUMN vaccine_targets.children1yr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.children1yr IS 'Children Below 1 year';


--
-- Name: COLUMN vaccine_targets.children2yr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.children2yr IS 'Children Below 2 year';


--
-- Name: COLUMN vaccine_targets.girls9_13yr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.girls9_13yr IS 'Girls between 9 to 13 years';


--
-- Name: COLUMN vaccine_targets.createdby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.createdby IS 'Created by';


--
-- Name: COLUMN vaccine_targets.createddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.createddate IS 'Created on';


--
-- Name: COLUMN vaccine_targets.modifiedby; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.modifiedby IS 'Modified by';


--
-- Name: COLUMN vaccine_targets.modifieddate; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN vaccine_targets.modifieddate IS 'Modified on';


--
-- Name: vaccine_targets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE vaccine_targets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vaccine_targets_id_seq OWNER TO postgres;

--
-- Name: vaccine_targets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE vaccine_targets_id_seq OWNED BY vaccine_targets.id;


--
-- Name: vw_districts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_districts AS
 SELECT d.id AS district_id,
    d.name AS district_name,
    r.id AS region_id,
    r.name AS region_name,
    z.id AS zone_id,
    z.name AS zone_name,
    z.parentid AS parent
   FROM ((geographic_zones d
   JOIN geographic_zones r ON ((d.parentid = r.id)))
   JOIN geographic_zones z ON ((z.id = r.parentid)));


ALTER TABLE public.vw_districts OWNER TO postgres;

--
-- Name: vw_district_consumption_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_district_consumption_summary AS
 SELECT programs.id AS program_id,
    programs.name AS program_name,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.startdate AS processing_periods_start_date,
    processing_periods.enddate AS processing_periods_end_date,
    processing_schedules.id AS processing_schedules_id,
    processing_schedules.name AS processing_schedules_name,
    facility_types.name AS facility_type_name,
    facility_types.id AS facility_type_id,
    facilities.code AS facility_code,
    facilities.id AS facility_id,
    facilities.name AS facility_name,
    geographic_zones.name AS zone_name,
    geographic_zones.id AS zone_id,
    requisition_line_items.id AS requisition_line_item_id,
    requisition_line_items.productcode,
    requisition_line_items.product,
    products.id AS product_id,
    product_categories.name AS product_category_name,
    product_categories.id AS product_category_id,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.quantitydispensed,
    requisition_line_items.id,
    vw_districts.zone_id AS district_zone_id,
    vw_districts.parent,
    vw_districts.region_id,
    vw_districts.district_id
   FROM (((((((((((requisition_line_items
   JOIN requisitions ON ((requisition_line_items.rnrid = requisitions.id)))
   JOIN products ON (((requisition_line_items.productcode)::text = (products.code)::text)))
   JOIN programs ON ((requisitions.programid = programs.id)))
   JOIN program_products ON (((products.id = program_products.productid) AND (program_products.programid = programs.id))))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN product_categories ON ((program_products.productcategoryid = product_categories.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN facilities ON ((requisitions.facilityid = facilities.id)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN vw_districts ON ((vw_districts.district_id = facilities.geographiczoneid)))
   JOIN geographic_zones ON ((facilities.geographiczoneid = geographic_zones.id)));


ALTER TABLE public.vw_district_consumption_summary OWNER TO postgres;

--
-- Name: vw_district_financial_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_district_financial_summary AS
 SELECT processing_periods.id AS periodid,
    processing_periods.name AS period,
    processing_periods.startdate,
    processing_periods.enddate,
    processing_periods.scheduleid,
    processing_schedules.name AS schedule,
    facility_types.id AS facilitytypeid,
    facility_types.name AS facilitytype,
    facilities.code AS facilitycode,
    facilities.name AS facility,
    facilities.id AS facility_id,
    requisitions.id AS rnrid,
    requisitions.status,
    geographic_zones.name AS region,
    p.name AS program,
    p.id AS programid,
    requisitions.fullsupplyitemssubmittedcost,
    requisitions.nonfullsupplyitemssubmittedcost,
    geographic_zones.id AS zoneid
   FROM ((((((requisitions
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN processing_periods ON ((processing_periods.id = requisitions.periodid)))
   JOIN processing_schedules ON ((processing_schedules.id = processing_periods.scheduleid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN programs p ON ((p.id = requisitions.programid)))
  WHERE ((requisitions.status)::text = ANY (ARRAY[('IN_APPROVAL'::character varying)::text, ('APPROVED'::character varying)::text, ('RELEASED'::character varying)::text]));


ALTER TABLE public.vw_district_financial_summary OWNER TO postgres;

--
-- Name: vw_equipment_list_by_donor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_equipment_list_by_donor AS
 SELECT geographic_zones.name AS district,
    facilities.name AS facilityname,
    donors.shortname AS donor,
    facility_program_equipments.sourceoffund,
    equipments.name AS equipment_name,
    facility_program_equipments.model,
    facility_program_equipments.yearofinstallation,
        CASE
            WHEN (facility_program_equipments.hasservicecontract = false) THEN 'No'::text
            ELSE 'yes'::text
        END AS hasservicecontract,
        CASE
            WHEN (facility_program_equipments.servicecontractenddate IS NULL) THEN '-'::text
            ELSE (facility_program_equipments.servicecontractenddate)::text
        END AS servicecontractenddate,
        CASE
            WHEN (facility_program_equipments.isactive = true) THEN 'Yes'::text
            ELSE 'No'::text
        END AS isactive,
        CASE
            WHEN (facility_program_equipments.datedecommissioned IS NULL) THEN '-'::text
            ELSE (facility_program_equipments.datedecommissioned)::text
        END AS datedecommissioned,
        CASE
            WHEN (facility_program_equipments.replacementrecommended = false) THEN 'No'::text
            ELSE 'Yes'::text
        END AS replacementrecommended,
    facilities.id AS facility_id,
    programs.id AS programid,
    equipments.id AS equipment_id,
    equipment_operational_status.id AS status_id,
    equipment_types.id AS equipmenttype_id,
    facilities.geographiczoneid,
    facilities.typeid AS ftype_id,
    vw_districts.district_id,
    vw_districts.zone_id,
    vw_districts.region_id,
    vw_districts.parent,
    donors.id AS donorid
   FROM (((((((((facility_program_equipments
   JOIN equipments ON ((facility_program_equipments.equipmentid = equipments.id)))
   JOIN programs ON ((facility_program_equipments.programid = programs.id)))
   JOIN facilities ON ((facilities.id = facility_program_equipments.facilityid)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN equipment_types ON ((equipment_types.id = equipments.equipmenttypeid)))
   LEFT JOIN donors ON ((donors.id = facility_program_equipments.primarydonorid)))
   JOIN vw_districts ON ((vw_districts.district_id = facilities.geographiczoneid)))
   JOIN equipment_operational_status ON ((equipment_operational_status.id = facility_program_equipments.operationalstatusid)))
  ORDER BY geographic_zones.name, facilities.name, facility_program_equipments.model;


ALTER TABLE public.vw_equipment_list_by_donor OWNER TO postgres;

--
-- Name: vw_equipment_operational_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_equipment_operational_status AS
 SELECT geographic_zones.name AS district,
    facilities.name AS facility_name,
    equipments.name AS equipment_name,
    facility_program_equipments.model,
    facility_program_equipments.serialnumber,
    equipment_status_line_items.testcount AS test,
    equipment_status_line_items.totalcount AS total_test,
    equipment_status_line_items.daysoutofuse,
    equipment_operational_status.name AS operational_status,
    facility_types.id AS ft_id,
    programs.id AS pg_id,
    facilities.id AS f_id,
    processing_schedules.id AS ps_id,
    processing_periods.id AS pp_id,
    equipment_types.id AS eqpt_ty_id,
    vw_districts.zone_id,
    vw_districts.parent,
    vw_districts.region_id,
    vw_districts.district_id
   FROM ((((((((((((facility_program_equipments
   JOIN equipments ON ((facility_program_equipments.equipmentid = equipments.id)))
   JOIN equipment_status_line_items ON ((((equipments.code)::text = (equipment_status_line_items.code)::text) AND ((facility_program_equipments.serialnumber)::text = (equipment_status_line_items.equipmentserial)::text))))
   JOIN requisitions ON ((requisitions.id = equipment_status_line_items.rnrid)))
   JOIN programs ON ((facility_program_equipments.programid = programs.id)))
   JOIN facilities ON ((facilities.id = facility_program_equipments.facilityid)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN equipment_operational_status ON ((equipment_operational_status.id = equipment_status_line_items.operationalstatusid)))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN equipment_types ON ((equipment_types.id = equipments.equipmenttypeid)))
   JOIN vw_districts ON ((vw_districts.district_id = facilities.geographiczoneid)))
  ORDER BY geographic_zones.name, facilities.name, facility_program_equipments.model, equipment_status_line_items.operationalstatusid;


ALTER TABLE public.vw_equipment_operational_status OWNER TO postgres;

--
-- Name: vw_expected_facilities; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_expected_facilities AS
 SELECT facilities.id AS facilityid,
    facilities.name AS facilityname,
    ps.programid,
    pp.scheduleid,
    pp.id AS periodid,
    pp.name AS periodname,
    pp.startdate,
    pp.enddate,
    gz.id AS geographiczoneid,
    gz.name AS geographiczonename
   FROM (((((facilities
   JOIN programs_supported ps ON ((ps.facilityid = facilities.id)))
   JOIN geographic_zones gz ON ((gz.id = facilities.geographiczoneid)))
   JOIN requisition_group_members rgm ON ((rgm.facilityid = facilities.id)))
   JOIN requisition_group_program_schedules rgps ON (((rgps.requisitiongroupid = rgm.requisitiongroupid) AND (rgps.programid = ps.programid))))
   JOIN processing_periods pp ON ((pp.scheduleid = rgps.scheduleid)))
  WHERE (gz.levelid = ( SELECT max(geographic_levels.id) AS max
   FROM geographic_levels));


ALTER TABLE public.vw_expected_facilities OWNER TO postgres;

--
-- Name: vw_facility_requisitions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_facility_requisitions AS
 SELECT facilities.id AS facilityid,
    facilities.code AS facilitycode,
    facilities.name AS facilityname,
    requisitions.id AS rnrid,
    requisitions.periodid,
    requisitions.status,
    facilities.geographiczoneid,
    facilities.enabled,
    facilities.sdp,
    facilities.typeid,
    requisitions.programid,
    requisitions.emergency,
    requisitions.createddate,
    geographic_zones.name AS geographiczonename
   FROM ((requisitions
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)));


ALTER TABLE public.vw_facility_requisitions OWNER TO postgres;

--
-- Name: vw_lab_equipment_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_lab_equipment_status AS
 SELECT programs.name AS program,
    facilities.code AS facility_code,
    facilities.name AS facility_name,
    facility_types.name AS facility_type,
    vw_districts.district_name AS disrict,
    vw_districts.zone_name AS zone,
    equipment_types.name AS equipment_type,
    facility_program_equipments.model AS equipment_model,
    facility_program_equipments.serialnumber AS serial_number,
    equipments.name AS equipment_name,
    equipment_operational_status.name AS equipment_status,
    facility_program_equipments.hasservicecontract,
    facilities.latitude,
    facilities.longitude,
    facilities.id AS facility_id,
    programs.id AS programid,
    equipments.id AS equipment_id,
    equipment_operational_status.id AS status_id,
    facilities.geographiczoneid,
    facilities.typeid AS ftype_id,
    vw_districts.district_id,
    vw_districts.zone_id,
    vw_districts.region_id,
    vw_districts.parent,
    equipment_types.id AS equipmenttype_id
   FROM ((((((((facility_program_equipments
   JOIN facilities ON ((facilities.id = facility_program_equipments.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN programs ON ((facility_program_equipments.programid = programs.id)))
   JOIN vw_districts ON ((vw_districts.district_id = facilities.geographiczoneid)))
   JOIN equipments ON ((equipments.id = facility_program_equipments.equipmentid)))
   JOIN equipment_types ON ((equipment_types.id = equipments.equipmenttypeid)))
   JOIN equipment_operational_status ON ((equipment_operational_status.id = facility_program_equipments.operationalstatusid)))
  ORDER BY facilities.name;


ALTER TABLE public.vw_lab_equipment_status OWNER TO postgres;

--
-- Name: vw_number_rnr_created_by_facility; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vw_number_rnr_created_by_facility (
    totalstatus bigint,
    status character varying(20),
    geographiczoneid integer,
    geographiczonename character varying(250)
);


ALTER TABLE public.vw_number_rnr_created_by_facility OWNER TO postgres;

--
-- Name: vw_order_fill_rate; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_order_fill_rate AS
 SELECT dw_orders.status,
    dw_orders.facilityid,
    dw_orders.periodid,
    dw_orders.productfullname AS product,
    products.code AS productcode,
    facilities.name AS facilityname,
    dw_orders.scheduleid,
    dw_orders.facilitytypeid,
    dw_orders.productid,
    dw_orders.productcategoryid,
    dw_orders.programid,
    dw_orders.geographiczoneid AS zoneid,
    dw_orders.geographiczonename AS zonename,
    sum((COALESCE(dw_orders.quantityapprovedprev, 0))::numeric) AS quantityapproved,
    sum((COALESCE(dw_orders.quantityreceived, 0))::numeric) AS quantityreceived,
    sum(
        CASE
            WHEN (COALESCE(dw_orders.quantityapprovedprev, 0) = 0) THEN (0)::numeric
            ELSE
            CASE
                WHEN (dw_orders.quantityapprovedprev > 0) THEN (1)::numeric
                ELSE (0)::numeric
            END
        END) AS totalproductsapproved,
    sum(
        CASE
            WHEN (COALESCE(dw_orders.quantityreceived, 0) = 0) THEN (0)::numeric
            ELSE
            CASE
                WHEN (dw_orders.quantityreceived > 0) THEN (1)::numeric
                ELSE (0)::numeric
            END
        END) AS totalproductsreceived,
    sum(
        CASE
            WHEN ((COALESCE(dw_orders.quantityreceived, 0) > 1) AND (COALESCE(dw_orders.quantityapprovedprev, 0) = 0)) THEN (1)::numeric
            ELSE (0)::numeric
        END) AS totalproductspushed
   FROM ((dw_orders
   JOIN products ON (((products.id = dw_orders.productid) AND ((products.primaryname)::text = (dw_orders.productprimaryname)::text))))
   JOIN facilities ON ((facilities.id = dw_orders.facilityid)))
  WHERE ((dw_orders.status)::text = ANY (ARRAY[('RELEASED'::character varying)::text]))
  GROUP BY dw_orders.scheduleid, dw_orders.facilitytypeid, dw_orders.productid, dw_orders.status, dw_orders.facilityid, dw_orders.periodid, dw_orders.productfullname, products.code, facilities.name, dw_orders.productcategoryid, dw_orders.programid, dw_orders.geographiczoneid, dw_orders.geographiczonename;


ALTER TABLE public.vw_order_fill_rate OWNER TO postgres;

--
-- Name: vw_order_fill_rate_details; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vw_order_fill_rate_details (
    programid integer,
    program character varying(50),
    category character varying(100),
    categoryid integer,
    periodid integer,
    period character varying(50),
    scheduleid integer,
    schedule character varying(50),
    facilitytypeid integer,
    total bigint,
    facilitytype character varying(30),
    req_id integer,
    facilityid integer,
    facility character varying(50),
    productcode character varying(50),
    product character varying(250),
    productid integer,
    zoneid integer,
    region character varying(250),
    receipts integer,
    approved integer
);


ALTER TABLE public.vw_order_fill_rate_details OWNER TO postgres;

--
-- Name: vw_period_factype_line_items; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_period_factype_line_items AS
 SELECT programs.id AS program_id,
    programs.name AS program_name,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.startdate AS processing_periods_start_date,
    processing_periods.startdate AS processing_periods_end_date,
    processing_schedules.id AS processing_schedules_id,
    processing_schedules.name AS processing_schedules_name,
    facility_types.id AS facility_type_id,
    facility_types.name AS facility_type_name,
    facilities.code AS facility_code,
    facilities.name AS facility_name,
    requisition_line_items.productcode,
    requisition_line_items.product,
    requisition_line_items.beginningbalance,
    requisition_line_items.quantityreceived,
    requisition_line_items.quantitydispensed,
    requisition_line_items.stockinhand,
    requisition_line_items.quantityrequested,
    requisition_line_items.calculatedorderquantity,
    requisition_line_items.quantityapproved,
    requisition_line_items.totallossesandadjustments,
    requisition_line_items.newpatientcount,
    requisition_line_items.stockoutdays,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.amc,
    requisition_line_items.maxmonthsofstock,
    requisition_line_items.maxstockquantity,
    requisition_line_items.packstoship,
    requisition_line_items.packsize,
    requisition_line_items.fullsupply,
    facilities.id AS facility_id
   FROM ((((((((program_products
   JOIN programs ON ((program_products.programid = programs.id)))
   JOIN products ON ((program_products.productid = products.id)))
   JOIN requisition_line_items ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN requisitions ON (((requisitions.programid = programs.id) AND (requisition_line_items.rnrid = requisitions.id))))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)));


ALTER TABLE public.vw_period_factype_line_items OWNER TO postgres;

--
-- Name: vw_program_facility_supplier; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_program_facility_supplier AS
 SELECT programs.name AS program_name,
    facilities.name AS facility_name,
    supply_lines.supplyingfacilityid AS supplying_facility_id,
    supervisory_nodes.name AS supervisory_node_name,
    supervisory_nodes.id AS supervisory_node_id,
    programs.id AS program_id,
    facilities.id AS facility_id,
    facilities.code AS facility_code,
    supply_lines.supervisorynodeid AS supply_line_id
   FROM (((supply_lines
   JOIN supervisory_nodes ON ((supply_lines.supervisorynodeid = supervisory_nodes.id)))
   JOIN facilities ON ((supply_lines.supplyingfacilityid = facilities.id)))
   JOIN programs ON ((supply_lines.programid = programs.id)));


ALTER TABLE public.vw_program_facility_supplier OWNER TO postgres;

--
-- Name: vw_regimen_district_distribution; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_regimen_district_distribution AS
 SELECT DISTINCT r.programid,
    ps.id AS scheduleid,
    pp.id AS periodid,
    regimens.categoryid,
    regimens.id AS regimenid,
    regimens.name AS regimen,
    li.patientsontreatment,
    li.patientstoinitiatetreatment,
    li.patientsstoppedtreatment,
    r.facilityid,
    r.status,
    f.name AS facilityname,
    f.typeid AS facilitytypeid,
    gz.name AS district,
    gz.id AS districtid,
    zone.id AS regionid,
    c.id AS zoneid,
    c.parentid
   FROM (((((((((regimen_line_items li
   JOIN requisitions r ON ((li.rnrid = r.id)))
   JOIN facilities f ON ((r.facilityid = f.id)))
   JOIN facility_types ft ON ((f.typeid = ft.id)))
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)))
   JOIN geographic_zones zone ON ((gz.parentid = zone.id)))
   JOIN geographic_zones c ON ((zone.parentid = c.id)))
   JOIN processing_periods pp ON ((r.periodid = pp.id)))
   JOIN processing_schedules ps ON ((pp.scheduleid = ps.id)))
   JOIN regimens ON ((r.programid = regimens.programid)));


ALTER TABLE public.vw_regimen_district_distribution OWNER TO postgres;

--
-- Name: vw_regimen_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_regimen_summary AS
 SELECT r.programid,
    ps.id AS scheduleid,
    pp.id AS periodid,
    li.regimencategory,
    regimens.categoryid,
    regimens.id AS regimenid,
    regimens.name AS regimen,
    li.patientsontreatment,
    li.patientstoinitiatetreatment,
    li.patientsstoppedtreatment,
    r.status,
    geographic_zones.id,
    geographic_zones.name
   FROM ((((((regimen_line_items li
   JOIN requisitions r ON ((r.id = li.rnrid)))
   JOIN processing_periods pp ON ((pp.id = r.periodid)))
   JOIN processing_schedules ps ON ((ps.id = pp.scheduleid)))
   JOIN regimens ON ((regimens.programid = r.programid)))
   JOIN facilities ON ((facilities.id = r.facilityid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)));


ALTER TABLE public.vw_regimen_summary OWNER TO postgres;

--
-- Name: vw_requisition_adjustment; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_requisition_adjustment AS
 SELECT programs.name AS program_name,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.startdate AS processing_periods_start_date,
    processing_periods.enddate AS processing_periods_end_date,
    processing_schedules.id AS processing_schedules_id,
    processing_schedules.name AS processing_schedules_name,
    facility_types.name AS facility_type_name,
    facility_types.id AS facility_type_id,
    facilities.code AS facility_code,
    facilities.id AS facility_id,
    facilities.name AS facility_name,
    (fn_get_supplying_facility_name(requisitions.supervisorynodeid))::character varying(50) AS supplying_facility_name,
    requisition_line_items.id AS requisition_line_item_id,
    requisition_line_items.productcode,
    requisition_line_items.product,
    products.id AS product_id,
    product_categories.name AS product_category_name,
    product_categories.id AS product_category_id,
    requisitions.status AS req_status,
    requisition_line_items.beginningbalance,
    requisition_line_items.quantityreceived,
    requisition_line_items.quantitydispensed,
    requisition_line_items.stockinhand,
    requisition_line_items.quantityrequested,
    requisition_line_items.calculatedorderquantity,
    requisition_line_items.quantityapproved,
    requisition_line_items.totallossesandadjustments,
    requisition_line_items.newpatientcount,
    requisition_line_items.stockoutdays,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.amc,
    requisition_line_items.maxmonthsofstock,
    requisition_line_items.maxstockquantity,
    requisition_line_items.packstoship,
    requisition_line_items.packsize,
    requisition_line_items.fullsupply,
    requisition_line_item_losses_adjustments.type AS adjustment_type,
    requisition_line_item_losses_adjustments.quantity AS adjutment_qty,
    losses_adjustments_types.displayorder AS adjustment_display_order,
    losses_adjustments_types.additive AS adjustment_additive,
    requisition_line_items.id
   FROM ((((((((((((requisition_line_items
   JOIN requisitions ON ((requisition_line_items.rnrid = requisitions.id)))
   JOIN products ON (((requisition_line_items.productcode)::text = (products.code)::text)))
   JOIN programs ON ((requisitions.programid = programs.id)))
   JOIN program_products ON (((products.id = program_products.productid) AND (program_products.programid = programs.id))))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN product_categories ON ((program_products.productcategoryid = product_categories.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN facilities ON ((requisitions.facilityid = facilities.id)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN geographic_zones ON ((facilities.geographiczoneid = geographic_zones.id)))
   JOIN requisition_line_item_losses_adjustments ON ((requisition_line_items.id = requisition_line_item_losses_adjustments.requisitionlineitemid)))
   JOIN losses_adjustments_types ON (((requisition_line_item_losses_adjustments.type)::text = (losses_adjustments_types.name)::text)));


ALTER TABLE public.vw_requisition_adjustment OWNER TO postgres;

--
-- Name: vw_requisition_detail; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_requisition_detail AS
 SELECT programs.id AS program_id,
    programs.name AS program_name,
    products.id AS product_id,
    products.code AS product_code,
    products.primaryname AS product_primaryname,
    products.description AS product_description,
    products.tracer AS indicator_product,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.startdate AS processing_periods_start_date,
    processing_periods.enddate AS processing_periods_end_date,
    processing_periods.scheduleid AS processing_schedules_id,
    facility_types.id AS facility_type_id,
    facility_types.name AS facility_type_name,
    facilities.code AS facility_code,
    facilities.name AS facility_name,
    requisition_line_items.productcode,
    requisition_line_items.product,
    requisition_line_items.beginningbalance,
    requisition_line_items.quantityreceived,
    requisition_line_items.quantitydispensed,
    requisition_line_items.stockinhand,
    requisition_line_items.quantityrequested,
    requisition_line_items.calculatedorderquantity,
    requisition_line_items.quantityapproved,
    requisition_line_items.totallossesandadjustments,
    requisition_line_items.newpatientcount,
    requisition_line_items.stockoutdays,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.amc,
    requisition_line_items.maxmonthsofstock,
    requisition_line_items.maxstockquantity,
    requisition_line_items.packstoship,
    requisition_line_items.packsize,
    requisition_line_items.fullsupply,
    facilities.id AS facility_id,
    requisitions.id AS req_id,
    requisitions.status AS req_status,
    requisition_line_items.id AS req_line_id,
    geographic_zones.id AS zone_id,
    geographic_zones.name AS region,
    facility_types.nominalmaxmonth,
    facility_types.nominaleop,
    dosage_units.code AS du_code,
    product_forms.code AS pf_code,
    products.dispensingunit,
    program_products.productcategoryid AS categoryid,
    products.productgroupid,
    processing_periods.scheduleid,
    requisitions.emergency
   FROM ((((((((((((requisition_line_items
   JOIN requisitions ON ((requisition_line_items.rnrid = requisitions.id)))
   JOIN products ON (((requisition_line_items.productcode)::text = (products.code)::text)))
   JOIN programs ON ((requisitions.programid = programs.id)))
   JOIN program_products ON (((products.id = program_products.productid) AND (program_products.programid = programs.id))))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN product_categories ON ((program_products.productcategoryid = product_categories.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN facilities ON ((requisitions.facilityid = facilities.id)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN geographic_zones ON ((facilities.geographiczoneid = geographic_zones.id)))
   JOIN product_forms ON ((products.formid = product_forms.id)))
   JOIN dosage_units ON ((products.dosageunitid = dosage_units.id)));


ALTER TABLE public.vw_requisition_detail OWNER TO postgres;

--
-- Name: vw_requisition_detail_2; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_requisition_detail_2 AS
 SELECT dosage_units.code AS du_code,
    facilities.code AS facility_code,
    facilities.id AS facility_id,
    facilities.name AS facility_name,
    facilities.sdp AS facility_is_sdp,
    facilities.enabled AS facility_is_enabled,
    facility_types.id AS facility_type_id,
    facility_types.name AS facility_type_name,
    facility_types.nominaleop,
    facility_types.nominalmaxmonth,
    geographic_zones.id AS zone_id,
    geographic_zones.name AS region,
    processing_periods.enddate AS processing_periods_end_date,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.scheduleid AS processing_schedules_id,
    processing_periods.scheduleid,
    processing_periods.startdate AS processing_periods_start_date,
    product_forms.code AS pf_code,
    products.code AS product_code,
    products.description AS product_description,
    products.dispensingunit,
    products.id AS product_id,
    products.primaryname AS product_primaryname,
    products.productgroupid,
    products.tracer AS indicator_product,
    product_categories.name AS categoryname,
    product_categories.id AS categoryid,
    programs.name AS program_name,
    programs.id AS program_id,
    requisition_line_items.amc,
    requisition_line_items.beginningbalance,
    requisition_line_items.calculatedorderquantity,
    requisition_line_items.fullsupply,
    requisition_line_items.id AS req_line_id,
    requisition_line_items.maxmonthsofstock,
    requisition_line_items.maxstockquantity,
    requisition_line_items.newpatientcount,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.packsize,
    requisition_line_items.packstoship,
    requisition_line_items.product,
    requisition_line_items.productcode,
    requisition_line_items.previousstockinhand,
    requisition_line_items.quantityapproved,
    requisition_line_items.quantitydispensed,
    requisition_line_items.quantityreceived,
    requisition_line_items.quantityrequested,
    requisition_line_items.stockinhand,
    requisition_line_items.stockoutdays,
    requisition_line_items.totallossesandadjustments,
    products.tracer,
    requisition_line_items.skipped,
    requisitions.emergency,
    requisitions.id AS req_id,
    requisitions.status AS req_status,
    processing_schedules.name AS schedulename
   FROM ((((((((((((requisition_line_items
   JOIN requisitions ON ((requisitions.id = requisition_line_items.rnrid)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN processing_periods ON ((processing_periods.id = requisitions.periodid)))
   JOIN processing_schedules ON ((processing_schedules.id = processing_periods.scheduleid)))
   JOIN products ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN program_products ON (((requisitions.programid = program_products.programid) AND (products.id = program_products.productid))))
   JOIN product_categories ON ((product_categories.id = program_products.productcategoryid)))
   JOIN programs ON ((programs.id = requisitions.programid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN dosage_units ON ((dosage_units.id = products.dosageunitid)))
   JOIN product_forms ON ((product_forms.id = products.formid)));


ALTER TABLE public.vw_requisition_detail_2 OWNER TO postgres;

--
-- Name: vw_rg_period_factype_line_items; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_rg_period_factype_line_items AS
 SELECT programs.id AS program_id,
    programs.name AS program_name,
    processing_periods.id AS processing_periods_id,
    processing_periods.name AS processing_periods_name,
    processing_periods.startdate AS processing_periods_start_date,
    processing_periods.startdate AS processing_periods_end_date,
    processing_schedules.id AS processing_schedules_id,
    processing_schedules.name AS processing_schedules_name,
    facility_types.id AS facility_type_id,
    facility_types.name AS facility_type_name,
    requisition_groups.id AS requisition_group_id,
    requisition_groups.name AS requisition_group_name,
    requisition_groups.supervisorynodeid AS requisition_group_noteid,
    facilities.code AS facility_code,
    facilities.name AS facility_name,
    requisition_line_items.productcode,
    requisition_line_items.product,
    requisition_line_items.beginningbalance,
    requisition_line_items.quantityreceived,
    requisition_line_items.quantitydispensed,
    requisition_line_items.stockinhand,
    requisition_line_items.quantityrequested,
    requisition_line_items.calculatedorderquantity,
    requisition_line_items.quantityapproved,
    requisition_line_items.totallossesandadjustments,
    requisition_line_items.newpatientcount,
    requisition_line_items.stockoutdays,
    requisition_line_items.normalizedconsumption,
    requisition_line_items.amc,
    requisition_line_items.maxmonthsofstock,
    requisition_line_items.maxstockquantity,
    requisition_line_items.packstoship,
    requisition_line_items.packsize,
    requisition_line_items.fullsupply,
    facilities.id AS facility_id
   FROM ((((((((((program_products
   JOIN programs ON ((program_products.programid = programs.id)))
   JOIN products ON ((program_products.productid = products.id)))
   JOIN requisition_line_items ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN requisitions ON (((requisitions.programid = programs.id) AND (requisition_line_items.rnrid = requisitions.id))))
   JOIN processing_periods ON ((requisitions.periodid = processing_periods.id)))
   JOIN processing_schedules ON ((processing_periods.scheduleid = processing_schedules.id)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facilities.typeid = facility_types.id)))
   JOIN requisition_group_members ON ((facilities.id = requisition_group_members.facilityid)))
   JOIN requisition_groups ON ((requisition_groups.id = requisition_group_members.requisitiongroupid)));


ALTER TABLE public.vw_rg_period_factype_line_items OWNER TO postgres;

--
-- Name: vw_rnr_feedback; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_rnr_feedback AS
 SELECT vw_requisition_detail.program_id,
    vw_requisition_detail.program_name,
    vw_requisition_detail.product_id,
    vw_requisition_detail.product_code,
    vw_requisition_detail.product_primaryname,
    shipment_line_items.substitutedproductcode,
    shipment_line_items.substitutedproductname,
    vw_requisition_detail.product_description,
    vw_requisition_detail.indicator_product,
    vw_requisition_detail.processing_periods_id,
    vw_requisition_detail.processing_periods_name,
    vw_requisition_detail.processing_periods_start_date,
    vw_requisition_detail.processing_periods_end_date,
    vw_requisition_detail.processing_schedules_id,
    vw_requisition_detail.facility_type_id,
    vw_requisition_detail.facility_type_name,
    vw_requisition_detail.facility_code,
    vw_requisition_detail.facility_name,
    vw_requisition_detail.productcode,
    vw_requisition_detail.product,
    vw_requisition_detail.facility_id,
    vw_requisition_detail.req_id,
    vw_requisition_detail.req_status,
    vw_requisition_detail.req_line_id,
    vw_requisition_detail.zone_id,
    vw_requisition_detail.region,
    vw_requisition_detail.du_code,
    vw_requisition_detail.pf_code,
    COALESCE(vw_requisition_detail.beginningbalance, 0) AS beginningbalance,
    COALESCE(vw_requisition_detail.quantityreceived, 0) AS quantityreceived,
    COALESCE(vw_requisition_detail.quantitydispensed, 0) AS quantitydispensed,
    COALESCE(vw_requisition_detail.stockinhand, 0) AS stockinhand,
    COALESCE(vw_requisition_detail.quantityapproved, 0) AS quantityapproved,
    COALESCE(vw_requisition_detail.totallossesandadjustments, 0) AS totallossesandadjustments,
    COALESCE(vw_requisition_detail.newpatientcount, 0) AS newpatientcount,
    COALESCE(vw_requisition_detail.stockoutdays, 0) AS stockoutdays,
    COALESCE(vw_requisition_detail.normalizedconsumption, 0) AS normalizedconsumption,
    COALESCE(vw_requisition_detail.amc, 0) AS amc,
    COALESCE(vw_requisition_detail.maxmonthsofstock, 0) AS maxmonthsofstock,
    COALESCE(vw_requisition_detail.maxstockquantity, 0) AS maxstockquantity,
    COALESCE(vw_requisition_detail.packstoship, 0) AS packstoship,
    vw_requisition_detail.packsize,
    vw_requisition_detail.fullsupply,
    vw_requisition_detail.nominalmaxmonth,
    vw_requisition_detail.nominaleop,
    vw_requisition_detail.dispensingunit,
    COALESCE(vw_requisition_detail.calculatedorderquantity, 0) AS calculatedorderquantity,
    COALESCE(vw_requisition_detail.quantityrequested, 0) AS quantityrequested,
    COALESCE(shipment_line_items.quantityshipped, 0) AS quantityshipped,
    COALESCE(shipment_line_items.substitutedproductquantityshipped, 0) AS substitutedproductquantityshipped,
    (COALESCE(shipment_line_items.quantityshipped, 0) + COALESCE(shipment_line_items.substitutedproductquantityshipped, 0)) AS quantity_shipped_total,
        CASE
            WHEN (fn_previous_cb(vw_requisition_detail.req_id, vw_requisition_detail.product_code) <> COALESCE(vw_requisition_detail.beginningbalance, 0)) THEN 1
            ELSE 0
        END AS err_open_balance,
        CASE
            WHEN (COALESCE(vw_requisition_detail.calculatedorderquantity, 0) <> COALESCE(vw_requisition_detail.quantityrequested, 0)) THEN 1
            ELSE 0
        END AS err_qty_required,
        CASE
            WHEN (COALESCE(vw_requisition_detail.quantityreceived, 0) <> (COALESCE(shipment_line_items.quantityshipped, 0) + COALESCE(shipment_line_items.substitutedproductquantityshipped, 0))) THEN 1
            ELSE 0
        END AS err_qty_received,
        CASE
            WHEN (COALESCE(vw_requisition_detail.stockinhand, 0) <> (((COALESCE(vw_requisition_detail.beginningbalance, 0) + COALESCE(vw_requisition_detail.quantityreceived, 0)) - COALESCE(vw_requisition_detail.quantitydispensed, 0)) + COALESCE(vw_requisition_detail.totallossesandadjustments, 0))) THEN 1
            ELSE 0
        END AS err_qty_stockinhand
   FROM ((vw_requisition_detail
   LEFT JOIN orders ON ((orders.id = vw_requisition_detail.req_id)))
   LEFT JOIN shipment_line_items ON (((orders.id = shipment_line_items.orderid) AND ((vw_requisition_detail.product_code)::text = (shipment_line_items.productcode)::text))));


ALTER TABLE public.vw_rnr_feedback OWNER TO postgres;

--
-- Name: vw_rnr_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_rnr_status AS
 SELECT p.name AS programname,
    r.programid,
    r.periodid,
    f.id AS facilityid,
    r.id AS rnrid,
    r.status,
    gz.name AS geographiczonename
   FROM ((((facilities f
   JOIN requisitions r ON ((r.facilityid = f.id)))
   JOIN programs p ON ((p.id = r.programid)))
   JOIN requisition_status_changes ON ((r.id = requisition_status_changes.rnrid)))
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)));


ALTER TABLE public.vw_rnr_status OWNER TO postgres;

--
-- Name: vw_rnr_status_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_rnr_status_details AS
 SELECT p.name AS programname,
    r.programid,
    r.periodid,
    ps.name AS periodname,
    r.createddate,
    f.code AS facilitycode,
    f.name AS facilityname,
    f.id AS facilityid,
    r.id AS rnrid,
    r.status,
    ft.name AS facilitytypename,
    gz.id AS geographiczoneid,
    gz.name AS geographiczonename
   FROM ((((((facilities f
   JOIN requisitions r ON ((r.facilityid = f.id)))
   JOIN programs p ON ((p.id = r.programid)))
   JOIN processing_periods ps ON ((ps.id = r.periodid)))
   JOIN requisition_status_changes ON ((r.id = requisition_status_changes.rnrid)))
   JOIN facility_types ft ON ((ft.id = f.typeid)))
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)));


ALTER TABLE public.vw_rnr_status_details OWNER TO postgres;

--
-- Name: vw_stock_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_stock_status AS
 SELECT fn_get_supplying_facility_name(requisitions.supervisorynodeid) AS supplyingfacility,
    facilities.code AS facilitycode,
    products.code AS productcode,
    facilities.name AS facility,
    requisitions.status AS req_status,
    requisition_line_items.product,
    requisition_line_items.stockinhand,
    ((((requisition_line_items.stockinhand + requisition_line_items.beginningbalance) + requisition_line_items.quantitydispensed) + requisition_line_items.quantityreceived) + abs(requisition_line_items.totallossesandadjustments)) AS reported_figures,
    requisitions.id AS rnrid,
    requisition_line_items.amc,
        CASE
            WHEN (COALESCE(requisition_line_items.amc, 0) = 0) THEN (0)::numeric
            ELSE ((requisition_line_items.stockinhand)::numeric / (requisition_line_items.amc)::numeric)
        END AS mos,
    COALESCE(
        CASE
            WHEN (((COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth) - requisition_line_items.stockinhand) < 0) THEN 0
            ELSE ((COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth) - requisition_line_items.stockinhand)
        END, 0) AS required,
        CASE
            WHEN (requisition_line_items.stockinhand = 0) THEN 'SO'::text
            ELSE
            CASE
                WHEN ((requisition_line_items.stockinhand > 0) AND ((requisition_line_items.stockinhand)::numeric <= ((COALESCE(requisition_line_items.amc, 0))::numeric * facility_types.nominaleop))) THEN 'US'::text
                ELSE
                CASE
                    WHEN (requisition_line_items.stockinhand > (COALESCE(requisition_line_items.amc, 0) * facility_types.nominalmaxmonth)) THEN 'OS'::text
                    ELSE 'SP'::text
                END
            END
        END AS status,
    facility_types.name AS facilitytypename,
    geographic_zones.id AS gz_id,
    geographic_zones.name AS location,
    products.id AS productid,
    processing_periods.startdate,
    programs.id AS programid,
    processing_schedules.id AS psid,
    processing_periods.enddate,
    processing_periods.id AS periodid,
    facility_types.id AS facilitytypeid,
    program_products.productcategoryid AS categoryid,
    products.tracer AS indicator_product,
    facilities.id AS facility_id,
    processing_periods.name AS processing_period_name,
    requisition_line_items.stockoutdays,
    requisitions.supervisorynodeid
   FROM ((((((((((requisition_line_items
   JOIN requisitions ON ((requisitions.id = requisition_line_items.rnrid)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN processing_periods ON ((processing_periods.id = requisitions.periodid)))
   JOIN processing_schedules ON ((processing_schedules.id = processing_periods.scheduleid)))
   JOIN products ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN program_products ON (((requisitions.programid = program_products.programid) AND (products.id = program_products.productid))))
   JOIN product_categories ON ((product_categories.id = program_products.productcategoryid)))
   JOIN programs ON ((programs.id = requisitions.programid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
  WHERE ((requisition_line_items.stockinhand IS NOT NULL) AND (requisition_line_items.skipped = false));


ALTER TABLE public.vw_stock_status OWNER TO postgres;

--
-- Name: vw_supply_status; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_supply_status AS
 SELECT requisition_line_items.id AS li_id,
    requisition_line_items.rnrid AS li_rnrid,
    requisition_line_items.productcode AS li_productcode,
    requisition_line_items.product AS li_product,
    requisition_line_items.productdisplayorder AS li_productdisplayorder,
    requisition_line_items.productcategory AS li_productcategory,
    requisition_line_items.productcategorydisplayorder AS li_productcategorydisplayorder,
    requisition_line_items.dispensingunit AS li_dispensingunit,
    requisition_line_items.beginningbalance AS li_beginningbalance,
    requisition_line_items.quantityreceived AS li_quantityreceived,
    requisition_line_items.quantitydispensed AS li_quantitydispensed,
    requisition_line_items.stockinhand AS li_stockinhand,
    requisition_line_items.quantityrequested AS li_quantityrequested,
    requisition_line_items.reasonforrequestedquantity AS li_reasonforrequestedquantity,
    requisition_line_items.calculatedorderquantity AS li_calculatedorderquantity,
    requisition_line_items.quantityapproved AS li_quantityapproved,
    requisition_line_items.totallossesandadjustments AS li_totallossesandadjustments,
    requisition_line_items.newpatientcount AS li_newpatientcount,
    requisition_line_items.stockoutdays AS li_stockoutdays,
    requisition_line_items.normalizedconsumption AS li_normalizedconsumption,
    requisition_line_items.amc AS li_amc,
    requisition_line_items.maxmonthsofstock AS li_maxmonthsofstock,
    requisition_line_items.maxstockquantity AS li_maxstockquantity,
    requisition_line_items.packstoship AS li_packstoship,
    requisition_line_items.price AS li_price,
    requisition_line_items.expirationdate AS li_expirationdate,
    requisition_line_items.remarks AS li_remarks,
    requisition_line_items.dosespermonth AS li_dosespermonth,
    requisition_line_items.dosesperdispensingunit AS li_dosesperdispensingunit,
    requisition_line_items.packsize AS li_packsize,
    requisition_line_items.roundtozero AS li_roundtozero,
    requisition_line_items.packroundingthreshold AS li_packroundingthreshold,
    requisition_line_items.fullsupply AS li_fullsupply,
    requisition_line_items.createdby AS li_createdby,
    requisition_line_items.createddate AS li_createddate,
    requisition_line_items.modifiedby AS li_modifiedby,
    requisition_line_items.modifieddate AS li_modifieddate,
    programs.id AS pg_id,
    programs.code AS pg_code,
    programs.name AS pg_name,
    products.id AS p_id,
    products.code AS p_code,
    products.primaryname AS p_primaryname,
    program_products.displayorder AS p_displayorder,
    products.tracer AS indicator_product,
    products.description AS p_description,
    facility_types.name AS facility_type_name,
    facility_types.id AS ft_id,
    facility_types.code AS ft_code,
    facility_types.nominalmaxmonth AS ft_nominalmaxmonth,
    facility_types.nominaleop AS ft_nominaleop,
    facilities.id AS f_id,
    facilities.code AS f_code,
    facilities.name AS facility,
    fn_get_supplying_facility_name(requisitions.supervisorynodeid) AS supplyingfacility,
    facilities.geographiczoneid AS f_zoneid,
    facility_approved_products.maxmonthsofstock AS fp_maxmonthsofstock,
    facility_approved_products.minmonthsofstock AS fp_minmonthsofstock,
    facility_approved_products.eop AS fp_eop,
    requisitions.status AS r_status,
    requisitions.supervisorynodeid,
    processing_schedules.id AS ps_id,
    processing_periods.id AS pp_id,
    geographic_zones.id AS geographiczoneid,
    geographic_zones.name AS geographiczonename
   FROM (((((((((((requisition_line_items
   JOIN requisitions ON ((requisitions.id = requisition_line_items.rnrid)))
   JOIN facilities ON ((facilities.id = requisitions.facilityid)))
   JOIN facility_types ON ((facility_types.id = facilities.typeid)))
   JOIN processing_periods ON ((processing_periods.id = requisitions.periodid)))
   JOIN processing_schedules ON ((processing_schedules.id = processing_periods.scheduleid)))
   JOIN products ON (((products.code)::text = (requisition_line_items.productcode)::text)))
   JOIN program_products ON (((requisitions.programid = program_products.programid) AND (products.id = program_products.productid))))
   JOIN product_categories ON ((product_categories.id = program_products.productcategoryid)))
   JOIN programs ON ((programs.id = requisitions.programid)))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)))
   JOIN facility_approved_products ON (((facility_types.id = facility_approved_products.facilitytypeid) AND (facility_approved_products.programproductid = program_products.id))));


ALTER TABLE public.vw_supply_status OWNER TO postgres;

--
-- Name: vw_user_facilities; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_facilities AS
 SELECT DISTINCT f.id AS facility_id,
    f.geographiczoneid AS district_id,
    rg.id AS requisition_group_id,
    ra.userid AS user_id,
    ra.programid AS program_id
   FROM ((((facilities f
   JOIN requisition_group_members m ON ((m.facilityid = f.id)))
   JOIN requisition_groups rg ON ((rg.id = m.requisitiongroupid)))
   JOIN supervisory_nodes sn ON ((sn.id = rg.supervisorynodeid)))
   JOIN role_assignments ra ON (((ra.supervisorynodeid = sn.id) OR (ra.supervisorynodeid = sn.parentid))));


ALTER TABLE public.vw_user_facilities OWNER TO postgres;

--
-- Name: vw_user_districts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_districts AS
 SELECT DISTINCT vw_user_facilities.user_id,
    vw_user_facilities.district_id,
    vw_user_facilities.program_id
   FROM vw_user_facilities;


ALTER TABLE public.vw_user_districts OWNER TO postgres;

--
-- Name: vw_user_geo_facilities; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_geo_facilities AS
 SELECT role_assignments.userid,
    role_assignments.supervisorynodeid,
    geographic_zones.id AS geographiczoneid,
    facilities.id AS facilityid,
    facilities.name AS facilityname,
    facilities.enabled AS facility_is_enabled,
    facilities.sdp AS facility_is_sdp,
    facilities.mainphone,
    facilities.fax,
    facilities.active,
    facilities.typeid,
    geographic_zones.levelid,
    geographic_zones.name AS geographiczonename
   FROM (((((facilities
   JOIN requisition_group_members ON ((facilities.id = requisition_group_members.facilityid)))
   JOIN requisition_groups ON ((requisition_groups.id = requisition_group_members.requisitiongroupid)))
   JOIN supervisory_nodes ON ((supervisory_nodes.id = requisition_groups.supervisorynodeid)))
   JOIN role_assignments ON (((supervisory_nodes.id = role_assignments.supervisorynodeid) OR (role_assignments.supervisorynodeid = supervisory_nodes.parentid))))
   JOIN geographic_zones ON ((geographic_zones.id = facilities.geographiczoneid)));


ALTER TABLE public.vw_user_geo_facilities OWNER TO postgres;

--
-- Name: vw_user_geographic_zones; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_geographic_zones AS
 SELECT DISTINCT ra.userid,
    ra.supervisorynodeid,
    gz.id AS geographiczoneid,
    gz.levelid,
    ra.programid
   FROM ((((((facilities f
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)))
   JOIN requisition_group_members m ON ((m.facilityid = f.id)))
   JOIN requisition_groups rg ON ((rg.id = m.requisitiongroupid)))
   JOIN supervisory_nodes sn ON ((sn.id = rg.supervisorynodeid)))
   JOIN role_assignments ra ON (((ra.supervisorynodeid = sn.id) OR (ra.supervisorynodeid = sn.parentid))))
   JOIN geographic_zones d ON ((d.id = f.geographiczoneid)))
  WHERE ((ra.supervisorynodeid IS NOT NULL) AND (rg.supervisorynodeid IS NOT NULL));


ALTER TABLE public.vw_user_geographic_zones OWNER TO postgres;

--
-- Name: vw_user_program_facilities; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_program_facilities AS
 SELECT DISTINCT users.id AS user_id,
    role_assignments.roleid AS role_id,
    requisition_groups.code AS rg_code,
    requisition_groups.name AS rg_name,
    requisition_groups.id AS rg_id,
    users.username,
    role_assignments.supervisorynodeid,
    programs.id AS program_id,
    programs.code AS program_code,
    facilities.id AS facility_id,
    facilities.code AS facility_code
   FROM ((((((programs
   JOIN role_assignments ON ((programs.id = role_assignments.programid)))
   JOIN users ON ((role_assignments.userid = users.id)))
   JOIN requisition_group_program_schedules ON ((programs.id = requisition_group_program_schedules.programid)))
   JOIN requisition_groups ON ((requisition_groups.id = requisition_group_program_schedules.requisitiongroupid)))
   JOIN requisition_group_members ON ((requisition_groups.id = requisition_group_members.requisitiongroupid)))
   JOIN facilities ON ((facilities.id = requisition_group_members.facilityid)));


ALTER TABLE public.vw_user_program_facilities OWNER TO postgres;

--
-- Name: VIEW vw_user_program_facilities; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW vw_user_program_facilities IS 'This view combines information from users, user_assignments, programs, facilities. This is used in user related stored functions. If using directly, please use DISTINCT ON to get distrinct list';


--
-- Name: vw_user_role_assignments; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_role_assignments AS
 SELECT users.firstname,
    users.lastname,
    users.email,
    users.cellphone,
    users.officephone,
    supervisory_nodes.name AS supervisorynodename,
    programs.name AS programname,
    roles.name AS rolename,
    programs.id AS programid,
    supervisory_nodes.id AS supervisorynodeid,
    roles.id AS roleid
   FROM ((((roles
   JOIN role_assignments ON ((roles.id = role_assignments.roleid)))
   JOIN programs ON ((programs.id = role_assignments.programid)))
   JOIN supervisory_nodes ON ((supervisory_nodes.id = role_assignments.supervisorynodeid)))
   JOIN users ON ((users.id = role_assignments.userid)));


ALTER TABLE public.vw_user_role_assignments OWNER TO postgres;

--
-- Name: vw_user_role_program_rg; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_role_program_rg AS
 SELECT DISTINCT users.id AS user_id,
    requisition_groups.code AS rg_code,
    requisition_groups.name AS rg_name,
    requisition_groups.id AS rg_id,
    users.username,
    role_assignments.supervisorynodeid,
    roles.id AS role_id,
    programs.id AS program_id,
    programs.code AS program_code
   FROM (((((requisition_group_program_schedules
   JOIN programs ON ((requisition_group_program_schedules.scheduleid = programs.id)))
   JOIN requisition_groups ON ((requisition_group_program_schedules.programid = requisition_groups.id)))
   JOIN role_assignments ON ((programs.id = role_assignments.programid)))
   JOIN roles ON ((role_assignments.roleid = roles.id)))
   JOIN users ON ((role_assignments.userid = users.id)));


ALTER TABLE public.vw_user_role_program_rg OWNER TO postgres;

--
-- Name: VIEW vw_user_role_program_rg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON VIEW vw_user_role_program_rg IS 'This view combines information from user, role, role_assignment, program, requisition_group. This view is used in user related stored function. If using directly, make sure you use DISTINCT ON';


--
-- Name: vw_user_supervisorynodes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW vw_user_supervisorynodes AS
 WITH RECURSIVE supervisorynodesrec AS (
                 SELECT DISTINCT ra.userid,
                    ra.programid,
                    s.id,
                    s.parentid,
                    s.facilityid,
                    s.name,
                    s.code,
                    s.description,
                    s.createdby,
                    s.createddate,
                    s.modifiedby,
                    s.modifieddate
                   FROM (supervisory_nodes s
              JOIN role_assignments ra ON ((s.id = ra.supervisorynodeid)))
        UNION
                 SELECT supervisorynodesrec_1.userid,
                    supervisorynodesrec_1.programid,
                    sn.id,
                    sn.parentid,
                    sn.facilityid,
                    sn.name,
                    sn.code,
                    sn.description,
                    sn.createdby,
                    sn.createddate,
                    sn.modifiedby,
                    sn.modifieddate
                   FROM (supervisory_nodes sn
              JOIN supervisorynodesrec supervisorynodesrec_1 ON ((sn.parentid = supervisorynodesrec_1.id)))
        )
 SELECT supervisorynodesrec.userid,
    supervisorynodesrec.programid,
    supervisorynodesrec.id,
    supervisorynodesrec.parentid,
    supervisorynodesrec.facilityid,
    supervisorynodesrec.name,
    supervisorynodesrec.code,
    supervisorynodesrec.description,
    supervisorynodesrec.createdby,
    supervisorynodesrec.createddate,
    supervisorynodesrec.modifiedby,
    supervisorynodesrec.modifieddate
   FROM supervisorynodesrec;


ALTER TABLE public.vw_user_supervisorynodes OWNER TO postgres;

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

ALTER TABLE ONLY alert_facility_stockedout ALTER COLUMN id SET DEFAULT nextval('alert_facility_stockedout_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_requisition_approved ALTER COLUMN id SET DEFAULT nextval('alert_requisition_approved_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_requisition_emergency ALTER COLUMN id SET DEFAULT nextval('alert_requisition_emergency_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_requisition_pending ALTER COLUMN id SET DEFAULT nextval('alert_requisition_pending_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_requisition_rejected ALTER COLUMN id SET DEFAULT nextval('alert_requisition_rejected_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_stockedout ALTER COLUMN id SET DEFAULT nextval('alert_stockedout_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY alert_summary ALTER COLUMN id SET DEFAULT nextval('alert_summary_id_seq'::regclass);


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

ALTER TABLE ONLY budgets ALTER COLUMN id SET DEFAULT nextval('budgets_id_seq'::regclass);


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

ALTER TABLE ONLY configuration_settings ALTER COLUMN id SET DEFAULT nextval('configuration_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


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

ALTER TABLE ONLY custom_reports ALTER COLUMN id SET DEFAULT nextval('custom_reports_id_seq'::regclass);


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

ALTER TABLE ONLY distribution_types ALTER COLUMN id SET DEFAULT nextval('distribution_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY donors ALTER COLUMN id SET DEFAULT nextval('donors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dosage_units ALTER COLUMN id SET DEFAULT nextval('dosage_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help ALTER COLUMN id SET DEFAULT nextval('elmis_help_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_document ALTER COLUMN id SET DEFAULT nextval('elmis_help_document_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic ALTER COLUMN id SET DEFAULT nextval('elmis_help_topic_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic_roles ALTER COLUMN id SET DEFAULT nextval('elmis_help_topic_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY email_notifications ALTER COLUMN id SET DEFAULT nextval('email_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY emergency_requisitions ALTER COLUMN id SET DEFAULT nextval('emergency_requisitions_id_seq'::regclass);


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

ALTER TABLE ONLY equipment_contract_service_types ALTER COLUMN id SET DEFAULT nextval('equipment_contract_service_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs ALTER COLUMN id SET DEFAULT nextval('equipment_maintenance_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_requests ALTER COLUMN id SET DEFAULT nextval('equipment_maintenance_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_operational_status ALTER COLUMN id SET DEFAULT nextval('equipment_operational_status_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_equipments ALTER COLUMN id SET DEFAULT nextval('equipment_service_contract_equipments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_facilities ALTER COLUMN id SET DEFAULT nextval('equipment_service_contract_facilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contracts ALTER COLUMN id SET DEFAULT nextval('equipment_service_contracts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_types ALTER COLUMN id SET DEFAULT nextval('equipment_service_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_vendor_users ALTER COLUMN id SET DEFAULT nextval('equipment_service_vendor_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_vendors ALTER COLUMN id SET DEFAULT nextval('equipment_service_vendors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_status_line_items ALTER COLUMN id SET DEFAULT nextval('equipment_status_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_types ALTER COLUMN id SET DEFAULT nextval('equipment_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipments ALTER COLUMN id SET DEFAULT nextval('equipments_id_seq'::regclass);


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

ALTER TABLE ONLY facility_program_equipments ALTER COLUMN id SET DEFAULT nextval('facility_program_equipments_id_seq'::regclass);


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

ALTER TABLE ONLY geographic_zone_geojson ALTER COLUMN id SET DEFAULT nextval('geographic_zone_geojson_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY geographic_zones ALTER COLUMN id SET DEFAULT nextval('geographic_zones_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_batches ALTER COLUMN id SET DEFAULT nextval('inventory_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions ALTER COLUMN id SET DEFAULT nextval('inventory_transactions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


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

ALTER TABLE ONLY odk_account ALTER COLUMN id SET DEFAULT nextval('odk_account_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_submission_data ALTER COLUMN id SET DEFAULT nextval('odk_proof_of_delivery_submission_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform ALTER COLUMN id SET DEFAULT nextval('odk_proof_of_delivery_xform_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_stock_status_submission ALTER COLUMN id SET DEFAULT nextval('odk_stock_status_submission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_submission ALTER COLUMN id SET DEFAULT nextval('odk_submission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_submission_data ALTER COLUMN id SET DEFAULT nextval('odk_submission_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_xform ALTER COLUMN id SET DEFAULT nextval('odk_xform_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_xform_survey_type ALTER COLUMN id SET DEFAULT nextval('odk_xform_survey_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand ALTER COLUMN id SET DEFAULT nextval('on_hand_id_seq'::regclass);


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

ALTER TABLE ONLY product_mapping ALTER COLUMN id SET DEFAULT nextval('product_mapping_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipment_products ALTER COLUMN id SET DEFAULT nextval('program_equipment_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipments ALTER COLUMN id SET DEFAULT nextval('program_equipments_id_seq'::regclass);


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

ALTER TABLE ONLY received_status ALTER COLUMN id SET DEFAULT nextval('received_status_id_seq'::regclass);


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

ALTER TABLE ONLY sms ALTER COLUMN id SET DEFAULT nextval('sms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY storage_types ALTER COLUMN id SET DEFAULT nextval('storage_types_id_seq'::regclass);


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

ALTER TABLE ONLY temperature ALTER COLUMN id SET DEFAULT nextval('temperature_id_seq'::regclass);


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

ALTER TABLE ONLY transaction_types ALTER COLUMN id SET DEFAULT nextval('transaction_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_preference_master ALTER COLUMN id SET DEFAULT nextval('user_preference_master_id_seq'::regclass);


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


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccination_types ALTER COLUMN id SET DEFAULT nextval('vaccination_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_administration_mode ALTER COLUMN id SET DEFAULT nextval('vaccine_administration_mode_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_dilution ALTER COLUMN id SET DEFAULT nextval('vaccine_dilution_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_diseases ALTER COLUMN id SET DEFAULT nextval('vaccine_diseases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches ALTER COLUMN id SET DEFAULT nextval('vaccine_distribution_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_demographics ALTER COLUMN id SET DEFAULT nextval('vaccine_distribution_demographics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_distribution_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_parameters ALTER COLUMN id SET DEFAULT nextval('vaccine_distribution_parameters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_doses ALTER COLUMN id SET DEFAULT nextval('vaccine_doses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_logistics_master_columns ALTER COLUMN id SET DEFAULT nextval('vaccine_logistics_master_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_product_doses ALTER COLUMN id SET DEFAULT nextval('vaccine_product_doses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_program_logistics_columns ALTER COLUMN id SET DEFAULT nextval('vaccine_program_logistics_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_quantifications ALTER COLUMN id SET DEFAULT nextval('vaccine_quantifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_adverse_effect_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_adverse_effect_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_campaign_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_campaign_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_cold_chain_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_cold_chain_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_coverage_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_coverage_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_disease_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_disease_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_logistics_line_items ALTER COLUMN id SET DEFAULT nextval('vaccine_report_logistics_line_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_reports ALTER COLUMN id SET DEFAULT nextval('vaccine_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_storage ALTER COLUMN id SET DEFAULT nextval('vaccine_storage_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_targets ALTER COLUMN id SET DEFAULT nextval('vaccine_targets_id_seq'::regclass);


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
-- Name: alert_facility_stockedout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_facility_stockedout
    ADD CONSTRAINT alert_facility_stockedout_pkey PRIMARY KEY (id);


--
-- Name: alert_requisition_approved_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_requisition_approved
    ADD CONSTRAINT alert_requisition_approved_pkey PRIMARY KEY (id);


--
-- Name: alert_requisition_emergency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_requisition_emergency
    ADD CONSTRAINT alert_requisition_emergency_pkey PRIMARY KEY (id);


--
-- Name: alert_requisition_pending_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_requisition_pending
    ADD CONSTRAINT alert_requisition_pending_pk PRIMARY KEY (id);


--
-- Name: alert_requisition_rejected_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_requisition_rejected
    ADD CONSTRAINT alert_requisition_rejected_pk PRIMARY KEY (id);


--
-- Name: alert_stockedout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_stockedout
    ADD CONSTRAINT alert_stockedout_pkey PRIMARY KEY (id);


--
-- Name: alert_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alert_summary
    ADD CONSTRAINT alert_summary_pkey PRIMARY KEY (id);


--
-- Name: alerts_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pk PRIMARY KEY (alerttype);


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
-- Name: budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


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
-- Name: configuration_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY configuration_settings
    ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


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
-- Name: custom_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_reports
    ADD CONSTRAINT custom_reports_pkey PRIMARY KEY (id);


--
-- Name: custom_reports_reportkey_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY custom_reports
    ADD CONSTRAINT custom_reports_reportkey_key UNIQUE (reportkey);


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
-- Name: distribution_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY distribution_types
    ADD CONSTRAINT distribution_types_name_key UNIQUE (name);


--
-- Name: distribution_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY distribution_types
    ADD CONSTRAINT distribution_types_pkey PRIMARY KEY (id);


--
-- Name: distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT distributions_pkey PRIMARY KEY (id);


--
-- Name: donors_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY donors
    ADD CONSTRAINT donors_code_key UNIQUE (code);


--
-- Name: donors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY donors
    ADD CONSTRAINT donors_pkey PRIMARY KEY (id);


--
-- Name: dosage_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dosage_units
    ADD CONSTRAINT dosage_units_pkey PRIMARY KEY (id);


--
-- Name: elmis_help_document_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY elmis_help_document
    ADD CONSTRAINT elmis_help_document_pkey PRIMARY KEY (id);


--
-- Name: elmis_help_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY elmis_help
    ADD CONSTRAINT elmis_help_pkey PRIMARY KEY (id);


--
-- Name: elmis_help_topic_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY elmis_help_topic
    ADD CONSTRAINT elmis_help_topic_pkey PRIMARY KEY (id);


--
-- Name: elmis_help_topic_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY elmis_help_topic_roles
    ADD CONSTRAINT elmis_help_topic_roles_pkey PRIMARY KEY (id);


--
-- Name: email_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY email_notifications
    ADD CONSTRAINT email_notifications_pkey PRIMARY KEY (id);


--
-- Name: emergency_requisitions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY emergency_requisitions
    ADD CONSTRAINT emergency_requisitions_pkey PRIMARY KEY (id);


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
-- Name: equipment_contract_service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_contract_service_types
    ADD CONSTRAINT equipment_contract_service_types_pkey PRIMARY KEY (id);


--
-- Name: equipment_maintenance_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_pkey PRIMARY KEY (id);


--
-- Name: equipment_maintenance_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_maintenance_requests
    ADD CONSTRAINT equipment_maintenance_requests_pkey PRIMARY KEY (id);


--
-- Name: equipment_operational_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_operational_status
    ADD CONSTRAINT equipment_operational_status_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_contract_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_contract_equipments
    ADD CONSTRAINT equipment_service_contract_equipments_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_contract_facilities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_contract_facilities
    ADD CONSTRAINT equipment_service_contract_facilities_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_contracts
    ADD CONSTRAINT equipment_service_contracts_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_types
    ADD CONSTRAINT equipment_service_types_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_vendor_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_vendor_users
    ADD CONSTRAINT equipment_service_vendor_users_pkey PRIMARY KEY (id);


--
-- Name: equipment_service_vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_service_vendors
    ADD CONSTRAINT equipment_service_vendors_pkey PRIMARY KEY (id);


--
-- Name: equipment_status_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_status_line_items
    ADD CONSTRAINT equipment_status_line_items_pkey PRIMARY KEY (id);


--
-- Name: equipment_types_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_types
    ADD CONSTRAINT equipment_types_code_key UNIQUE (code);


--
-- Name: equipment_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipment_types
    ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);


--
-- Name: equipments_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipments
    ADD CONSTRAINT equipments_code_key UNIQUE (code);


--
-- Name: equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (id);


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
-- Name: facility_program_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_pkey PRIMARY KEY (id);


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
-- Name: geographic_zone_geojson_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY geographic_zone_geojson
    ADD CONSTRAINT geographic_zone_geojson_pkey PRIMARY KEY (id);


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
-- Name: inventory_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_batches
    ADD CONSTRAINT inventory_batches_pkey PRIMARY KEY (id);


--
-- Name: inventory_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);


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
-- Name: manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


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
-- Name: migration_schema_version_primary_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY migration_schema_version
    ADD CONSTRAINT migration_schema_version_primary_key PRIMARY KEY (version);


--
-- Name: migration_schema_version_script_unique; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY migration_schema_version
    ADD CONSTRAINT migration_schema_version_script_unique UNIQUE (script);


--
-- Name: odk_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_account
    ADD CONSTRAINT odk_account_pkey PRIMARY KEY (id);


--
-- Name: odk_proof_of_delivery_submission_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_proof_of_delivery_submission_data
    ADD CONSTRAINT odk_proof_of_delivery_submission_data_pkey PRIMARY KEY (id);


--
-- Name: odk_proof_of_delivery_xform_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_xform_pkey PRIMARY KEY (id);


--
-- Name: odk_stock_status_submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_stock_status_submission
    ADD CONSTRAINT odk_stock_status_submission_pkey PRIMARY KEY (id);


--
-- Name: odk_submission_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_submission_data
    ADD CONSTRAINT odk_submission_data_pkey PRIMARY KEY (id);


--
-- Name: odk_submission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_submission
    ADD CONSTRAINT odk_submission_pkey PRIMARY KEY (id);


--
-- Name: odk_xform_formid_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_xform
    ADD CONSTRAINT odk_xform_formid_key UNIQUE (formid);


--
-- Name: odk_xform_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_xform
    ADD CONSTRAINT odk_xform_pkey PRIMARY KEY (id);


--
-- Name: odk_xform_survey_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY odk_xform_survey_type
    ADD CONSTRAINT odk_xform_survey_type_pkey PRIMARY KEY (id);


--
-- Name: on_hand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_pkey PRIMARY KEY (id);


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
-- Name: product_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_mapping
    ADD CONSTRAINT product_mapping_pkey PRIMARY KEY (id);


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
-- Name: program_equipment_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_equipment_products
    ADD CONSTRAINT program_equipment_products_pkey PRIMARY KEY (id);


--
-- Name: program_equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY program_equipments
    ADD CONSTRAINT program_equipments_pkey PRIMARY KEY (id);


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
-- Name: received_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY received_status
    ADD CONSTRAINT received_status_pkey PRIMARY KEY (id);


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
-- Name: sms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sms
    ADD CONSTRAINT sms_pkey PRIMARY KEY (id);


--
-- Name: storage_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY storage_types
    ADD CONSTRAINT storage_types_pkey PRIMARY KEY (id);


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
-- Name: temperature_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY temperature
    ADD CONSTRAINT temperature_pkey PRIMARY KEY (id);


--
-- Name: template_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: transaction_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_types
    ADD CONSTRAINT transaction_types_pkey PRIMARY KEY (id);


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
-- Name: user_preference_master_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_preference_master
    ADD CONSTRAINT user_preference_master_key_key UNIQUE (key);


--
-- Name: user_preference_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_preference_master
    ADD CONSTRAINT user_preference_master_pkey PRIMARY KEY (id);


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
-- Name: vaccination_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccination_types
    ADD CONSTRAINT vaccination_types_name_key UNIQUE (name);


--
-- Name: vaccination_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccination_types
    ADD CONSTRAINT vaccination_types_pkey PRIMARY KEY (id);


--
-- Name: vaccine_administration_mode_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_administration_mode
    ADD CONSTRAINT vaccine_administration_mode_name_key UNIQUE (name);


--
-- Name: vaccine_administration_mode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_administration_mode
    ADD CONSTRAINT vaccine_administration_mode_pkey PRIMARY KEY (id);


--
-- Name: vaccine_dilution_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_dilution
    ADD CONSTRAINT vaccine_dilution_name_key UNIQUE (name);


--
-- Name: vaccine_dilution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_dilution
    ADD CONSTRAINT vaccine_dilution_pkey PRIMARY KEY (id);


--
-- Name: vaccine_diseases_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_diseases
    ADD CONSTRAINT vaccine_diseases_name_key UNIQUE (name);


--
-- Name: vaccine_diseases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_diseases
    ADD CONSTRAINT vaccine_diseases_pkey PRIMARY KEY (id);


--
-- Name: vaccine_distribution_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_pkey PRIMARY KEY (id);


--
-- Name: vaccine_distribution_demographics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_distribution_demographics
    ADD CONSTRAINT vaccine_distribution_demographics_pkey PRIMARY KEY (id);


--
-- Name: vaccine_distribution_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_distribution_line_items
    ADD CONSTRAINT vaccine_distribution_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_distribution_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_distribution_parameters
    ADD CONSTRAINT vaccine_distribution_parameters_pkey PRIMARY KEY (id);


--
-- Name: vaccine_distribution_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_distribution_types
    ADD CONSTRAINT vaccine_distribution_types_pkey PRIMARY KEY (id);


--
-- Name: vaccine_doses_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_doses
    ADD CONSTRAINT vaccine_doses_name_key UNIQUE (name);


--
-- Name: vaccine_doses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_doses
    ADD CONSTRAINT vaccine_doses_pkey PRIMARY KEY (id);


--
-- Name: vaccine_logistics_master_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_logistics_master_columns
    ADD CONSTRAINT vaccine_logistics_master_columns_pkey PRIMARY KEY (id);


--
-- Name: vaccine_product_doses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_product_doses
    ADD CONSTRAINT vaccine_product_doses_pkey PRIMARY KEY (id);


--
-- Name: vaccine_program_logistics_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_program_logistics_columns
    ADD CONSTRAINT vaccine_program_logistics_columns_pkey PRIMARY KEY (id);


--
-- Name: vaccine_quantifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_quantifications
    ADD CONSTRAINT vaccine_quantifications_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_adverse_effect_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_adverse_effect_line_items
    ADD CONSTRAINT vaccine_report_adverse_effect_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_campaign_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_campaign_line_items
    ADD CONSTRAINT vaccine_report_campaign_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_cold_chain_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_cold_chain_line_items
    ADD CONSTRAINT vaccine_report_cold_chain_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_coverage_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_coverage_line_items
    ADD CONSTRAINT vaccine_report_coverage_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_disease_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_disease_line_items
    ADD CONSTRAINT vaccine_report_disease_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_report_logistics_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_report_logistics_line_items
    ADD CONSTRAINT vaccine_report_logistics_line_items_pkey PRIMARY KEY (id);


--
-- Name: vaccine_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_reports
    ADD CONSTRAINT vaccine_reports_pkey PRIMARY KEY (id);


--
-- Name: vaccine_storage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_storage
    ADD CONSTRAINT vaccine_storage_pkey PRIMARY KEY (id);


--
-- Name: vaccine_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY vaccine_targets
    ADD CONSTRAINT vaccine_targets_pkey PRIMARY KEY (id);


--
-- Name: dw_orders_index_facility; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_facility ON dw_orders USING btree (facilityid);


--
-- Name: dw_orders_index_period; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_period ON dw_orders USING btree (periodid);


--
-- Name: dw_orders_index_product; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_product ON dw_orders USING btree (productid);


--
-- Name: dw_orders_index_prog; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_prog ON dw_orders USING btree (programid);


--
-- Name: dw_orders_index_schedule; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_schedule ON dw_orders USING btree (scheduleid);


--
-- Name: dw_orders_index_status; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_status ON dw_orders USING btree (status);


--
-- Name: dw_orders_index_zone; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX dw_orders_index_zone ON dw_orders USING btree (geographiczoneid);


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
-- Name: i_dw_orders_stockedoutinpast; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX i_dw_orders_stockedoutinpast ON dw_orders USING btree (stockedoutinpast);


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
-- Name: migration_schema_version_current_version_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX migration_schema_version_current_version_index ON migration_schema_version USING btree (current_version);


--
-- Name: program_id_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX program_id_index ON program_rnr_columns USING btree (programid);


--
-- Name: schema_version_current_version_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX schema_version_current_version_index ON schema_version USING btree (current_version);


--
-- Name: uc_administration_mode_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_administration_mode_lower_name ON vaccine_administration_mode USING btree (lower((name)::text));


--
-- Name: INDEX uc_administration_mode_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_administration_mode_lower_name IS 'Unique administration mode required';


--
-- Name: uc_budget_line_items_facilityid_programid_periodid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_budget_line_items_facilityid_programid_periodid ON budget_line_items USING btree (facilityid, programid, periodid);


--
-- Name: uc_countries_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_countries_lower_name ON countries USING btree (lower((name)::text));


--
-- Name: INDEX uc_countries_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_countries_lower_name IS 'Unique country name required';


--
-- Name: uc_delivery_zones_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_delivery_zones_lower_code ON delivery_zones USING btree (lower((code)::text));


--
-- Name: uc_dilution_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_dilution_lower_name ON vaccine_dilution USING btree (lower((name)::text));


--
-- Name: INDEX uc_dilution_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_dilution_lower_name IS 'Unique dilution required';


--
-- Name: uc_distribution_types_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_distribution_types_lower_name ON distribution_types USING btree (lower((name)::text));


--
-- Name: INDEX uc_distribution_types_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_distribution_types_lower_name IS 'Unique storage type required';


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
-- Name: uc_manufacturers_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_manufacturers_lower_name ON manufacturers USING btree (lower((name)::text));


--
-- Name: uc_processing_period_name_scheduleid; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_processing_period_name_scheduleid ON processing_periods USING btree (lower((name)::text), scheduleid, date_part('year'::text, startdate));


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
-- Name: uc_received_status_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_received_status_lower_name ON received_status USING btree (lower((name)::text));


--
-- Name: INDEX uc_received_status_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_received_status_lower_name IS 'Unique shipment received status required';


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
-- Name: uc_storage_types_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_storage_types_lower_name ON storage_types USING btree (lower((storagetypename)::text));


--
-- Name: INDEX uc_storage_types_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_storage_types_lower_name IS 'Unique storage type required';


--
-- Name: uc_supervisory_nodes_lower_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_supervisory_nodes_lower_code ON supervisory_nodes USING btree (lower((code)::text));


--
-- Name: uc_temperature_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_temperature_lower_name ON temperature USING btree (lower((temperaturename)::text));


--
-- Name: INDEX uc_temperature_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_temperature_lower_name IS 'Unique temperature required';


--
-- Name: uc_transaction_types_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_transaction_types_lower_name ON transaction_types USING btree (lower((name)::text));


--
-- Name: INDEX uc_transaction_types_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_transaction_types_lower_name IS 'Unique transaction types required';


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
-- Name: uc_vaccination_types_lower_name; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_vaccination_types_lower_name ON vaccination_types USING btree (lower((name)::text));


--
-- Name: INDEX uc_vaccination_types_lower_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_vaccination_types_lower_name IS 'Unique vaccination type required';


--
-- Name: uc_vaccine_quantifications_year; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_vaccine_quantifications_year ON vaccine_quantifications USING btree (programid, quantificationyear, vaccinetypeid, productcode);


--
-- Name: INDEX uc_vaccine_quantifications_year; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_vaccine_quantifications_year IS 'One vaccine quantification parameter per year allowed';


--
-- Name: uc_vaccine_storage_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_vaccine_storage_code ON vaccine_storage USING btree (loccode);


--
-- Name: INDEX uc_vaccine_storage_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_vaccine_storage_code IS 'Unique code required for storage location';


--
-- Name: uc_vaccine_targets_year; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX uc_vaccine_targets_year ON vaccine_targets USING btree (geographiczoneid, targetyear);


--
-- Name: INDEX uc_vaccine_targets_year; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX uc_vaccine_targets_year IS 'One target per geographic zone allowed';


--
-- Name: unique_donor_code_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_donor_code_index ON donors USING btree (code);


--
-- Name: unique_equipment_code; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_equipment_code ON equipments USING btree (code);


--
-- Name: unique_equipment_type_code_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_equipment_type_code_index ON equipment_types USING btree (code);


--
-- Name: unique_program_equipment_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_program_equipment_index ON program_equipments USING btree (programid, equipmentid);


--
-- Name: unique_program_equipment_product_index; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX unique_program_equipment_product_index ON program_equipment_products USING btree (programequipmentid, productid);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE "_RETURN" AS
    ON SELECT TO vw_number_rnr_created_by_facility DO INSTEAD  SELECT count(r.status) AS totalstatus,
    r.status,
    gz.id AS geographiczoneid,
    gz.name AS geographiczonename
   FROM (((facilities f
   JOIN requisitions r ON ((r.facilityid = f.id)))
   JOIN programs p ON ((p.id = r.programid)))
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)))
  WHERE (r.id IN ( SELECT requisition_status_changes.rnrid
   FROM requisition_status_changes
  GROUP BY requisition_status_changes.rnrid, requisition_status_changes.status
 HAVING (count(*) > 0)))
  GROUP BY r.status, gz.id
  ORDER BY r.status;


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE "_RETURN" AS
    ON SELECT TO vw_order_fill_rate_details DO INSTEAD  SELECT r.programid,
    programs.name AS program,
    li.productcategory AS category,
    prc.id AS categoryid,
    pp.id AS periodid,
    pp.name AS period,
    ps.id AS scheduleid,
    ps.name AS schedule,
    ft.id AS facilitytypeid,
    count(li.quantityapproved) AS total,
    ft.name AS facilitytype,
    r.id AS req_id,
    f.id AS facilityid,
    f.name AS facility,
    li.productcode,
    li.product,
    pr.id AS productid,
    gz.id AS zoneid,
    gz.name AS region,
    li.quantityreceived AS receipts,
    li.quantityapproved AS approved
   FROM ((((((((((requisition_line_items li
   JOIN requisitions r ON ((r.id = li.rnrid)))
   JOIN facilities f ON ((r.facilityid = f.id)))
   JOIN facility_types ft ON ((ft.id = f.typeid)))
   JOIN processing_periods pp ON ((pp.id = r.periodid)))
   JOIN products pr ON (((pr.code)::text = (li.productcode)::text)))
   JOIN geographic_zones gz ON ((gz.id = f.geographiczoneid)))
   JOIN program_products ON (((r.programid = program_products.programid) AND (pr.id = program_products.productid))))
   JOIN product_categories prc ON ((prc.id = program_products.productcategoryid)))
   JOIN programs ON ((r.programid = programs.id)))
   JOIN processing_schedules ps ON ((ps.id = pp.scheduleid)))
  GROUP BY li.product, r.id, li.productcategory, f.name, ft.name, li.productcode, li.quantityapproved, li.quantityreceived, gz.name, r.programid, programs.name, prc.id, pp.id, ps.id, ft.id, f.id, pr.id, gz.id;


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
-- Name: budgets_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budgets
    ADD CONSTRAINT budgets_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: budgets_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budgets
    ADD CONSTRAINT budgets_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: budgets_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY budgets
    ADD CONSTRAINT budgets_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


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
-- Name: elmis_help_helptopicid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help
    ADD CONSTRAINT elmis_help_helptopicid_fkey FOREIGN KEY (helptopicid) REFERENCES elmis_help_topic(id);


--
-- Name: elmis_help_topic_parent_help_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic
    ADD CONSTRAINT elmis_help_topic_parent_help_topic_id_fkey FOREIGN KEY (parent_help_topic_id) REFERENCES elmis_help_topic(id);


--
-- Name: elmis_help_topic_roles_help_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic_roles
    ADD CONSTRAINT elmis_help_topic_roles_help_topic_id_fkey FOREIGN KEY (help_topic_id) REFERENCES elmis_help_topic(id);


--
-- Name: elmis_help_topic_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic_roles
    ADD CONSTRAINT elmis_help_topic_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);


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
-- Name: equipment_contract_service_types_contractid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_contract_service_types
    ADD CONSTRAINT equipment_contract_service_types_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);


--
-- Name: equipment_contract_service_types_servicetypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_contract_service_types
    ADD CONSTRAINT equipment_contract_service_types_servicetypeid_fkey FOREIGN KEY (servicetypeid) REFERENCES equipment_service_types(id);


--
-- Name: equipment_maintenance_logs_contractid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);


--
-- Name: equipment_maintenance_logs_equipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);


--
-- Name: equipment_maintenance_logs_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: equipment_maintenance_logs_requestid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_requestid_fkey FOREIGN KEY (requestid) REFERENCES equipment_maintenance_requests(id);


--
-- Name: equipment_maintenance_logs_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: equipment_maintenance_logs_vendorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_logs
    ADD CONSTRAINT equipment_maintenance_logs_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);


--
-- Name: equipment_maintenance_requests_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_requests
    ADD CONSTRAINT equipment_maintenance_requests_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: equipment_maintenance_requests_inventoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_requests
    ADD CONSTRAINT equipment_maintenance_requests_inventoryid_fkey FOREIGN KEY (inventoryid) REFERENCES facility_program_equipments(id);


--
-- Name: equipment_maintenance_requests_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_requests
    ADD CONSTRAINT equipment_maintenance_requests_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: equipment_maintenance_requests_vendorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_maintenance_requests
    ADD CONSTRAINT equipment_maintenance_requests_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);


--
-- Name: equipment_service_contract_equipments_contractid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_equipments
    ADD CONSTRAINT equipment_service_contract_equipments_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);


--
-- Name: equipment_service_contract_equipments_equipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_equipments
    ADD CONSTRAINT equipment_service_contract_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);


--
-- Name: equipment_service_contract_facilities_contractid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_facilities
    ADD CONSTRAINT equipment_service_contract_facilities_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);


--
-- Name: equipment_service_contract_facilities_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contract_facilities
    ADD CONSTRAINT equipment_service_contract_facilities_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: equipment_service_contracts_vendorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_contracts
    ADD CONSTRAINT equipment_service_contracts_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);


--
-- Name: equipment_service_vendor_users_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_vendor_users
    ADD CONSTRAINT equipment_service_vendor_users_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: equipment_service_vendor_users_vendorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_service_vendor_users
    ADD CONSTRAINT equipment_service_vendor_users_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);


--
-- Name: equipment_status_line_items_equipmentinventoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_status_line_items
    ADD CONSTRAINT equipment_status_line_items_equipmentinventoryid_fkey FOREIGN KEY (equipmentinventoryid) REFERENCES facility_program_equipments(id);


--
-- Name: equipment_status_line_items_operationalstatusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_status_line_items
    ADD CONSTRAINT equipment_status_line_items_operationalstatusid_fkey FOREIGN KEY (operationalstatusid) REFERENCES equipment_operational_status(id);


--
-- Name: equipment_status_line_items_rnrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipment_status_line_items
    ADD CONSTRAINT equipment_status_line_items_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: equipments_equipmenttypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY equipments
    ADD CONSTRAINT equipments_equipmenttypeid_fkey FOREIGN KEY (equipmenttypeid) REFERENCES equipment_types(id);


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
-- Name: facility_program_equipments_equipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);


--
-- Name: facility_program_equipments_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: facility_program_equipments_operationalstatusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_operationalstatusid_fkey FOREIGN KEY (operationalstatusid) REFERENCES equipment_operational_status(id);


--
-- Name: facility_program_equipments_primarydonorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_primarydonorid_fkey FOREIGN KEY (primarydonorid) REFERENCES donors(id);


--
-- Name: facility_program_equipments_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY facility_program_equipments
    ADD CONSTRAINT facility_program_equipments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


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
-- Name: fk_foreign_users_modifier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic
    ADD CONSTRAINT fk_foreign_users_modifier FOREIGN KEY (modifiedby) REFERENCES users(id);


--
-- Name: fk_foreing_users_creator; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help_topic
    ADD CONSTRAINT fk_foreing_users_creator FOREIGN KEY (created_by) REFERENCES users(id);


--
-- Name: fk_user_help_modifier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY elmis_help
    ADD CONSTRAINT fk_user_help_modifier FOREIGN KEY (modifiedby) REFERENCES users(id);


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
-- Name: inventory_batches_transactionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_batches
    ADD CONSTRAINT inventory_batches_transactionid_fkey FOREIGN KEY (transactionid) REFERENCES inventory_transactions(id);


--
-- Name: inventory_transactions_donorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_donorid_fkey FOREIGN KEY (donorid) REFERENCES donors(id);


--
-- Name: inventory_transactions_fromfacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_fromfacilityid_fkey FOREIGN KEY (fromfacilityid) REFERENCES facilities(id);


--
-- Name: inventory_transactions_locationid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_locationid_fkey FOREIGN KEY (locationid) REFERENCES vaccine_storage(id);


--
-- Name: inventory_transactions_manufacturerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);


--
-- Name: inventory_transactions_origincountryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_origincountryid_fkey FOREIGN KEY (origincountryid) REFERENCES countries(id);


--
-- Name: inventory_transactions_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: inventory_transactions_statusid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_statusid_fkey FOREIGN KEY (statusid) REFERENCES received_status(id);


--
-- Name: inventory_transactions_tofacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_tofacilityid_fkey FOREIGN KEY (tofacilityid) REFERENCES facilities(id);


--
-- Name: inventory_transactions_transactiontypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY inventory_transactions
    ADD CONSTRAINT inventory_transactions_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);


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
-- Name: odk_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_submission
    ADD CONSTRAINT odk_account_id_fkey FOREIGN KEY (odkaccountid) REFERENCES odk_account(id);


--
-- Name: odk_proof_of_delivery_district_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_district_id_fkey FOREIGN KEY (districtid) REFERENCES geographic_zones(id);


--
-- Name: odk_proof_of_delivery_facility_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_facility_id_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: odk_proof_of_delivery_odk_xform_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_odk_xform_id_fkey FOREIGN KEY (odkxformid) REFERENCES odk_xform(id);


--
-- Name: odk_proof_of_delivery_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_period_id_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: odk_proof_of_delivery_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_program_id_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: odk_proof_of_delivery_rnr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_xform
    ADD CONSTRAINT odk_proof_of_delivery_rnr_id_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: odk_proof_of_delivery_submission_data_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_submission_data
    ADD CONSTRAINT odk_proof_of_delivery_submission_data_product_id_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: odk_proof_of_delivery_submission_data_rnr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_proof_of_delivery_submission_data
    ADD CONSTRAINT odk_proof_of_delivery_submission_data_rnr_id_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);


--
-- Name: odk_stock_status_submission_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_stock_status_submission
    ADD CONSTRAINT odk_stock_status_submission_submission_id_fkey FOREIGN KEY (odksubmissionid) REFERENCES odk_submission(id);


--
-- Name: odk_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_submission_data
    ADD CONSTRAINT odk_submission_id_fkey FOREIGN KEY (odksubmissionid) REFERENCES odk_submission(id);


--
-- Name: odk_xform_odk_xform_survey_type_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY odk_xform
    ADD CONSTRAINT odk_xform_odk_xform_survey_type_fk FOREIGN KEY (odkxformsurveytypeid) REFERENCES odk_xform_survey_type(id);


--
-- Name: on_hand_batchnumber_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_batchnumber_fkey FOREIGN KEY (batchnumber) REFERENCES inventory_batches(id);


--
-- Name: on_hand_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: on_hand_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: on_hand_transactionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_transactionid_fkey FOREIGN KEY (transactionid) REFERENCES inventory_transactions(id);


--
-- Name: on_hand_transactiontypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_hand
    ADD CONSTRAINT on_hand_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);


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
-- Name: product_mapping_manufacturerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_mapping
    ADD CONSTRAINT product_mapping_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);


--
-- Name: product_mapping_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY product_mapping
    ADD CONSTRAINT product_mapping_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


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
-- Name: program_equipment_products_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipment_products
    ADD CONSTRAINT program_equipment_products_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: program_equipment_products_programequipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipment_products
    ADD CONSTRAINT program_equipment_products_programequipmentid_fkey FOREIGN KEY (programequipmentid) REFERENCES program_equipments(id);


--
-- Name: program_equipments_equipmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipments
    ADD CONSTRAINT program_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);


--
-- Name: program_equipments_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY program_equipments
    ADD CONSTRAINT program_equipments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


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
-- Name: received_status_transactiontypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY received_status
    ADD CONSTRAINT received_status_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);


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
-- Name: supply_lines_parentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_parentid_fkey FOREIGN KEY (parentid) REFERENCES supply_lines(id);


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
-- Name: user_preference_roles_roleid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_preference_roles
    ADD CONSTRAINT user_preference_roles_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: user_preference_roles_userpreferencekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_preference_roles
    ADD CONSTRAINT user_preference_roles_userpreferencekey_fkey FOREIGN KEY (userpreferencekey) REFERENCES user_preference_master(key);


--
-- Name: user_preferences_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_preferences
    ADD CONSTRAINT user_preferences_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: user_preferences_userpreferencekey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY user_preferences
    ADD CONSTRAINT user_preferences_userpreferencekey_fkey FOREIGN KEY (userpreferencekey) REFERENCES user_preference_master(key);


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
-- Name: vaccine_distribution_batches_distributiontypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_distributiontypeid_fkey FOREIGN KEY (distributiontypeid) REFERENCES distribution_types(name);


--
-- Name: vaccine_distribution_batches_donorid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_donorid_fkey FOREIGN KEY (donorid) REFERENCES donors(id);


--
-- Name: vaccine_distribution_batches_fromfacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_fromfacilityid_fkey FOREIGN KEY (fromfacilityid) REFERENCES facilities(id);


--
-- Name: vaccine_distribution_batches_manufacturerid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);


--
-- Name: vaccine_distribution_batches_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: vaccine_distribution_batches_tofacilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_batches
    ADD CONSTRAINT vaccine_distribution_batches_tofacilityid_fkey FOREIGN KEY (tofacilityid) REFERENCES facilities(id);


--
-- Name: vaccine_distribution_line_items_distributionbatchid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_distribution_line_items
    ADD CONSTRAINT vaccine_distribution_line_items_distributionbatchid_fkey FOREIGN KEY (distributionbatchid) REFERENCES vaccine_distribution_batches(id);


--
-- Name: vaccine_product_doses_doseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_product_doses
    ADD CONSTRAINT vaccine_product_doses_doseid_fkey FOREIGN KEY (doseid) REFERENCES vaccine_doses(id);


--
-- Name: vaccine_product_doses_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_product_doses
    ADD CONSTRAINT vaccine_product_doses_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: vaccine_product_doses_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_product_doses
    ADD CONSTRAINT vaccine_product_doses_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: vaccine_program_logistics_columns_mastercolumnid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_program_logistics_columns
    ADD CONSTRAINT vaccine_program_logistics_columns_mastercolumnid_fkey FOREIGN KEY (mastercolumnid) REFERENCES vaccine_logistics_master_columns(id);


--
-- Name: vaccine_program_logistics_columns_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_program_logistics_columns
    ADD CONSTRAINT vaccine_program_logistics_columns_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: vaccine_quantifications_productcode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_quantifications
    ADD CONSTRAINT vaccine_quantifications_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);


--
-- Name: vaccine_quantifications_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_quantifications
    ADD CONSTRAINT vaccine_quantifications_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: vaccine_report_adverse_effect_line_items_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_adverse_effect_line_items
    ADD CONSTRAINT vaccine_report_adverse_effect_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: vaccine_report_adverse_effect_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_adverse_effect_line_items
    ADD CONSTRAINT vaccine_report_adverse_effect_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_report_campaign_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_campaign_line_items
    ADD CONSTRAINT vaccine_report_campaign_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_report_cold_chain_line_items_equipmentinventoryid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_cold_chain_line_items
    ADD CONSTRAINT vaccine_report_cold_chain_line_items_equipmentinventoryid_fkey FOREIGN KEY (equipmentinventoryid) REFERENCES facility_program_equipments(id);


--
-- Name: vaccine_report_cold_chain_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_cold_chain_line_items
    ADD CONSTRAINT vaccine_report_cold_chain_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_report_coverage_line_items_doseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_coverage_line_items
    ADD CONSTRAINT vaccine_report_coverage_line_items_doseid_fkey FOREIGN KEY (doseid) REFERENCES vaccine_doses(id);


--
-- Name: vaccine_report_coverage_line_items_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_coverage_line_items
    ADD CONSTRAINT vaccine_report_coverage_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: vaccine_report_coverage_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_coverage_line_items
    ADD CONSTRAINT vaccine_report_coverage_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_report_disease_line_items_diseaseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_disease_line_items
    ADD CONSTRAINT vaccine_report_disease_line_items_diseaseid_fkey FOREIGN KEY (diseaseid) REFERENCES vaccine_diseases(id);


--
-- Name: vaccine_report_disease_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_disease_line_items
    ADD CONSTRAINT vaccine_report_disease_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_report_logistics_line_items_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_logistics_line_items
    ADD CONSTRAINT vaccine_report_logistics_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);


--
-- Name: vaccine_report_logistics_line_items_reportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_report_logistics_line_items
    ADD CONSTRAINT vaccine_report_logistics_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);


--
-- Name: vaccine_reports_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_reports
    ADD CONSTRAINT vaccine_reports_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: vaccine_reports_periodid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_reports
    ADD CONSTRAINT vaccine_reports_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);


--
-- Name: vaccine_reports_programid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_reports
    ADD CONSTRAINT vaccine_reports_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: vaccine_storage_facilityid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_storage
    ADD CONSTRAINT vaccine_storage_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: vaccine_storage_storagetypeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_storage
    ADD CONSTRAINT vaccine_storage_storagetypeid_fkey FOREIGN KEY (storagetypeid) REFERENCES storage_types(id);


--
-- Name: vaccine_storage_temperatureid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_storage
    ADD CONSTRAINT vaccine_storage_temperatureid_fkey FOREIGN KEY (temperatureid) REFERENCES temperature(id);


--
-- Name: vaccine_targets_geographiczoneid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY vaccine_targets
    ADD CONSTRAINT vaccine_targets_geographiczoneid_fkey FOREIGN KEY (geographiczoneid) REFERENCES geographic_zones(id);


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

