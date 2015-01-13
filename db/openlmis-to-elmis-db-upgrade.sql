
SET search_path = public, pg_catalog;

DROP INDEX uc_processing_period_name_scheduleid;

CREATE SEQUENCE alert_facility_stockedout_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_requisition_approved_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_requisition_emergency_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_requisition_pending_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_requisition_rejected_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_stockedout_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE alert_summary_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE budgets_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE configuration_settings_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE countries_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE custom_reports_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE distribution_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE donors_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE elmis_help_document_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE elmis_help_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE elmis_help_topic_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE elmis_help_topic_roles_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE emergency_requisitions_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_contract_service_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_maintenance_logs_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_maintenance_requests_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_operational_status_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_contract_equipments_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_contract_facilities_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_contracts_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_vendor_users_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_service_vendors_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_status_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipment_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE equipments_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE facility_program_equipments_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE geographic_zone_geojson_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE inventory_batches_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE inventory_transactions_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE manufacturers_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_account_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_proof_of_delivery_submission_data_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_proof_of_delivery_xform_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_stock_status_submission_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_submission_data_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_submission_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_xform_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE odk_xform_survey_type_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE on_hand_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE product_mapping_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE program_equipment_products_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE program_equipments_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE received_status_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE sms_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE storage_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE temperature_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE transaction_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE user_preference_master_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccination_types_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_administration_mode_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_dilution_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_diseases_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_distribution_batches_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_distribution_demographics_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_distribution_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_distribution_parameters_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_doses_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_logistics_master_columns_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_product_doses_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_program_logistics_columns_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_quantifications_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_adverse_effect_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_campaign_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_cold_chain_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_coverage_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_disease_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_report_logistics_line_items_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_reports_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_storage_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE vaccine_targets_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE alert_facility_stockedout (
	id integer DEFAULT nextval('alert_facility_stockedout_id_seq'::regclass) NOT NULL,
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

CREATE TABLE alert_requisition_approved (
	id integer DEFAULT nextval('alert_requisition_approved_id_seq'::regclass) NOT NULL,
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

CREATE TABLE alert_requisition_emergency (
	id integer DEFAULT nextval('alert_requisition_emergency_id_seq'::regclass) NOT NULL,
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

CREATE TABLE alert_requisition_pending (
	id integer DEFAULT nextval('alert_requisition_pending_id_seq'::regclass) NOT NULL,
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

CREATE TABLE alert_requisition_rejected (
	id integer DEFAULT nextval('alert_requisition_rejected_id_seq'::regclass) NOT NULL,
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

CREATE TABLE alert_stockedout (
	id integer DEFAULT nextval('alert_stockedout_id_seq'::regclass) NOT NULL,
	alertsummaryid integer,
	facilityid integer,
	facilityname character varying(50),
	stockoutdays integer,
	amc integer,
	productid integer
);

CREATE TABLE alert_summary (
	id integer DEFAULT nextval('alert_summary_id_seq'::regclass) NOT NULL,
	statics_value integer,
	description character varying(2000),
	geographiczoneid integer,
	alerttypeid character varying(50),
	programid integer,
	periodid integer,
	productid integer
);

CREATE TABLE alerts (
	alerttype character varying(50) NOT NULL,
	display_section character varying(50),
	email boolean,
	sms boolean,
	detail_table character varying(50),
	sms_msg_template_key character varying(250),
	email_msg_template_key character varying(250)
);

CREATE TABLE budgets (
	id integer DEFAULT nextval('budgets_id_seq'::regclass) NOT NULL,
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

CREATE TABLE configuration_settings (
	id integer DEFAULT nextval('configuration_settings_id_seq'::regclass) NOT NULL,
	"key" character varying(250) NOT NULL,
	"value" character varying(250),
	name character varying(250) NOT NULL,
	description character varying(1000),
	groupname character varying(250) DEFAULT 'General'::character varying NOT NULL,
	displayorder integer DEFAULT 1 NOT NULL,
	valuetype character varying(250) DEFAULT 'TEXT'::character varying NOT NULL,
	valueoptions character varying(1000)
);

CREATE TABLE countries (
	id integer DEFAULT nextval('countries_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	longname character varying(250),
	isocode2 character varying(2),
	isocode3 character varying(3),
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE countries IS 'Countries';

COMMENT ON COLUMN countries.id IS 'ID';

COMMENT ON COLUMN countries.name IS 'Name';

COMMENT ON COLUMN countries.longname IS 'Long name';

COMMENT ON COLUMN countries.isocode2 IS 'ISO code (2 digit)';

COMMENT ON COLUMN countries.isocode3 IS 'ISO code (3 digit)';

COMMENT ON COLUMN countries.createdby IS 'Created by';

COMMENT ON COLUMN countries.createddate IS 'Created on';

COMMENT ON COLUMN countries.modifiedby IS 'Modified by';

COMMENT ON COLUMN countries.modifieddate IS 'Modified on';

CREATE TABLE custom_reports (
	id integer DEFAULT nextval('custom_reports_id_seq'::regclass) NOT NULL,
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

CREATE TABLE distribution_types (
	id integer DEFAULT nextval('distribution_types_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE distribution_types IS 'Vaccine storage types';

COMMENT ON COLUMN distribution_types.id IS 'ID';

COMMENT ON COLUMN distribution_types.name IS 'Distribution type';

COMMENT ON COLUMN distribution_types.createdby IS 'Created by';

COMMENT ON COLUMN distribution_types.createddate IS 'Created on';

COMMENT ON COLUMN distribution_types.modifiedby IS 'Modified by';

COMMENT ON COLUMN distribution_types.modifieddate IS 'Modified on';

CREATE TABLE donors (
	id integer DEFAULT nextval('donors_id_seq'::regclass) NOT NULL,
	shortname character varying(200) NOT NULL,
	longname character varying(200) NOT NULL,
	code character varying(50),
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

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

CREATE TABLE elmis_help (
	name character varying(500),
	modifiedby integer,
	htmlcontent character varying(2000),
	imagelink character varying(100),
	createddate date,
	id integer DEFAULT nextval('elmis_help_id_seq'::regclass) NOT NULL,
	createdby integer,
	modifieddate date,
	helptopicid integer
);

CREATE TABLE elmis_help_document (
	id integer DEFAULT nextval('elmis_help_document_id_seq'::regclass) NOT NULL,
	document_type character varying(20),
	url character varying(100),
	created_date date,
	modified_date date,
	created_by integer,
	modified_by integer
);

CREATE TABLE elmis_help_topic (
	"level" integer,
	name character varying(200),
	created_by integer,
	createddate date,
	modifiedby integer,
	modifieddate date,
	id integer DEFAULT nextval('elmis_help_topic_id_seq'::regclass) NOT NULL,
	parent_help_topic_id integer,
	is_category boolean DEFAULT true,
	html_content character varying(50000)
);

CREATE TABLE elmis_help_topic_roles (
	id integer DEFAULT nextval('elmis_help_topic_roles_id_seq'::regclass) NOT NULL,
	help_topic_id integer,
	role_id integer,
	is_asigned boolean DEFAULT true,
	was_previosly_assigned boolean DEFAULT true,
	created_by integer,
	createddate date,
	modifiedby integer,
	modifieddate date
);

CREATE TABLE emergency_requisitions (
	id integer DEFAULT nextval('emergency_requisitions_id_seq'::regclass) NOT NULL,
	alertsummaryid integer,
	rnrid integer,
	facilityid integer,
	status character varying(50)
);

CREATE TABLE equipment_contract_service_types (
	id integer DEFAULT nextval('equipment_contract_service_types_id_seq'::regclass) NOT NULL,
	contractid integer,
	servicetypeid integer,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_maintenance_logs (
	id integer DEFAULT nextval('equipment_maintenance_logs_id_seq'::regclass) NOT NULL,
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

CREATE TABLE equipment_maintenance_requests (
	id integer DEFAULT nextval('equipment_maintenance_requests_id_seq'::regclass) NOT NULL,
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

CREATE TABLE equipment_operational_status (
	id integer DEFAULT nextval('equipment_operational_status_id_seq'::regclass) NOT NULL,
	name character varying(200) NOT NULL,
	displayorder integer DEFAULT 0 NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_service_contract_equipments (
	id integer DEFAULT nextval('equipment_service_contract_equipments_id_seq'::regclass) NOT NULL,
	contractid integer NOT NULL,
	equipmentid integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_service_contract_facilities (
	id integer DEFAULT nextval('equipment_service_contract_facilities_id_seq'::regclass) NOT NULL,
	contractid integer,
	facilityid integer,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_service_contracts (
	id integer DEFAULT nextval('equipment_service_contracts_id_seq'::regclass) NOT NULL,
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

CREATE TABLE equipment_service_types (
	id integer DEFAULT nextval('equipment_service_types_id_seq'::regclass) NOT NULL,
	name character varying(1000) NOT NULL,
	description character varying(2000) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_service_vendor_users (
	id integer DEFAULT nextval('equipment_service_vendor_users_id_seq'::regclass) NOT NULL,
	userid integer NOT NULL,
	vendorid integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipment_service_vendors (
	id integer DEFAULT nextval('equipment_service_vendors_id_seq'::regclass) NOT NULL,
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

CREATE TABLE equipment_status_line_items (
	id integer DEFAULT nextval('equipment_status_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE equipment_types (
	id integer DEFAULT nextval('equipment_types_id_seq'::regclass) NOT NULL,
	code character varying(20) NOT NULL,
	name character varying(200),
	displayorder integer DEFAULT 0 NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE equipments (
	id integer DEFAULT nextval('equipments_id_seq'::regclass) NOT NULL,
	code character varying(200) NOT NULL,
	name character varying(200) NOT NULL,
	equipmenttypeid integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE facility_program_equipments (
	id integer DEFAULT nextval('facility_program_equipments_id_seq'::regclass) NOT NULL,
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

CREATE TABLE geographic_zone_geojson (
	id integer DEFAULT nextval('geographic_zone_geojson_id_seq'::regclass) NOT NULL,
	zoneid integer,
	geojsonid integer,
	geometry text,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE inventory_batches (
	id integer DEFAULT nextval('inventory_batches_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE inventory_batches IS 'On hand of inventory';

COMMENT ON COLUMN inventory_batches.id IS 'ID';

COMMENT ON COLUMN inventory_batches.transactionid IS 'Inventory trasaction ID';

COMMENT ON COLUMN inventory_batches.batchnumber IS 'Batch/Lot number';

COMMENT ON COLUMN inventory_batches.manufacturedate IS 'Manufacturing date';

COMMENT ON COLUMN inventory_batches.expirydate IS 'Expiry date';

COMMENT ON COLUMN inventory_batches.quantity IS 'Batch quantity';

COMMENT ON COLUMN inventory_batches.vvm1_qty IS 'VVM 1 quantity';

COMMENT ON COLUMN inventory_batches.vvm2_qty IS 'VVM 2 quantity';

COMMENT ON COLUMN inventory_batches.vvm3_qty IS 'VVM 3 quantity';

COMMENT ON COLUMN inventory_batches.vvm4_qty IS 'VVM 4 quantity';

COMMENT ON COLUMN inventory_batches.note IS 'Note';

COMMENT ON COLUMN inventory_batches.createdby IS 'Created by';

COMMENT ON COLUMN inventory_batches.createddate IS 'Created on';

COMMENT ON COLUMN inventory_batches.modifiedby IS 'Modified by';

COMMENT ON COLUMN inventory_batches.modifieddate IS 'Modified on';

CREATE TABLE inventory_transactions (
	id integer DEFAULT nextval('inventory_transactions_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE inventory_transactions IS 'Inventory transactions';

COMMENT ON COLUMN inventory_transactions.id IS 'ID';

COMMENT ON COLUMN inventory_transactions.transactiontypeid IS 'Transaction type';

COMMENT ON COLUMN inventory_transactions.fromfacilityid IS 'Received from';

COMMENT ON COLUMN inventory_transactions.tofacilityid IS 'Send to';

COMMENT ON COLUMN inventory_transactions.productid IS 'Product';

COMMENT ON COLUMN inventory_transactions.dispatchreference IS 'Dispatch reference';

COMMENT ON COLUMN inventory_transactions.dispatchdate IS 'Dispatch date';

COMMENT ON COLUMN inventory_transactions.bol IS 'Bill of lading';

COMMENT ON COLUMN inventory_transactions.donorid IS 'Donor';

COMMENT ON COLUMN inventory_transactions.origincountryid IS 'Country of origin';

COMMENT ON COLUMN inventory_transactions.manufacturerid IS 'Manufacturer';

COMMENT ON COLUMN inventory_transactions.statusid IS 'Received status';

COMMENT ON COLUMN inventory_transactions.purpose IS 'Purpose for the vaccine';

COMMENT ON COLUMN inventory_transactions.vvmtracked IS 'Consignment temperature monitored through VVM';

COMMENT ON COLUMN inventory_transactions.barcoded IS 'Consignment is bar coded';

COMMENT ON COLUMN inventory_transactions.gs1 IS 'GS1 bar coded';

COMMENT ON COLUMN inventory_transactions.quantity IS 'Quantity';

COMMENT ON COLUMN inventory_transactions.packsize IS 'Pack size';

COMMENT ON COLUMN inventory_transactions.unitprice IS 'Unit price';

COMMENT ON COLUMN inventory_transactions.totalcost IS 'Total cost';

COMMENT ON COLUMN inventory_transactions.locationid IS 'Storage location ';

COMMENT ON COLUMN inventory_transactions.expecteddate IS 'Date the shipment expected';

COMMENT ON COLUMN inventory_transactions.arrivaldate IS 'Date the shipment arrived at destination';

COMMENT ON COLUMN inventory_transactions.confirmedby IS 'Proof-of-receipt confirmed by';

COMMENT ON COLUMN inventory_transactions.note IS 'Notes';

COMMENT ON COLUMN inventory_transactions.createdby IS 'Created by';

COMMENT ON COLUMN inventory_transactions.createddate IS 'Created on';

COMMENT ON COLUMN inventory_transactions.modifiedby IS 'Modified by';

COMMENT ON COLUMN inventory_transactions.modifieddate IS 'Modified on';

CREATE TABLE manufacturers (
	id integer DEFAULT nextval('manufacturers_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE manufacturers IS 'Manufacturers';

COMMENT ON COLUMN manufacturers.id IS 'id';

COMMENT ON COLUMN manufacturers.name IS 'name';

COMMENT ON COLUMN manufacturers.website IS 'website';

COMMENT ON COLUMN manufacturers.contactperson IS 'contactPerson';

COMMENT ON COLUMN manufacturers.primaryphone IS 'primaryPhone';

COMMENT ON COLUMN manufacturers.email IS 'email';

COMMENT ON COLUMN manufacturers.description IS 'description';

COMMENT ON COLUMN manufacturers.specialization IS 'specialization';

COMMENT ON COLUMN manufacturers.geographiccoverage IS 'geographicCoverage';

COMMENT ON COLUMN manufacturers.registrationdate IS 'registrationDate';

COMMENT ON COLUMN manufacturers.createdby IS 'createdBy';

COMMENT ON COLUMN manufacturers.createddate IS 'createdDate';

COMMENT ON COLUMN manufacturers.modifiedby IS 'modifiedBy';

COMMENT ON COLUMN manufacturers.modifieddate IS 'modifiedDate';

CREATE TABLE migration_schema_version (
	version character varying(20) NOT NULL,
	description character varying(100),
	type character varying(10) NOT NULL,
	script character varying(200) NOT NULL,
	checksum integer,
	installed_by character varying(30) NOT NULL,
	installed_on timestamp without time zone DEFAULT now(),
	execution_time integer,
	"state" character varying(15) NOT NULL,
	current_version boolean NOT NULL
);

CREATE TABLE odk_account (
	id integer DEFAULT nextval('odk_account_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_proof_of_delivery_submission_data (
	id integer DEFAULT nextval('odk_proof_of_delivery_submission_data_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_proof_of_delivery_xform (
	id integer DEFAULT nextval('odk_proof_of_delivery_xform_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_stock_status_submission (
	id integer DEFAULT nextval('odk_stock_status_submission_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_submission (
	id integer DEFAULT nextval('odk_submission_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_submission_data (
	id integer DEFAULT nextval('odk_submission_data_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_xform (
	id integer DEFAULT nextval('odk_xform_id_seq'::regclass) NOT NULL,
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

CREATE TABLE odk_xform_survey_type (
	id integer DEFAULT nextval('odk_xform_survey_type_id_seq'::regclass) NOT NULL,
	surveyname character varying(400) NOT NULL,
	numberofquestions integer NOT NULL,
	active boolean NOT NULL,
	comment text,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE on_hand (
	id integer DEFAULT nextval('on_hand_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE on_hand IS 'On hand of inventory';

COMMENT ON COLUMN on_hand.id IS 'ID';

COMMENT ON COLUMN on_hand.transactionid IS 'Trasaction reference';

COMMENT ON COLUMN on_hand.transactiontypeid IS 'Transaction Type';

COMMENT ON COLUMN on_hand.productid IS 'Product code';

COMMENT ON COLUMN on_hand.facilityid IS 'Facility ID';

COMMENT ON COLUMN on_hand.batchnumber IS 'Batch number';

COMMENT ON COLUMN on_hand.quantity IS 'Quantity';

COMMENT ON COLUMN on_hand.vvm1_qty IS 'VVM1';

COMMENT ON COLUMN on_hand.vvm2_qty IS 'VVM2';

COMMENT ON COLUMN on_hand.vvm3_qty IS 'VVM3';

COMMENT ON COLUMN on_hand.vvm4_qty IS 'VVM4';

COMMENT ON COLUMN on_hand.note IS 'Notes';

COMMENT ON COLUMN on_hand.createdby IS 'Created by';

COMMENT ON COLUMN on_hand.createddate IS 'Created on';

COMMENT ON COLUMN on_hand.modifiedby IS 'Modified by';

COMMENT ON COLUMN on_hand.modifieddate IS 'Modified on';

CREATE TABLE product_code_change_log (
	program character varying(4),
	old_code character varying(12),
	new_code character varying(12),
	product character varying(200),
	unit character varying(200),
	changeddate timestamp without time zone,
	migrated boolean DEFAULT false
);

CREATE TABLE product_mapping (
	id integer DEFAULT nextval('product_mapping_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE product_mapping IS 'product mapping';

COMMENT ON COLUMN product_mapping.productcode IS 'productCode';

COMMENT ON COLUMN product_mapping.gtin IS 'gtin';

COMMENT ON COLUMN product_mapping.elmis IS 'elmis';

COMMENT ON COLUMN product_mapping.rhi IS 'rhi';

COMMENT ON COLUMN product_mapping.ppmr IS 'ppmr';

COMMENT ON COLUMN product_mapping.who IS 'who';

COMMENT ON COLUMN product_mapping.other1 IS 'other1';

COMMENT ON COLUMN product_mapping.other2 IS 'other2';

COMMENT ON COLUMN product_mapping.other3 IS 'other3';

COMMENT ON COLUMN product_mapping.other4 IS 'other4';

COMMENT ON COLUMN product_mapping.other5 IS 'other5';

CREATE TABLE program_equipment_products (
	id integer DEFAULT nextval('program_equipment_products_id_seq'::regclass) NOT NULL,
	programequipmentid integer NOT NULL,
	productid integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE program_equipments (
	id integer DEFAULT nextval('program_equipments_id_seq'::regclass) NOT NULL,
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

CREATE TABLE received_status (
	id integer DEFAULT nextval('received_status_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	transactiontypeid integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE received_status IS 'Shipment received status';

COMMENT ON COLUMN received_status.id IS 'ID';

COMMENT ON COLUMN received_status.name IS 'Name';

COMMENT ON COLUMN received_status.createdby IS 'Created by';

COMMENT ON COLUMN received_status.createddate IS 'Created on';

COMMENT ON COLUMN received_status.modifiedby IS 'Modified by';

COMMENT ON COLUMN received_status.modifieddate IS 'Modified on';

CREATE TABLE sms (
	id integer DEFAULT nextval('sms_id_seq'::regclass) NOT NULL,
	message character varying(250),
	phonenumber character varying(20),
	direction character varying(40),
	sent boolean DEFAULT false,
	datesaved date
);

CREATE TABLE storage_types (
	id integer DEFAULT nextval('storage_types_id_seq'::regclass) NOT NULL,
	storagetypename character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE storage_types IS 'Vaccine storage types';

COMMENT ON COLUMN storage_types.id IS 'ID';

COMMENT ON COLUMN storage_types.storagetypename IS 'Storage type';

COMMENT ON COLUMN storage_types.createdby IS 'Created by';

COMMENT ON COLUMN storage_types.createddate IS 'Created on';

COMMENT ON COLUMN storage_types.modifiedby IS 'Modified by';

COMMENT ON COLUMN storage_types.modifieddate IS 'Modified on';

CREATE TABLE temperature (
	id integer DEFAULT nextval('temperature_id_seq'::regclass) NOT NULL,
	temperaturename character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE temperature IS 'Vaccine storage temperature';

COMMENT ON COLUMN temperature.id IS 'ID';

COMMENT ON COLUMN temperature.temperaturename IS 'Temperature';

COMMENT ON COLUMN temperature.createdby IS 'Created by';

COMMENT ON COLUMN temperature.createddate IS 'Created on';

COMMENT ON COLUMN temperature.modifiedby IS 'Modified by';

COMMENT ON COLUMN temperature.modifieddate IS 'Modified on';

CREATE TABLE transaction_types (
	id integer DEFAULT nextval('transaction_types_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE transaction_types IS 'Inventory transaction types';

COMMENT ON COLUMN transaction_types.id IS 'ID';

COMMENT ON COLUMN transaction_types.name IS 'Transaction Name';

COMMENT ON COLUMN transaction_types.createdby IS 'Created by';

COMMENT ON COLUMN transaction_types.createddate IS 'Created on';

COMMENT ON COLUMN transaction_types.modifiedby IS 'Modified by';

COMMENT ON COLUMN transaction_types.modifieddate IS 'Modified on';

CREATE TABLE user_preference_master (
	id integer DEFAULT nextval('user_preference_master_id_seq'::regclass) NOT NULL,
	"key" character varying(50) NOT NULL,
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

CREATE TABLE user_preferences (
	userid integer NOT NULL,
	userpreferencekey character varying(50),
	"value" character varying(2000),
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE vaccination_types (
	id integer DEFAULT nextval('vaccination_types_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE vaccination_types IS 'Vaccine storage types';

COMMENT ON COLUMN vaccination_types.id IS 'ID';

COMMENT ON COLUMN vaccination_types.name IS 'Vaccination type';

COMMENT ON COLUMN vaccination_types.createdby IS 'Created by';

COMMENT ON COLUMN vaccination_types.createddate IS 'Created on';

COMMENT ON COLUMN vaccination_types.modifiedby IS 'Modified by';

COMMENT ON COLUMN vaccination_types.modifieddate IS 'Modified on';

CREATE TABLE vaccine_administration_mode (
	id integer DEFAULT nextval('vaccine_administration_mode_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE vaccine_administration_mode IS 'administration_mode';

COMMENT ON COLUMN vaccine_administration_mode.id IS 'ID';

COMMENT ON COLUMN vaccine_administration_mode.name IS 'Administration mode';

COMMENT ON COLUMN vaccine_administration_mode.createdby IS 'Created by';

COMMENT ON COLUMN vaccine_administration_mode.createddate IS 'Created on';

COMMENT ON COLUMN vaccine_administration_mode.modifiedby IS 'Modified by';

COMMENT ON COLUMN vaccine_administration_mode.modifieddate IS 'Modified on';

CREATE TABLE vaccine_dilution (
	id integer DEFAULT nextval('vaccine_dilution_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

COMMENT ON TABLE vaccine_dilution IS 'dilution';

COMMENT ON COLUMN vaccine_dilution.id IS 'ID';

COMMENT ON COLUMN vaccine_dilution.name IS 'Diluation';

COMMENT ON COLUMN vaccine_dilution.createdby IS 'Created by';

COMMENT ON COLUMN vaccine_dilution.createddate IS 'Created on';

COMMENT ON COLUMN vaccine_dilution.modifiedby IS 'Modified by';

COMMENT ON COLUMN vaccine_dilution.modifieddate IS 'Modified on';

CREATE TABLE vaccine_diseases (
	id integer DEFAULT nextval('vaccine_diseases_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	description character varying(200),
	displayorder integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE vaccine_distribution_batches (
	id integer DEFAULT nextval('vaccine_distribution_batches_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE vaccine_distribution_batches IS 'vaccine distribution batches';

COMMENT ON COLUMN vaccine_distribution_batches.id IS 'id';

COMMENT ON COLUMN vaccine_distribution_batches.batchid IS 'batchId';

COMMENT ON COLUMN vaccine_distribution_batches.expirydate IS 'expiryDate';

COMMENT ON COLUMN vaccine_distribution_batches.productiondate IS 'productionDate';

COMMENT ON COLUMN vaccine_distribution_batches.manufacturerid IS 'manufacturerId';

COMMENT ON COLUMN vaccine_distribution_batches.donorid IS 'donorId';

COMMENT ON COLUMN vaccine_distribution_batches.receivedate IS 'receiveDate';

COMMENT ON COLUMN vaccine_distribution_batches.productcode IS 'productCode';

COMMENT ON COLUMN vaccine_distribution_batches.fromfacilityid IS 'fromFacilityId';

COMMENT ON COLUMN vaccine_distribution_batches.tofacilityid IS 'toFacilityId';

COMMENT ON COLUMN vaccine_distribution_batches.distributiontypeid IS 'distributionType';

COMMENT ON COLUMN vaccine_distribution_batches.vialsperbox IS 'vialsPerBox';

COMMENT ON COLUMN vaccine_distribution_batches.boxlength IS 'boxLength';

COMMENT ON COLUMN vaccine_distribution_batches.boxwidth IS 'boxWidth';

COMMENT ON COLUMN vaccine_distribution_batches.boxheight IS 'boxHeight';

COMMENT ON COLUMN vaccine_distribution_batches.unitcost IS 'unitCost';

COMMENT ON COLUMN vaccine_distribution_batches.totalcost IS 'totalCost';

COMMENT ON COLUMN vaccine_distribution_batches.purposeid IS 'purposeId';

COMMENT ON COLUMN vaccine_distribution_batches.createdby IS 'createdBy';

COMMENT ON COLUMN vaccine_distribution_batches.createddate IS 'createdDate';

COMMENT ON COLUMN vaccine_distribution_batches.modifiedby IS 'modifiedBy';

COMMENT ON COLUMN vaccine_distribution_batches.modifieddate IS 'modifiedDate';

CREATE TABLE vaccine_distribution_demographics (
	id integer DEFAULT nextval('vaccine_distribution_demographics_id_seq'::regclass) NOT NULL,
	geographiczoneid integer,
	population integer,
	expected_births integer,
	expected_pregnancies integer,
	serving_infants integer,
	surviving_infants integer
);

CREATE TABLE vaccine_distribution_line_items (
	id integer DEFAULT nextval('vaccine_distribution_line_items_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE vaccine_distribution_line_items IS 'vaccine distribution line items';

COMMENT ON COLUMN vaccine_distribution_line_items.id IS 'id';

COMMENT ON COLUMN vaccine_distribution_line_items.distributionbatchid IS 'distributionBatchId';

COMMENT ON COLUMN vaccine_distribution_line_items.quantityreceived IS 'quantityReceived';

COMMENT ON COLUMN vaccine_distribution_line_items.vvmstage IS 'vvmStage';

COMMENT ON COLUMN vaccine_distribution_line_items.confirmed IS 'confirmed';

COMMENT ON COLUMN vaccine_distribution_line_items.comments IS 'comments';

CREATE TABLE vaccine_distribution_parameters (
	id integer DEFAULT nextval('vaccine_distribution_parameters_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_distribution_types (
	id integer NOT NULL,
	colde character varying(50),
	name character varying(250),
	nature character varying(2)
);

CREATE TABLE vaccine_doses (
	id integer DEFAULT nextval('vaccine_doses_id_seq'::regclass) NOT NULL,
	name character varying(100) NOT NULL,
	description character varying(200),
	displayorder integer NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE vaccine_logistics_master_columns (
	id integer DEFAULT nextval('vaccine_logistics_master_columns_id_seq'::regclass) NOT NULL,
	name character varying(200) NOT NULL,
	description character varying(200) NOT NULL,
	label character varying(200) NOT NULL,
	"indicator" character varying(20) NOT NULL,
	displayorder integer NOT NULL,
	mandatory boolean NOT NULL,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE vaccine_product_doses (
	id integer DEFAULT nextval('vaccine_product_doses_id_seq'::regclass) NOT NULL,
	doseid integer NOT NULL,
	programid integer NOT NULL,
	productid integer NOT NULL,
	isactive boolean,
	createdby integer,
	createddate timestamp without time zone DEFAULT now(),
	modifiedby integer,
	modifieddate timestamp without time zone DEFAULT now()
);

CREATE TABLE vaccine_program_logistics_columns (
	id integer DEFAULT nextval('vaccine_program_logistics_columns_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_quantifications (
	id integer DEFAULT nextval('vaccine_quantifications_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE vaccine_quantifications IS 'Parameters to be used for vaccine quantifications';

COMMENT ON COLUMN vaccine_quantifications.id IS 'ID';

COMMENT ON COLUMN vaccine_quantifications.programid IS 'Program';

COMMENT ON COLUMN vaccine_quantifications.quantificationyear IS 'Year';

COMMENT ON COLUMN vaccine_quantifications.vaccinetypeid IS 'Vaccine type';

COMMENT ON COLUMN vaccine_quantifications.productcode IS 'Product';

COMMENT ON COLUMN vaccine_quantifications.targetpopulation IS 'Target population';

COMMENT ON COLUMN vaccine_quantifications.targetpopulationpercent IS 'Target population percentage';

COMMENT ON COLUMN vaccine_quantifications.dosespertarget IS 'Doses per target';

COMMENT ON COLUMN vaccine_quantifications.presentation IS 'Presentation';

COMMENT ON COLUMN vaccine_quantifications.expectedcoverage IS 'Expected coverage';

COMMENT ON COLUMN vaccine_quantifications.wastagerate IS 'Wastage rate';

COMMENT ON COLUMN vaccine_quantifications.administrationmodeid IS 'Administration mode';

COMMENT ON COLUMN vaccine_quantifications.dilutionid IS 'Diluation';

COMMENT ON COLUMN vaccine_quantifications.supplyinterval IS 'Supply interval (months)';

COMMENT ON COLUMN vaccine_quantifications.safetystock IS 'Safety stock';

COMMENT ON COLUMN vaccine_quantifications.leadtime IS 'Lead time';

COMMENT ON COLUMN vaccine_quantifications.createdby IS 'Created by';

COMMENT ON COLUMN vaccine_quantifications.createddate IS 'Created on';

COMMENT ON COLUMN vaccine_quantifications.modifiedby IS 'Modified by';

COMMENT ON COLUMN vaccine_quantifications.modifieddate IS 'Modified on';

CREATE TABLE vaccine_report_adverse_effect_line_items (
	id integer DEFAULT nextval('vaccine_report_adverse_effect_line_items_id_seq'::regclass) NOT NULL,
	reportid integer NOT NULL,
	productid integer NOT NULL,
	"date" date,
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

CREATE TABLE vaccine_report_campaign_line_items (
	id integer DEFAULT nextval('vaccine_report_campaign_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_report_cold_chain_line_items (
	id integer DEFAULT nextval('vaccine_report_cold_chain_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_report_coverage_line_items (
	id integer DEFAULT nextval('vaccine_report_coverage_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_report_disease_line_items (
	id integer DEFAULT nextval('vaccine_report_disease_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_report_logistics_line_items (
	id integer DEFAULT nextval('vaccine_report_logistics_line_items_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_reports (
	id integer DEFAULT nextval('vaccine_reports_id_seq'::regclass) NOT NULL,
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

CREATE TABLE vaccine_storage (
	id integer DEFAULT nextval('vaccine_storage_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE vaccine_storage IS 'Vaccine storage capacity';

COMMENT ON COLUMN vaccine_storage.id IS 'ID';

COMMENT ON COLUMN vaccine_storage.storagetypeid IS 'Storage type';

COMMENT ON COLUMN vaccine_storage.facilityid IS 'Facility';

COMMENT ON COLUMN vaccine_storage.loccode IS 'Storage location code';

COMMENT ON COLUMN vaccine_storage.name IS 'Storage name';

COMMENT ON COLUMN vaccine_storage.temperatureid IS 'Temperature';

CREATE TABLE vaccine_targets (
	id integer DEFAULT nextval('vaccine_targets_id_seq'::regclass) NOT NULL,
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

COMMENT ON TABLE vaccine_targets IS 'Demographics and targets for the vaccine program';

COMMENT ON COLUMN vaccine_targets.id IS 'ID';

COMMENT ON COLUMN vaccine_targets.geographiczoneid IS 'Zone ID';

COMMENT ON COLUMN vaccine_targets.targetyear IS 'Year';

COMMENT ON COLUMN vaccine_targets.population IS 'Population';

COMMENT ON COLUMN vaccine_targets.expectedbirths IS 'Expected births';

COMMENT ON COLUMN vaccine_targets.expectedpregnancies IS 'Expected pregnancies';

COMMENT ON COLUMN vaccine_targets.servinginfants IS 'Serving infants';

COMMENT ON COLUMN vaccine_targets.survivinginfants IS 'Surviving infants';

COMMENT ON COLUMN vaccine_targets.children1yr IS 'Children Below 1 year';

COMMENT ON COLUMN vaccine_targets.children2yr IS 'Children Below 2 year';

COMMENT ON COLUMN vaccine_targets.girls9_13yr IS 'Girls between 9 to 13 years';

COMMENT ON COLUMN vaccine_targets.createdby IS 'Created by';

COMMENT ON COLUMN vaccine_targets.createddate IS 'Created on';

COMMENT ON COLUMN vaccine_targets.modifiedby IS 'Modified by';

COMMENT ON COLUMN vaccine_targets.modifieddate IS 'Modified on';

CREATE TABLE vw_number_rnr_created_by_facility (
	totalstatus bigint,
	status character varying(20),
	geographiczoneid integer,
	geographiczonename character varying(250)
);

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

ALTER TABLE dosage_units
	DROP COLUMN createdby,
	DROP COLUMN modifiedby,
	DROP COLUMN modifieddate;

ALTER TABLE facility_types
	DROP COLUMN createdby,
	DROP COLUMN modifiedby,
	DROP COLUMN modifieddate;

ALTER TABLE program_products
	ADD COLUMN fullsupply boolean;

ALTER TABLE programs
	ADD COLUMN isequipmentconfigured boolean DEFAULT false;

ALTER TABLE requisition_line_items
	ALTER COLUMN maxmonthsofstock TYPE integer /* TYPE change - table: requisition_line_items original: numeric(4,2) new: integer */;

ALTER TABLE epi_inventory_line_items
	DROP COLUMN idealquantitybypacksize;

ALTER TABLE facility_approved_products
	ALTER COLUMN maxmonthsofstock TYPE integer /* TYPE change - table: facility_approved_products original: numeric(4,2) new: integer */;

ALTER TABLE facility_operators
	DROP COLUMN createdby,
	DROP COLUMN modifiedby,
	DROP COLUMN modifieddate;

ALTER TABLE geographic_levels
	DROP COLUMN createdby,
	DROP COLUMN modifiedby,
	DROP COLUMN modifieddate;

ALTER TABLE master_rnr_columns
	ADD COLUMN calculationoption character varying(200) DEFAULT 'DEFAULT'::character varying;

ALTER TABLE orders
	ALTER COLUMN ordernumber SET DEFAULT 0;

ALTER TABLE pod
	ALTER COLUMN ordernumber SET DEFAULT 0;

ALTER TABLE product_forms
	DROP COLUMN createdby,
	DROP COLUMN modifiedby,
	DROP COLUMN modifieddate;

ALTER TABLE program_rnr_columns
	ADD COLUMN calculationoption character varying(200) DEFAULT 'DEFAULT'::character varying;

ALTER TABLE regimen_line_items
	ADD COLUMN skipped boolean DEFAULT false NOT NULL;

ALTER TABLE shipment_line_items
	ADD COLUMN concatenatedorderid character varying(50),
	ADD COLUMN facilitycode character varying(50),
	ADD COLUMN programcode character varying(50),
	ADD COLUMN quantityordered integer,
	ADD COLUMN substitutedproductcode character varying(50),
	ADD COLUMN substitutedproductname character varying(200),
	ADD COLUMN substitutedproductquantityshipped integer,
	ADD COLUMN packsize integer;

ALTER TABLE supply_lines
	ADD COLUMN parentid integer,
	ALTER COLUMN supervisorynodeid DROP NOT NULL;

ALTER TABLE template_parameters
	DROP COLUMN selectsql;

ALTER SEQUENCE alert_facility_stockedout_id_seq
	OWNED BY alert_facility_stockedout.id;

ALTER SEQUENCE alert_requisition_approved_id_seq
	OWNED BY alert_requisition_approved.id;

ALTER SEQUENCE alert_requisition_emergency_id_seq
	OWNED BY alert_requisition_emergency.id;

ALTER SEQUENCE alert_requisition_pending_id_seq
	OWNED BY alert_requisition_pending.id;

ALTER SEQUENCE alert_requisition_rejected_id_seq
	OWNED BY alert_requisition_rejected.id;

ALTER SEQUENCE alert_stockedout_id_seq
	OWNED BY alert_stockedout.id;

ALTER SEQUENCE alert_summary_id_seq
	OWNED BY alert_summary.id;

ALTER SEQUENCE budgets_id_seq
	OWNED BY budgets.id;

ALTER SEQUENCE configuration_settings_id_seq
	OWNED BY configuration_settings.id;

ALTER SEQUENCE countries_id_seq
	OWNED BY countries.id;

ALTER SEQUENCE custom_reports_id_seq
	OWNED BY custom_reports.id;

ALTER SEQUENCE distribution_types_id_seq
	OWNED BY distribution_types.id;

ALTER SEQUENCE donors_id_seq
	OWNED BY donors.id;

ALTER SEQUENCE elmis_help_document_id_seq
	OWNED BY elmis_help_document.id;

ALTER SEQUENCE elmis_help_id_seq
	OWNED BY elmis_help.id;

ALTER SEQUENCE elmis_help_topic_id_seq
	OWNED BY elmis_help_topic.id;

ALTER SEQUENCE elmis_help_topic_roles_id_seq
	OWNED BY elmis_help_topic_roles.id;

ALTER SEQUENCE emergency_requisitions_id_seq
	OWNED BY emergency_requisitions.id;

ALTER SEQUENCE equipment_contract_service_types_id_seq
	OWNED BY equipment_contract_service_types.id;

ALTER SEQUENCE equipment_maintenance_logs_id_seq
	OWNED BY equipment_maintenance_logs.id;

ALTER SEQUENCE equipment_maintenance_requests_id_seq
	OWNED BY equipment_maintenance_requests.id;

ALTER SEQUENCE equipment_operational_status_id_seq
	OWNED BY equipment_operational_status.id;

ALTER SEQUENCE equipment_service_contract_equipments_id_seq
	OWNED BY equipment_service_contract_equipments.id;

ALTER SEQUENCE equipment_service_contract_facilities_id_seq
	OWNED BY equipment_service_contract_facilities.id;

ALTER SEQUENCE equipment_service_contracts_id_seq
	OWNED BY equipment_service_contracts.id;

ALTER SEQUENCE equipment_service_types_id_seq
	OWNED BY equipment_service_types.id;

ALTER SEQUENCE equipment_service_vendor_users_id_seq
	OWNED BY equipment_service_vendor_users.id;

ALTER SEQUENCE equipment_service_vendors_id_seq
	OWNED BY equipment_service_vendors.id;

ALTER SEQUENCE equipment_status_line_items_id_seq
	OWNED BY equipment_status_line_items.id;

ALTER SEQUENCE equipment_types_id_seq
	OWNED BY equipment_types.id;

ALTER SEQUENCE equipments_id_seq
	OWNED BY equipments.id;

ALTER SEQUENCE facility_program_equipments_id_seq
	OWNED BY facility_program_equipments.id;

ALTER SEQUENCE geographic_zone_geojson_id_seq
	OWNED BY geographic_zone_geojson.id;

ALTER SEQUENCE inventory_batches_id_seq
	OWNED BY inventory_batches.id;

ALTER SEQUENCE inventory_transactions_id_seq
	OWNED BY inventory_transactions.id;

ALTER SEQUENCE manufacturers_id_seq
	OWNED BY manufacturers.id;

ALTER SEQUENCE odk_account_id_seq
	OWNED BY odk_account.id;

ALTER SEQUENCE odk_proof_of_delivery_submission_data_id_seq
	OWNED BY odk_proof_of_delivery_submission_data.id;

ALTER SEQUENCE odk_proof_of_delivery_xform_id_seq
	OWNED BY odk_proof_of_delivery_xform.id;

ALTER SEQUENCE odk_stock_status_submission_id_seq
	OWNED BY odk_stock_status_submission.id;

ALTER SEQUENCE odk_submission_data_id_seq
	OWNED BY odk_submission_data.id;

ALTER SEQUENCE odk_submission_id_seq
	OWNED BY odk_submission.id;

ALTER SEQUENCE odk_xform_id_seq
	OWNED BY odk_xform.id;

ALTER SEQUENCE odk_xform_survey_type_id_seq
	OWNED BY odk_xform_survey_type.id;

ALTER SEQUENCE on_hand_id_seq
	OWNED BY on_hand.id;

ALTER SEQUENCE product_mapping_id_seq
	OWNED BY product_mapping.id;

ALTER SEQUENCE program_equipment_products_id_seq
	OWNED BY program_equipment_products.id;

ALTER SEQUENCE program_equipments_id_seq
	OWNED BY program_equipments.id;

ALTER SEQUENCE received_status_id_seq
	OWNED BY received_status.id;

ALTER SEQUENCE sms_id_seq
	OWNED BY sms.id;

ALTER SEQUENCE storage_types_id_seq
	OWNED BY storage_types.id;

ALTER SEQUENCE temperature_id_seq
	OWNED BY temperature.id;

ALTER SEQUENCE transaction_types_id_seq
	OWNED BY transaction_types.id;

ALTER SEQUENCE user_preference_master_id_seq
	OWNED BY user_preference_master.id;

ALTER SEQUENCE vaccination_types_id_seq
	OWNED BY vaccination_types.id;

ALTER SEQUENCE vaccine_administration_mode_id_seq
	OWNED BY vaccine_administration_mode.id;

ALTER SEQUENCE vaccine_dilution_id_seq
	OWNED BY vaccine_dilution.id;

ALTER SEQUENCE vaccine_diseases_id_seq
	OWNED BY vaccine_diseases.id;

ALTER SEQUENCE vaccine_distribution_batches_id_seq
	OWNED BY vaccine_distribution_batches.id;

ALTER SEQUENCE vaccine_distribution_demographics_id_seq
	OWNED BY vaccine_distribution_demographics.id;

ALTER SEQUENCE vaccine_distribution_line_items_id_seq
	OWNED BY vaccine_distribution_line_items.id;

ALTER SEQUENCE vaccine_distribution_parameters_id_seq
	OWNED BY vaccine_distribution_parameters.id;

ALTER SEQUENCE vaccine_doses_id_seq
	OWNED BY vaccine_doses.id;

ALTER SEQUENCE vaccine_logistics_master_columns_id_seq
	OWNED BY vaccine_logistics_master_columns.id;

ALTER SEQUENCE vaccine_product_doses_id_seq
	OWNED BY vaccine_product_doses.id;

ALTER SEQUENCE vaccine_program_logistics_columns_id_seq
	OWNED BY vaccine_program_logistics_columns.id;

ALTER SEQUENCE vaccine_quantifications_id_seq
	OWNED BY vaccine_quantifications.id;

ALTER SEQUENCE vaccine_report_adverse_effect_line_items_id_seq
	OWNED BY vaccine_report_adverse_effect_line_items.id;

ALTER SEQUENCE vaccine_report_campaign_line_items_id_seq
	OWNED BY vaccine_report_campaign_line_items.id;

ALTER SEQUENCE vaccine_report_cold_chain_line_items_id_seq
	OWNED BY vaccine_report_cold_chain_line_items.id;

ALTER SEQUENCE vaccine_report_coverage_line_items_id_seq
	OWNED BY vaccine_report_coverage_line_items.id;

ALTER SEQUENCE vaccine_report_disease_line_items_id_seq
	OWNED BY vaccine_report_disease_line_items.id;

ALTER SEQUENCE vaccine_report_logistics_line_items_id_seq
	OWNED BY vaccine_report_logistics_line_items.id;

ALTER SEQUENCE vaccine_reports_id_seq
	OWNED BY vaccine_reports.id;

ALTER SEQUENCE vaccine_storage_id_seq
	OWNED BY vaccine_storage.id;

ALTER SEQUENCE vaccine_targets_id_seq
	OWNED BY vaccine_targets.id;

CREATE OR REPLACE FUNCTION fn_changeproductcodes() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_current_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_delete_rnr(in_rnrid integer) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_dw_scheduler() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_get_geozonetree(in_facilityid integer) RETURNS TABLE(districtid integer, regionid integer, zoneid integer)
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

CREATE OR REPLACE FUNCTION fn_get_max_mos(v_program integer, v_facility integer, v_product character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_get_notification_details(_tbl_name anyelement, id integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) || ' where alertsummaryid = '||id;
END
$$;

CREATE OR REPLACE FUNCTION fn_get_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) ||
' where programId = '||programId ||' and periodId= '||periodId||
'and geographiczoneid in (select geographiczoneid from fn_get_user_geographiczone_children('||userId||', '||zoneId||'))';
END
$$;

CREATE OR REPLACE FUNCTION fn_get_parent_geographiczone(v_geographiczoneid integer, v_level integer) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_get_program_product_id(v_program integer, v_product integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
v_ret integer;
BEGIN
SELECT id into v_ret FROM program_products where programid = v_program and productid = v_product;
return v_ret;
END;
$$;

CREATE OR REPLACE FUNCTION fn_get_reporting_status_by_facilityid_programid_and_periodid(v_facilityid integer, v_programid integer, v_periodid integer) RETURNS text
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

CREATE OR REPLACE FUNCTION fn_get_stocked_out_notification_details(_tbl_name anyelement, userid integer, programid integer, periodid integer, zoneid integer, productid integer) RETURNS SETOF anyelement
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || pg_typeof(_tbl_name) ||
' where programId = '||programId ||' and periodId= '||periodId||' and productId= '||productId||
'and geographiczoneid in (select geographiczoneid from fn_get_user_geographiczone_children('||userId||', '||zoneId||'))';
END
$$;

CREATE OR REPLACE FUNCTION fn_get_supervisorynodeid_by_facilityid(v_facilityid integer) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_get_supplying_facility_name(v_supervisorynode_id integer) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_get_user_default_settings(in_programid integer, in_facilityid integer) RETURNS TABLE(programid integer, facilityid integer, scheduleid integer, periodid integer, geographiczoneid integer)
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

CREATE OR REPLACE FUNCTION fn_get_user_geographiczone_children(in_userid integer, in_parentid integer) RETURNS TABLE(geographiczoneid integer, levelid integer, parentid integer)
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

CREATE OR REPLACE FUNCTION fn_getstockstatusgraphdata(in_programid integer, in_geographiczoneid integer, in_periodid integer, in_productid character varying) RETURNS TABLE(productid integer, productname text, periodid integer, periodname text, periodyear integer, quantityonhand integer, quantityconsumed integer, amc integer)
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

CREATE OR REPLACE FUNCTION fn_populate_alert_facility_stockedout() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_populate_alert_requisition_approved() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_populate_alert_requisition_emergency() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_populate_alert_requisition_pending() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_populate_alert_requisition_rejected() RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_populate_dw_orders(in_flag integer) RETURNS character varying
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

COMMENT ON FUNCTION fn_populate_dw_orders(in_flag integer) IS 'populated data in dw_orders table - a flat table to store requisition, stock status, reporting status
References:
dw_orders - table
pod - table
vw_requisition_detail - view
shipment_line_items - table
returns success message on success
returns error message on failure
';

CREATE OR REPLACE FUNCTION fn_populate_dw_rnr() RETURNS trigger
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

CREATE OR REPLACE FUNCTION fn_previous_cb(v_rnr_id integer, v_productcode character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_previous_cb(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_previous_pd(v_rnr_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_previous_period(v_program_id integer, v_facility_id integer, v_period_id integer, v_productcode character varying) RETURNS integer
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

CREATE OR REPLACE FUNCTION fn_previous_rnr_detail(v_program_id integer, v_period_id integer, v_facility_id integer, v_productcode character varying) RETURNS TABLE(rnrid integer, productcode character varying, beginningbalance integer, quantityreceived integer, quantitydispensed integer, stockinhand integer, quantityrequested integer, calculatedorderquantity integer, quantityapproved integer, totallossesandadjustments integer, reportingdays integer, previousstockinhand integer, periodnormalizedconsumption integer, amc integer)
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

CREATE OR REPLACE FUNCTION fn_save_user_preference(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_save_user_preference2(in_userid integer, in_programid integer, in_facilityid integer, in_productid character varying) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_set_user_preference(in_userid integer, in_key character varying, in_value character varying) RETURNS character varying
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

CREATE OR REPLACE FUNCTION fn_tbl_user_attributes(in_user_id integer = NULL::integer, in_user_name character varying = NULL::character varying, in_program_id integer = NULL::integer, in_output text = NULL::text) RETURNS text
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

ALTER TABLE alert_facility_stockedout
	ADD CONSTRAINT alert_facility_stockedout_pkey PRIMARY KEY (id);

ALTER TABLE alert_requisition_approved
	ADD CONSTRAINT alert_requisition_approved_pkey PRIMARY KEY (id);

ALTER TABLE alert_requisition_emergency
	ADD CONSTRAINT alert_requisition_emergency_pkey PRIMARY KEY (id);

ALTER TABLE alert_requisition_pending
	ADD CONSTRAINT alert_requisition_pending_pk PRIMARY KEY (id);

ALTER TABLE alert_requisition_rejected
	ADD CONSTRAINT alert_requisition_rejected_pk PRIMARY KEY (id);

ALTER TABLE alert_stockedout
	ADD CONSTRAINT alert_stockedout_pkey PRIMARY KEY (id);

ALTER TABLE alert_summary
	ADD CONSTRAINT alert_summary_pkey PRIMARY KEY (id);

ALTER TABLE alerts
	ADD CONSTRAINT alerts_pk PRIMARY KEY (alerttype);

ALTER TABLE budgets
	ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);

ALTER TABLE configuration_settings
	ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (id);

ALTER TABLE countries
	ADD CONSTRAINT countries_pkey PRIMARY KEY (id);

ALTER TABLE custom_reports
	ADD CONSTRAINT custom_reports_pkey PRIMARY KEY (id);

ALTER TABLE distribution_types
	ADD CONSTRAINT distribution_types_pkey PRIMARY KEY (id);

ALTER TABLE donors
	ADD CONSTRAINT donors_pkey PRIMARY KEY (id);

ALTER TABLE elmis_help
	ADD CONSTRAINT elmis_help_pkey PRIMARY KEY (id);

ALTER TABLE elmis_help_document
	ADD CONSTRAINT elmis_help_document_pkey PRIMARY KEY (id);

ALTER TABLE elmis_help_topic
	ADD CONSTRAINT elmis_help_topic_pkey PRIMARY KEY (id);

ALTER TABLE elmis_help_topic_roles
	ADD CONSTRAINT elmis_help_topic_roles_pkey PRIMARY KEY (id);

ALTER TABLE emergency_requisitions
	ADD CONSTRAINT emergency_requisitions_pkey PRIMARY KEY (id);

ALTER TABLE equipment_contract_service_types
	ADD CONSTRAINT equipment_contract_service_types_pkey PRIMARY KEY (id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_pkey PRIMARY KEY (id);

ALTER TABLE equipment_maintenance_requests
	ADD CONSTRAINT equipment_maintenance_requests_pkey PRIMARY KEY (id);

ALTER TABLE equipment_operational_status
	ADD CONSTRAINT equipment_operational_status_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_contract_equipments
	ADD CONSTRAINT equipment_service_contract_equipments_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_contract_facilities
	ADD CONSTRAINT equipment_service_contract_facilities_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_contracts
	ADD CONSTRAINT equipment_service_contracts_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_types
	ADD CONSTRAINT equipment_service_types_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_vendor_users
	ADD CONSTRAINT equipment_service_vendor_users_pkey PRIMARY KEY (id);

ALTER TABLE equipment_service_vendors
	ADD CONSTRAINT equipment_service_vendors_pkey PRIMARY KEY (id);

ALTER TABLE equipment_status_line_items
	ADD CONSTRAINT equipment_status_line_items_pkey PRIMARY KEY (id);

ALTER TABLE equipment_types
	ADD CONSTRAINT equipment_types_pkey PRIMARY KEY (id);

ALTER TABLE equipments
	ADD CONSTRAINT equipments_pkey PRIMARY KEY (id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_pkey PRIMARY KEY (id);

ALTER TABLE geographic_zone_geojson
	ADD CONSTRAINT geographic_zone_geojson_pkey PRIMARY KEY (id);

ALTER TABLE inventory_batches
	ADD CONSTRAINT inventory_batches_pkey PRIMARY KEY (id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_pkey PRIMARY KEY (id);

ALTER TABLE manufacturers
	ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);

ALTER TABLE migration_schema_version
	ADD CONSTRAINT migration_schema_version_primary_key PRIMARY KEY (version);

ALTER TABLE odk_account
	ADD CONSTRAINT odk_account_pkey PRIMARY KEY (id);

ALTER TABLE odk_proof_of_delivery_submission_data
	ADD CONSTRAINT odk_proof_of_delivery_submission_data_pkey PRIMARY KEY (id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_xform_pkey PRIMARY KEY (id);

ALTER TABLE odk_stock_status_submission
	ADD CONSTRAINT odk_stock_status_submission_pkey PRIMARY KEY (id);

ALTER TABLE odk_submission
	ADD CONSTRAINT odk_submission_pkey PRIMARY KEY (id);

ALTER TABLE odk_submission_data
	ADD CONSTRAINT odk_submission_data_pkey PRIMARY KEY (id);

ALTER TABLE odk_xform
	ADD CONSTRAINT odk_xform_pkey PRIMARY KEY (id);

ALTER TABLE odk_xform_survey_type
	ADD CONSTRAINT odk_xform_survey_type_pkey PRIMARY KEY (id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_pkey PRIMARY KEY (id);

ALTER TABLE product_mapping
	ADD CONSTRAINT product_mapping_pkey PRIMARY KEY (id);

ALTER TABLE program_equipment_products
	ADD CONSTRAINT program_equipment_products_pkey PRIMARY KEY (id);

ALTER TABLE program_equipments
	ADD CONSTRAINT program_equipments_pkey PRIMARY KEY (id);

ALTER TABLE received_status
	ADD CONSTRAINT received_status_pkey PRIMARY KEY (id);

ALTER TABLE sms
	ADD CONSTRAINT sms_pkey PRIMARY KEY (id);

ALTER TABLE storage_types
	ADD CONSTRAINT storage_types_pkey PRIMARY KEY (id);

ALTER TABLE temperature
	ADD CONSTRAINT temperature_pkey PRIMARY KEY (id);

ALTER TABLE transaction_types
	ADD CONSTRAINT transaction_types_pkey PRIMARY KEY (id);

ALTER TABLE user_preference_master
	ADD CONSTRAINT user_preference_master_pkey PRIMARY KEY (id);

ALTER TABLE vaccination_types
	ADD CONSTRAINT vaccination_types_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_administration_mode
	ADD CONSTRAINT vaccine_administration_mode_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_dilution
	ADD CONSTRAINT vaccine_dilution_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_diseases
	ADD CONSTRAINT vaccine_diseases_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_distribution_demographics
	ADD CONSTRAINT vaccine_distribution_demographics_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_distribution_line_items
	ADD CONSTRAINT vaccine_distribution_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_distribution_parameters
	ADD CONSTRAINT vaccine_distribution_parameters_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_distribution_types
	ADD CONSTRAINT vaccine_distribution_types_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_doses
	ADD CONSTRAINT vaccine_doses_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_logistics_master_columns
	ADD CONSTRAINT vaccine_logistics_master_columns_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_product_doses
	ADD CONSTRAINT vaccine_product_doses_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_program_logistics_columns
	ADD CONSTRAINT vaccine_program_logistics_columns_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_quantifications
	ADD CONSTRAINT vaccine_quantifications_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_adverse_effect_line_items
	ADD CONSTRAINT vaccine_report_adverse_effect_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_campaign_line_items
	ADD CONSTRAINT vaccine_report_campaign_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_cold_chain_line_items
	ADD CONSTRAINT vaccine_report_cold_chain_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_coverage_line_items
	ADD CONSTRAINT vaccine_report_coverage_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_disease_line_items
	ADD CONSTRAINT vaccine_report_disease_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_report_logistics_line_items
	ADD CONSTRAINT vaccine_report_logistics_line_items_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_reports
	ADD CONSTRAINT vaccine_reports_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_storage
	ADD CONSTRAINT vaccine_storage_pkey PRIMARY KEY (id);

ALTER TABLE vaccine_targets
	ADD CONSTRAINT vaccine_targets_pkey PRIMARY KEY (id);

ALTER TABLE budgets
	ADD CONSTRAINT budgets_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE budgets
	ADD CONSTRAINT budgets_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);

ALTER TABLE budgets
	ADD CONSTRAINT budgets_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE custom_reports
	ADD CONSTRAINT custom_reports_reportkey_key UNIQUE (reportkey);

ALTER TABLE distribution_types
	ADD CONSTRAINT distribution_types_name_key UNIQUE (name);

ALTER TABLE donors
	ADD CONSTRAINT donors_code_key UNIQUE (code);

ALTER TABLE elmis_help
	ADD CONSTRAINT elmis_help_helptopicid_fkey FOREIGN KEY (helptopicid) REFERENCES elmis_help_topic(id);

ALTER TABLE elmis_help
	ADD CONSTRAINT fk_user_help_modifier FOREIGN KEY (modifiedby) REFERENCES users(id);

ALTER TABLE elmis_help_topic
	ADD CONSTRAINT elmis_help_topic_parent_help_topic_id_fkey FOREIGN KEY (parent_help_topic_id) REFERENCES elmis_help_topic(id);

ALTER TABLE elmis_help_topic
	ADD CONSTRAINT fk_foreign_users_modifier FOREIGN KEY (modifiedby) REFERENCES users(id);

ALTER TABLE elmis_help_topic
	ADD CONSTRAINT fk_foreing_users_creator FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE elmis_help_topic_roles
	ADD CONSTRAINT elmis_help_topic_roles_help_topic_id_fkey FOREIGN KEY (help_topic_id) REFERENCES elmis_help_topic(id);

ALTER TABLE elmis_help_topic_roles
	ADD CONSTRAINT elmis_help_topic_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);

ALTER TABLE equipment_contract_service_types
	ADD CONSTRAINT equipment_contract_service_types_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);

ALTER TABLE equipment_contract_service_types
	ADD CONSTRAINT equipment_contract_service_types_servicetypeid_fkey FOREIGN KEY (servicetypeid) REFERENCES equipment_service_types(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_requestid_fkey FOREIGN KEY (requestid) REFERENCES equipment_maintenance_requests(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE equipment_maintenance_logs
	ADD CONSTRAINT equipment_maintenance_logs_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);

ALTER TABLE equipment_maintenance_requests
	ADD CONSTRAINT equipment_maintenance_requests_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE equipment_maintenance_requests
	ADD CONSTRAINT equipment_maintenance_requests_inventoryid_fkey FOREIGN KEY (inventoryid) REFERENCES facility_program_equipments(id);

ALTER TABLE equipment_maintenance_requests
	ADD CONSTRAINT equipment_maintenance_requests_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE equipment_maintenance_requests
	ADD CONSTRAINT equipment_maintenance_requests_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);

ALTER TABLE equipment_service_contract_equipments
	ADD CONSTRAINT equipment_service_contract_equipments_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);

ALTER TABLE equipment_service_contract_equipments
	ADD CONSTRAINT equipment_service_contract_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);

ALTER TABLE equipment_service_contract_facilities
	ADD CONSTRAINT equipment_service_contract_facilities_contractid_fkey FOREIGN KEY (contractid) REFERENCES equipment_service_contracts(id);

ALTER TABLE equipment_service_contract_facilities
	ADD CONSTRAINT equipment_service_contract_facilities_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE equipment_service_contracts
	ADD CONSTRAINT equipment_service_contracts_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);

ALTER TABLE equipment_service_vendor_users
	ADD CONSTRAINT equipment_service_vendor_users_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE equipment_service_vendor_users
	ADD CONSTRAINT equipment_service_vendor_users_vendorid_fkey FOREIGN KEY (vendorid) REFERENCES equipment_service_vendors(id);

ALTER TABLE equipment_status_line_items
	ADD CONSTRAINT equipment_status_line_items_equipmentinventoryid_fkey FOREIGN KEY (equipmentinventoryid) REFERENCES facility_program_equipments(id);

ALTER TABLE equipment_status_line_items
	ADD CONSTRAINT equipment_status_line_items_operationalstatusid_fkey FOREIGN KEY (operationalstatusid) REFERENCES equipment_operational_status(id);

ALTER TABLE equipment_status_line_items
	ADD CONSTRAINT equipment_status_line_items_rnrid_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);

ALTER TABLE equipment_types
	ADD CONSTRAINT equipment_types_code_key UNIQUE (code);

ALTER TABLE equipments
	ADD CONSTRAINT equipments_code_key UNIQUE (code);

ALTER TABLE equipments
	ADD CONSTRAINT equipments_equipmenttypeid_fkey FOREIGN KEY (equipmenttypeid) REFERENCES equipment_types(id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_operationalstatusid_fkey FOREIGN KEY (operationalstatusid) REFERENCES equipment_operational_status(id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_primarydonorid_fkey FOREIGN KEY (primarydonorid) REFERENCES donors(id);

ALTER TABLE facility_program_equipments
	ADD CONSTRAINT facility_program_equipments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE inventory_batches
	ADD CONSTRAINT inventory_batches_transactionid_fkey FOREIGN KEY (transactionid) REFERENCES inventory_transactions(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_donorid_fkey FOREIGN KEY (donorid) REFERENCES donors(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_fromfacilityid_fkey FOREIGN KEY (fromfacilityid) REFERENCES facilities(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_locationid_fkey FOREIGN KEY (locationid) REFERENCES vaccine_storage(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_origincountryid_fkey FOREIGN KEY (origincountryid) REFERENCES countries(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_statusid_fkey FOREIGN KEY (statusid) REFERENCES received_status(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_tofacilityid_fkey FOREIGN KEY (tofacilityid) REFERENCES facilities(id);

ALTER TABLE inventory_transactions
	ADD CONSTRAINT inventory_transactions_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);

ALTER TABLE migration_schema_version
	ADD CONSTRAINT migration_schema_version_script_unique UNIQUE (script);

ALTER TABLE odk_proof_of_delivery_submission_data
	ADD CONSTRAINT odk_proof_of_delivery_submission_data_product_id_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE odk_proof_of_delivery_submission_data
	ADD CONSTRAINT odk_proof_of_delivery_submission_data_rnr_id_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_district_id_fkey FOREIGN KEY (districtid) REFERENCES geographic_zones(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_facility_id_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_odk_xform_id_fkey FOREIGN KEY (odkxformid) REFERENCES odk_xform(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_period_id_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_program_id_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE odk_proof_of_delivery_xform
	ADD CONSTRAINT odk_proof_of_delivery_rnr_id_fkey FOREIGN KEY (rnrid) REFERENCES requisitions(id);

ALTER TABLE odk_stock_status_submission
	ADD CONSTRAINT odk_stock_status_submission_submission_id_fkey FOREIGN KEY (odksubmissionid) REFERENCES odk_submission(id);

ALTER TABLE odk_submission
	ADD CONSTRAINT odk_account_id_fkey FOREIGN KEY (odkaccountid) REFERENCES odk_account(id);

ALTER TABLE odk_submission_data
	ADD CONSTRAINT odk_submission_id_fkey FOREIGN KEY (odksubmissionid) REFERENCES odk_submission(id);

ALTER TABLE odk_xform
	ADD CONSTRAINT odk_xform_formid_key UNIQUE (formid);

ALTER TABLE odk_xform
	ADD CONSTRAINT odk_xform_odk_xform_survey_type_fk FOREIGN KEY (odkxformsurveytypeid) REFERENCES odk_xform_survey_type(id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_batchnumber_fkey FOREIGN KEY (batchnumber) REFERENCES inventory_batches(id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_transactionid_fkey FOREIGN KEY (transactionid) REFERENCES inventory_transactions(id);

ALTER TABLE on_hand
	ADD CONSTRAINT on_hand_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);

ALTER TABLE product_mapping
	ADD CONSTRAINT product_mapping_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);

ALTER TABLE product_mapping
	ADD CONSTRAINT product_mapping_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);

ALTER TABLE program_equipment_products
	ADD CONSTRAINT program_equipment_products_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE program_equipment_products
	ADD CONSTRAINT program_equipment_products_programequipmentid_fkey FOREIGN KEY (programequipmentid) REFERENCES program_equipments(id);

ALTER TABLE program_equipments
	ADD CONSTRAINT program_equipments_equipmentid_fkey FOREIGN KEY (equipmentid) REFERENCES equipments(id);

ALTER TABLE program_equipments
	ADD CONSTRAINT program_equipments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE received_status
	ADD CONSTRAINT received_status_transactiontypeid_fkey FOREIGN KEY (transactiontypeid) REFERENCES transaction_types(id);

ALTER TABLE supply_lines
	ADD CONSTRAINT supply_lines_parentid_fkey FOREIGN KEY (parentid) REFERENCES supply_lines(id);

ALTER TABLE user_preference_master
	ADD CONSTRAINT user_preference_master_key_key UNIQUE (key);

ALTER TABLE user_preference_roles
	ADD CONSTRAINT user_preference_roles_roleid_fkey FOREIGN KEY (roleid) REFERENCES roles(id);

ALTER TABLE user_preference_roles
	ADD CONSTRAINT user_preference_roles_userpreferencekey_fkey FOREIGN KEY (userpreferencekey) REFERENCES user_preference_master(key);

ALTER TABLE user_preferences
	ADD CONSTRAINT user_preferences_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);

ALTER TABLE user_preferences
	ADD CONSTRAINT user_preferences_userpreferencekey_fkey FOREIGN KEY (userpreferencekey) REFERENCES user_preference_master(key);

ALTER TABLE vaccination_types
	ADD CONSTRAINT vaccination_types_name_key UNIQUE (name);

ALTER TABLE vaccine_administration_mode
	ADD CONSTRAINT vaccine_administration_mode_name_key UNIQUE (name);

ALTER TABLE vaccine_dilution
	ADD CONSTRAINT vaccine_dilution_name_key UNIQUE (name);

ALTER TABLE vaccine_diseases
	ADD CONSTRAINT vaccine_diseases_name_key UNIQUE (name);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_distributiontypeid_fkey FOREIGN KEY (distributiontypeid) REFERENCES distribution_types(name);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_donorid_fkey FOREIGN KEY (donorid) REFERENCES donors(id);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_fromfacilityid_fkey FOREIGN KEY (fromfacilityid) REFERENCES facilities(id);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_manufacturerid_fkey FOREIGN KEY (manufacturerid) REFERENCES manufacturers(id);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);

ALTER TABLE vaccine_distribution_batches
	ADD CONSTRAINT vaccine_distribution_batches_tofacilityid_fkey FOREIGN KEY (tofacilityid) REFERENCES facilities(id);

ALTER TABLE vaccine_distribution_line_items
	ADD CONSTRAINT vaccine_distribution_line_items_distributionbatchid_fkey FOREIGN KEY (distributionbatchid) REFERENCES vaccine_distribution_batches(id);

ALTER TABLE vaccine_doses
	ADD CONSTRAINT vaccine_doses_name_key UNIQUE (name);

ALTER TABLE vaccine_product_doses
	ADD CONSTRAINT vaccine_product_doses_doseid_fkey FOREIGN KEY (doseid) REFERENCES vaccine_doses(id);

ALTER TABLE vaccine_product_doses
	ADD CONSTRAINT vaccine_product_doses_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE vaccine_product_doses
	ADD CONSTRAINT vaccine_product_doses_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE vaccine_program_logistics_columns
	ADD CONSTRAINT vaccine_program_logistics_columns_mastercolumnid_fkey FOREIGN KEY (mastercolumnid) REFERENCES vaccine_logistics_master_columns(id);

ALTER TABLE vaccine_program_logistics_columns
	ADD CONSTRAINT vaccine_program_logistics_columns_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE vaccine_quantifications
	ADD CONSTRAINT vaccine_quantifications_productcode_fkey FOREIGN KEY (productcode) REFERENCES products(code);

ALTER TABLE vaccine_quantifications
	ADD CONSTRAINT vaccine_quantifications_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE vaccine_report_adverse_effect_line_items
	ADD CONSTRAINT vaccine_report_adverse_effect_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE vaccine_report_adverse_effect_line_items
	ADD CONSTRAINT vaccine_report_adverse_effect_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_report_campaign_line_items
	ADD CONSTRAINT vaccine_report_campaign_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_report_cold_chain_line_items
	ADD CONSTRAINT vaccine_report_cold_chain_line_items_equipmentinventoryid_fkey FOREIGN KEY (equipmentinventoryid) REFERENCES facility_program_equipments(id);

ALTER TABLE vaccine_report_cold_chain_line_items
	ADD CONSTRAINT vaccine_report_cold_chain_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_report_coverage_line_items
	ADD CONSTRAINT vaccine_report_coverage_line_items_doseid_fkey FOREIGN KEY (doseid) REFERENCES vaccine_doses(id);

ALTER TABLE vaccine_report_coverage_line_items
	ADD CONSTRAINT vaccine_report_coverage_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE vaccine_report_coverage_line_items
	ADD CONSTRAINT vaccine_report_coverage_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_report_disease_line_items
	ADD CONSTRAINT vaccine_report_disease_line_items_diseaseid_fkey FOREIGN KEY (diseaseid) REFERENCES vaccine_diseases(id);

ALTER TABLE vaccine_report_disease_line_items
	ADD CONSTRAINT vaccine_report_disease_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_report_logistics_line_items
	ADD CONSTRAINT vaccine_report_logistics_line_items_productid_fkey FOREIGN KEY (productid) REFERENCES products(id);

ALTER TABLE vaccine_report_logistics_line_items
	ADD CONSTRAINT vaccine_report_logistics_line_items_reportid_fkey FOREIGN KEY (reportid) REFERENCES vaccine_reports(id);

ALTER TABLE vaccine_reports
	ADD CONSTRAINT vaccine_reports_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE vaccine_reports
	ADD CONSTRAINT vaccine_reports_periodid_fkey FOREIGN KEY (periodid) REFERENCES processing_periods(id);

ALTER TABLE vaccine_reports
	ADD CONSTRAINT vaccine_reports_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);

ALTER TABLE vaccine_storage
	ADD CONSTRAINT vaccine_storage_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);

ALTER TABLE vaccine_storage
	ADD CONSTRAINT vaccine_storage_storagetypeid_fkey FOREIGN KEY (storagetypeid) REFERENCES storage_types(id);

ALTER TABLE vaccine_storage
	ADD CONSTRAINT vaccine_storage_temperatureid_fkey FOREIGN KEY (temperatureid) REFERENCES temperature(id);

ALTER TABLE vaccine_targets
	ADD CONSTRAINT vaccine_targets_geographiczoneid_fkey FOREIGN KEY (geographiczoneid) REFERENCES geographic_zones(id);

CREATE UNIQUE INDEX uc_countries_lower_name ON countries USING btree (lower((name)::text));

COMMENT ON INDEX uc_countries_lower_name IS 'Unique country name required';

CREATE UNIQUE INDEX uc_distribution_types_lower_name ON distribution_types USING btree (lower((name)::text));

COMMENT ON INDEX uc_distribution_types_lower_name IS 'Unique storage type required';

CREATE UNIQUE INDEX unique_donor_code_index ON donors USING btree (code);

CREATE INDEX dw_orders_index_facility ON dw_orders USING btree (facilityid);

CREATE INDEX dw_orders_index_period ON dw_orders USING btree (periodid);

CREATE INDEX dw_orders_index_product ON dw_orders USING btree (productid);

CREATE INDEX dw_orders_index_prog ON dw_orders USING btree (programid);

CREATE INDEX dw_orders_index_schedule ON dw_orders USING btree (scheduleid);

CREATE INDEX dw_orders_index_status ON dw_orders USING btree (status);

CREATE INDEX dw_orders_index_zone ON dw_orders USING btree (geographiczoneid);

CREATE INDEX i_dw_orders_stockedoutinpast ON dw_orders USING btree (stockedoutinpast);

CREATE UNIQUE INDEX uc_processing_period_name_scheduleid ON processing_periods USING btree (lower((name)::text), scheduleid, date_part('year'::text, startdate));

CREATE UNIQUE INDEX unique_equipment_type_code_index ON equipment_types USING btree (code);

CREATE UNIQUE INDEX unique_equipment_code ON equipments USING btree (code);

CREATE UNIQUE INDEX uc_manufacturers_lower_name ON manufacturers USING btree (lower((name)::text));

CREATE INDEX migration_schema_version_current_version_index ON migration_schema_version USING btree (current_version);

CREATE UNIQUE INDEX unique_program_equipment_product_index ON program_equipment_products USING btree (programequipmentid, productid);

CREATE UNIQUE INDEX unique_program_equipment_index ON program_equipments USING btree (programid, equipmentid);

CREATE UNIQUE INDEX uc_received_status_lower_name ON received_status USING btree (lower((name)::text));

COMMENT ON INDEX uc_received_status_lower_name IS 'Unique shipment received status required';

CREATE UNIQUE INDEX uc_storage_types_lower_name ON storage_types USING btree (lower((storagetypename)::text));

COMMENT ON INDEX uc_storage_types_lower_name IS 'Unique storage type required';

CREATE UNIQUE INDEX uc_temperature_lower_name ON temperature USING btree (lower((temperaturename)::text));

COMMENT ON INDEX uc_temperature_lower_name IS 'Unique temperature required';

CREATE UNIQUE INDEX uc_transaction_types_lower_name ON transaction_types USING btree (lower((name)::text));

COMMENT ON INDEX uc_transaction_types_lower_name IS 'Unique transaction types required';

CREATE UNIQUE INDEX uc_vaccination_types_lower_name ON vaccination_types USING btree (lower((name)::text));

COMMENT ON INDEX uc_vaccination_types_lower_name IS 'Unique vaccination type required';

CREATE UNIQUE INDEX uc_administration_mode_lower_name ON vaccine_administration_mode USING btree (lower((name)::text));

COMMENT ON INDEX uc_administration_mode_lower_name IS 'Unique administration mode required';

CREATE UNIQUE INDEX uc_dilution_lower_name ON vaccine_dilution USING btree (lower((name)::text));

COMMENT ON INDEX uc_dilution_lower_name IS 'Unique dilution required';

CREATE UNIQUE INDEX uc_vaccine_quantifications_year ON vaccine_quantifications USING btree (programid, quantificationyear, vaccinetypeid, productcode);

COMMENT ON INDEX uc_vaccine_quantifications_year IS 'One vaccine quantification parameter per year allowed';

CREATE UNIQUE INDEX uc_vaccine_storage_code ON vaccine_storage USING btree (loccode);

COMMENT ON INDEX uc_vaccine_storage_code IS 'Unique code required for storage location';

CREATE UNIQUE INDEX uc_vaccine_targets_year ON vaccine_targets USING btree (geographiczoneid, targetyear);

COMMENT ON INDEX uc_vaccine_targets_year IS 'One target per geographic zone allowed';

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

COMMENT ON VIEW dw_product_lead_time_vw IS 'dw_product_lead_time_vw-
calculate product shipping lead time - Total days from the day order submitted to received
Filters: Geographic zone id (district), periodid, program
created March 14, 2014 wolde';

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

CREATE VIEW vw_user_districts AS
	SELECT DISTINCT vw_user_facilities.user_id,
    vw_user_facilities.district_id,
    vw_user_facilities.program_id
   FROM vw_user_facilities;

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

COMMENT ON VIEW vw_user_program_facilities IS 'This view combines information from users, user_assignments, programs, facilities. This is used in user related stored functions. If using directly, please use DISTINCT ON to get distrinct list';

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

COMMENT ON VIEW vw_user_role_program_rg IS 'This view combines information from user, role, role_assignment, program, requisition_group. This view is used in user related stored function. If using directly, make sure you use DISTINCT ON';

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
