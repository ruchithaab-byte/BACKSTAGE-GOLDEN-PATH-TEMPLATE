-- ============================================================================
-- COMPLETE HIMS PLATFORM SCHEMA
-- Generated from production schema export (2025-12-22)
-- ============================================================================
-- 
-- This migration creates the complete HIMS Platform database schema:
-- - All 14 schemas (core, clinical, billing, abdm, laboratory, etc.)
-- - All 147+ tables with proper structure
-- - All indexes, constraints, RLS policies
-- - All functions, triggers, views
-- - Complete and production-ready
-- 
-- This is a comprehensive schema script for initial database setup.
-- For future changes, use incremental migrations (V002, V003, etc.).
-- ============================================================================

SET search_path TO public;

--
-- Name: abdm; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS abdm;


--
-- Name: billing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS billing;


--
-- Name: blood_bank; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS blood_bank;


--
-- Name: clinical; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS clinical;


--
-- Name: communication; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS communication;


--
-- Name: core; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS core;


--
-- Name: documents; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS documents;


--
-- Name: imaging; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS imaging;


--
-- Name: integration; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS integration;


--
-- Name: inventory; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS inventory;


--
-- Name: laboratory; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS laboratory;


--
-- Name: scheduling; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS scheduling;


--
-- Name: terminology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS terminology;


--
-- Name: warehouse; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS warehouse;


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: claim_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.claim_status AS ENUM (
    'draft',
    'submitted',
    'processing',
    'approved',
    'rejected',
    'appealed',
    'settled'
);


--
-- Name: data_sovereignty_region; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.data_sovereignty_region AS ENUM (
    'INDIA_LOCAL',
    'INDIA_GOVT',
    'EU_CENTRAL',
    'US_HIPAA'
);


--
-- Name: dicom_modality; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.dicom_modality AS ENUM (
    'CR',
    'CT',
    'DX',
    'ES',
    'MG',
    'MR',
    'NM',
    'OT',
    'PT',
    'RF',
    'RG',
    'SC',
    'US',
    'XA'
);


--
-- Name: fhir_condition_clinical_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_condition_clinical_status AS ENUM (
    'active',
    'recurrence',
    'relapse',
    'inactive',
    'remission',
    'resolved'
);


--
-- Name: fhir_diagnostic_report_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_diagnostic_report_status AS ENUM (
    'registered',
    'partial',
    'preliminary',
    'final',
    'amended',
    'corrected',
    'appended',
    'cancelled',
    'entered-in-error',
    'unknown'
);


--
-- Name: fhir_encounter_class; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_encounter_class AS ENUM (
    'AMB',
    'IMP',
    'EMER',
    'HH',
    'VR',
    'OBSENC'
);


--
-- Name: fhir_encounter_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_encounter_status AS ENUM (
    'planned',
    'arrived',
    'triaged',
    'in-progress',
    'onleave',
    'finished',
    'cancelled',
    'entered-in-error',
    'unknown'
);


--
-- Name: fhir_gender; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_gender AS ENUM (
    'male',
    'female',
    'other',
    'unknown'
);


--
-- Name: fhir_medication_request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_medication_request_status AS ENUM (
    'active',
    'on-hold',
    'cancelled',
    'completed',
    'entered-in-error',
    'stopped',
    'draft',
    'unknown'
);


--
-- Name: fhir_observation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fhir_observation_status AS ENUM (
    'registered',
    'preliminary',
    'final',
    'amended',
    'corrected',
    'cancelled',
    'entered-in-error',
    'unknown'
);


--
-- Name: invoice_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invoice_status AS ENUM (
    'draft',
    'issued',
    'paid',
    'partially_paid',
    'cancelled',
    'written_off'
);


--
-- Name: stock_transaction_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.stock_transaction_type AS ENUM (
    'purchase',
    'sale',
    'adjustment',
    'return',
    'expired',
    'transfer'
);


--
-- Name: validate_invoice_totals(); Type: FUNCTION; Schema: billing; Owner: -
--

CREATE FUNCTION billing.validate_invoice_totals() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    calculated_total DECIMAL(14,2);
BEGIN
    SELECT COALESCE(SUM(net_amount), 0) INTO calculated_total
    FROM billing.invoice_line_items
    WHERE invoice_id = NEW.id;
    
    IF ABS(calculated_total - NEW.total_amount) > 0.01 THEN
        RAISE EXCEPTION 'Invoice total mismatch: calculated=%, stored=%', 
            calculated_total, NEW.total_amount;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: apply_patient_merge_event(); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.apply_patient_merge_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Apply only on final status
  IF NEW.status = 'merged' THEN
    UPDATE clinical.patients p
    SET merged_into_patient_id = NEW.target_patient_id,
        merged_at = NEW.event_at,
        merged_by = COALESCE(NEW.performed_by, NEW.approved_by, NEW.requested_by),
        is_active = false
    WHERE p.tenant_id = NEW.tenant_id
      AND p.id = NEW.source_patient_id
      AND (p.merged_into_patient_id IS NULL OR p.merged_into_patient_id = NEW.target_patient_id);
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: apply_patient_unmerge_event(); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.apply_patient_unmerge_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_tenant uuid;
  v_target uuid;
  v_source uuid;
BEGIN
  SELECT tenant_id, target_patient_id, source_patient_id
    INTO v_tenant, v_target, v_source
  FROM clinical.patient_merge_events
  WHERE id = NEW.merge_event_id AND event_at = NEW.merge_event_at;

  -- revert patient redirect
  UPDATE clinical.patients p
  SET merged_into_patient_id = NULL,
      merged_at = NULL,
      merged_by = NULL,
      is_active = true
  WHERE p.tenant_id = v_tenant
    AND p.id = v_source
    AND p.merged_into_patient_id = v_target;

  -- mark merge event reverted (idempotent)
  UPDATE clinical.patient_merge_events
  SET status = 'reverted'
  WHERE id = NEW.merge_event_id AND event_at = NEW.merge_event_at
    AND status <> 'reverted';

  RETURN NEW;
END;
$$;


--
-- Name: can_access_sensitive(uuid); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.can_access_sensitive(p_tenant_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT
    public.has_admin_access()
    OR public.has_sensitive_access()
    OR EXISTS (
      SELECT 1
      FROM clinical.break_glass_sessions s
      WHERE s.tenant_id = p_tenant_id
        AND s.user_id = public.current_user_id()
        AND s.status = 'active'
        AND s.expires_at > now()
        AND (s.closed_at IS NULL)
    );
$$;


--
-- Name: enforce_break_glass_user(); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.enforce_break_glass_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_user uuid;
BEGIN
  v_user := public.current_user_id();

  IF v_user IS NULL THEN
    RAISE EXCEPTION 'User context not set. Call SET app.current_user before break-glass operations.'
      USING ERRCODE = '42501';
  END IF;

  -- Auto-set user_id if missing
  IF TG_OP = 'INSERT' AND NEW.user_id IS NULL THEN
    NEW.user_id := v_user;
  END IF;

  -- Non-admin cannot create/modify sessions for other users
  IF NOT public.has_admin_access() AND NEW.user_id IS DISTINCT FROM v_user THEN
    RAISE EXCEPTION 'Cannot create/modify break-glass for another user (row %, session %).',
      NEW.user_id, v_user
      USING ERRCODE = '42501';
  END IF;

  -- user_id immutable
  IF TG_OP = 'UPDATE' AND NEW.user_id IS DISTINCT FROM OLD.user_id THEN
    RAISE EXCEPTION 'user_id is immutable on break-glass session update.'
      USING ERRCODE = '42501';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: get_active_care_team(uuid); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.get_active_care_team(p_encounter_id uuid) RETURNS TABLE(id uuid, tenant_id uuid, encounter_id uuid, patient_id uuid, member_kind text, practitioner_id uuid, user_id uuid, external_member jsonb, role_code text, role_display text, specialty text, is_primary boolean, assigned_by uuid, source text, from_ts timestamp with time zone, to_ts timestamp with time zone, notes text, metadata jsonb, created_at timestamp with time zone, updated_at timestamp with time zone)
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT 
    e.id,
    e.tenant_id,
    e.encounter_id,
    e.patient_id,
    e.member_kind,
    e.practitioner_id,
    e.user_id,
    e.external_member,
    e.role_code,
    e.role_display,
    e.specialty,
    e.is_primary,
    e.assigned_by,
    e.source,
    e.from_ts,
    e.to_ts,
    e.notes,
    e.metadata,
    e.created_at,
    e.updated_at
  FROM clinical.encounter_care_team_members e
  WHERE e.tenant_id = public.current_tenant_id()
    AND e.encounter_id = p_encounter_id
    AND (e.to_ts IS NULL OR e.to_ts > now());
$$;


--
-- Name: FUNCTION get_active_care_team(p_encounter_id uuid); Type: COMMENT; Schema: clinical; Owner: -
--

COMMENT ON FUNCTION clinical.get_active_care_team(p_encounter_id uuid) IS 'Returns active care team members for a given encounter. Automatically filters by current tenant context.';


--
-- Name: is_patient_sensitive(uuid, uuid); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.is_patient_sensitive(p_tenant_id uuid, p_patient_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM clinical.patient_sensitivity s
    WHERE s.tenant_id = p_tenant_id
      AND s.patient_id = p_patient_id
      AND (s.expires_at IS NULL OR s.expires_at > now())
  );
$$;


--
-- Name: is_resource_sensitive(uuid, text, uuid); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.is_resource_sensitive(p_tenant_id uuid, p_resource_type text, p_resource_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM clinical.resource_sensitivity rs
    WHERE rs.tenant_id = p_tenant_id
      AND rs.resource_type = p_resource_type
      AND rs.resource_id = p_resource_id
      AND (rs.expires_at IS NULL OR rs.expires_at > now())
  );
$$;


--
-- Name: log_sensitive_access(text, uuid, uuid, text, text, uuid, jsonb); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.log_sensitive_access(p_resource_type text, p_resource_id uuid, p_patient_id uuid DEFAULT NULL::uuid, p_action text DEFAULT 'read'::text, p_purpose text DEFAULT NULL::text, p_break_glass_session_id uuid DEFAULT NULL::uuid, p_metadata jsonb DEFAULT '{}'::jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_tenant uuid;
  v_user uuid;
BEGIN
  v_tenant := public.current_tenant_id();
  v_user   := public.current_user_id();

  IF v_tenant IS NULL THEN
    RAISE EXCEPTION 'Tenant context not set for log_sensitive_access()'
      USING ERRCODE = '42501';
  END IF;
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'User context not set for log_sensitive_access()'
      USING ERRCODE = '42501';
  END IF;

  INSERT INTO clinical.sensitive_access_log(
    tenant_id, user_id,
    resource_type, resource_id, patient_id,
    action, purpose, break_glass_session_id,
    metadata
  )
  VALUES (
    v_tenant, v_user,
    p_resource_type, p_resource_id, p_patient_id,
    COALESCE(p_action,'read'), p_purpose, p_break_glass_session_id,
    COALESCE(p_metadata,'{}'::jsonb)
  );
END;
$$;


--
-- Name: normalize_encounter_care_team_member(); Type: FUNCTION; Schema: clinical; Owner: -
--

CREATE FUNCTION clinical.normalize_encounter_care_team_member() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_patient_id uuid;
BEGIN
  -- Fetch encounter patient_id
  SELECT e.patient_id
    INTO v_patient_id
  FROM clinical.encounters e
  WHERE e.tenant_id = NEW.tenant_id
    AND e.id = NEW.encounter_id;

  IF v_patient_id IS NULL THEN
    RAISE EXCEPTION 'Invalid encounter_id for tenant in encounter_care_team_members';
  END IF;

  -- Populate patient_id if null
  IF NEW.patient_id IS NULL THEN
    NEW.patient_id := v_patient_id;
  END IF;

  -- Enforce patient match
  IF NEW.patient_id IS DISTINCT FROM v_patient_id THEN
    RAISE EXCEPTION 'patient_id must match encounter.patient_id for tenant % (encounter %, patient %, expected %)',
      NEW.tenant_id, NEW.encounter_id, NEW.patient_id, v_patient_id
      USING ERRCODE = '23514';
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: check_user_limit(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.check_user_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    max_users INT;
    current_users INT;
    custom_limits JSONB;
BEGIN
    -- Get subscription limits
    SELECT ts.custom_limits INTO custom_limits
    FROM core.tenant_subscriptions ts
    WHERE ts.tenant_id = NEW.tenant_id
      AND ts.status = 'active'
    LIMIT 1;
    
    IF custom_limits IS NOT NULL AND custom_limits ? 'max_users' THEN
        max_users := (custom_limits->>'max_users')::INT;
        
        -- Count current active users
        SELECT COUNT(*) INTO current_users
        FROM core.users
        WHERE tenant_id = NEW.tenant_id
          AND is_active = true;
        
        IF current_users >= max_users THEN
            RAISE EXCEPTION 'User limit exceeded: %/% users. Please upgrade your subscription.', 
                current_users, max_users;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


--
-- Name: enforce_retention_policies(); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.enforce_retention_policies() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    policy_record RECORD;
    affected_count INT;
BEGIN
    FOR policy_record IN 
        SELECT * FROM core.retention_policies 
        WHERE is_active = true
    LOOP
        -- Archive or delete based on policy
        -- This is a template - actual implementation depends on archive strategy
        IF policy_record.action = 'delete' THEN
            -- Delete records older than retention period
            EXECUTE format(
                'DELETE FROM %I.%I WHERE %I < NOW() - INTERVAL ''%s days''',
                policy_record.table_schema,
                policy_record.table_name,
                policy_record.date_column,
                policy_record.retention_days
            );
            GET DIAGNOSTICS affected_count = ROW_COUNT;
            
            -- Log the deletion
            INSERT INTO core.audit_logs (
                tenant_id, table_name, action, old_values, occurred_at
            ) VALUES (
                NULL, -- System-level operation
                policy_record.table_name,
                'retention_policy_delete',
                jsonb_build_object('deleted_count', affected_count, 'policy_id', policy_record.id),
                NOW()
            );
        ELSIF policy_record.action = 'archive' THEN
            -- Archive records (implementation depends on archive table structure)
            -- This is a placeholder - implement based on your archive strategy
            RAISE NOTICE 'Archive action not yet implemented for policy %', policy_record.id;
        END IF;
    END LOOP;
END;
$$;


--
-- Name: mask_pii(jsonb); Type: FUNCTION; Schema: core; Owner: -
--

CREATE FUNCTION core.mask_pii(data jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Mask email addresses
    IF data ? 'email' THEN
        data := jsonb_set(data, '{email}', to_jsonb('***@***.***'::text));
    END IF;
    
    -- Mask phone numbers
    IF data ? 'phone' OR data ? 'contact_number' OR data ? 'mobile' THEN
        IF data ? 'phone' THEN
            data := jsonb_set(data, '{phone}', to_jsonb('******'::text));
        END IF;
        IF data ? 'contact_number' THEN
            data := jsonb_set(data, '{contact_number}', to_jsonb('******'::text));
        END IF;
        IF data ? 'mobile' THEN
            data := jsonb_set(data, '{mobile}', to_jsonb('******'::text));
        END IF;
    END IF;
    
    -- Mask Aadhaar numbers (12 digits)
    IF data ? 'aadhaar' OR data ? 'aadhaar_number' THEN
        IF data ? 'aadhaar' THEN
            data := jsonb_set(data, '{aadhaar}', to_jsonb('****-****-****'::text));
        END IF;
        IF data ? 'aadhaar_number' THEN
            data := jsonb_set(data, '{aadhaar_number}', to_jsonb('****-****-****'::text));
        END IF;
    END IF;
    
    RETURN data;
END;
$$;


--
-- Name: get_worklist_entry(uuid); Type: FUNCTION; Schema: imaging; Owner: -
--

CREATE FUNCTION imaging.get_worklist_entry(order_id uuid) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'AccessionNumber', o.accession_number,
        'PatientID', o.patient_mrn,
        'PatientName', o.patient_name,
        'PatientBirthDate', to_char(o.patient_dob, 'YYYYMMDD'),
        'PatientSex', CASE o.patient_gender 
            WHEN 'male' THEN 'M' 
            WHEN 'female' THEN 'F' 
            ELSE 'O' 
        END,
        'ScheduledProcedureStepStartDate', to_char(o.scheduled_date_time, 'YYYYMMDD'),
        'ScheduledProcedureStepStartTime', to_char(o.scheduled_date_time, 'HH24MISS'),
        'Modality', o.modality,
        'ScheduledStationAETitle', o.performing_location,
        'RequestedProcedureDescription', o.procedure_code->'coding'->0->>'display',
        'ReferringPhysicianName', o.requester_name
    ) INTO result
    FROM imaging.imaging_orders o
    WHERE o.id = order_id;
    
    RETURN result;
END;
$$;


--
-- Name: check_tenant_resource_limit(uuid, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_tenant_resource_limit(p_tenant_id uuid, p_resource_type text, p_current_count integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_limit INT;
    v_current INT;
    v_plan_id UUID;
BEGIN
    -- Get subscription limits
    SELECT 
        (ts.custom_limits->>p_resource_type)::INT,
        ts.plan_id
    INTO v_limit, v_plan_id
    FROM core.tenant_subscriptions ts
    WHERE ts.tenant_id = p_tenant_id
      AND ts.status = 'active'
    ORDER BY ts.started_at DESC
    LIMIT 1;
    
    -- If custom limit not set, check plan limits
    IF v_limit IS NULL AND v_plan_id IS NOT NULL THEN
        SELECT 
            CASE p_resource_type
                WHEN 'max_users' THEN sp.max_users
                WHEN 'max_patients' THEN sp.max_patients
                WHEN 'max_locations' THEN sp.max_locations
                ELSE NULL
            END
        INTO v_limit
        FROM core.subscription_plans sp
        WHERE sp.id = v_plan_id;
    END IF;
    
    -- If no limit, allow
    IF v_limit IS NULL THEN
        RETURN true;
    END IF;
    
    -- Get current count if not provided
    IF p_current_count IS NULL THEN
        CASE p_resource_type
            WHEN 'max_users' THEN
                SELECT COUNT(*) INTO v_current FROM core.users WHERE tenant_id = p_tenant_id;
            WHEN 'max_patients' THEN
                SELECT COUNT(*) INTO v_current FROM clinical.patients WHERE tenant_id = p_tenant_id;
            WHEN 'max_locations' THEN
                SELECT COUNT(*) INTO v_current FROM clinical.locations WHERE tenant_id = p_tenant_id;
            ELSE
                v_current := 0;
        END CASE;
    ELSE
        v_current := p_current_count;
    END IF;
    
    -- Check limit
    RETURN v_current < v_limit;
END;
$$;


--
-- Name: FUNCTION check_tenant_resource_limit(p_tenant_id uuid, p_resource_type text, p_current_count integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.check_tenant_resource_limit(p_tenant_id uuid, p_resource_type text, p_current_count integer) IS 'Checks if tenant has reached resource limit based on subscription plan';


--
-- Name: current_org_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_org_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('app.current_org', true), '')::uuid;
$$;


--
-- Name: current_tenant_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_tenant_id() RETURNS uuid
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_tenant', true), '')::UUID;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$;


--
-- Name: current_user_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_user_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('app.current_user', true), '')::uuid;
$$;


--
-- Name: has_admin_access(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_admin_access() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(NULLIF(current_setting('app.admin_access', true), ''), 'false')::boolean;
$$;


--
-- Name: has_sensitive_access(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_sensitive_access() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(NULLIF(current_setting('app.sensitive_access', true), ''), 'false')::boolean;
$$;


--
-- Name: mask_pii(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mask_pii(data jsonb) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    masked_data JSONB := data;
    keys_to_mask TEXT[] := ARRAY['email', 'phone', 'mobile', 'aadhaar_number', 'pan', 'gstin'];
    key TEXT;
BEGIN
    IF masked_data IS NULL THEN
        RETURN NULL;
    END IF;
    
    FOREACH key IN ARRAY keys_to_mask
    LOOP
        IF masked_data ? key THEN
            masked_data := jsonb_set(
                masked_data,
                ARRAY[key],
                to_jsonb('***MASKED***'::text)
            );
        END IF;
    END LOOP;
    
    RETURN masked_data;
END;
$$;


--
-- Name: FUNCTION mask_pii(data jsonb); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.mask_pii(data jsonb) IS 'Masks PII fields in JSONB data for audit logs';


--
-- Name: require_org_context(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.require_org_context() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_org uuid;
BEGIN
  v_org := public.current_org_id();

  IF v_org IS NULL THEN
    RAISE EXCEPTION 'Org context not set. Call SET app.current_org before operations.'
      USING ERRCODE = '42501';
  END IF;

  -- If row has org_id, enforce
  IF TG_OP IN ('INSERT','UPDATE') THEN
    IF NEW.org_id IS NULL THEN
      NEW.org_id := v_org;
    END IF;

    IF NEW.org_id IS DISTINCT FROM v_org THEN
      RAISE EXCEPTION 'Cross-org write blocked on %.% (row org_id %, session org_id %)',
        TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.org_id, v_org
        USING ERRCODE = '42501';
    END IF;

    IF TG_OP = 'UPDATE' AND NEW.org_id IS DISTINCT FROM OLD.org_id THEN
      RAISE EXCEPTION 'org_id is immutable on UPDATE for %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
        USING ERRCODE = '42501';
    END IF;

    RETURN NEW;
  END IF;

  -- DELETE: allow only if row is in org context (RLS should handle; belt-and-suspenders)
  IF TG_OP = 'DELETE' THEN
    IF OLD.org_id IS DISTINCT FROM v_org THEN
      RAISE EXCEPTION 'Cross-org delete blocked on %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
        USING ERRCODE = '42501';
    END IF;
    RETURN OLD;
  END IF;

  RETURN NULL;
END;
$$;


--
-- Name: require_tenant_context(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.require_tenant_context() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_tenant uuid;
BEGIN
  v_tenant := public.current_tenant_id();

  -- When tenant context is not set:
  -- allow only "global" rows (tenant_id IS NULL) to be inserted/updated/deleted
  IF v_tenant IS NULL THEN
    IF TG_OP = 'INSERT' THEN
      IF NEW.tenant_id IS NOT NULL THEN
        RAISE EXCEPTION 'Tenant context is required for non-global INSERT into %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
          USING ERRCODE = '42501';
      END IF;
      RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
      IF (OLD.tenant_id IS DISTINCT FROM NEW.tenant_id) THEN
        RAISE EXCEPTION 'tenant_id is immutable on UPDATE for %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
          USING ERRCODE = '42501';
      END IF;
      IF NEW.tenant_id IS NOT NULL THEN
        RAISE EXCEPTION 'Tenant context is required for non-global UPDATE on %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
          USING ERRCODE = '42501';
      END IF;
      RETURN NEW;

    ELSE
      -- DELETE
      IF OLD.tenant_id IS NOT NULL THEN
        RAISE EXCEPTION 'Tenant context is required for non-global DELETE on %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME
          USING ERRCODE = '42501';
      END IF;
      RETURN OLD;
    END IF;
  END IF;

  -- Tenant context is set:
  IF TG_OP = 'INSERT' THEN
    IF NEW.tenant_id IS NULL THEN
      NEW.tenant_id := v_tenant;
    END IF;

    IF NEW.tenant_id IS DISTINCT FROM v_tenant THEN
      RAISE EXCEPTION 'Cross-tenant INSERT blocked on %.% (row tenant_id %, session tenant_id %)',
        TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.tenant_id, v_tenant
        USING ERRCODE = '42501';
    END IF;

    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    -- tenant_id immutable
    IF NEW.tenant_id IS DISTINCT FROM OLD.tenant_id THEN
      RAISE EXCEPTION 'tenant_id is immutable on UPDATE for %.% (old %, new %)',
        TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.tenant_id, NEW.tenant_id
        USING ERRCODE = '42501';
    END IF;

    IF NEW.tenant_id IS NOT NULL AND NEW.tenant_id IS DISTINCT FROM v_tenant THEN
      RAISE EXCEPTION 'Cross-tenant UPDATE blocked on %.% (row tenant_id %, session tenant_id %)',
        TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.tenant_id, v_tenant
        USING ERRCODE = '42501';
    END IF;

    RETURN NEW;

  ELSE
    -- DELETE
    IF OLD.tenant_id IS NOT NULL AND OLD.tenant_id IS DISTINCT FROM v_tenant THEN
      RAISE EXCEPTION 'Cross-tenant DELETE blocked on %.% (row tenant_id %, session tenant_id %)',
        TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.tenant_id, v_tenant
        USING ERRCODE = '42501';
    END IF;

    RETURN OLD;
  END IF;
END;
$$;


--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_concept_search(); Type: FUNCTION; Schema: terminology; Owner: -
--

CREATE FUNCTION terminology.update_concept_search() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.search_terms := to_tsvector('english', 
        COALESCE(NEW.display, '') || ' ' || 
        COALESCE(NEW.code, '') || ' ' ||
        COALESCE(array_to_string(NEW.synonyms, ' '), '')
    );
    RETURN NEW;
END;
$$;


SET default_table_access_method = heap;

--
-- Name: abdm_care_contexts; Type: TABLE; Schema: abdm; Owner: -
--

CREATE TABLE abdm.abdm_care_contexts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    care_context_reference character varying(255) NOT NULL,
    care_context_type character varying(50) NOT NULL,
    linking_status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    linked_at timestamp with time zone,
    delinked_at timestamp with time zone,
    delink_reason text,
    abdm_request_id character varying(255),
    notification_sent_date timestamp with time zone,
    notification_status character varying(50),
    abdm_response jsonb,
    hip_id character varying(255),
    hip_name character varying(255),
    hip_facility_id uuid,
    hiu_id character varying(255),
    hiu_name character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY abdm.abdm_care_contexts FORCE ROW LEVEL SECURITY;


--
-- Name: abdm_registrations; Type: TABLE; Schema: abdm; Owner: -
--

CREATE TABLE abdm.abdm_registrations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid,
    abha_number character varying(20),
    abha_address character varying(100),
    creation_method character varying(50) NOT NULL,
    aadhaar_number character varying(12),
    mobile_number character varying(10),
    email character varying(255),
    kyc_status character varying(50) DEFAULT 'pending'::character varying,
    kyc_verified_at timestamp with time zone,
    kyc_verification_method character varying(50),
    guardian_abha_number character varying(20),
    guardian_abha_address character varying(100),
    guardian_relationship character varying(50),
    abdm_request_id character varying(255),
    abdm_response jsonb,
    abdm_error_code character varying(50),
    abdm_error_message text,
    qr_code_url text,
    qr_code_data text,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    verified_at timestamp with time zone,
    created_by uuid
);

ALTER TABLE ONLY abdm.abdm_registrations FORCE ROW LEVEL SECURITY;


--
-- Name: hiu_data_requests; Type: TABLE; Schema: abdm; Owner: -
--

CREATE TABLE abdm.hiu_data_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    hiu_id character varying(255) NOT NULL,
    hiu_name character varying(255),
    hiu_facility_id uuid,
    request_id character varying(255) NOT NULL,
    request_type character varying(50) NOT NULL,
    date_range_start date,
    date_range_end date,
    requested_categories text[] NOT NULL,
    consent_artifact_id character varying(255),
    consent_status character varying(50) DEFAULT 'pending'::character varying,
    consent_granted_at timestamp with time zone,
    consent_expires_at timestamp with time zone,
    status character varying(50) DEFAULT 'pending'::character varying,
    fulfilled_at timestamp with time zone,
    data_shared jsonb,
    fhir_bundle_id character varying(255),
    error_message text,
    abdm_request_id character varying(255),
    abdm_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY abdm.hiu_data_requests FORCE ROW LEVEL SECURITY;


--
-- Name: accounts; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    account_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    account_type character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    patient_id uuid,
    service_period_start timestamp with time zone,
    service_period_end timestamp with time zone,
    owner_type character varying(50),
    owner_id uuid,
    owner_name character varying(255),
    guarantor jsonb DEFAULT '[]'::jsonb,
    coverage jsonb DEFAULT '[]'::jsonb,
    total_charges numeric(14,2) DEFAULT 0,
    total_payments numeric(14,2) DEFAULT 0,
    total_adjustments numeric(14,2) DEFAULT 0,
    balance_amount numeric(14,2) GENERATED ALWAYS AS (((total_charges - total_payments) - total_adjustments)) STORED,
    credit_limit numeric(14,2),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.accounts FORCE ROW LEVEL SECURITY;


--
-- Name: insurance_claims; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.insurance_claims (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    claim_number character varying(50) NOT NULL,
    status public.claim_status DEFAULT 'draft'::public.claim_status NOT NULL,
    claim_type character varying(50) NOT NULL,
    claim_subtype character varying(50),
    patient_id uuid NOT NULL,
    encounter_id uuid,
    insurance_company_id uuid NOT NULL,
    policy_number character varying(100) NOT NULL,
    member_id character varying(100),
    invoice_ids uuid[],
    claim_date date DEFAULT CURRENT_DATE NOT NULL,
    admission_date date,
    discharge_date date,
    diagnosis_codes jsonb DEFAULT '[]'::jsonb,
    procedure_codes jsonb DEFAULT '[]'::jsonb,
    total_claimed numeric(14,2) NOT NULL,
    total_approved numeric(14,2),
    total_rejected numeric(14,2),
    patient_liability numeric(14,2),
    submitted_at timestamp with time zone,
    adjudicated_at timestamp with time zone,
    insurer_claim_number character varying(100),
    adjudication_notes text,
    rejection_reason text,
    payment_reference character varying(100),
    payment_date date,
    documents jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    nhcx_bundle_id character varying(255),
    cpd_status character varying(50),
    cpd_id uuid,
    cpd_remarks text,
    utr_number character varying(100),
    package_code character varying(50),
    beneficiary_id character varying(50),
    bis_verified boolean DEFAULT false,
    bis_verification_date timestamp with time zone
);

ALTER TABLE ONLY billing.insurance_claims FORCE ROW LEVEL SECURITY;


--
-- Name: insurance_companies; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.insurance_companies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    is_tpa boolean DEFAULT false,
    tpa_name character varying(255),
    contact_person character varying(255),
    email character varying(255),
    phone character varying(50),
    address jsonb,
    edi_id character varying(50),
    api_endpoint text,
    price_list_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.insurance_companies FORCE ROW LEVEL SECURITY;


--
-- Name: insurance_policies; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.insurance_policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    insurance_company_id uuid NOT NULL,
    policy_number character varying(100) NOT NULL,
    member_id character varying(100),
    beneficiary_id character varying(50),
    family_id character varying(50),
    wallet_balance numeric(14,2) DEFAULT 0,
    wallet_balance_last_updated timestamp with time zone,
    coverage_type character varying(50),
    scheme_code character varying(50),
    pre_auth_mandatory boolean DEFAULT true,
    pre_auth_amount_limit numeric(14,2),
    valid_from date NOT NULL,
    valid_till date,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY billing.insurance_policies FORCE ROW LEVEL SECURITY;


--
-- Name: invoice_line_items; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoice_line_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    sequence integer NOT NULL,
    charge_item_type character varying(50) NOT NULL,
    service_id uuid,
    item_id uuid,
    code jsonb,
    description character varying(1000) NOT NULL,
    serviced_date date,
    serviced_period jsonb,
    quantity numeric(10,3) DEFAULT 1 NOT NULL,
    unit_of_measure character varying(50),
    unit_price numeric(12,2) NOT NULL,
    gross_amount numeric(14,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0,
    discount_amount numeric(12,2) DEFAULT 0,
    tax_rate numeric(5,2) DEFAULT 0,
    tax_amount numeric(12,2) DEFAULT 0,
    hsn_sac_code character varying(20),
    net_amount numeric(14,2) NOT NULL,
    is_insurance_billable boolean DEFAULT true,
    insurance_covered numeric(12,2) DEFAULT 0,
    patient_share numeric(12,2),
    price_override_reason text,
    performer_id uuid,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.invoice_line_items FORCE ROW LEVEL SECURITY;


--
-- Name: invoices; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    invoice_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    status public.invoice_status DEFAULT 'draft'::public.invoice_status NOT NULL,
    invoice_type character varying(50) NOT NULL,
    patient_id uuid NOT NULL,
    account_id uuid,
    encounter_id uuid,
    invoice_date date DEFAULT CURRENT_DATE NOT NULL,
    due_date date,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    issuer_name character varying(255),
    issuer_address jsonb,
    recipient_name character varying(255) NOT NULL,
    recipient_address jsonb,
    recipient_gstin character varying(20),
    subtotal numeric(14,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(14,2) DEFAULT 0,
    discount_reason text,
    tax_amount numeric(14,2) DEFAULT 0,
    total_amount numeric(14,2) DEFAULT 0 NOT NULL,
    amount_paid numeric(14,2) DEFAULT 0,
    amount_due numeric(14,2) GENERATED ALWAYS AS ((total_amount - amount_paid)) STORED,
    insurance_amount numeric(14,2) DEFAULT 0,
    patient_responsibility numeric(14,2),
    cgst_amount numeric(14,2) DEFAULT 0,
    sgst_amount numeric(14,2) DEFAULT 0,
    igst_amount numeric(14,2) DEFAULT 0,
    price_list_id uuid,
    note jsonb DEFAULT '[]'::jsonb,
    payment_terms text,
    encryption_key_id uuid,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    consent_ref uuid,
    cancelled_at timestamp with time zone,
    cancelled_by uuid,
    cancellation_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT chk_amount_due_non_negative CHECK ((amount_due >= (0)::numeric)),
    CONSTRAINT chk_amount_paid_not_exceed_total CHECK ((amount_paid <= total_amount))
);

ALTER TABLE ONLY billing.invoices FORCE ROW LEVEL SECURITY;


--
-- Name: payment_allocations; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.payment_allocations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    payment_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    amount numeric(14,2) NOT NULL,
    allocated_at timestamp with time zone DEFAULT now() NOT NULL,
    allocated_by uuid
);

ALTER TABLE ONLY billing.payment_allocations FORCE ROW LEVEL SECURITY;


--
-- Name: payments; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    payment_number character varying(50) NOT NULL,
    payment_type character varying(50) NOT NULL,
    patient_id uuid,
    account_id uuid,
    invoice_id uuid,
    payment_date date DEFAULT CURRENT_DATE NOT NULL,
    payment_method character varying(50) NOT NULL,
    amount numeric(14,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    transaction_reference character varying(100),
    bank_name character varying(255),
    bank_reference character varying(100),
    card_type character varying(20),
    card_last_four character varying(4),
    upi_id character varying(100),
    gateway_transaction_id character varying(255),
    gateway_response jsonb,
    gateway_fee numeric(12,2),
    gateway_name character varying(50),
    status character varying(50) DEFAULT 'completed'::character varying NOT NULL,
    original_payment_id uuid,
    refund_reason text,
    receipt_number character varying(50),
    receipt_url text,
    notes text,
    received_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.payments FORCE ROW LEVEL SECURITY;


--
-- Name: pre_authorizations; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.pre_authorizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    admission_id uuid,
    encounter_id uuid,
    insurance_policy_id uuid,
    insurance_company_id uuid NOT NULL,
    preauth_number character varying(50) NOT NULL,
    request_date date DEFAULT CURRENT_DATE NOT NULL,
    amount_requested numeric(14,2) NOT NULL,
    diagnosis_codes jsonb DEFAULT '[]'::jsonb,
    procedure_codes jsonb DEFAULT '[]'::jsonb,
    package_code character varying(50),
    clinical_justification text,
    estimated_duration_days integer,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    ppd_id uuid,
    ppd_remarks text,
    ppd_reviewed_at timestamp with time zone,
    mandatory_docs_uploaded jsonb DEFAULT '[]'::jsonb,
    documents jsonb DEFAULT '[]'::jsonb,
    enhancement_request_count integer DEFAULT 0,
    enhancement_reason text,
    enhancement_amount numeric(14,2),
    approved_amount numeric(14,2),
    approved_package_code character varying(50),
    approval_number character varying(100),
    approval_validity_days integer,
    rejection_reason text,
    query_remarks text,
    nhcx_preauth_id character varying(255),
    abdm_request_id character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY billing.pre_authorizations FORCE ROW LEVEL SECURITY;


--
-- Name: price_list_items; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.price_list_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    price_list_id uuid NOT NULL,
    service_id uuid NOT NULL,
    price numeric(12,2) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0,
    max_covered_amount numeric(12,2),
    co_pay_percent numeric(5,2) DEFAULT 0,
    co_pay_amount numeric(12,2) DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL
);

ALTER TABLE ONLY billing.price_list_items FORCE ROW LEVEL SECURITY;


--
-- Name: price_lists; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.price_lists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price_list_type character varying(50) NOT NULL,
    insurance_company_id uuid,
    corporate_id uuid,
    effective_from date NOT NULL,
    effective_to date,
    discount_percent numeric(5,2) DEFAULT 0,
    markup_percent numeric(5,2) DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.price_lists FORCE ROW LEVEL SECURITY;


--
-- Name: service_masters; Type: TABLE; Schema: billing; Owner: -
--

CREATE TABLE billing.service_masters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(500) NOT NULL,
    description text,
    category character varying(100),
    sub_category character varying(100),
    department character varying(100),
    charge_code jsonb,
    base_price numeric(12,2) NOT NULL,
    hsn_sac_code character varying(20),
    tax_rate numeric(5,2) DEFAULT 18,
    is_tax_inclusive boolean DEFAULT false,
    revenue_account_code character varying(50),
    cost_center character varying(50),
    is_package_eligible boolean DEFAULT true,
    is_insurance_billable boolean DEFAULT true,
    requires_authorization boolean DEFAULT false,
    is_active boolean DEFAULT true NOT NULL,
    effective_from date DEFAULT CURRENT_DATE NOT NULL,
    effective_to date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY billing.service_masters FORCE ROW LEVEL SECURITY;


--
-- Name: blood_units; Type: TABLE; Schema: blood_bank; Owner: -
--

CREATE TABLE blood_bank.blood_units (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    unit_number character varying(50) NOT NULL,
    bag_number character varying(100),
    barcode character varying(100),
    blood_group character varying(10) NOT NULL,
    rh_factor character varying(5) NOT NULL,
    component_type character varying(50) NOT NULL,
    donor_id uuid,
    collection_date date NOT NULL,
    collection_time time without time zone,
    collected_by_id uuid,
    processing_date date,
    processing_time time without time zone,
    processed_by_id uuid,
    expiry_date date NOT NULL,
    is_expired boolean DEFAULT false,
    volume_ml integer,
    status character varying(50) DEFAULT 'available'::character varying NOT NULL,
    storage_location character varying(255),
    test_results jsonb DEFAULT '{}'::jsonb,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_volume_positive CHECK (((volume_ml IS NULL) OR (volume_ml > 0)))
);

ALTER TABLE ONLY blood_bank.blood_units FORCE ROW LEVEL SECURITY;


--
-- Name: cross_matches; Type: TABLE; Schema: blood_bank; Owner: -
--

CREATE TABLE blood_bank.cross_matches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    blood_unit_id uuid NOT NULL,
    requested_by_id uuid,
    performed_by_id uuid,
    cross_match_date timestamp with time zone DEFAULT now() NOT NULL,
    result character varying(50) NOT NULL,
    compatibility_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY blood_bank.cross_matches FORCE ROW LEVEL SECURITY;


--
-- Name: donors; Type: TABLE; Schema: blood_bank; Owner: -
--

CREATE TABLE blood_bank.donors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    donor_number character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    date_of_birth date,
    gender public.fhir_gender,
    blood_group character varying(10) NOT NULL,
    rh_factor character varying(5),
    phone character varying(50),
    email character varying(255),
    address jsonb,
    medical_history jsonb DEFAULT '[]'::jsonb,
    medications text[],
    allergies text[],
    last_donation_date date,
    total_donations integer DEFAULT 0,
    last_donation_id uuid,
    eligibility_status character varying(50) DEFAULT 'eligible'::character varying,
    deferral_reason text,
    deferral_until_date date,
    weight_kg numeric(5,2),
    last_hemoglobin_gdl numeric(4,2),
    last_hemoglobin_date date,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY blood_bank.donors FORCE ROW LEVEL SECURITY;


--
-- Name: transfusions; Type: TABLE; Schema: blood_bank; Owner: -
--

CREATE TABLE blood_bank.transfusions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    blood_unit_id uuid NOT NULL,
    cross_match_id uuid,
    encounter_id uuid,
    ordered_by_id uuid,
    administered_by_id uuid,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone,
    volume_ml integer,
    rate_ml_per_hour numeric(10,2),
    status character varying(50) DEFAULT 'in-progress'::character varying NOT NULL,
    adverse_reactions jsonb DEFAULT '[]'::jsonb,
    vital_signs jsonb DEFAULT '[]'::jsonb,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY blood_bank.transfusions FORCE ROW LEVEL SECURITY;


--
-- Name: allergy_intolerances; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.allergy_intolerances (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    clinical_status character varying(50) DEFAULT 'active'::character varying,
    verification_status character varying(50) DEFAULT 'confirmed'::character varying,
    type character varying(20),
    category text[],
    criticality character varying(20),
    code jsonb NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    onset_date_time timestamp with time zone,
    onset_string text,
    recorded_date timestamp with time zone DEFAULT now(),
    recorder_id uuid,
    asserter_id uuid,
    last_occurrence timestamp with time zone,
    note jsonb DEFAULT '[]'::jsonb,
    reaction jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.allergy_intolerances FORCE ROW LEVEL SECURITY;


--
-- Name: anesthesia_records; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.anesthesia_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    surgery_id uuid NOT NULL,
    anesthetist_id uuid NOT NULL,
    anesthesia_type character varying(100) NOT NULL,
    anesthesia_agents jsonb DEFAULT '[]'::jsonb,
    airway_management character varying(100),
    vital_signs jsonb DEFAULT '[]'::jsonb,
    complications text,
    induction_time timestamp with time zone,
    emergence_time timestamp with time zone,
    extubation_time timestamp with time zone,
    recovery_score jsonb,
    recovery_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.anesthesia_records FORCE ROW LEVEL SECURITY;


--
-- Name: beds; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.beds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    bed_number character varying(50) NOT NULL,
    location_id uuid,
    bed_type character varying(50) NOT NULL,
    room_number character varying(50),
    has_oxygen boolean DEFAULT false,
    has_suction boolean DEFAULT false,
    has_monitor boolean DEFAULT false,
    has_ventilator boolean DEFAULT false,
    patient_id uuid,
    encounter_id uuid,
    assigned_at timestamp with time zone,
    status character varying(50) DEFAULT 'available'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.beds FORCE ROW LEVEL SECURITY;


--
-- Name: break_glass_sessions; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.break_glass_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    reason_code text NOT NULL,
    reason_text text,
    purpose text DEFAULT 'treatment'::text NOT NULL,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    closed_at timestamp with time zone,
    status text DEFAULT 'requested'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_bg_purpose CHECK ((purpose = ANY (ARRAY['treatment'::text, 'payment'::text, 'operations'::text, 'legal'::text, 'other'::text]))),
    CONSTRAINT chk_bg_reason CHECK ((reason_code = ANY (ARRAY['emergency'::text, 'medico_legal'::text, 'patient_request'::text, 'ops'::text, 'other'::text]))),
    CONSTRAINT chk_bg_status CHECK ((status = ANY (ARRAY['requested'::text, 'active'::text, 'denied'::text, 'expired'::text, 'closed'::text]))),
    CONSTRAINT chk_bg_time CHECK ((expires_at > requested_at))
);

ALTER TABLE ONLY clinical.break_glass_sessions FORCE ROW LEVEL SECURITY;


--
-- Name: care_plans; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.care_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    plan_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    instantiates_canonical text[],
    instantiates_uri text[],
    based_on uuid[],
    replaces uuid,
    part_of uuid[],
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    intent character varying(50) DEFAULT 'plan'::character varying NOT NULL,
    category jsonb DEFAULT '[]'::jsonb,
    title character varying(500) NOT NULL,
    description text,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    period_start date,
    period_end date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    author_id uuid,
    contributor_ids uuid[],
    care_team jsonb DEFAULT '[]'::jsonb,
    addresses uuid[],
    supporting_info jsonb DEFAULT '[]'::jsonb,
    goals jsonb DEFAULT '[]'::jsonb,
    activities jsonb DEFAULT '[]'::jsonb,
    note jsonb DEFAULT '[]'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.care_plans FORCE ROW LEVEL SECURITY;


--
-- Name: clinical_notes; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.clinical_notes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    note_type character varying(50) NOT NULL,
    code jsonb,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    author_id uuid NOT NULL,
    authored_on timestamp with time zone DEFAULT now() NOT NULL,
    status character varying(50) DEFAULT 'current'::character varying,
    content text NOT NULL,
    content_format character varying(20) DEFAULT 'text'::character varying,
    structured_content jsonb,
    attachments jsonb DEFAULT '[]'::jsonb,
    is_signed boolean DEFAULT false,
    signed_at timestamp with time zone,
    signed_by uuid,
    signature_data text,
    amended_from uuid,
    amendment_reason text,
    encryption_key_id uuid,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    consent_ref uuid,
    search_content tsvector,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.clinical_notes FORCE ROW LEVEL SECURITY;


--
-- Name: conditions; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.conditions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    clinical_status public.fhir_condition_clinical_status DEFAULT 'active'::public.fhir_condition_clinical_status NOT NULL,
    verification_status character varying(50) DEFAULT 'confirmed'::character varying,
    category jsonb DEFAULT '[]'::jsonb,
    severity jsonb,
    code jsonb NOT NULL,
    body_site jsonb DEFAULT '[]'::jsonb,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    onset_date_time timestamp with time zone,
    onset_age jsonb,
    onset_period jsonb,
    onset_string text,
    abatement_date_time timestamp with time zone,
    abatement_age jsonb,
    abatement_period jsonb,
    abatement_string text,
    recorded_date timestamp with time zone DEFAULT now(),
    recorder_id uuid,
    asserter_id uuid,
    stage jsonb DEFAULT '[]'::jsonb,
    evidence jsonb DEFAULT '[]'::jsonb,
    note jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.conditions FORCE ROW LEVEL SECURITY;


--
-- Name: diagnostic_reports; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.diagnostic_reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    report_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    based_on jsonb DEFAULT '[]'::jsonb,
    status public.fhir_diagnostic_report_status DEFAULT 'registered'::public.fhir_diagnostic_report_status NOT NULL,
    category jsonb DEFAULT '[]'::jsonb,
    code jsonb NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    effective_date_time timestamp with time zone,
    effective_period jsonb,
    issued timestamp with time zone DEFAULT now(),
    performer_id uuid,
    results_interpreter_id uuid,
    specimen jsonb DEFAULT '[]'::jsonb,
    result uuid[],
    imaging_study jsonb DEFAULT '[]'::jsonb,
    media jsonb DEFAULT '[]'::jsonb,
    conclusion text,
    conclusion_code jsonb DEFAULT '[]'::jsonb,
    presented_form jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.diagnostic_reports FORCE ROW LEVEL SECURITY;


--
-- Name: discharge_summaries; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.discharge_summaries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    admission_id uuid,
    encounter_id uuid,
    patient_id uuid NOT NULL,
    summary_number character varying(50) NOT NULL,
    discharge_date date NOT NULL,
    discharge_time time without time zone,
    discharge_status character varying(50) NOT NULL,
    discharge_disposition character varying(100),
    cause_of_death_icd10 jsonb,
    cause_of_death_text text,
    death_certificate_number character varying(100),
    admission_diagnosis jsonb DEFAULT '[]'::jsonb,
    final_diagnosis jsonb DEFAULT '[]'::jsonb,
    procedures_performed jsonb DEFAULT '[]'::jsonb,
    course_of_treatment text,
    advice_on_discharge text,
    stg_adherence_checklist jsonb DEFAULT '[]'::jsonb,
    stg_compliance_percentage numeric(5,2),
    stg_reviewed_by uuid,
    stg_reviewed_at timestamp with time zone,
    discharge_medications uuid[],
    follow_up_required boolean DEFAULT false,
    follow_up_date date,
    follow_up_instructions text,
    referred_to_facility character varying(255),
    referral_reason text,
    author_id uuid NOT NULL,
    co_author_ids uuid[],
    status character varying(50) DEFAULT 'draft'::character varying,
    is_signed boolean DEFAULT false,
    signed_at timestamp with time zone,
    signed_by uuid,
    care_context_id uuid,
    linked_to_abdm boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.discharge_summaries FORCE ROW LEVEL SECURITY;


--
-- Name: encounter_care_team_members; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.encounter_care_team_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid NOT NULL,
    patient_id uuid,
    member_kind text DEFAULT 'practitioner'::text NOT NULL,
    practitioner_id uuid,
    user_id uuid,
    external_member jsonb,
    role_code text NOT NULL,
    role_display text,
    specialty text,
    is_primary boolean DEFAULT false NOT NULL,
    assigned_by uuid,
    source text DEFAULT 'manual'::text NOT NULL,
    from_ts timestamp with time zone DEFAULT now() NOT NULL,
    to_ts timestamp with time zone,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_member_kind_valid CHECK ((member_kind = ANY (ARRAY['practitioner'::text, 'user'::text, 'external'::text]))),
    CONSTRAINT chk_member_ref_consistent CHECK ((((member_kind = 'practitioner'::text) AND (practitioner_id IS NOT NULL) AND (user_id IS NULL) AND (external_member IS NULL)) OR ((member_kind = 'user'::text) AND (user_id IS NOT NULL) AND (practitioner_id IS NULL) AND (external_member IS NULL)) OR ((member_kind = 'external'::text) AND (external_member IS NOT NULL) AND (practitioner_id IS NULL) AND (user_id IS NULL)))),
    CONSTRAINT chk_team_member_time CHECK (((to_ts IS NULL) OR (to_ts > from_ts)))
);

ALTER TABLE ONLY clinical.encounter_care_team_members FORCE ROW LEVEL SECURITY;


--
-- Name: encounters; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.encounters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    status public.fhir_encounter_status DEFAULT 'planned'::public.fhir_encounter_status NOT NULL,
    status_history jsonb DEFAULT '[]'::jsonb,
    class public.fhir_encounter_class NOT NULL,
    class_history jsonb DEFAULT '[]'::jsonb,
    type jsonb DEFAULT '[]'::jsonb,
    service_type jsonb,
    priority jsonb,
    patient_id uuid NOT NULL,
    episode_of_care_id uuid,
    participants jsonb DEFAULT '[]'::jsonb,
    primary_practitioner_id uuid,
    appointment_id uuid,
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone,
    length_minutes integer,
    reason_code jsonb DEFAULT '[]'::jsonb,
    reason_reference jsonb DEFAULT '[]'::jsonb,
    diagnosis jsonb DEFAULT '[]'::jsonb,
    location_id uuid,
    location_history jsonb DEFAULT '[]'::jsonb,
    hospitalization jsonb,
    bed_id uuid,
    account_id uuid,
    encryption_key_id uuid,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    consent_ref uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    mlc_flag boolean DEFAULT false,
    mlc_number character varying(100)
);

ALTER TABLE ONLY clinical.encounters FORCE ROW LEVEL SECURITY;


--
-- Name: episode_of_care; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.episode_of_care (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    episode_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    patient_id uuid NOT NULL,
    status character varying(50) DEFAULT 'planned'::character varying NOT NULL,
    status_history jsonb DEFAULT '[]'::jsonb,
    type jsonb DEFAULT '[]'::jsonb,
    diagnosis jsonb DEFAULT '[]'::jsonb,
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone,
    care_team jsonb DEFAULT '[]'::jsonb,
    managing_organization_id uuid,
    referral_request_id uuid,
    care_manager_id uuid,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);

ALTER TABLE ONLY clinical.episode_of_care FORCE ROW LEVEL SECURITY;


--
-- Name: external_fulfillments; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.external_fulfillments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    internal_resource_type text NOT NULL,
    internal_resource_id uuid NOT NULL,
    external_org_id uuid,
    external_practitioner_id uuid,
    status text DEFAULT 'ordered'::text NOT NULL,
    external_reference text,
    scheduled_at timestamp with time zone,
    performed_at timestamp with time zone,
    reported_at timestamp with time zone,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_external_fulfillment_status CHECK ((status = ANY (ARRAY['ordered'::text, 'scheduled'::text, 'performed'::text, 'reported'::text, 'cancelled'::text])))
);

ALTER TABLE ONLY clinical.external_fulfillments FORCE ROW LEVEL SECURITY;


--
-- Name: icu_beds; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.icu_beds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    bed_number character varying(50) NOT NULL,
    icu_unit_id uuid,
    bed_type character varying(50),
    has_ventilator boolean DEFAULT false,
    ventilator_id character varying(100),
    has_monitor boolean DEFAULT true,
    monitor_id character varying(100),
    has_dialysis boolean DEFAULT false,
    patient_id uuid,
    encounter_id uuid,
    assigned_at timestamp with time zone,
    status character varying(50) DEFAULT 'available'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.icu_beds FORCE ROW LEVEL SECURITY;


--
-- Name: locations; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    mode character varying(20) DEFAULT 'instance'::character varying,
    type jsonb,
    physical_type character varying(50),
    address jsonb,
    "position" jsonb,
    part_of uuid,
    bed_count integer,
    status character varying(20) DEFAULT 'active'::character varying,
    operational_status jsonb,
    hours_of_operation jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.locations FORCE ROW LEVEL SECURITY;


--
-- Name: medication_administrations; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.medication_administrations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    medication_request_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    scheduled_time timestamp with time zone NOT NULL,
    administered_time timestamp with time zone,
    administered_by_id uuid,
    dose_administered jsonb,
    route character varying(100),
    site character varying(100),
    status character varying(50) DEFAULT 'scheduled'::character varying NOT NULL,
    refusal_reason text,
    hold_reason text,
    notes text,
    adverse_reaction boolean DEFAULT false,
    adverse_reaction_details text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.medication_administrations FORCE ROW LEVEL SECURITY;


--
-- Name: medication_requests; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.medication_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    prescription_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    status public.fhir_medication_request_status DEFAULT 'active'::public.fhir_medication_request_status NOT NULL,
    status_reason jsonb,
    intent character varying(50) DEFAULT 'order'::character varying NOT NULL,
    category jsonb DEFAULT '[]'::jsonb,
    priority character varying(20) DEFAULT 'routine'::character varying,
    do_not_perform boolean DEFAULT false,
    reported boolean DEFAULT false,
    medication jsonb NOT NULL,
    medication_reference uuid,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    supporting_info jsonb DEFAULT '[]'::jsonb,
    authored_on timestamp with time zone DEFAULT now() NOT NULL,
    requester_id uuid NOT NULL,
    performer_id uuid,
    reason_code jsonb DEFAULT '[]'::jsonb,
    reason_reference jsonb DEFAULT '[]'::jsonb,
    course_of_therapy jsonb,
    insurance jsonb DEFAULT '[]'::jsonb,
    note jsonb DEFAULT '[]'::jsonb,
    dosage_instruction jsonb NOT NULL,
    dispense_request jsonb,
    substitution jsonb,
    prior_prescription_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.medication_requests FORCE ROW LEVEL SECURITY;


--
-- Name: medico_legal_cases; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.medico_legal_cases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    mlc_number character varying(100) NOT NULL,
    police_station character varying(255),
    fir_date date,
    fir_number character varying(100),
    case_type character varying(100),
    case_description text,
    status character varying(50) DEFAULT 'active'::character varying,
    closed_at timestamp with time zone,
    closure_reason text,
    documents jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.medico_legal_cases FORCE ROW LEVEL SECURITY;


--
-- Name: nursing_tasks; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.nursing_tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid,
    patient_id uuid NOT NULL,
    care_plan_id uuid,
    task_type character varying(100) NOT NULL,
    task_description text NOT NULL,
    task_code jsonb,
    scheduled_time timestamp with time zone NOT NULL,
    frequency character varying(100),
    due_time timestamp with time zone,
    assigned_to_nurse_id uuid,
    assigned_ward_id uuid,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    completed_at timestamp with time zone,
    completed_by_id uuid,
    completion_notes text,
    observations jsonb DEFAULT '{}'::jsonb,
    priority character varying(20) DEFAULT 'normal'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.nursing_tasks FORCE ROW LEVEL SECURITY;


--
-- Name: observations; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.observations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    based_on jsonb DEFAULT '[]'::jsonb,
    part_of uuid,
    status public.fhir_observation_status DEFAULT 'final'::public.fhir_observation_status NOT NULL,
    category jsonb NOT NULL,
    code jsonb NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    effective_date_time timestamp with time zone,
    effective_period jsonb,
    issued timestamp with time zone DEFAULT now(),
    performer_id uuid,
    value_type character varying(50) NOT NULL,
    value jsonb NOT NULL,
    data_absent_reason jsonb,
    interpretation jsonb DEFAULT '[]'::jsonb,
    note jsonb DEFAULT '[]'::jsonb,
    body_site jsonb,
    method jsonb,
    device_id uuid,
    reference_range jsonb DEFAULT '[]'::jsonb,
    has_member uuid[],
    derived_from uuid[],
    component jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.observations FORCE ROW LEVEL SECURITY;


--
-- Name: operation_theatres; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.operation_theatres (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    location_id uuid,
    ot_number character varying(50) NOT NULL,
    ot_name character varying(255) NOT NULL,
    specialties text[],
    equipment_available jsonb DEFAULT '[]'::jsonb,
    is_laminar_flow boolean DEFAULT false,
    is_hybrid boolean DEFAULT false,
    status character varying(50) DEFAULT 'available'::character varying,
    current_case_id uuid,
    max_duration_hours integer DEFAULT 8,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.operation_theatres FORCE ROW LEVEL SECURITY;


--
-- Name: patient_consent_directives; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_consent_directives (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    directive_type text NOT NULL,
    data_scope text NOT NULL,
    label_code text,
    purpose text,
    recipient_type text DEFAULT 'external'::text NOT NULL,
    recipient_ref jsonb,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_to timestamp with time zone,
    recorded_by uuid,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    source text DEFAULT 'manual'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_consent_time CHECK (((effective_to IS NULL) OR (effective_to > effective_from))),
    CONSTRAINT chk_data_scope CHECK ((data_scope = ANY (ARRAY['full_record'::text, 'labs'::text, 'imaging'::text, 'notes'::text, 'billing'::text, 'specific_label'::text]))),
    CONSTRAINT chk_directive_type CHECK ((directive_type = ANY (ARRAY['allow'::text, 'deny'::text]))),
    CONSTRAINT chk_recipient_type CHECK ((recipient_type = ANY (ARRAY['internal'::text, 'external'::text, 'insurer'::text, 'govt'::text, 'other'::text]))),
    CONSTRAINT chk_specific_label_requires_code CHECK (((data_scope <> 'specific_label'::text) OR (label_code IS NOT NULL)))
);

ALTER TABLE ONLY clinical.patient_consent_directives FORCE ROW LEVEL SECURITY;


--
-- Name: patient_identifiers; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_identifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    identifier_type text NOT NULL,
    system text,
    issuer text,
    value text,
    value_hash text,
    is_primary boolean DEFAULT false NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    verification_status text DEFAULT 'unverified'::text NOT NULL,
    verified_at timestamp with time zone,
    verified_by uuid,
    valid_from date,
    valid_to date,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_patient_identifier_value_or_hash CHECK (((value IS NOT NULL) OR (value_hash IS NOT NULL)))
);

ALTER TABLE ONLY clinical.patient_identifiers FORCE ROW LEVEL SECURITY;


--
-- Name: patient_merge_events; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_merge_events (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    target_patient_id uuid NOT NULL,
    source_patient_id uuid NOT NULL,
    status text DEFAULT 'merged'::text NOT NULL,
    reason text,
    method text,
    notes text,
    requested_by uuid,
    approved_by uuid,
    performed_by uuid,
    event_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_patient_merge_not_self CHECK ((target_patient_id <> source_patient_id))
)
PARTITION BY RANGE (event_at);

ALTER TABLE ONLY clinical.patient_merge_events FORCE ROW LEVEL SECURITY;


--
-- Name: patient_merge_events_default; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_merge_events_default (
    id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    target_patient_id uuid NOT NULL,
    source_patient_id uuid NOT NULL,
    status text DEFAULT 'merged'::text NOT NULL,
    reason text,
    method text,
    notes text,
    requested_by uuid,
    approved_by uuid,
    performed_by uuid,
    event_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_patient_merge_not_self CHECK ((target_patient_id <> source_patient_id))
);


--
-- Name: patient_merge_undo_events; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_merge_undo_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    merge_event_id uuid NOT NULL,
    merge_event_at timestamp with time zone NOT NULL,
    reason text,
    performed_by uuid,
    event_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY clinical.patient_merge_undo_events FORCE ROW LEVEL SECURITY;


--
-- Name: patient_sensitivity; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patient_sensitivity (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    label_code text NOT NULL,
    applied_by uuid,
    applied_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    reason text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_patient_sensitivity_expiry CHECK (((expires_at IS NULL) OR (expires_at > applied_at)))
);

ALTER TABLE ONLY clinical.patient_sensitivity FORCE ROW LEVEL SECURITY;


--
-- Name: patients; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    mrn character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    name jsonb NOT NULL,
    telecom jsonb DEFAULT '[]'::jsonb,
    gender public.fhir_gender NOT NULL,
    birth_date date NOT NULL,
    deceased boolean DEFAULT false,
    deceased_date_time timestamp with time zone,
    address jsonb DEFAULT '[]'::jsonb,
    marital_status jsonb,
    photo_url text,
    contacts jsonb DEFAULT '[]'::jsonb,
    communication jsonb DEFAULT '[]'::jsonb,
    general_practitioner_id uuid,
    managing_organization character varying(255),
    abha_number character varying(20),
    abha_address character varying(100),
    encryption_key_id uuid,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    consent_ref uuid,
    search_name character varying(500) GENERATED ALWAYS AS (((COALESCE((name ->> 'family'::text), ''::text) || ' '::text) || COALESCE(((name -> 'given'::text) ->> 0), ''::text))) STORED,
    search_phone character varying(20),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    merged_into_patient_id uuid,
    merged_at timestamp with time zone,
    merged_by uuid,
    CONSTRAINT chk_patients_not_merge_into_self CHECK (((merged_into_patient_id IS NULL) OR (merged_into_patient_id <> id)))
);

ALTER TABLE ONLY clinical.patients FORCE ROW LEVEL SECURITY;


--
-- Name: practitioners; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.practitioners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    registration_number character varying(100) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    name jsonb NOT NULL,
    telecom jsonb DEFAULT '[]'::jsonb,
    gender public.fhir_gender,
    birth_date date,
    address jsonb DEFAULT '[]'::jsonb,
    photo_url text,
    qualifications jsonb DEFAULT '[]'::jsonb,
    communication jsonb DEFAULT '[]'::jsonb,
    specialties text[],
    signature_url text,
    digital_signature_cert text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    hpr_id character varying(20),
    registration_council character varying(100),
    degree_certificate_path text,
    hpr_registration_date date,
    hpr_status character varying(50) DEFAULT 'pending'::character varying
);

ALTER TABLE ONLY clinical.practitioners FORCE ROW LEVEL SECURITY;


--
-- Name: resource_sensitivity; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.resource_sensitivity (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    resource_type text NOT NULL,
    resource_id uuid NOT NULL,
    label_code text NOT NULL,
    applied_by uuid,
    applied_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    reason text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_resource_sensitivity_expiry CHECK (((expires_at IS NULL) OR (expires_at > applied_at)))
);

ALTER TABLE ONLY clinical.resource_sensitivity FORCE ROW LEVEL SECURITY;


--
-- Name: sensitive_access_log; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.sensitive_access_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    resource_type text NOT NULL,
    resource_id uuid NOT NULL,
    patient_id uuid,
    action text DEFAULT 'read'::text NOT NULL,
    purpose text,
    break_glass_session_id uuid,
    accessed_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY clinical.sensitive_access_log FORCE ROW LEVEL SECURITY;


--
-- Name: sensitivity_labels; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.sensitivity_labels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code text NOT NULL,
    display_name text NOT NULL,
    severity integer DEFAULT 50 NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_sensitivity_severity CHECK (((severity >= 0) AND (severity <= 100)))
);

ALTER TABLE ONLY clinical.sensitivity_labels FORCE ROW LEVEL SECURITY;


--
-- Name: service_requests; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.service_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    request_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    based_on uuid,
    replaces uuid,
    requisition character varying(100),
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    intent character varying(50) DEFAULT 'order'::character varying NOT NULL,
    category jsonb DEFAULT '[]'::jsonb,
    priority character varying(20) DEFAULT 'routine'::character varying,
    do_not_perform boolean DEFAULT false,
    code jsonb NOT NULL,
    order_detail jsonb DEFAULT '[]'::jsonb,
    quantity jsonb,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    occurrence_date_time timestamp with time zone,
    occurrence_period jsonb,
    occurrence_timing jsonb,
    as_needed boolean DEFAULT false,
    as_needed_for jsonb,
    authored_on timestamp with time zone DEFAULT now() NOT NULL,
    requester_id uuid NOT NULL,
    performer_type character varying(50),
    performer_id uuid,
    performer_location_id uuid,
    reason_code jsonb DEFAULT '[]'::jsonb,
    reason_reference uuid[],
    supporting_info jsonb DEFAULT '[]'::jsonb,
    specimen_requirement jsonb DEFAULT '[]'::jsonb,
    body_site jsonb DEFAULT '[]'::jsonb,
    note jsonb DEFAULT '[]'::jsonb,
    patient_instruction text,
    insurance_authorization character varying(100),
    service_id uuid,
    is_billable boolean DEFAULT true,
    result_references uuid[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.service_requests FORCE ROW LEVEL SECURITY;


--
-- Name: shift_handovers; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.shift_handovers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    shift_type character varying(50) NOT NULL,
    shift_date date NOT NULL,
    shift_start_time timestamp with time zone NOT NULL,
    shift_end_time timestamp with time zone NOT NULL,
    handing_over_nurse_id uuid NOT NULL,
    taking_over_nurse_id uuid NOT NULL,
    ward_id uuid,
    patient_summaries jsonb DEFAULT '[]'::jsonb,
    critical_events jsonb DEFAULT '[]'::jsonb,
    pending_tasks jsonb DEFAULT '[]'::jsonb,
    medications_due jsonb DEFAULT '[]'::jsonb,
    status character varying(50) DEFAULT 'draft'::character varying,
    acknowledged_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY clinical.shift_handovers FORCE ROW LEVEL SECURITY;


--
-- Name: surgeries; Type: TABLE; Schema: clinical; Owner: -
--

CREATE TABLE clinical.surgeries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid,
    patient_id uuid NOT NULL,
    service_request_id uuid,
    surgery_number character varying(50) NOT NULL,
    procedure_code jsonb NOT NULL,
    procedure_name character varying(500) NOT NULL,
    procedure_category character varying(100),
    ot_id uuid,
    scheduled_start_time timestamp with time zone NOT NULL,
    scheduled_end_time timestamp with time zone,
    estimated_duration_minutes integer,
    primary_surgeon_id uuid NOT NULL,
    assistant_surgeon_ids uuid[],
    anesthetist_id uuid,
    scrub_nurse_id uuid,
    circulating_nurse_id uuid,
    status character varying(50) DEFAULT 'scheduled'::character varying NOT NULL,
    pre_op_checklist jsonb DEFAULT '[]'::jsonb,
    pre_op_notes text,
    anesthesia_type character varying(100),
    anesthesia_plan text,
    actual_start_time timestamp with time zone,
    actual_end_time timestamp with time zone,
    anesthesia_start_time timestamp with time zone,
    anesthesia_end_time timestamp with time zone,
    post_op_notes text,
    post_op_complications text,
    recovery_room_duration_minutes integer,
    implants_used jsonb DEFAULT '[]'::jsonb,
    consumables_used jsonb DEFAULT '[]'::jsonb,
    is_billed boolean DEFAULT false,
    invoice_id uuid,
    cancelled_at timestamp with time zone,
    cancelled_by uuid,
    cancellation_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    external_org_id uuid
);

ALTER TABLE ONLY clinical.surgeries FORCE ROW LEVEL SECURITY;


--
-- Name: v_active_care_team_members; Type: VIEW; Schema: clinical; Owner: -
--

CREATE VIEW clinical.v_active_care_team_members AS
 SELECT id,
    tenant_id,
    encounter_id,
    patient_id,
    member_kind,
    practitioner_id,
    user_id,
    external_member,
    role_code,
    role_display,
    specialty,
    is_primary,
    assigned_by,
    source,
    from_ts,
    to_ts,
    notes,
    metadata,
    created_at,
    updated_at
   FROM clinical.encounter_care_team_members
  WHERE ((to_ts IS NULL) OR (to_ts > now()));


--
-- Name: VIEW v_active_care_team_members; Type: COMMENT; Schema: clinical; Owner: -
--

COMMENT ON VIEW clinical.v_active_care_team_members IS 'Active care team members (where to_ts IS NULL or to_ts > now()). Use with tenant context set.';


--
-- Name: v_patients_safe; Type: VIEW; Schema: clinical; Owner: -
--

CREATE VIEW clinical.v_patients_safe AS
 SELECT tenant_id,
    id,
    gender,
    birth_date,
        CASE
            WHEN public.has_sensitive_access() THEN name
            ELSE '{"text": "***MASKED***"}'::jsonb
        END AS name,
    (EXISTS ( SELECT 1
           FROM clinical.patient_sensitivity s
          WHERE ((s.tenant_id = p.tenant_id) AND (s.patient_id = p.id) AND ((s.expires_at IS NULL) OR (s.expires_at > now()))))) AS is_sensitive,
    created_at,
    updated_at
   FROM clinical.patients p
  WHERE (tenant_id = public.current_tenant_id());


--
-- Name: VIEW v_patients_safe; Type: COMMENT; Schema: clinical; Owner: -
--

COMMENT ON VIEW clinical.v_patients_safe IS 'Safe view of patients that masks sensitive data unless app.sensitive_access=true. Use SET app.sensitive_access=true to view full data.';


--
-- Name: bulk_campaigns; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.bulk_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    template_id uuid,
    channel_type character varying(50) NOT NULL,
    audience_type character varying(50) NOT NULL,
    audience_filter jsonb,
    audience_list uuid[],
    estimated_recipients integer,
    subject character varying(500),
    body text,
    merge_fields jsonb DEFAULT '{}'::jsonb,
    send_type character varying(20) DEFAULT 'immediate'::character varying NOT NULL,
    scheduled_for timestamp with time zone,
    recurrence_rule character varying(255),
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    total_recipients integer DEFAULT 0,
    sent_count integer DEFAULT 0,
    delivered_count integer DEFAULT 0,
    failed_count integer DEFAULT 0,
    opened_count integer DEFAULT 0,
    clicked_count integer DEFAULT 0,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    total_cost numeric(12,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    approved_by uuid,
    approved_at timestamp with time zone
);

ALTER TABLE ONLY communication.bulk_campaigns FORCE ROW LEVEL SECURITY;


--
-- Name: notification_channels; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notification_channels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    channel_type character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    provider character varying(100) NOT NULL,
    config jsonb NOT NULL,
    encryption_key_id uuid,
    is_default boolean DEFAULT false,
    rate_limit_per_minute integer,
    rate_limit_per_hour integer,
    rate_limit_per_day integer,
    is_active boolean DEFAULT true NOT NULL,
    last_health_check timestamp with time zone,
    health_status character varying(20) DEFAULT 'unknown'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notification_channels FORCE ROW LEVEL SECURITY;


--
-- Name: notification_logs; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notification_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    notification_id uuid,
    channel_type character varying(50) NOT NULL,
    recipient character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    error_message text,
    provider_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notification_logs FORCE ROW LEVEL SECURITY;


--
-- Name: notification_templates; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notification_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100),
    event_type character varying(100),
    channel_type character varying(50) NOT NULL,
    subject character varying(500),
    body text NOT NULL,
    body_html text,
    whatsapp_template_name character varying(255),
    whatsapp_template_id character varying(100),
    whatsapp_language character varying(10) DEFAULT 'en'::character varying,
    variables jsonb DEFAULT '[]'::jsonb,
    sample_data jsonb,
    attachment_templates jsonb DEFAULT '[]'::jsonb,
    locale character varying(10) DEFAULT 'en'::character varying,
    translations jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    version integer DEFAULT 1,
    approval_status character varying(50),
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notification_templates FORCE ROW LEVEL SECURITY;


--
-- Name: notifications; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    template_id uuid,
    template_code character varying(100),
    channel_type character varying(50) NOT NULL,
    recipient_type character varying(50) NOT NULL,
    recipient_id uuid NOT NULL,
    subject character varying(500),
    body_text text,
    body_html text,
    metadata jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    error_message text,
    retry_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (created_at);

ALTER TABLE ONLY communication.notifications FORCE ROW LEVEL SECURITY;


--
-- Name: notifications_y2024m12; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notifications_y2024m12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    template_id uuid,
    template_code character varying(100),
    channel_type character varying(50) NOT NULL,
    recipient_type character varying(50) NOT NULL,
    recipient_id uuid NOT NULL,
    subject character varying(500),
    body_text text,
    body_html text,
    metadata jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    error_message text,
    retry_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notifications_y2024m12 FORCE ROW LEVEL SECURITY;


--
-- Name: notifications_y2025m01; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notifications_y2025m01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    template_id uuid,
    template_code character varying(100),
    channel_type character varying(50) NOT NULL,
    recipient_type character varying(50) NOT NULL,
    recipient_id uuid NOT NULL,
    subject character varying(500),
    body_text text,
    body_html text,
    metadata jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    error_message text,
    retry_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notifications_y2025m01 FORCE ROW LEVEL SECURITY;


--
-- Name: notifications_y2025m02; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notifications_y2025m02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    template_id uuid,
    template_code character varying(100),
    channel_type character varying(50) NOT NULL,
    recipient_type character varying(50) NOT NULL,
    recipient_id uuid NOT NULL,
    subject character varying(500),
    body_text text,
    body_html text,
    metadata jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    error_message text,
    retry_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notifications_y2025m02 FORCE ROW LEVEL SECURITY;


--
-- Name: notifications_y2025m03; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.notifications_y2025m03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    template_id uuid,
    template_code character varying(100),
    channel_type character varying(50) NOT NULL,
    recipient_type character varying(50) NOT NULL,
    recipient_id uuid NOT NULL,
    subject character varying(500),
    body_text text,
    body_html text,
    metadata jsonb DEFAULT '{}'::jsonb,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    error_message text,
    retry_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY communication.notifications_y2025m03 FORCE ROW LEVEL SECURITY;


--
-- Name: user_notification_preferences; Type: TABLE; Schema: communication; Owner: -
--

CREATE TABLE communication.user_notification_preferences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    patient_id uuid,
    category character varying(100) NOT NULL,
    channel_type character varying(50) NOT NULL,
    is_enabled boolean DEFAULT true,
    digest_frequency character varying(20) DEFAULT 'immediate'::character varying,
    opted_out_at timestamp with time zone,
    opt_out_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_notification_user CHECK (((user_id IS NOT NULL) OR (patient_id IS NOT NULL)))
);

ALTER TABLE ONLY communication.user_notification_preferences FORCE ROW LEVEL SECURITY;


--
-- Name: api_clients; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.api_clients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    client_id character varying(100) NOT NULL,
    client_name character varying(255) NOT NULL,
    description text,
    client_type character varying(50) NOT NULL,
    developer_name character varying(255),
    developer_email character varying(255),
    homepage_url text,
    privacy_policy_url text,
    terms_of_service_url text,
    redirect_uris text[],
    allowed_grant_types text[] DEFAULT ARRAY['authorization_code'::text],
    allowed_scopes text[],
    client_secret_hash character varying(255),
    require_pkce boolean DEFAULT true,
    rate_limit_tier character varying(50) DEFAULT 'standard'::character varying,
    is_active boolean DEFAULT true NOT NULL,
    is_verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.api_clients FORCE ROW LEVEL SECURITY;


--
-- Name: api_keys; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    api_client_id uuid,
    key_prefix character varying(10) NOT NULL,
    key_hash character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    scopes text[],
    allowed_ips inet[],
    allowed_origins text[],
    rate_limit_override integer,
    expires_at timestamp with time zone,
    last_used_at timestamp with time zone,
    last_used_ip inet,
    usage_count bigint DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    revoked_at timestamp with time zone,
    revoked_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_api_key_owner CHECK (((user_id IS NOT NULL) OR (api_client_id IS NOT NULL)))
);

ALTER TABLE ONLY core.api_keys FORCE ROW LEVEL SECURITY;


--
-- Name: api_rate_limits; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.api_rate_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tier_name character varying(50) NOT NULL,
    description text,
    requests_per_minute integer DEFAULT 60 NOT NULL,
    requests_per_hour integer DEFAULT 1000 NOT NULL,
    requests_per_day integer DEFAULT 10000 NOT NULL,
    burst_size integer DEFAULT 10,
    endpoint_limits jsonb DEFAULT '{}'::jsonb,
    throttle_delay_ms integer DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    ip_address inet,
    user_agent text,
    action character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    module character varying(50),
    endpoint character varying(255),
    http_method character varying(10),
    old_values jsonb,
    new_values jsonb,
    is_phi_access boolean DEFAULT false,
    is_break_glass boolean DEFAULT false,
    break_glass_reason text,
    status character varying(20) DEFAULT 'success'::character varying,
    error_message text,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (occurred_at);

ALTER TABLE ONLY core.audit_logs FORCE ROW LEVEL SECURITY;


--
-- Name: audit_logs_y2024m12; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.audit_logs_y2024m12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    ip_address inet,
    user_agent text,
    action character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    module character varying(50),
    endpoint character varying(255),
    http_method character varying(10),
    old_values jsonb,
    new_values jsonb,
    is_phi_access boolean DEFAULT false,
    is_break_glass boolean DEFAULT false,
    break_glass_reason text,
    status character varying(20) DEFAULT 'success'::character varying,
    error_message text,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.audit_logs_y2024m12 FORCE ROW LEVEL SECURITY;


--
-- Name: audit_logs_y2025m01; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.audit_logs_y2025m01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    ip_address inet,
    user_agent text,
    action character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    module character varying(50),
    endpoint character varying(255),
    http_method character varying(10),
    old_values jsonb,
    new_values jsonb,
    is_phi_access boolean DEFAULT false,
    is_break_glass boolean DEFAULT false,
    break_glass_reason text,
    status character varying(20) DEFAULT 'success'::character varying,
    error_message text,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.audit_logs_y2025m01 FORCE ROW LEVEL SECURITY;


--
-- Name: audit_logs_y2025m02; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.audit_logs_y2025m02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    ip_address inet,
    user_agent text,
    action character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    module character varying(50),
    endpoint character varying(255),
    http_method character varying(10),
    old_values jsonb,
    new_values jsonb,
    is_phi_access boolean DEFAULT false,
    is_break_glass boolean DEFAULT false,
    break_glass_reason text,
    status character varying(20) DEFAULT 'success'::character varying,
    error_message text,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.audit_logs_y2025m02 FORCE ROW LEVEL SECURITY;


--
-- Name: audit_logs_y2025m03; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.audit_logs_y2025m03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    ip_address inet,
    user_agent text,
    action character varying(100) NOT NULL,
    resource_type character varying(100) NOT NULL,
    resource_id uuid,
    module character varying(50),
    endpoint character varying(255),
    http_method character varying(10),
    old_values jsonb,
    new_values jsonb,
    is_phi_access boolean DEFAULT false,
    is_break_glass boolean DEFAULT false,
    break_glass_reason text,
    status character varying(20) DEFAULT 'success'::character varying,
    error_message text,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.audit_logs_y2025m03 FORCE ROW LEVEL SECURITY;


--
-- Name: consent_logs; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.consent_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    consent_type character varying(100) NOT NULL,
    purpose text NOT NULL,
    data_categories text[],
    status character varying(50) NOT NULL,
    granted_at timestamp with time zone,
    revoked_at timestamp with time zone,
    expires_at timestamp with time zone,
    consent_document_url text,
    signature jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    consent_manager_id character varying(255),
    consent_artifact_id character varying(255),
    is_revocable boolean DEFAULT true,
    data_fiduciary_id uuid,
    artifact_status character varying(50) DEFAULT 'granted'::character varying,
    hiu_id character varying(255),
    hiu_name character varying(255),
    consent_request_id character varying(255),
    abdm_response jsonb
);

ALTER TABLE ONLY core.consent_logs FORCE ROW LEVEL SECURITY;


--
-- Name: data_deletion_requests; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.data_deletion_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    request_number character varying(50) NOT NULL,
    patient_id uuid NOT NULL,
    patient_identifier character varying(255),
    requester_type character varying(50) NOT NULL,
    requester_name character varying(255),
    requester_email character varying(255),
    requester_phone character varying(50),
    request_type character varying(50) NOT NULL,
    data_categories text[],
    reason text,
    identity_verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    verified_by uuid,
    verification_method character varying(100),
    requires_legal_review boolean DEFAULT false,
    legal_reviewed_at timestamp with time zone,
    legal_reviewed_by uuid,
    legal_hold_reason text,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    scheduled_for timestamp with time zone,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    tables_processed jsonb DEFAULT '[]'::jsonb,
    errors jsonb DEFAULT '[]'::jsonb,
    certificate_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY core.data_deletion_requests FORCE ROW LEVEL SECURITY;


--
-- Name: external_organizations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.external_organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name text NOT NULL,
    org_type text NOT NULL,
    hfr_id text,
    nabl_code text,
    gstin text,
    pan text,
    address jsonb,
    contacts jsonb,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_external_org_type CHECK ((org_type = ANY (ARRAY['hospital'::text, 'clinic'::text, 'lab'::text, 'radiology_center'::text, 'pharmacy'::text, 'ambulance'::text, 'other'::text])))
);

ALTER TABLE ONLY core.external_organizations FORCE ROW LEVEL SECURITY;


--
-- Name: external_practitioners; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.external_practitioners (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    external_org_id uuid,
    full_name text NOT NULL,
    practitioner_type text DEFAULT 'doctor'::text NOT NULL,
    registration_number text,
    registration_council text,
    specialty text,
    contacts jsonb,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_external_practitioner_type CHECK ((practitioner_type = ANY (ARRAY['doctor'::text, 'nurse'::text, 'technician'::text, 'radiologist'::text, 'anesthetist'::text, 'other'::text])))
);

ALTER TABLE ONLY core.external_practitioners FORCE ROW LEVEL SECURITY;


--
-- Name: external_service_agreements; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.external_service_agreements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    external_org_id uuid NOT NULL,
    service_type text NOT NULL,
    pricing jsonb,
    sla jsonb,
    effective_from date DEFAULT CURRENT_DATE NOT NULL,
    effective_to date,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_agreement_dates CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))),
    CONSTRAINT chk_service_type CHECK ((service_type = ANY (ARRAY['radiology'::text, 'lab'::text, 'ot'::text, 'referral'::text, 'other'::text])))
);

ALTER TABLE ONLY core.external_service_agreements FORCE ROW LEVEL SECURITY;


--
-- Name: feature_flags; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.feature_flags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_enabled boolean DEFAULT false NOT NULL,
    tenant_overrides jsonb DEFAULT '{}'::jsonb,
    user_overrides jsonb DEFAULT '{}'::jsonb,
    rollout_percentage integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT feature_flags_rollout_percentage_check CHECK (((rollout_percentage >= 0) AND (rollout_percentage <= 100)))
);


--
-- Name: organization_members; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.organization_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    org_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.organization_members FORCE ROW LEVEL SECURITY;


--
-- Name: organization_tenant_memberships; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.organization_tenant_memberships (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    is_primary boolean DEFAULT true NOT NULL,
    effective_from timestamp with time zone DEFAULT now() NOT NULL,
    effective_to timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.organization_tenant_memberships FORCE ROW LEVEL SECURITY;


--
-- Name: organizations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    legal_name text,
    pan text,
    gstin text,
    cin text,
    registered_address jsonb,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.organizations FORCE ROW LEVEL SECURITY;


--
-- Name: otp_verifications; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.otp_verifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    otp_code character varying(10) NOT NULL,
    otp_type character varying(50) NOT NULL,
    delivery_channel character varying(20) NOT NULL,
    delivery_address character varying(255),
    context jsonb,
    ip_address inet,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    attempts integer DEFAULT 0,
    max_attempts integer DEFAULT 3,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone
);

ALTER TABLE ONLY core.otp_verifications FORCE ROW LEVEL SECURITY;


--
-- Name: password_policies; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.password_policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    name character varying(255) NOT NULL,
    is_default boolean DEFAULT false,
    min_length integer DEFAULT 8 NOT NULL,
    max_length integer DEFAULT 128,
    require_uppercase boolean DEFAULT true,
    require_lowercase boolean DEFAULT true,
    require_numbers boolean DEFAULT true,
    require_special_chars boolean DEFAULT true,
    special_chars_allowed character varying(100) DEFAULT '!@#$%^&*()_+-=[]{}|;:,.<>?'::character varying,
    password_history_count integer DEFAULT 5,
    password_expires_days integer DEFAULT 90,
    warn_before_expiry_days integer DEFAULT 14,
    max_failed_attempts integer DEFAULT 5,
    lockout_duration_mins integer DEFAULT 30,
    session_timeout_mins integer DEFAULT 480,
    idle_timeout_mins integer DEFAULT 30,
    max_concurrent_sessions integer DEFAULT 5,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.password_policies FORCE ROW LEVEL SECURITY;


--
-- Name: permissions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource character varying(100) NOT NULL,
    action character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_phi_access boolean DEFAULT false,
    requires_mfa boolean DEFAULT false
);


--
-- Name: retention_policies; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.retention_policies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    name character varying(255) NOT NULL,
    description text,
    schema_name character varying(100) NOT NULL,
    table_name character varying(100),
    retention_days integer NOT NULL,
    archive_after_days integer,
    delete_after_days integer,
    archive_destination character varying(50),
    archive_bucket text,
    legal_hold_enabled boolean DEFAULT false,
    run_schedule character varying(100) DEFAULT '0 2 * * *'::character varying,
    last_run_at timestamp with time zone,
    next_run_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.retention_policies FORCE ROW LEVEL SECURITY;


--
-- Name: role_permissions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.role_permissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    conditions jsonb
);


--
-- Name: roles; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    parent_role_id uuid,
    is_system_role boolean DEFAULT false,
    is_clinical_role boolean DEFAULT false,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.roles FORCE ROW LEVEL SECURITY;


--
-- Name: schema_versions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.schema_versions (
    version character varying(50) NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL,
    description text,
    applied_by character varying(255)
);


--
-- Name: TABLE schema_versions; Type: COMMENT; Schema: core; Owner: -
--

COMMENT ON TABLE core.schema_versions IS 'Tracks schema migration versions applied to the database';


--
-- Name: subscription_plans; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.subscription_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    billing_cycle character varying(20) NOT NULL,
    base_price numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'INR'::character varying,
    max_users integer,
    max_patients integer,
    max_locations integer,
    max_storage_gb integer,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    feature_limits jsonb DEFAULT '{}'::jsonb,
    api_rate_limit_tier character varying(50),
    trial_days integer DEFAULT 14,
    is_active boolean DEFAULT true NOT NULL,
    is_public boolean DEFAULT true,
    effective_from date DEFAULT CURRENT_DATE NOT NULL,
    effective_to date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: system_configurations; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.system_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    scope character varying(20) NOT NULL,
    tenant_id uuid,
    user_id uuid,
    config_key character varying(255) NOT NULL,
    config_value jsonb NOT NULL,
    config_type character varying(50) NOT NULL,
    description text,
    category character varying(100),
    validation_rules jsonb,
    is_overridable boolean DEFAULT true,
    encryption_key_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);

ALTER TABLE ONLY core.system_configurations FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_subscriptions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tenant_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    current_period_start date NOT NULL,
    current_period_end date NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    cancelled_at timestamp with time zone,
    cancellation_reason text,
    trial_ends_at date,
    billing_email character varying(255),
    payment_method jsonb,
    custom_limits jsonb DEFAULT '{}'::jsonb,
    custom_features jsonb DEFAULT '[]'::jsonb,
    custom_price numeric(12,2),
    current_users integer DEFAULT 0,
    current_patients integer DEFAULT 0,
    current_storage_gb numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.tenant_subscriptions FORCE ROW LEVEL SECURITY;


--
-- Name: tenants; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.tenants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    legal_name character varying(500),
    fhir_organization_id character varying(255),
    settings jsonb DEFAULT '{}'::jsonb,
    feature_flags jsonb DEFAULT '{}'::jsonb,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    data_region character varying(50) DEFAULT 'ap-south-1'::character varying,
    subscription_tier character varying(50) DEFAULT 'standard'::character varying,
    subscription_status character varying(50) DEFAULT 'active'::character varying,
    subscription_expires_at timestamp with time zone,
    primary_email character varying(255),
    primary_phone character varying(50),
    address jsonb,
    is_active boolean DEFAULT true NOT NULL,
    onboarded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    hfr_id character varying(20),
    geo_coordinates jsonb,
    rohini_id character varying(50),
    organization_type character varying(50),
    facility_category character varying(100),
    facility_level character varying(50),
    hfr_registration_date date,
    hfr_status character varying(50) DEFAULT 'pending'::character varying,
    org_id uuid NOT NULL
);


--
-- Name: usage_metrics; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.usage_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    subscription_id uuid,
    metric_type character varying(100) NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    quantity numeric(14,4) NOT NULL,
    unit character varying(50),
    unit_price numeric(10,4),
    total_amount numeric(12,2),
    is_billable boolean DEFAULT true,
    billed_at timestamp with time zone,
    invoice_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY core.usage_metrics FORCE ROW LEVEL SECURITY;


--
-- Name: user_roles; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.user_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    department_id uuid,
    location_id uuid,
    valid_from timestamp with time zone DEFAULT now() NOT NULL,
    valid_until timestamp with time zone,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_by uuid
);

ALTER TABLE ONLY core.user_roles FORCE ROW LEVEL SECURITY;


--
-- Name: user_sessions; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.user_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    user_id uuid NOT NULL,
    session_token character varying(500) NOT NULL,
    refresh_token character varying(500),
    device_id character varying(255),
    device_type character varying(50),
    device_name character varying(255),
    user_agent text,
    ip_address inet,
    geo_location jsonb,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_activity_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    revoked_reason character varying(100)
);

ALTER TABLE ONLY core.user_sessions FORCE ROW LEVEL SECURITY;


--
-- Name: users; Type: TABLE; Schema: core; Owner: -
--

CREATE TABLE core.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(50),
    username character varying(100),
    fhir_practitioner_id character varying(255),
    name jsonb NOT NULL,
    external_id character varying(255),
    identity_provider character varying(100),
    password_hash character varying(255),
    mfa_enabled boolean DEFAULT false,
    mfa_secret character varying(255),
    last_login_at timestamp with time zone,
    last_login_ip inet,
    failed_login_attempts integer DEFAULT 0,
    locked_until timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    is_system_user boolean DEFAULT false,
    preferences jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);

ALTER TABLE ONLY core.users FORCE ROW LEVEL SECURITY;


--
-- Name: document_access_log; Type: TABLE; Schema: documents; Owner: -
--

CREATE TABLE documents.document_access_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    document_id uuid NOT NULL,
    user_id uuid,
    user_email character varying(255),
    access_type character varying(50) NOT NULL,
    access_method character varying(50),
    ip_address inet,
    user_agent text,
    access_reason text,
    is_break_glass boolean DEFAULT false,
    was_successful boolean DEFAULT true NOT NULL,
    failure_reason text,
    download_url_generated boolean DEFAULT false,
    url_expires_at timestamp with time zone,
    shared_with character varying(255),
    accessed_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY documents.document_access_log FORCE ROW LEVEL SECURITY;


--
-- Name: document_types; Type: TABLE; Schema: documents; Owner: -
--

CREATE TABLE documents.document_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(100) NOT NULL,
    allowed_mime_types text[] NOT NULL,
    max_file_size_mb integer DEFAULT 10 NOT NULL,
    storage_bucket character varying(255),
    storage_path_template character varying(500),
    encryption_required boolean DEFAULT true,
    requires_consent boolean DEFAULT false,
    retention_days integer,
    archive_after_days integer,
    is_phi boolean DEFAULT false,
    is_pii boolean DEFAULT false,
    sensitivity_level character varying(20) DEFAULT 'normal'::character varying,
    versioning_enabled boolean DEFAULT true,
    max_versions integer DEFAULT 10,
    virus_scan_required boolean DEFAULT true,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY documents.document_types FORCE ROW LEVEL SECURITY;


--
-- Name: document_versions; Type: TABLE; Schema: documents; Owner: -
--

CREATE TABLE documents.document_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    document_id uuid NOT NULL,
    version_number integer NOT NULL,
    original_filename character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size_bytes bigint NOT NULL,
    storage_bucket character varying(255) NOT NULL,
    storage_key character varying(1000) NOT NULL,
    content_hash character varying(64),
    change_reason text,
    change_summary text,
    previous_version_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY documents.document_versions FORCE ROW LEVEL SECURITY;


--
-- Name: documents; Type: TABLE; Schema: documents; Owner: -
--

CREATE TABLE documents.documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    document_number character varying(100) NOT NULL,
    document_type_id uuid NOT NULL,
    document_type_code character varying(50) NOT NULL,
    title character varying(500) NOT NULL,
    description text,
    owner_type character varying(50) NOT NULL,
    patient_id uuid,
    user_id uuid,
    encounter_id uuid,
    entity_type character varying(100),
    entity_id uuid,
    original_filename character varying(500) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size_bytes bigint NOT NULL,
    file_extension character varying(20),
    storage_provider character varying(50) DEFAULT 's3'::character varying NOT NULL,
    storage_bucket character varying(255) NOT NULL,
    storage_key character varying(1000) NOT NULL,
    storage_url text,
    url_expires_at timestamp with time zone,
    content_hash character varying(64),
    content_hash_algorithm character varying(20) DEFAULT 'SHA256'::character varying,
    encryption_key_id uuid,
    is_encrypted boolean DEFAULT true,
    virus_scan_status character varying(20) DEFAULT 'pending'::character varying,
    virus_scan_at timestamp with time zone,
    virus_scan_result jsonb,
    version_number integer DEFAULT 1 NOT NULL,
    is_latest_version boolean DEFAULT true NOT NULL,
    parent_document_id uuid,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    tags text[],
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    consent_ref uuid,
    retention_until date,
    archived_at timestamp with time zone,
    deleted_at timestamp with time zone,
    deletion_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);

ALTER TABLE ONLY documents.documents FORCE ROW LEVEL SECURITY;


--
-- Name: imaging_orders; Type: TABLE; Schema: imaging; Owner: -
--

CREATE TABLE imaging.imaging_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    order_number character varying(50) NOT NULL,
    accession_number character varying(50),
    service_request_id uuid,
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    priority character varying(20) DEFAULT 'routine'::character varying,
    procedure_code jsonb NOT NULL,
    modality public.dicom_modality,
    body_site jsonb,
    laterality character varying(10),
    patient_id uuid NOT NULL,
    patient_name character varying(255),
    patient_mrn character varying(50),
    patient_dob date,
    patient_gender character varying(10),
    encounter_id uuid,
    requester_id uuid NOT NULL,
    requester_name character varying(255),
    reason_for_study text,
    reason_code jsonb DEFAULT '[]'::jsonb,
    clinical_history text,
    patient_instructions text,
    technician_notes text,
    requested_date date,
    requested_time time without time zone,
    scheduled_date_time timestamp with time zone,
    performing_location_id uuid,
    performing_location character varying(255),
    assigned_technician_id uuid,
    assigned_radiologist_id uuid,
    insurance_authorization character varying(100),
    authorization_status character varying(50),
    worklist_status character varying(50) DEFAULT 'pending'::character varying,
    worklist_sent_at timestamp with time zone,
    performed_date_time timestamp with time zone,
    performed_by_id uuid,
    imaging_study_id uuid,
    diagnostic_report_id uuid,
    service_id uuid,
    is_billable boolean DEFAULT true,
    is_billed boolean DEFAULT false,
    cancelled_at timestamp with time zone,
    cancelled_by uuid,
    cancellation_reason text,
    ordered_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    external_org_id uuid,
    external_practitioner_id uuid
);

ALTER TABLE ONLY imaging.imaging_orders FORCE ROW LEVEL SECURITY;


--
-- Name: imaging_studies; Type: TABLE; Schema: imaging; Owner: -
--

CREATE TABLE imaging.imaging_studies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    imaging_order_id uuid,
    accession_number character varying(50),
    orthanc_study_id character varying(255) NOT NULL,
    dicom_study_uid character varying(255) NOT NULL,
    status character varying(50) DEFAULT 'available'::character varying NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    study_date date,
    study_time time without time zone,
    study_description character varying(500),
    modalities_in_study text[],
    number_of_series integer,
    number_of_instances integer,
    body_part_examined character varying(100),
    procedure_code jsonb DEFAULT '[]'::jsonb,
    referring_physician character varying(255),
    institution_name character varying(255),
    reason_code jsonb DEFAULT '[]'::jsonb,
    interpreter_id uuid,
    diagnostic_report_id uuid,
    viewer_url text,
    wado_rs_endpoint text,
    thumbnail_url text,
    storage_size_bytes bigint,
    series_summary jsonb DEFAULT '[]'::jsonb,
    has_critical_finding boolean DEFAULT false,
    critical_finding_at timestamp with time zone,
    critical_notified boolean DEFAULT false,
    data_sovereignty_tag public.data_sovereignty_region DEFAULT 'INDIA_LOCAL'::public.data_sovereignty_region NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY imaging.imaging_studies FORCE ROW LEVEL SECURITY;


--
-- Name: hl7_message_log; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.hl7_message_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    message_id character varying(255) NOT NULL,
    message_type character varying(50) NOT NULL,
    message_control_id character varying(255),
    sending_application character varying(255),
    sending_facility character varying(255),
    receiving_application character varying(255),
    receiving_facility character varying(255),
    message_content text NOT NULL,
    direction character varying(20) NOT NULL,
    status character varying(50) DEFAULT 'received'::character varying NOT NULL,
    error_message text,
    processed_at timestamp with time zone,
    received_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (received_at);

ALTER TABLE ONLY integration.hl7_message_log FORCE ROW LEVEL SECURITY;


--
-- Name: hl7_message_log_y2024m12; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.hl7_message_log_y2024m12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    message_id character varying(255) NOT NULL,
    message_type character varying(50) NOT NULL,
    message_control_id character varying(255),
    sending_application character varying(255),
    sending_facility character varying(255),
    receiving_application character varying(255),
    receiving_facility character varying(255),
    message_content text NOT NULL,
    direction character varying(20) NOT NULL,
    status character varying(50) DEFAULT 'received'::character varying NOT NULL,
    error_message text,
    processed_at timestamp with time zone,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.hl7_message_log_y2024m12 FORCE ROW LEVEL SECURITY;


--
-- Name: hl7_message_log_y2025m01; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.hl7_message_log_y2025m01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    message_id character varying(255) NOT NULL,
    message_type character varying(50) NOT NULL,
    message_control_id character varying(255),
    sending_application character varying(255),
    sending_facility character varying(255),
    receiving_application character varying(255),
    receiving_facility character varying(255),
    message_content text NOT NULL,
    direction character varying(20) NOT NULL,
    status character varying(50) DEFAULT 'received'::character varying NOT NULL,
    error_message text,
    processed_at timestamp with time zone,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.hl7_message_log_y2025m01 FORCE ROW LEVEL SECURITY;


--
-- Name: hl7_message_log_y2025m02; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.hl7_message_log_y2025m02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    message_id character varying(255) NOT NULL,
    message_type character varying(50) NOT NULL,
    message_control_id character varying(255),
    sending_application character varying(255),
    sending_facility character varying(255),
    receiving_application character varying(255),
    receiving_facility character varying(255),
    message_content text NOT NULL,
    direction character varying(20) NOT NULL,
    status character varying(50) DEFAULT 'received'::character varying NOT NULL,
    error_message text,
    processed_at timestamp with time zone,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.hl7_message_log_y2025m02 FORCE ROW LEVEL SECURITY;


--
-- Name: hl7_message_log_y2025m03; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.hl7_message_log_y2025m03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    message_id character varying(255) NOT NULL,
    message_type character varying(50) NOT NULL,
    message_control_id character varying(255),
    sending_application character varying(255),
    sending_facility character varying(255),
    receiving_application character varying(255),
    receiving_facility character varying(255),
    message_content text NOT NULL,
    direction character varying(20) NOT NULL,
    status character varying(50) DEFAULT 'received'::character varying NOT NULL,
    error_message text,
    processed_at timestamp with time zone,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.hl7_message_log_y2025m03 FORCE ROW LEVEL SECURITY;


--
-- Name: integration_credentials; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.integration_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    endpoint_id uuid,
    code character varying(100) NOT NULL,
    credential_type character varying(50) NOT NULL,
    encrypted_credentials jsonb NOT NULL,
    is_active boolean DEFAULT true,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.integration_credentials FORCE ROW LEVEL SECURITY;


--
-- Name: integration_endpoints; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.integration_endpoints (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(100) NOT NULL,
    endpoint_type character varying(50) NOT NULL,
    base_url character varying(500) NOT NULL,
    authentication_type character varying(50) NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.integration_endpoints FORCE ROW LEVEL SECURITY;


--
-- Name: webhook_deliveries; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.webhook_deliveries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    event_type character varying(100) NOT NULL,
    event_id uuid NOT NULL,
    payload jsonb NOT NULL,
    payload_size_bytes integer,
    request_url text NOT NULL,
    request_headers jsonb,
    request_method character varying(10),
    response_status_code integer,
    response_headers jsonb,
    response_body text,
    response_time_ms integer,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    attempt_number integer DEFAULT 1 NOT NULL,
    next_retry_at timestamp with time zone,
    error_type character varying(100),
    error_message text,
    scheduled_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY integration.webhook_deliveries FORCE ROW LEVEL SECURITY;


--
-- Name: webhook_subscriptions; Type: TABLE; Schema: integration; Owner: -
--

CREATE TABLE integration.webhook_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    target_url text NOT NULL,
    http_method character varying(10) DEFAULT 'POST'::character varying,
    event_types text[] NOT NULL,
    event_filter jsonb,
    custom_headers jsonb DEFAULT '{}'::jsonb,
    auth_type character varying(50) DEFAULT 'none'::character varying,
    auth_header_name character varying(100) DEFAULT 'Authorization'::character varying,
    auth_value text,
    hmac_secret text,
    payload_format character varying(20) DEFAULT 'json'::character varying,
    include_full_resource boolean DEFAULT true,
    max_retries integer DEFAULT 5,
    retry_delay_seconds integer[] DEFAULT ARRAY[60, 300, 900, 3600, 7200],
    timeout_seconds integer DEFAULT 30,
    is_active boolean DEFAULT true NOT NULL,
    last_triggered_at timestamp with time zone,
    last_success_at timestamp with time zone,
    last_failure_at timestamp with time zone,
    consecutive_failures integer DEFAULT 0,
    is_disabled_by_failures boolean DEFAULT false,
    total_deliveries bigint DEFAULT 0,
    successful_deliveries bigint DEFAULT 0,
    failed_deliveries bigint DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY integration.webhook_subscriptions FORCE ROW LEVEL SECURITY;


--
-- Name: batches; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    batch_number character varying(100) NOT NULL,
    manufacturer_batch character varying(100),
    expiry_date date NOT NULL,
    manufacturing_date date,
    quantity_received numeric(12,3) NOT NULL,
    quantity_available numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    location_id uuid,
    supplier_id uuid,
    received_date date DEFAULT CURRENT_DATE NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_available_not_exceed_received CHECK ((quantity_available <= quantity_received)),
    CONSTRAINT chk_quantity_non_negative CHECK (((quantity_available >= (0)::numeric) AND (quantity_received >= (0)::numeric)))
);

ALTER TABLE ONLY inventory.batches FORCE ROW LEVEL SECURITY;


--
-- Name: current_stock; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.current_stock (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    quantity_available numeric(12,3) DEFAULT 0 NOT NULL,
    quantity_reserved numeric(12,3) DEFAULT 0 NOT NULL,
    quantity_on_order numeric(12,3) DEFAULT 0 NOT NULL,
    reorder_level numeric(12,3),
    reorder_quantity numeric(12,3),
    is_below_reorder boolean DEFAULT false,
    last_transaction_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_current_stock_quantities CHECK (((quantity_available >= (0)::numeric) AND (quantity_reserved >= (0)::numeric)))
);

ALTER TABLE ONLY inventory.current_stock FORCE ROW LEVEL SECURITY;


--
-- Name: item_categories; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.item_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    parent_id uuid,
    path text,
    level integer DEFAULT 0 NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_medication boolean DEFAULT false,
    is_controlled boolean DEFAULT false,
    is_consumable boolean DEFAULT true,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY inventory.item_categories FORCE ROW LEVEL SECURITY;


--
-- Name: items; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    sku character varying(50) NOT NULL,
    barcode character varying(100),
    code jsonb,
    name character varying(500) NOT NULL,
    generic_name character varying(500),
    brand_name character varying(255),
    manufacturer character varying(255),
    category_id uuid,
    item_type character varying(50) NOT NULL,
    form jsonb,
    strength character varying(100),
    route jsonb DEFAULT '[]'::jsonb,
    unit_of_measure character varying(50) NOT NULL,
    pack_size integer DEFAULT 1,
    is_controlled boolean DEFAULT false,
    schedule_type character varying(20),
    requires_prescription boolean DEFAULT true,
    mrp numeric(12,2),
    purchase_price numeric(12,2),
    selling_price numeric(12,2),
    hsn_code character varying(20),
    tax_rate numeric(5,2) DEFAULT 0,
    reorder_level integer DEFAULT 0,
    reorder_quantity integer DEFAULT 0,
    max_stock_level integer,
    storage_conditions character varying(100),
    is_cold_chain boolean DEFAULT false,
    is_active boolean DEFAULT true NOT NULL,
    is_discontinued boolean DEFAULT false,
    search_terms tsvector,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY inventory.items FORCE ROW LEVEL SECURITY;


--
-- Name: purchase_order_items; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.purchase_order_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    purchase_order_id uuid NOT NULL,
    item_id uuid NOT NULL,
    quantity_ordered integer NOT NULL,
    quantity_received integer DEFAULT 0,
    unit_price numeric(12,2) NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0,
    tax_amount numeric(12,2) DEFAULT 0,
    discount_percent numeric(5,2) DEFAULT 0,
    line_total numeric(14,2) NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY inventory.purchase_order_items FORCE ROW LEVEL SECURITY;


--
-- Name: purchase_orders; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.purchase_orders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    po_number character varying(50) NOT NULL,
    supplier_id uuid NOT NULL,
    order_date date DEFAULT CURRENT_DATE NOT NULL,
    expected_delivery_date date,
    subtotal numeric(14,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(14,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(14,2) DEFAULT 0,
    total_amount numeric(14,2) DEFAULT 0 NOT NULL,
    status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    approved_by uuid,
    approved_at timestamp with time zone,
    notes text,
    terms_and_conditions text,
    delivery_address jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY inventory.purchase_orders FORCE ROW LEVEL SECURITY;


--
-- Name: stock_ledgers; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_ledgers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    transaction_type public.stock_transaction_type NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    batch_id uuid,
    reference_type character varying(50),
    reference_id uuid,
    notes text,
    balance_after numeric(12,3) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
)
PARTITION BY RANGE (created_at);

ALTER TABLE ONLY inventory.stock_ledgers FORCE ROW LEVEL SECURITY;


--
-- Name: stock_ledgers_y2024m12; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_ledgers_y2024m12 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    transaction_type public.stock_transaction_type NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    batch_id uuid,
    reference_type character varying(50),
    reference_id uuid,
    notes text,
    balance_after numeric(12,3) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY inventory.stock_ledgers_y2024m12 FORCE ROW LEVEL SECURITY;


--
-- Name: stock_ledgers_y2025m01; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_ledgers_y2025m01 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    transaction_type public.stock_transaction_type NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    batch_id uuid,
    reference_type character varying(50),
    reference_id uuid,
    notes text,
    balance_after numeric(12,3) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY inventory.stock_ledgers_y2025m01 FORCE ROW LEVEL SECURITY;


--
-- Name: stock_ledgers_y2025m02; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_ledgers_y2025m02 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    transaction_type public.stock_transaction_type NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    batch_id uuid,
    reference_type character varying(50),
    reference_id uuid,
    notes text,
    balance_after numeric(12,3) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY inventory.stock_ledgers_y2025m02 FORCE ROW LEVEL SECURITY;


--
-- Name: stock_ledgers_y2025m03; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_ledgers_y2025m03 (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    item_id uuid NOT NULL,
    location_id uuid,
    transaction_type public.stock_transaction_type NOT NULL,
    quantity numeric(12,3) NOT NULL,
    unit_cost numeric(14,2),
    batch_id uuid,
    reference_type character varying(50),
    reference_id uuid,
    notes text,
    balance_after numeric(12,3) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY inventory.stock_ledgers_y2025m03 FORCE ROW LEVEL SECURITY;


--
-- Name: stock_locations; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.stock_locations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    parent_id uuid,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    location_type character varying(50) NOT NULL,
    clinical_location_id uuid,
    is_cold_storage boolean DEFAULT false,
    temperature_min numeric(5,2),
    temperature_max numeric(5,2),
    capacity integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY inventory.stock_locations FORCE ROW LEVEL SECURITY;


--
-- Name: suppliers; Type: TABLE; Schema: inventory; Owner: -
--

CREATE TABLE inventory.suppliers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    legal_name character varying(500),
    gstin character varying(20),
    pan character varying(20),
    drug_license_number character varying(100),
    contact_person character varying(255),
    email character varying(255),
    phone character varying(50),
    address jsonb,
    bank_details jsonb,
    payment_terms character varying(100),
    credit_limit numeric(14,2),
    credit_period_days integer,
    rating numeric(3,2),
    is_active boolean DEFAULT true NOT NULL,
    is_approved boolean DEFAULT false,
    approved_at timestamp with time zone,
    approved_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY inventory.suppliers FORCE ROW LEVEL SECURITY;


--
-- Name: alert_configurations; Type: TABLE; Schema: laboratory; Owner: -
--

CREATE TABLE laboratory.alert_configurations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    test_code jsonb NOT NULL,
    test_name character varying(255),
    alert_type character varying(50) NOT NULL,
    critical_low jsonb,
    critical_high jsonb,
    abnormal_low jsonb,
    abnormal_high jsonb,
    delta_percentage numeric(5,2),
    delta_time_window_hours integer,
    notify_doctor boolean DEFAULT true,
    notify_nurse boolean DEFAULT false,
    notify_patient boolean DEFAULT false,
    notify_lab_director boolean DEFAULT false,
    notification_channels text[] DEFAULT ARRAY['sms'::text, 'in_app'::text],
    escalation_enabled boolean DEFAULT false,
    escalation_time_minutes integer,
    escalation_recipients text[],
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);

ALTER TABLE ONLY laboratory.alert_configurations FORCE ROW LEVEL SECURITY;


--
-- Name: quality_controls; Type: TABLE; Schema: laboratory; Owner: -
--

CREATE TABLE laboratory.quality_controls (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    test_code jsonb NOT NULL,
    test_name character varying(255),
    machine_id character varying(100),
    qc_type character varying(50) NOT NULL,
    qc_date date NOT NULL,
    qc_time time without time zone,
    control_lot_number character varying(100),
    control_expiry_date date,
    control_manufacturer character varying(255),
    expected_value jsonb,
    expected_range_low jsonb,
    expected_range_high jsonb,
    observed_value jsonb NOT NULL,
    is_within_range boolean,
    deviation_percentage numeric(5,2),
    status character varying(50) DEFAULT 'pending'::character varying,
    reviewed_by_id uuid,
    reviewed_at timestamp with time zone,
    review_notes text,
    action_taken character varying(100),
    corrective_action text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY laboratory.quality_controls FORCE ROW LEVEL SECURITY;


--
-- Name: samples; Type: TABLE; Schema: laboratory; Owner: -
--

CREATE TABLE laboratory.samples (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    service_request_id uuid NOT NULL,
    sample_number character varying(50) NOT NULL,
    barcode character varying(100),
    qr_code_url text,
    sample_type character varying(100) NOT NULL,
    collection_method character varying(100),
    collection_container character varying(100),
    container_color character varying(50),
    collected_at timestamp with time zone NOT NULL,
    collected_by_id uuid,
    collection_location_id uuid,
    patient_id uuid NOT NULL,
    patient_mrn character varying(50),
    status character varying(50) DEFAULT 'collected'::character varying NOT NULL,
    received_at timestamp with time zone,
    received_by_id uuid,
    rejection_reason text,
    storage_conditions character varying(100),
    storage_location character varying(100),
    expiry_time timestamp with time zone,
    machine_id character varying(100),
    machine_interface_status character varying(50),
    machine_request_id character varying(255),
    quality_status character varying(50) DEFAULT 'acceptable'::character varying,
    quality_notes text,
    volume_ml numeric(8,2),
    quantity character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid
);

ALTER TABLE ONLY laboratory.samples FORCE ROW LEVEL SECURITY;


--
-- Name: appointment_history; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.appointment_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    appointment_id uuid NOT NULL,
    previous_status character varying(50),
    new_status character varying(50) NOT NULL,
    reason text,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    changed_by uuid
);

ALTER TABLE ONLY scheduling.appointment_history FORCE ROW LEVEL SECURITY;


--
-- Name: appointments; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.appointments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    appointment_number character varying(50) NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    status character varying(50) DEFAULT 'proposed'::character varying NOT NULL,
    cancellation_reason jsonb,
    service_category jsonb DEFAULT '[]'::jsonb,
    service_type jsonb DEFAULT '[]'::jsonb,
    specialty jsonb DEFAULT '[]'::jsonb,
    appointment_type jsonb,
    reason_code jsonb DEFAULT '[]'::jsonb,
    reason_reference jsonb DEFAULT '[]'::jsonb,
    priority integer DEFAULT 5,
    description text,
    supporting_info jsonb DEFAULT '[]'::jsonb,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    duration_minutes integer,
    slot_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    booked_at timestamp with time zone,
    patient_id uuid NOT NULL,
    patient_instruction text,
    practitioner_id uuid,
    location_id uuid,
    participants jsonb DEFAULT '[]'::jsonb,
    requested_period jsonb DEFAULT '[]'::jsonb,
    based_on jsonb DEFAULT '[]'::jsonb,
    encounter_id uuid,
    comment text,
    patient_notes text,
    reminder_sent boolean DEFAULT false,
    reminder_sent_at timestamp with time zone,
    checked_in_at timestamp with time zone,
    checked_in_by uuid,
    billing_status character varying(50),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT chk_appointment_times CHECK ((end_time > start_time))
);

ALTER TABLE ONLY scheduling.appointments FORCE ROW LEVEL SECURITY;


--
-- Name: block_schedules; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.block_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    practitioner_id uuid,
    location_id uuid,
    block_type character varying(50) NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    is_all_day boolean DEFAULT false,
    is_recurring boolean DEFAULT false,
    recurrence_rule character varying(255),
    reason text,
    is_active boolean DEFAULT true NOT NULL,
    requires_approval boolean DEFAULT false,
    approved_by uuid,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY scheduling.block_schedules FORCE ROW LEVEL SECURITY;


--
-- Name: queue_tokens; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.queue_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    queue_id uuid NOT NULL,
    token_number character varying(20) NOT NULL,
    token_sequence integer NOT NULL,
    patient_id uuid NOT NULL,
    encounter_id uuid,
    status character varying(50) DEFAULT 'waiting'::character varying NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    called_at timestamp with time zone,
    serving_started_at timestamp with time zone,
    completed_at timestamp with time zone,
    counter_number character varying(20),
    served_by_id uuid,
    estimated_wait_minutes integer,
    priority integer DEFAULT 5,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY scheduling.queue_tokens FORCE ROW LEVEL SECURITY;


--
-- Name: queues; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.queues (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    queue_name character varying(100) NOT NULL,
    location_id uuid,
    department character varying(100),
    token_prefix character varying(10),
    current_token_number integer DEFAULT 0,
    max_concurrent_serving integer DEFAULT 3,
    is_active boolean DEFAULT true NOT NULL,
    is_accepting_new boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY scheduling.queues FORCE ROW LEVEL SECURITY;


--
-- Name: schedules; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    is_active boolean DEFAULT true NOT NULL,
    service_category jsonb DEFAULT '[]'::jsonb,
    service_type jsonb DEFAULT '[]'::jsonb,
    specialty jsonb DEFAULT '[]'::jsonb,
    actor_type character varying(50) NOT NULL,
    practitioner_id uuid,
    location_id uuid,
    device_id uuid,
    planning_horizon_start timestamp with time zone NOT NULL,
    planning_horizon_end timestamp with time zone NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY scheduling.schedules FORCE ROW LEVEL SECURITY;


--
-- Name: slots; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.slots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    identifiers jsonb DEFAULT '[]'::jsonb,
    service_category jsonb DEFAULT '[]'::jsonb,
    service_type jsonb DEFAULT '[]'::jsonb,
    specialty jsonb DEFAULT '[]'::jsonb,
    appointment_type jsonb,
    schedule_id uuid NOT NULL,
    status character varying(50) DEFAULT 'free'::character varying NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    duration_minutes integer GENERATED ALWAYS AS ((EXTRACT(epoch FROM (end_time - start_time)) / (60)::numeric)) STORED,
    is_overbooked boolean DEFAULT false,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_slot_times CHECK ((end_time > start_time))
);

ALTER TABLE ONLY scheduling.slots FORCE ROW LEVEL SECURITY;


--
-- Name: waitlist; Type: TABLE; Schema: scheduling; Owner: -
--

CREATE TABLE scheduling.waitlist (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    service_type jsonb,
    specialty jsonb,
    preferred_practitioner_id uuid,
    preferred_location_id uuid,
    priority integer DEFAULT 5,
    preferred_date_start date NOT NULL,
    preferred_date_end date,
    preferred_time_of_day character varying(50),
    status character varying(50) DEFAULT 'waiting'::character varying NOT NULL,
    offered_appointment_id uuid,
    offered_at timestamp with time zone,
    offer_expires_at timestamp with time zone,
    scheduled_appointment_id uuid,
    notes text,
    contact_preference character varying(50) DEFAULT 'phone'::character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY scheduling.waitlist FORCE ROW LEVEL SECURITY;


--
-- Name: code_systems; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.code_systems (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    url character varying(500) NOT NULL,
    identifier character varying(100) NOT NULL,
    version character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(500),
    publisher character varying(255),
    copyright text,
    status character varying(50) DEFAULT 'active'::character varying,
    experimental boolean DEFAULT false,
    case_sensitive boolean DEFAULT false,
    value_set character varying(500),
    hierarchy_meaning character varying(50),
    compositional boolean DEFAULT false,
    version_needed boolean DEFAULT false,
    content character varying(50) DEFAULT 'complete'::character varying,
    count integer,
    filters jsonb DEFAULT '[]'::jsonb,
    properties jsonb DEFAULT '[]'::jsonb,
    concepts jsonb DEFAULT '[]'::jsonb,
    supplements jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    last_updated timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY terminology.code_systems FORCE ROW LEVEL SECURITY;


--
-- Name: concept_map_elements; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.concept_map_elements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    concept_map_id uuid NOT NULL,
    code character varying(100) NOT NULL,
    display character varying(500),
    target jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: concept_maps; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.concept_maps (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    url character varying(500) NOT NULL,
    identifier character varying(100),
    version character varying(50),
    name character varying(255) NOT NULL,
    title character varying(500),
    status character varying(50) DEFAULT 'draft'::character varying,
    experimental boolean DEFAULT false,
    publisher character varying(255),
    source_uri character varying(500),
    target_uri character varying(500),
    source_version character varying(50),
    target_version character varying(50),
    "group" jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY terminology.concept_maps FORCE ROW LEVEL SECURITY;


--
-- Name: concepts; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.concepts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code_system_id uuid NOT NULL,
    tenant_id uuid,
    code character varying(100) NOT NULL,
    display character varying(500) NOT NULL,
    definition text,
    designation jsonb DEFAULT '[]'::jsonb,
    property jsonb DEFAULT '[]'::jsonb,
    parent_concept_id uuid,
    is_abstract boolean DEFAULT false,
    is_inactive boolean DEFAULT false,
    inactive_reason character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY terminology.concepts FORCE ROW LEVEL SECURITY;


--
-- Name: value_set_concepts; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.value_set_concepts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    value_set_id uuid NOT NULL,
    concept_id uuid NOT NULL,
    sort_order integer
);


--
-- Name: value_sets; Type: TABLE; Schema: terminology; Owner: -
--

CREATE TABLE terminology.value_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    url character varying(500) NOT NULL,
    identifier character varying(100) NOT NULL,
    version character varying(50) DEFAULT '1.0.0'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    title character varying(500),
    description text,
    compose jsonb,
    expansion jsonb,
    use_context jsonb,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: dim_patients; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.dim_patients (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    patient_key text NOT NULL,
    gender text,
    birth_year integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY warehouse.dim_patients FORCE ROW LEVEL SECURITY;


--
-- Name: dim_tenants; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.dim_tenants (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    tenant_name text,
    facility_type text,
    city text,
    state text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY warehouse.dim_tenants FORCE ROW LEVEL SECURITY;


--
-- Name: fact_encounters; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.fact_encounters (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid NOT NULL,
    patient_id uuid,
    class text,
    status text,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone,
    department text,
    location_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (start_at);

ALTER TABLE ONLY warehouse.fact_encounters FORCE ROW LEVEL SECURITY;


--
-- Name: fact_encounters_2025_01; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.fact_encounters_2025_01 (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    encounter_id uuid NOT NULL,
    patient_id uuid,
    class text,
    status text,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone,
    department text,
    location_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: fact_invoices; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.fact_invoices (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    patient_id uuid,
    status text,
    invoice_date date,
    gross_amount numeric,
    net_amount numeric,
    payer_type text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY warehouse.fact_invoices FORCE ROW LEVEL SECURITY;


--
-- Name: fact_stock_movements; Type: TABLE; Schema: warehouse; Owner: -
--

CREATE TABLE warehouse.fact_stock_movements (
    org_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    movement_id uuid NOT NULL,
    item_id uuid,
    movement_type text,
    qty numeric,
    occurred_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (occurred_at);

ALTER TABLE ONLY warehouse.fact_stock_movements FORCE ROW LEVEL SECURITY;


--
-- Name: v_org_kpis; Type: VIEW; Schema: warehouse; Owner: -
--

CREATE VIEW warehouse.v_org_kpis AS
 SELECT org_id,
    (date_trunc('month'::text, start_at))::date AS month,
    count(*) FILTER (WHERE (class = 'inpatient'::text)) AS inpatient_encounters,
    count(*) FILTER (WHERE (class = 'outpatient'::text)) AS outpatient_encounters,
    count(*) AS total_encounters
   FROM warehouse.fact_encounters
  GROUP BY org_id, ((date_trunc('month'::text, start_at))::date);


--
-- Name: patient_merge_events_default; Type: TABLE ATTACH; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_events ATTACH PARTITION clinical.patient_merge_events_default DEFAULT;


--
-- Name: notifications_y2024m12; Type: TABLE ATTACH; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications ATTACH PARTITION communication.notifications_y2024m12 FOR VALUES FROM ('2024-12-01 00:00:00+00') TO ('2025-01-01 00:00:00+00');


--
-- Name: notifications_y2025m01; Type: TABLE ATTACH; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications ATTACH PARTITION communication.notifications_y2025m01 FOR VALUES FROM ('2025-01-01 00:00:00+00') TO ('2025-02-01 00:00:00+00');


--
-- Name: notifications_y2025m02; Type: TABLE ATTACH; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications ATTACH PARTITION communication.notifications_y2025m02 FOR VALUES FROM ('2025-02-01 00:00:00+00') TO ('2025-03-01 00:00:00+00');


--
-- Name: notifications_y2025m03; Type: TABLE ATTACH; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications ATTACH PARTITION communication.notifications_y2025m03 FOR VALUES FROM ('2025-03-01 00:00:00+00') TO ('2025-04-01 00:00:00+00');


--
-- Name: audit_logs_y2024m12; Type: TABLE ATTACH; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs ATTACH PARTITION core.audit_logs_y2024m12 FOR VALUES FROM ('2024-12-01 00:00:00+00') TO ('2025-01-01 00:00:00+00');


--
-- Name: audit_logs_y2025m01; Type: TABLE ATTACH; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs ATTACH PARTITION core.audit_logs_y2025m01 FOR VALUES FROM ('2025-01-01 00:00:00+00') TO ('2025-02-01 00:00:00+00');


--
-- Name: audit_logs_y2025m02; Type: TABLE ATTACH; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs ATTACH PARTITION core.audit_logs_y2025m02 FOR VALUES FROM ('2025-02-01 00:00:00+00') TO ('2025-03-01 00:00:00+00');


--
-- Name: audit_logs_y2025m03; Type: TABLE ATTACH; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs ATTACH PARTITION core.audit_logs_y2025m03 FOR VALUES FROM ('2025-03-01 00:00:00+00') TO ('2025-04-01 00:00:00+00');


--
-- Name: hl7_message_log_y2024m12; Type: TABLE ATTACH; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log ATTACH PARTITION integration.hl7_message_log_y2024m12 FOR VALUES FROM ('2024-12-01 00:00:00+00') TO ('2025-01-01 00:00:00+00');


--
-- Name: hl7_message_log_y2025m01; Type: TABLE ATTACH; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log ATTACH PARTITION integration.hl7_message_log_y2025m01 FOR VALUES FROM ('2025-01-01 00:00:00+00') TO ('2025-02-01 00:00:00+00');


--
-- Name: hl7_message_log_y2025m02; Type: TABLE ATTACH; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log ATTACH PARTITION integration.hl7_message_log_y2025m02 FOR VALUES FROM ('2025-02-01 00:00:00+00') TO ('2025-03-01 00:00:00+00');


--
-- Name: hl7_message_log_y2025m03; Type: TABLE ATTACH; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log ATTACH PARTITION integration.hl7_message_log_y2025m03 FOR VALUES FROM ('2025-03-01 00:00:00+00') TO ('2025-04-01 00:00:00+00');


--
-- Name: stock_ledgers_y2024m12; Type: TABLE ATTACH; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers ATTACH PARTITION inventory.stock_ledgers_y2024m12 FOR VALUES FROM ('2024-12-01 00:00:00+00') TO ('2025-01-01 00:00:00+00');


--
-- Name: stock_ledgers_y2025m01; Type: TABLE ATTACH; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers ATTACH PARTITION inventory.stock_ledgers_y2025m01 FOR VALUES FROM ('2025-01-01 00:00:00+00') TO ('2025-02-01 00:00:00+00');


--
-- Name: stock_ledgers_y2025m02; Type: TABLE ATTACH; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers ATTACH PARTITION inventory.stock_ledgers_y2025m02 FOR VALUES FROM ('2025-02-01 00:00:00+00') TO ('2025-03-01 00:00:00+00');


--
-- Name: stock_ledgers_y2025m03; Type: TABLE ATTACH; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers ATTACH PARTITION inventory.stock_ledgers_y2025m03 FOR VALUES FROM ('2025-03-01 00:00:00+00') TO ('2025-04-01 00:00:00+00');


--
-- Name: fact_encounters_2025_01; Type: TABLE ATTACH; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_encounters ATTACH PARTITION warehouse.fact_encounters_2025_01 FOR VALUES FROM ('2025-01-01 00:00:00+00') TO ('2025-02-01 00:00:00+00');


--
-- Name: abdm_care_contexts abdm_care_contexts_care_context_reference_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_care_context_reference_key UNIQUE (care_context_reference);


--
-- Name: abdm_care_contexts abdm_care_contexts_pkey; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_pkey PRIMARY KEY (id);


--
-- Name: abdm_care_contexts abdm_care_contexts_tenant_id_care_context_reference_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_tenant_id_care_context_reference_key UNIQUE (tenant_id, care_context_reference);


--
-- Name: abdm_care_contexts abdm_care_contexts_tenant_id_id_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: abdm_registrations abdm_registrations_abha_number_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_registrations
    ADD CONSTRAINT abdm_registrations_abha_number_key UNIQUE (abha_number);


--
-- Name: abdm_registrations abdm_registrations_pkey; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_registrations
    ADD CONSTRAINT abdm_registrations_pkey PRIMARY KEY (id);


--
-- Name: abdm_registrations abdm_registrations_tenant_id_abha_number_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_registrations
    ADD CONSTRAINT abdm_registrations_tenant_id_abha_number_key UNIQUE (tenant_id, abha_number);


--
-- Name: abdm_registrations abdm_registrations_tenant_id_id_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_registrations
    ADD CONSTRAINT abdm_registrations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: hiu_data_requests hiu_data_requests_pkey; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_pkey PRIMARY KEY (id);


--
-- Name: hiu_data_requests hiu_data_requests_request_id_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_request_id_key UNIQUE (request_id);


--
-- Name: hiu_data_requests hiu_data_requests_tenant_id_id_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: hiu_data_requests hiu_data_requests_tenant_id_request_id_key; Type: CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_tenant_id_request_id_key UNIQUE (tenant_id, request_id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_tenant_id_account_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.accounts
    ADD CONSTRAINT accounts_tenant_id_account_number_key UNIQUE (tenant_id, account_number);


--
-- Name: accounts accounts_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.accounts
    ADD CONSTRAINT accounts_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: insurance_claims insurance_claims_nhcx_bundle_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_nhcx_bundle_id_key UNIQUE (nhcx_bundle_id);


--
-- Name: insurance_claims insurance_claims_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_pkey PRIMARY KEY (id);


--
-- Name: insurance_claims insurance_claims_tenant_id_claim_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_tenant_id_claim_number_key UNIQUE (tenant_id, claim_number);


--
-- Name: insurance_claims insurance_claims_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: insurance_companies insurance_companies_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_companies
    ADD CONSTRAINT insurance_companies_pkey PRIMARY KEY (id);


--
-- Name: insurance_companies insurance_companies_tenant_id_code_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_companies
    ADD CONSTRAINT insurance_companies_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: insurance_companies insurance_companies_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_companies
    ADD CONSTRAINT insurance_companies_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: insurance_policies insurance_policies_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_policies
    ADD CONSTRAINT insurance_policies_pkey PRIMARY KEY (id);


--
-- Name: insurance_policies insurance_policies_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_policies
    ADD CONSTRAINT insurance_policies_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: insurance_policies insurance_policies_tenant_id_patient_id_policy_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_policies
    ADD CONSTRAINT insurance_policies_tenant_id_patient_id_policy_number_key UNIQUE (tenant_id, patient_id, policy_number);


--
-- Name: invoice_line_items invoice_line_items_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_line_items
    ADD CONSTRAINT invoice_line_items_pkey PRIMARY KEY (id);


--
-- Name: invoice_line_items invoice_line_items_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_line_items
    ADD CONSTRAINT invoice_line_items_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: invoices invoices_tenant_id_invoice_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_tenant_id_invoice_number_key UNIQUE (tenant_id, invoice_number);


--
-- Name: payment_allocations payment_allocations_payment_id_invoice_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_payment_id_invoice_id_key UNIQUE (payment_id, invoice_id);


--
-- Name: payment_allocations payment_allocations_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_pkey PRIMARY KEY (id);


--
-- Name: payment_allocations payment_allocations_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: payments payments_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: payments payments_tenant_id_payment_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_tenant_id_payment_number_key UNIQUE (tenant_id, payment_number);


--
-- Name: pre_authorizations pre_authorizations_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_pkey PRIMARY KEY (id);


--
-- Name: pre_authorizations pre_authorizations_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: pre_authorizations pre_authorizations_tenant_id_preauth_number_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_tenant_id_preauth_number_key UNIQUE (tenant_id, preauth_number);


--
-- Name: price_list_items price_list_items_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_pkey PRIMARY KEY (id);


--
-- Name: price_list_items price_list_items_price_list_id_service_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_price_list_id_service_id_key UNIQUE (price_list_id, service_id);


--
-- Name: price_list_items price_list_items_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: price_lists price_lists_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_lists
    ADD CONSTRAINT price_lists_pkey PRIMARY KEY (id);


--
-- Name: price_lists price_lists_tenant_id_code_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_lists
    ADD CONSTRAINT price_lists_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: price_lists price_lists_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_lists
    ADD CONSTRAINT price_lists_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: service_masters service_masters_pkey; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.service_masters
    ADD CONSTRAINT service_masters_pkey PRIMARY KEY (id);


--
-- Name: service_masters service_masters_tenant_id_code_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.service_masters
    ADD CONSTRAINT service_masters_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: service_masters service_masters_tenant_id_id_key; Type: CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.service_masters
    ADD CONSTRAINT service_masters_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: blood_units blood_units_barcode_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_barcode_key UNIQUE (barcode);


--
-- Name: blood_units blood_units_pkey; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_pkey PRIMARY KEY (id);


--
-- Name: blood_units blood_units_tenant_id_id_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: blood_units blood_units_unit_number_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_unit_number_key UNIQUE (unit_number);


--
-- Name: cross_matches cross_matches_pkey; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.cross_matches
    ADD CONSTRAINT cross_matches_pkey PRIMARY KEY (id);


--
-- Name: cross_matches cross_matches_tenant_id_id_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.cross_matches
    ADD CONSTRAINT cross_matches_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: donors donors_pkey; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.donors
    ADD CONSTRAINT donors_pkey PRIMARY KEY (id);


--
-- Name: donors donors_tenant_id_donor_number_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.donors
    ADD CONSTRAINT donors_tenant_id_donor_number_key UNIQUE (tenant_id, donor_number);


--
-- Name: donors donors_tenant_id_id_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.donors
    ADD CONSTRAINT donors_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: transfusions transfusions_pkey; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_pkey PRIMARY KEY (id);


--
-- Name: transfusions transfusions_tenant_id_id_key; Type: CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: allergy_intolerances allergy_intolerances_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.allergy_intolerances
    ADD CONSTRAINT allergy_intolerances_pkey PRIMARY KEY (id);


--
-- Name: allergy_intolerances allergy_intolerances_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.allergy_intolerances
    ADD CONSTRAINT allergy_intolerances_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: anesthesia_records anesthesia_records_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.anesthesia_records
    ADD CONSTRAINT anesthesia_records_pkey PRIMARY KEY (id);


--
-- Name: anesthesia_records anesthesia_records_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.anesthesia_records
    ADD CONSTRAINT anesthesia_records_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: beds beds_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.beds
    ADD CONSTRAINT beds_pkey PRIMARY KEY (id);


--
-- Name: beds beds_tenant_id_bed_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.beds
    ADD CONSTRAINT beds_tenant_id_bed_number_key UNIQUE (tenant_id, bed_number);


--
-- Name: beds beds_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.beds
    ADD CONSTRAINT beds_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: break_glass_sessions break_glass_sessions_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.break_glass_sessions
    ADD CONSTRAINT break_glass_sessions_pkey PRIMARY KEY (id);


--
-- Name: break_glass_sessions break_glass_sessions_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.break_glass_sessions
    ADD CONSTRAINT break_glass_sessions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: care_plans care_plans_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_pkey PRIMARY KEY (id);


--
-- Name: care_plans care_plans_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: care_plans care_plans_tenant_id_plan_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_tenant_id_plan_number_key UNIQUE (tenant_id, plan_number);


--
-- Name: clinical_notes clinical_notes_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_pkey PRIMARY KEY (id);


--
-- Name: clinical_notes clinical_notes_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: diagnostic_reports diagnostic_reports_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_pkey PRIMARY KEY (id);


--
-- Name: diagnostic_reports diagnostic_reports_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: discharge_summaries discharge_summaries_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_pkey PRIMARY KEY (id);


--
-- Name: discharge_summaries discharge_summaries_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: discharge_summaries discharge_summaries_tenant_id_summary_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_tenant_id_summary_number_key UNIQUE (tenant_id, summary_number);


--
-- Name: encounter_care_team_members encounter_care_team_members_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT encounter_care_team_members_pkey PRIMARY KEY (id);


--
-- Name: encounters encounters_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_pkey PRIMARY KEY (id);


--
-- Name: encounters encounters_tenant_id_encounter_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_tenant_id_encounter_number_key UNIQUE (tenant_id, encounter_number);


--
-- Name: encounters encounters_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: episode_of_care episode_of_care_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.episode_of_care
    ADD CONSTRAINT episode_of_care_pkey PRIMARY KEY (id);


--
-- Name: episode_of_care episode_of_care_tenant_id_episode_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.episode_of_care
    ADD CONSTRAINT episode_of_care_tenant_id_episode_number_key UNIQUE (tenant_id, episode_number);


--
-- Name: episode_of_care episode_of_care_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.episode_of_care
    ADD CONSTRAINT episode_of_care_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: external_fulfillments external_fulfillments_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.external_fulfillments
    ADD CONSTRAINT external_fulfillments_pkey PRIMARY KEY (id);


--
-- Name: icu_beds icu_beds_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.icu_beds
    ADD CONSTRAINT icu_beds_pkey PRIMARY KEY (id);


--
-- Name: icu_beds icu_beds_tenant_id_bed_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.icu_beds
    ADD CONSTRAINT icu_beds_tenant_id_bed_number_key UNIQUE (tenant_id, bed_number);


--
-- Name: icu_beds icu_beds_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.icu_beds
    ADD CONSTRAINT icu_beds_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: locations locations_tenant_id_code_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.locations
    ADD CONSTRAINT locations_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: locations locations_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.locations
    ADD CONSTRAINT locations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: medication_administrations medication_administrations_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT medication_administrations_pkey PRIMARY KEY (id);


--
-- Name: medication_administrations medication_administrations_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT medication_administrations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: medication_requests medication_requests_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_pkey PRIMARY KEY (id);


--
-- Name: medication_requests medication_requests_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: medico_legal_cases medico_legal_cases_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_pkey PRIMARY KEY (id);


--
-- Name: medico_legal_cases medico_legal_cases_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: medico_legal_cases medico_legal_cases_tenant_id_mlc_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_tenant_id_mlc_number_key UNIQUE (tenant_id, mlc_number);


--
-- Name: nursing_tasks nursing_tasks_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.nursing_tasks
    ADD CONSTRAINT nursing_tasks_pkey PRIMARY KEY (id);


--
-- Name: nursing_tasks nursing_tasks_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.nursing_tasks
    ADD CONSTRAINT nursing_tasks_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: observations observations_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_pkey PRIMARY KEY (id);


--
-- Name: observations observations_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: operation_theatres operation_theatres_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.operation_theatres
    ADD CONSTRAINT operation_theatres_pkey PRIMARY KEY (id);


--
-- Name: operation_theatres operation_theatres_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.operation_theatres
    ADD CONSTRAINT operation_theatres_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: operation_theatres operation_theatres_tenant_id_ot_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.operation_theatres
    ADD CONSTRAINT operation_theatres_tenant_id_ot_number_key UNIQUE (tenant_id, ot_number);


--
-- Name: patient_consent_directives patient_consent_directives_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_consent_directives
    ADD CONSTRAINT patient_consent_directives_pkey PRIMARY KEY (id);


--
-- Name: patient_identifiers patient_identifiers_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_identifiers
    ADD CONSTRAINT patient_identifiers_pkey PRIMARY KEY (id);


--
-- Name: patient_merge_events patient_merge_events_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_events_pkey PRIMARY KEY (id, event_at);


--
-- Name: patient_merge_events_default patient_merge_events_default_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_events_default
    ADD CONSTRAINT patient_merge_events_default_pkey PRIMARY KEY (id, event_at);


--
-- Name: patient_merge_undo_events patient_merge_undo_events_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_undo_events
    ADD CONSTRAINT patient_merge_undo_events_pkey PRIMARY KEY (id);


--
-- Name: patient_sensitivity patient_sensitivity_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_sensitivity
    ADD CONSTRAINT patient_sensitivity_pkey PRIMARY KEY (id);


--
-- Name: patient_sensitivity patient_sensitivity_tenant_id_patient_id_label_code_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_sensitivity
    ADD CONSTRAINT patient_sensitivity_tenant_id_patient_id_label_code_key UNIQUE (tenant_id, patient_id, label_code);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: patients patients_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: patients patients_tenant_id_mrn_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_tenant_id_mrn_key UNIQUE (tenant_id, mrn);


--
-- Name: practitioners practitioners_hpr_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_hpr_id_key UNIQUE (hpr_id);


--
-- Name: practitioners practitioners_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_pkey PRIMARY KEY (id);


--
-- Name: practitioners practitioners_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: practitioners practitioners_tenant_id_registration_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_tenant_id_registration_number_key UNIQUE (tenant_id, registration_number);


--
-- Name: resource_sensitivity resource_sensitivity_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.resource_sensitivity
    ADD CONSTRAINT resource_sensitivity_pkey PRIMARY KEY (id);


--
-- Name: resource_sensitivity resource_sensitivity_tenant_id_resource_type_resource_id_la_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.resource_sensitivity
    ADD CONSTRAINT resource_sensitivity_tenant_id_resource_type_resource_id_la_key UNIQUE (tenant_id, resource_type, resource_id, label_code);


--
-- Name: sensitive_access_log sensitive_access_log_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.sensitive_access_log
    ADD CONSTRAINT sensitive_access_log_pkey PRIMARY KEY (id);


--
-- Name: sensitivity_labels sensitivity_labels_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.sensitivity_labels
    ADD CONSTRAINT sensitivity_labels_pkey PRIMARY KEY (id);


--
-- Name: sensitivity_labels sensitivity_labels_tenant_id_code_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.sensitivity_labels
    ADD CONSTRAINT sensitivity_labels_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: service_requests service_requests_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_pkey PRIMARY KEY (id);


--
-- Name: service_requests service_requests_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: service_requests service_requests_tenant_id_request_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_tenant_id_request_number_key UNIQUE (tenant_id, request_number);


--
-- Name: shift_handovers shift_handovers_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.shift_handovers
    ADD CONSTRAINT shift_handovers_pkey PRIMARY KEY (id);


--
-- Name: shift_handovers shift_handovers_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.shift_handovers
    ADD CONSTRAINT shift_handovers_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: surgeries surgeries_pkey; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_pkey PRIMARY KEY (id);


--
-- Name: surgeries surgeries_tenant_id_id_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: surgeries surgeries_tenant_id_surgery_number_key; Type: CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_tenant_id_surgery_number_key UNIQUE (tenant_id, surgery_number);


--
-- Name: bulk_campaigns bulk_campaigns_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.bulk_campaigns
    ADD CONSTRAINT bulk_campaigns_pkey PRIMARY KEY (id);


--
-- Name: bulk_campaigns bulk_campaigns_tenant_id_id_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.bulk_campaigns
    ADD CONSTRAINT bulk_campaigns_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: notification_channels notification_channels_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_channels
    ADD CONSTRAINT notification_channels_pkey PRIMARY KEY (id);


--
-- Name: notification_channels notification_channels_tenant_id_id_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_channels
    ADD CONSTRAINT notification_channels_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: notification_logs notification_logs_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_logs
    ADD CONSTRAINT notification_logs_pkey PRIMARY KEY (id);


--
-- Name: notification_logs notification_logs_tenant_id_id_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_logs
    ADD CONSTRAINT notification_logs_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: notification_templates notification_templates_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_templates
    ADD CONSTRAINT notification_templates_pkey PRIMARY KEY (id);


--
-- Name: notification_templates notification_templates_tenant_id_code_channel_type_locale_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_templates
    ADD CONSTRAINT notification_templates_tenant_id_code_channel_type_locale_key UNIQUE (tenant_id, code, channel_type, locale);


--
-- Name: notification_templates notification_templates_tenant_id_id_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_templates
    ADD CONSTRAINT notification_templates_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id, created_at);


--
-- Name: notifications_y2024m12 notifications_y2024m12_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications_y2024m12
    ADD CONSTRAINT notifications_y2024m12_pkey PRIMARY KEY (id, created_at);


--
-- Name: notifications_y2025m01 notifications_y2025m01_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications_y2025m01
    ADD CONSTRAINT notifications_y2025m01_pkey PRIMARY KEY (id, created_at);


--
-- Name: notifications_y2025m02 notifications_y2025m02_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications_y2025m02
    ADD CONSTRAINT notifications_y2025m02_pkey PRIMARY KEY (id, created_at);


--
-- Name: notifications_y2025m03 notifications_y2025m03_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notifications_y2025m03
    ADD CONSTRAINT notifications_y2025m03_pkey PRIMARY KEY (id, created_at);


--
-- Name: user_notification_preferences user_notification_preferences_pkey; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_pkey PRIMARY KEY (id);


--
-- Name: user_notification_preferences user_notification_preferences_tenant_id_id_key; Type: CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: api_clients api_clients_client_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_clients
    ADD CONSTRAINT api_clients_client_id_key UNIQUE (client_id);


--
-- Name: api_clients api_clients_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_clients
    ADD CONSTRAINT api_clients_pkey PRIMARY KEY (id);


--
-- Name: api_clients api_clients_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_clients
    ADD CONSTRAINT api_clients_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: api_keys api_keys_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_keys
    ADD CONSTRAINT api_keys_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: api_rate_limits api_rate_limits_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_rate_limits
    ADD CONSTRAINT api_rate_limits_pkey PRIMARY KEY (id);


--
-- Name: api_rate_limits api_rate_limits_tier_name_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_rate_limits
    ADD CONSTRAINT api_rate_limits_tier_name_key UNIQUE (tier_name);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id, occurred_at);


--
-- Name: audit_logs_y2024m12 audit_logs_y2024m12_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2024m12
    ADD CONSTRAINT audit_logs_y2024m12_pkey PRIMARY KEY (id, occurred_at);


--
-- Name: audit_logs_y2025m01 audit_logs_y2025m01_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m01
    ADD CONSTRAINT audit_logs_y2025m01_pkey PRIMARY KEY (id, occurred_at);


--
-- Name: audit_logs_y2025m02 audit_logs_y2025m02_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m02
    ADD CONSTRAINT audit_logs_y2025m02_pkey PRIMARY KEY (id, occurred_at);


--
-- Name: audit_logs_y2025m03 audit_logs_y2025m03_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m03
    ADD CONSTRAINT audit_logs_y2025m03_pkey PRIMARY KEY (id, occurred_at);


--
-- Name: consent_logs consent_logs_consent_artifact_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.consent_logs
    ADD CONSTRAINT consent_logs_consent_artifact_id_key UNIQUE (consent_artifact_id);


--
-- Name: consent_logs consent_logs_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.consent_logs
    ADD CONSTRAINT consent_logs_pkey PRIMARY KEY (id);


--
-- Name: consent_logs consent_logs_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.consent_logs
    ADD CONSTRAINT consent_logs_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: data_deletion_requests data_deletion_requests_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.data_deletion_requests
    ADD CONSTRAINT data_deletion_requests_pkey PRIMARY KEY (id);


--
-- Name: data_deletion_requests data_deletion_requests_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.data_deletion_requests
    ADD CONSTRAINT data_deletion_requests_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: data_deletion_requests data_deletion_requests_tenant_id_request_number_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.data_deletion_requests
    ADD CONSTRAINT data_deletion_requests_tenant_id_request_number_key UNIQUE (tenant_id, request_number);


--
-- Name: external_organizations external_organizations_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_organizations
    ADD CONSTRAINT external_organizations_pkey PRIMARY KEY (id);


--
-- Name: external_organizations external_orgs_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_organizations
    ADD CONSTRAINT external_orgs_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: external_practitioners external_pract_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_practitioners
    ADD CONSTRAINT external_pract_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: external_practitioners external_practitioners_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_practitioners
    ADD CONSTRAINT external_practitioners_pkey PRIMARY KEY (id);


--
-- Name: external_service_agreements external_service_agreements_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_service_agreements
    ADD CONSTRAINT external_service_agreements_pkey PRIMARY KEY (id);


--
-- Name: feature_flags feature_flags_key_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.feature_flags
    ADD CONSTRAINT feature_flags_key_key UNIQUE (key);


--
-- Name: feature_flags feature_flags_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: organization_members organization_members_org_id_user_id_role_effective_from_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_members
    ADD CONSTRAINT organization_members_org_id_user_id_role_effective_from_key UNIQUE (org_id, user_id, role, effective_from);


--
-- Name: organization_members organization_members_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_members
    ADD CONSTRAINT organization_members_pkey PRIMARY KEY (id);


--
-- Name: organization_tenant_memberships organization_tenant_memberships_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_tenant_memberships
    ADD CONSTRAINT organization_tenant_memberships_pkey PRIMARY KEY (id);


--
-- Name: organization_tenant_memberships organization_tenant_memberships_tenant_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_tenant_memberships
    ADD CONSTRAINT organization_tenant_memberships_tenant_id_key UNIQUE (tenant_id) DEFERRABLE;


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: otp_verifications otp_verifications_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.otp_verifications
    ADD CONSTRAINT otp_verifications_pkey PRIMARY KEY (id);


--
-- Name: otp_verifications otp_verifications_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.otp_verifications
    ADD CONSTRAINT otp_verifications_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: password_policies password_policies_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.password_policies
    ADD CONSTRAINT password_policies_pkey PRIMARY KEY (id);


--
-- Name: password_policies password_policies_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.password_policies
    ADD CONSTRAINT password_policies_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_resource_action_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.permissions
    ADD CONSTRAINT permissions_resource_action_key UNIQUE (resource, action);


--
-- Name: retention_policies retention_policies_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.retention_policies
    ADD CONSTRAINT retention_policies_pkey PRIMARY KEY (id);


--
-- Name: retention_policies retention_policies_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.retention_policies
    ADD CONSTRAINT retention_policies_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_role_id_permission_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.role_permissions
    ADD CONSTRAINT role_permissions_role_id_permission_id_key UNIQUE (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_tenant_id_code_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.roles
    ADD CONSTRAINT roles_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: roles roles_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.roles
    ADD CONSTRAINT roles_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: schema_versions schema_versions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.schema_versions
    ADD CONSTRAINT schema_versions_pkey PRIMARY KEY (version);


--
-- Name: subscription_plans subscription_plans_code_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.subscription_plans
    ADD CONSTRAINT subscription_plans_code_key UNIQUE (code);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: system_configurations system_configurations_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.system_configurations
    ADD CONSTRAINT system_configurations_pkey PRIMARY KEY (id);


--
-- Name: system_configurations system_configurations_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.system_configurations
    ADD CONSTRAINT system_configurations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: tenant_subscriptions tenant_subscriptions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_subscriptions
    ADD CONSTRAINT tenant_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tenant_subscriptions tenant_subscriptions_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_subscriptions
    ADD CONSTRAINT tenant_subscriptions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: tenants tenants_code_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenants
    ADD CONSTRAINT tenants_code_key UNIQUE (code);


--
-- Name: tenants tenants_hfr_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenants
    ADD CONSTRAINT tenants_hfr_id_key UNIQUE (hfr_id);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: usage_metrics usage_metrics_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usage_metrics
    ADD CONSTRAINT usage_metrics_pkey PRIMARY KEY (id);


--
-- Name: usage_metrics usage_metrics_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usage_metrics
    ADD CONSTRAINT usage_metrics_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: usage_metrics usage_metrics_tenant_id_metric_type_period_start_period_end_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usage_metrics
    ADD CONSTRAINT usage_metrics_tenant_id_metric_type_period_start_period_end_key UNIQUE (tenant_id, metric_type, period_start, period_end);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: user_roles user_roles_tenant_id_user_id_role_id_department_id_location_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_tenant_id_user_id_role_id_department_id_location_key UNIQUE (tenant_id, user_id, role_id, department_id, location_id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_session_token_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_sessions
    ADD CONSTRAINT user_sessions_session_token_key UNIQUE (session_token);


--
-- Name: user_sessions user_sessions_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_sessions
    ADD CONSTRAINT user_sessions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_tenant_id_email_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.users
    ADD CONSTRAINT users_tenant_id_email_key UNIQUE (tenant_id, email);


--
-- Name: users users_tenant_id_id_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.users
    ADD CONSTRAINT users_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: users users_tenant_id_username_key; Type: CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.users
    ADD CONSTRAINT users_tenant_id_username_key UNIQUE (tenant_id, username);


--
-- Name: document_access_log document_access_log_pkey; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_access_log
    ADD CONSTRAINT document_access_log_pkey PRIMARY KEY (id);


--
-- Name: document_access_log document_access_log_tenant_id_id_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_access_log
    ADD CONSTRAINT document_access_log_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: document_types document_types_tenant_id_id_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_types
    ADD CONSTRAINT document_types_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: document_versions document_versions_document_id_version_number_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_document_id_version_number_key UNIQUE (document_id, version_number);


--
-- Name: document_versions document_versions_pkey; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_pkey PRIMARY KEY (id);


--
-- Name: document_versions document_versions_tenant_id_id_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: documents documents_tenant_id_document_number_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_tenant_id_document_number_key UNIQUE (tenant_id, document_number);


--
-- Name: documents documents_tenant_id_id_key; Type: CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: imaging_orders imaging_orders_pkey; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_pkey PRIMARY KEY (id);


--
-- Name: imaging_orders imaging_orders_tenant_id_id_key; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: imaging_orders imaging_orders_tenant_id_order_number_key; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_tenant_id_order_number_key UNIQUE (tenant_id, order_number);


--
-- Name: imaging_studies imaging_studies_pkey; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_studies
    ADD CONSTRAINT imaging_studies_pkey PRIMARY KEY (id);


--
-- Name: imaging_studies imaging_studies_tenant_id_dicom_study_uid_key; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_studies
    ADD CONSTRAINT imaging_studies_tenant_id_dicom_study_uid_key UNIQUE (tenant_id, dicom_study_uid);


--
-- Name: imaging_studies imaging_studies_tenant_id_id_key; Type: CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_studies
    ADD CONSTRAINT imaging_studies_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: hl7_message_log hl7_message_log_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log
    ADD CONSTRAINT hl7_message_log_pkey PRIMARY KEY (id, received_at);


--
-- Name: hl7_message_log_y2024m12 hl7_message_log_y2024m12_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log_y2024m12
    ADD CONSTRAINT hl7_message_log_y2024m12_pkey PRIMARY KEY (id, received_at);


--
-- Name: hl7_message_log_y2025m01 hl7_message_log_y2025m01_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log_y2025m01
    ADD CONSTRAINT hl7_message_log_y2025m01_pkey PRIMARY KEY (id, received_at);


--
-- Name: hl7_message_log_y2025m02 hl7_message_log_y2025m02_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log_y2025m02
    ADD CONSTRAINT hl7_message_log_y2025m02_pkey PRIMARY KEY (id, received_at);


--
-- Name: hl7_message_log_y2025m03 hl7_message_log_y2025m03_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.hl7_message_log_y2025m03
    ADD CONSTRAINT hl7_message_log_y2025m03_pkey PRIMARY KEY (id, received_at);


--
-- Name: integration_credentials integration_credentials_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credentials
    ADD CONSTRAINT integration_credentials_pkey PRIMARY KEY (id);


--
-- Name: integration_credentials integration_credentials_tenant_id_id_key; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credentials
    ADD CONSTRAINT integration_credentials_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: integration_endpoints integration_endpoints_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_endpoints
    ADD CONSTRAINT integration_endpoints_pkey PRIMARY KEY (id);


--
-- Name: integration_endpoints integration_endpoints_tenant_id_code_key; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_endpoints
    ADD CONSTRAINT integration_endpoints_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: integration_endpoints integration_endpoints_tenant_id_id_key; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_endpoints
    ADD CONSTRAINT integration_endpoints_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: webhook_deliveries webhook_deliveries_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_pkey PRIMARY KEY (id);


--
-- Name: webhook_deliveries webhook_deliveries_tenant_id_id_key; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: webhook_subscriptions webhook_subscriptions_pkey; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_subscriptions
    ADD CONSTRAINT webhook_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: webhook_subscriptions webhook_subscriptions_tenant_id_id_key; Type: CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_subscriptions
    ADD CONSTRAINT webhook_subscriptions_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);


--
-- Name: batches batches_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: batches batches_tenant_id_item_id_batch_number_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_tenant_id_item_id_batch_number_key UNIQUE (tenant_id, item_id, batch_number);


--
-- Name: current_stock current_stock_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.current_stock
    ADD CONSTRAINT current_stock_pkey PRIMARY KEY (id);


--
-- Name: current_stock current_stock_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.current_stock
    ADD CONSTRAINT current_stock_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: item_categories item_categories_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.item_categories
    ADD CONSTRAINT item_categories_pkey PRIMARY KEY (id);


--
-- Name: item_categories item_categories_tenant_id_code_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.item_categories
    ADD CONSTRAINT item_categories_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: item_categories item_categories_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.item_categories
    ADD CONSTRAINT item_categories_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: items items_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.items
    ADD CONSTRAINT items_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: items items_tenant_id_sku_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.items
    ADD CONSTRAINT items_tenant_id_sku_key UNIQUE (tenant_id, sku);


--
-- Name: purchase_order_items purchase_order_items_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_items purchase_order_items_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_order_items
    ADD CONSTRAINT purchase_order_items_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_orders
    ADD CONSTRAINT purchase_orders_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: purchase_orders purchase_orders_tenant_id_po_number_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_orders
    ADD CONSTRAINT purchase_orders_tenant_id_po_number_key UNIQUE (tenant_id, po_number);


--
-- Name: stock_ledgers stock_ledgers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers
    ADD CONSTRAINT stock_ledgers_pkey PRIMARY KEY (id, created_at);


--
-- Name: stock_ledgers_y2024m12 stock_ledgers_y2024m12_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers_y2024m12
    ADD CONSTRAINT stock_ledgers_y2024m12_pkey PRIMARY KEY (id, created_at);


--
-- Name: stock_ledgers_y2025m01 stock_ledgers_y2025m01_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers_y2025m01
    ADD CONSTRAINT stock_ledgers_y2025m01_pkey PRIMARY KEY (id, created_at);


--
-- Name: stock_ledgers_y2025m02 stock_ledgers_y2025m02_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers_y2025m02
    ADD CONSTRAINT stock_ledgers_y2025m02_pkey PRIMARY KEY (id, created_at);


--
-- Name: stock_ledgers_y2025m03 stock_ledgers_y2025m03_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_ledgers_y2025m03
    ADD CONSTRAINT stock_ledgers_y2025m03_pkey PRIMARY KEY (id, created_at);


--
-- Name: stock_locations stock_locations_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_locations
    ADD CONSTRAINT stock_locations_pkey PRIMARY KEY (id);


--
-- Name: stock_locations stock_locations_tenant_id_code_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_locations
    ADD CONSTRAINT stock_locations_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: stock_locations stock_locations_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_locations
    ADD CONSTRAINT stock_locations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_tenant_id_code_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.suppliers
    ADD CONSTRAINT suppliers_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: suppliers suppliers_tenant_id_id_key; Type: CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.suppliers
    ADD CONSTRAINT suppliers_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: alert_configurations alert_configurations_pkey; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.alert_configurations
    ADD CONSTRAINT alert_configurations_pkey PRIMARY KEY (id);


--
-- Name: alert_configurations alert_configurations_tenant_id_id_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.alert_configurations
    ADD CONSTRAINT alert_configurations_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: alert_configurations alert_configurations_tenant_id_test_code_alert_type_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.alert_configurations
    ADD CONSTRAINT alert_configurations_tenant_id_test_code_alert_type_key UNIQUE (tenant_id, test_code, alert_type);


--
-- Name: quality_controls quality_controls_pkey; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.quality_controls
    ADD CONSTRAINT quality_controls_pkey PRIMARY KEY (id);


--
-- Name: quality_controls quality_controls_tenant_id_id_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.quality_controls
    ADD CONSTRAINT quality_controls_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: quality_controls quality_controls_tenant_id_test_code_qc_date_control_lot_nu_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.quality_controls
    ADD CONSTRAINT quality_controls_tenant_id_test_code_qc_date_control_lot_nu_key UNIQUE (tenant_id, test_code, qc_date, control_lot_number, qc_time);


--
-- Name: samples samples_barcode_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.samples
    ADD CONSTRAINT samples_barcode_key UNIQUE (barcode);


--
-- Name: samples samples_pkey; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.samples
    ADD CONSTRAINT samples_pkey PRIMARY KEY (id);


--
-- Name: samples samples_tenant_id_id_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.samples
    ADD CONSTRAINT samples_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: samples samples_tenant_id_sample_number_key; Type: CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.samples
    ADD CONSTRAINT samples_tenant_id_sample_number_key UNIQUE (tenant_id, sample_number);


--
-- Name: appointment_history appointment_history_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointment_history
    ADD CONSTRAINT appointment_history_pkey PRIMARY KEY (id);


--
-- Name: appointment_history appointment_history_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointment_history
    ADD CONSTRAINT appointment_history_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_tenant_id_appointment_number_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointments
    ADD CONSTRAINT appointments_tenant_id_appointment_number_key UNIQUE (tenant_id, appointment_number);


--
-- Name: appointments appointments_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointments
    ADD CONSTRAINT appointments_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: block_schedules block_schedules_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.block_schedules
    ADD CONSTRAINT block_schedules_pkey PRIMARY KEY (id);


--
-- Name: block_schedules block_schedules_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.block_schedules
    ADD CONSTRAINT block_schedules_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: queue_tokens queue_tokens_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queue_tokens
    ADD CONSTRAINT queue_tokens_pkey PRIMARY KEY (id);


--
-- Name: queue_tokens queue_tokens_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queue_tokens
    ADD CONSTRAINT queue_tokens_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: queue_tokens queue_tokens_tenant_id_queue_id_token_number_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queue_tokens
    ADD CONSTRAINT queue_tokens_tenant_id_queue_id_token_number_key UNIQUE (tenant_id, queue_id, token_number);


--
-- Name: queues queues_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queues
    ADD CONSTRAINT queues_pkey PRIMARY KEY (id);


--
-- Name: queues queues_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queues
    ADD CONSTRAINT queues_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: queues queues_tenant_id_queue_name_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queues
    ADD CONSTRAINT queues_tenant_id_queue_name_key UNIQUE (tenant_id, queue_name);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.schedules
    ADD CONSTRAINT schedules_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: slots slots_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.slots
    ADD CONSTRAINT slots_pkey PRIMARY KEY (id);


--
-- Name: slots slots_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.slots
    ADD CONSTRAINT slots_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: waitlist waitlist_pkey; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.waitlist
    ADD CONSTRAINT waitlist_pkey PRIMARY KEY (id);


--
-- Name: waitlist waitlist_tenant_id_id_key; Type: CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.waitlist
    ADD CONSTRAINT waitlist_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: code_systems code_systems_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.code_systems
    ADD CONSTRAINT code_systems_pkey PRIMARY KEY (id);


--
-- Name: code_systems code_systems_tenant_id_id_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.code_systems
    ADD CONSTRAINT code_systems_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: concept_map_elements concept_map_elements_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concept_map_elements
    ADD CONSTRAINT concept_map_elements_pkey PRIMARY KEY (id);


--
-- Name: concept_maps concept_maps_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concept_maps
    ADD CONSTRAINT concept_maps_pkey PRIMARY KEY (id);


--
-- Name: concept_maps concept_maps_tenant_id_id_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concept_maps
    ADD CONSTRAINT concept_maps_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: concepts concepts_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concepts
    ADD CONSTRAINT concepts_pkey PRIMARY KEY (id);


--
-- Name: concepts concepts_tenant_id_id_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concepts
    ADD CONSTRAINT concepts_tenant_id_id_key UNIQUE (tenant_id, id);


--
-- Name: value_set_concepts value_set_concepts_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_set_concepts
    ADD CONSTRAINT value_set_concepts_pkey PRIMARY KEY (id);


--
-- Name: value_set_concepts value_set_concepts_value_set_id_concept_id_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_set_concepts
    ADD CONSTRAINT value_set_concepts_value_set_id_concept_id_key UNIQUE (value_set_id, concept_id);


--
-- Name: value_sets value_sets_identifier_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_sets
    ADD CONSTRAINT value_sets_identifier_key UNIQUE (identifier);


--
-- Name: value_sets value_sets_pkey; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_sets
    ADD CONSTRAINT value_sets_pkey PRIMARY KEY (id);


--
-- Name: value_sets value_sets_url_key; Type: CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_sets
    ADD CONSTRAINT value_sets_url_key UNIQUE (url);


--
-- Name: dim_patients dim_patients_org_id_tenant_id_patient_key_key; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_patients
    ADD CONSTRAINT dim_patients_org_id_tenant_id_patient_key_key UNIQUE (org_id, tenant_id, patient_key);


--
-- Name: dim_patients dim_patients_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_patients
    ADD CONSTRAINT dim_patients_pkey PRIMARY KEY (org_id, tenant_id, patient_id);


--
-- Name: dim_tenants dim_tenants_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_tenants
    ADD CONSTRAINT dim_tenants_pkey PRIMARY KEY (org_id, tenant_id);


--
-- Name: fact_encounters fact_encounters_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_encounters
    ADD CONSTRAINT fact_encounters_pkey PRIMARY KEY (org_id, tenant_id, encounter_id, start_at);


--
-- Name: fact_encounters_2025_01 fact_encounters_2025_01_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_encounters_2025_01
    ADD CONSTRAINT fact_encounters_2025_01_pkey PRIMARY KEY (org_id, tenant_id, encounter_id, start_at);


--
-- Name: fact_invoices fact_invoices_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_invoices
    ADD CONSTRAINT fact_invoices_pkey PRIMARY KEY (org_id, tenant_id, invoice_id);


--
-- Name: fact_stock_movements fact_stock_movements_pkey; Type: CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_stock_movements
    ADD CONSTRAINT fact_stock_movements_pkey PRIMARY KEY (org_id, tenant_id, movement_id, occurred_at);


--
-- Name: idx_abdm_reg_abha; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_abdm_reg_abha ON abdm.abdm_registrations USING btree (abha_number) WHERE (abha_number IS NOT NULL);


--
-- Name: idx_abdm_reg_kyc; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_abdm_reg_kyc ON abdm.abdm_registrations USING btree (kyc_status) WHERE ((kyc_status)::text = 'pending'::text);


--
-- Name: idx_abdm_reg_patient; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_abdm_reg_patient ON abdm.abdm_registrations USING btree (patient_id);


--
-- Name: idx_abdm_reg_status; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_abdm_reg_status ON abdm.abdm_registrations USING btree (status);


--
-- Name: idx_abdm_reg_tenant; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_abdm_reg_tenant ON abdm.abdm_registrations USING btree (tenant_id);


--
-- Name: idx_care_context_encounter; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_encounter ON abdm.abdm_care_contexts USING btree (encounter_id);


--
-- Name: idx_care_context_hip; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_hip ON abdm.abdm_care_contexts USING btree (hip_facility_id);


--
-- Name: idx_care_context_patient; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_patient ON abdm.abdm_care_contexts USING btree (patient_id);


--
-- Name: idx_care_context_reference; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_reference ON abdm.abdm_care_contexts USING btree (care_context_reference);


--
-- Name: idx_care_context_status; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_status ON abdm.abdm_care_contexts USING btree (linking_status);


--
-- Name: idx_care_context_tenant; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_care_context_tenant ON abdm.abdm_care_contexts USING btree (tenant_id);


--
-- Name: idx_hiu_requests_artifact; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_artifact ON abdm.hiu_data_requests USING btree (consent_artifact_id) WHERE (consent_artifact_id IS NOT NULL);


--
-- Name: idx_hiu_requests_consent; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_consent ON abdm.hiu_data_requests USING btree (consent_status);


--
-- Name: idx_hiu_requests_hiu; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_hiu ON abdm.hiu_data_requests USING btree (hiu_id);


--
-- Name: idx_hiu_requests_patient; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_patient ON abdm.hiu_data_requests USING btree (patient_id);


--
-- Name: idx_hiu_requests_status; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_status ON abdm.hiu_data_requests USING btree (status);


--
-- Name: idx_hiu_requests_tenant; Type: INDEX; Schema: abdm; Owner: -
--

CREATE INDEX idx_hiu_requests_tenant ON abdm.hiu_data_requests USING btree (tenant_id);


--
-- Name: idx_accounts_patient; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_accounts_patient ON billing.accounts USING btree (patient_id);


--
-- Name: idx_accounts_status; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_accounts_status ON billing.accounts USING btree (status);


--
-- Name: idx_accounts_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_accounts_tenant ON billing.accounts USING btree (tenant_id);


--
-- Name: idx_allocations_invoice; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_allocations_invoice ON billing.payment_allocations USING btree (invoice_id);


--
-- Name: idx_allocations_payment; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_allocations_payment ON billing.payment_allocations USING btree (payment_id);


--
-- Name: idx_claims_beneficiary; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_beneficiary ON billing.insurance_claims USING btree (beneficiary_id) WHERE (beneficiary_id IS NOT NULL);


--
-- Name: idx_claims_cpd_status; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_cpd_status ON billing.insurance_claims USING btree (cpd_status) WHERE (cpd_status IS NOT NULL);


--
-- Name: idx_claims_insurer; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_insurer ON billing.insurance_claims USING btree (insurance_company_id);


--
-- Name: idx_claims_nhcx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_nhcx ON billing.insurance_claims USING btree (nhcx_bundle_id) WHERE (nhcx_bundle_id IS NOT NULL);


--
-- Name: idx_claims_patient; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_patient ON billing.insurance_claims USING btree (patient_id);


--
-- Name: idx_claims_policy; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_policy ON billing.insurance_claims USING btree (policy_number);


--
-- Name: idx_claims_status; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_status ON billing.insurance_claims USING btree (status);


--
-- Name: idx_claims_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_tenant ON billing.insurance_claims USING btree (tenant_id);


--
-- Name: idx_claims_tenant_status_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_claims_tenant_status_date ON billing.insurance_claims USING btree (tenant_id, status, claim_date DESC);


--
-- Name: idx_insurance_policies_active; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurance_policies_active ON billing.insurance_policies USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_insurance_policies_beneficiary; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurance_policies_beneficiary ON billing.insurance_policies USING btree (beneficiary_id) WHERE (beneficiary_id IS NOT NULL);


--
-- Name: idx_insurance_policies_insurer; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurance_policies_insurer ON billing.insurance_policies USING btree (insurance_company_id);


--
-- Name: idx_insurance_policies_patient; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurance_policies_patient ON billing.insurance_policies USING btree (patient_id);


--
-- Name: idx_insurance_policies_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurance_policies_tenant ON billing.insurance_policies USING btree (tenant_id);


--
-- Name: idx_insurers_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_insurers_tenant ON billing.insurance_companies USING btree (tenant_id);


--
-- Name: idx_invoiceitems_invoice; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoiceitems_invoice ON billing.invoice_line_items USING btree (invoice_id);


--
-- Name: idx_invoiceitems_item; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoiceitems_item ON billing.invoice_line_items USING btree (item_id);


--
-- Name: idx_invoiceitems_service; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoiceitems_service ON billing.invoice_line_items USING btree (service_id);


--
-- Name: idx_invoices_account; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_account ON billing.invoices USING btree (account_id);


--
-- Name: idx_invoices_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_date ON billing.invoices USING btree (tenant_id, invoice_date DESC);


--
-- Name: idx_invoices_due_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_due_date ON billing.invoices USING btree (tenant_id, due_date) WHERE ((status = 'issued'::public.invoice_status) AND (amount_due > (0)::numeric));


--
-- Name: idx_invoices_encounter; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_encounter ON billing.invoices USING btree (encounter_id);


--
-- Name: idx_invoices_patient; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_patient ON billing.invoices USING btree (patient_id);


--
-- Name: idx_invoices_status; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_status ON billing.invoices USING btree (status);


--
-- Name: idx_invoices_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_tenant ON billing.invoices USING btree (tenant_id);


--
-- Name: idx_invoices_tenant_due_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_tenant_due_date ON billing.invoices USING btree (tenant_id, due_date) WHERE ((status = 'issued'::public.invoice_status) AND (amount_due > (0)::numeric));


--
-- Name: idx_invoices_tenant_status_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_invoices_tenant_status_date ON billing.invoices USING btree (tenant_id, status, invoice_date DESC);


--
-- Name: idx_payments_account; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_account ON billing.payments USING btree (account_id);


--
-- Name: idx_payments_date; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_date ON billing.payments USING btree (tenant_id, payment_date DESC);


--
-- Name: idx_payments_invoice; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_invoice ON billing.payments USING btree (invoice_id);


--
-- Name: idx_payments_patient; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_patient ON billing.payments USING btree (patient_id);


--
-- Name: idx_payments_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_tenant ON billing.payments USING btree (tenant_id);


--
-- Name: idx_payments_tenant_date_method; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_payments_tenant_date_method ON billing.payments USING btree (tenant_id, payment_date DESC, payment_method);


--
-- Name: idx_preauth_encounter; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_preauth_encounter ON billing.pre_authorizations USING btree (encounter_id);


--
-- Name: idx_preauth_nhcx; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_preauth_nhcx ON billing.pre_authorizations USING btree (nhcx_preauth_id) WHERE (nhcx_preauth_id IS NOT NULL);


--
-- Name: idx_preauth_policy; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_preauth_policy ON billing.pre_authorizations USING btree (insurance_policy_id);


--
-- Name: idx_preauth_status; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_preauth_status ON billing.pre_authorizations USING btree (status);


--
-- Name: idx_preauth_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_preauth_tenant ON billing.pre_authorizations USING btree (tenant_id);


--
-- Name: idx_priceitems_pricelist; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_priceitems_pricelist ON billing.price_list_items USING btree (price_list_id);


--
-- Name: idx_priceitems_service; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_priceitems_service ON billing.price_list_items USING btree (service_id);


--
-- Name: idx_pricelists_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_pricelists_tenant ON billing.price_lists USING btree (tenant_id);


--
-- Name: idx_services_category; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_services_category ON billing.service_masters USING btree (category);


--
-- Name: idx_services_name; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_services_name ON billing.service_masters USING gin (name public.gin_trgm_ops);


--
-- Name: idx_services_tenant; Type: INDEX; Schema: billing; Owner: -
--

CREATE INDEX idx_services_tenant ON billing.service_masters USING btree (tenant_id);


--
-- Name: idx_donors_blood_group; Type: INDEX; Schema: blood_bank; Owner: -
--

CREATE INDEX idx_donors_blood_group ON blood_bank.donors USING btree (blood_group);


--
-- Name: idx_donors_eligibility; Type: INDEX; Schema: blood_bank; Owner: -
--

CREATE INDEX idx_donors_eligibility ON blood_bank.donors USING btree (eligibility_status);


--
-- Name: idx_donors_name; Type: INDEX; Schema: blood_bank; Owner: -
--

CREATE INDEX idx_donors_name ON blood_bank.donors USING gin (name public.gin_trgm_ops);


--
-- Name: idx_donors_tenant; Type: INDEX; Schema: blood_bank; Owner: -
--

CREATE INDEX idx_donors_tenant ON blood_bank.donors USING btree (tenant_id);


--
-- Name: idx_allergies_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_allergies_code ON clinical.allergy_intolerances USING gin (code);


--
-- Name: idx_allergies_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_allergies_patient ON clinical.allergy_intolerances USING btree (patient_id);


--
-- Name: idx_allergies_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_allergies_tenant ON clinical.allergy_intolerances USING btree (tenant_id);


--
-- Name: idx_anesthesia_anesthetist; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_anesthesia_anesthetist ON clinical.anesthesia_records USING btree (anesthetist_id);


--
-- Name: idx_anesthesia_surgery; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_anesthesia_surgery ON clinical.anesthesia_records USING btree (surgery_id);


--
-- Name: idx_anesthesia_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_anesthesia_tenant ON clinical.anesthesia_records USING btree (tenant_id);


--
-- Name: idx_beds_location; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_beds_location ON clinical.beds USING btree (location_id);


--
-- Name: idx_beds_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_beds_patient ON clinical.beds USING btree (patient_id) WHERE (patient_id IS NOT NULL);


--
-- Name: idx_beds_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_beds_status ON clinical.beds USING btree (tenant_id, status);


--
-- Name: idx_beds_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_beds_tenant ON clinical.beds USING btree (tenant_id);


--
-- Name: idx_beds_type; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_beds_type ON clinical.beds USING btree (bed_type);


--
-- Name: idx_bg_sessions_tenant_user_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_bg_sessions_tenant_user_status ON clinical.break_glass_sessions USING btree (tenant_id, user_id, status, expires_at);


--
-- Name: idx_care_plans_category; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_category ON clinical.care_plans USING gin (category);


--
-- Name: idx_care_plans_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_encounter ON clinical.care_plans USING btree (encounter_id);


--
-- Name: idx_care_plans_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_patient ON clinical.care_plans USING btree (patient_id);


--
-- Name: idx_care_plans_period; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_period ON clinical.care_plans USING btree (period_start, period_end);


--
-- Name: idx_care_plans_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_status ON clinical.care_plans USING btree (status);


--
-- Name: idx_care_plans_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_care_plans_tenant ON clinical.care_plans USING btree (tenant_id);


--
-- Name: idx_conditions_clinical_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_conditions_clinical_status ON clinical.conditions USING btree (clinical_status);


--
-- Name: idx_conditions_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_conditions_code ON clinical.conditions USING gin (code);


--
-- Name: idx_conditions_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_conditions_encounter ON clinical.conditions USING btree (encounter_id);


--
-- Name: idx_conditions_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_conditions_patient ON clinical.conditions USING btree (patient_id);


--
-- Name: idx_conditions_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_conditions_tenant ON clinical.conditions USING btree (tenant_id);


--
-- Name: idx_diagreports_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_diagreports_code ON clinical.diagnostic_reports USING gin (code);


--
-- Name: idx_diagreports_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_diagreports_encounter ON clinical.diagnostic_reports USING btree (encounter_id);


--
-- Name: idx_diagreports_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_diagreports_patient ON clinical.diagnostic_reports USING btree (patient_id);


--
-- Name: idx_diagreports_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_diagreports_status ON clinical.diagnostic_reports USING btree (status);


--
-- Name: idx_diagreports_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_diagreports_tenant ON clinical.diagnostic_reports USING btree (tenant_id);


--
-- Name: idx_discharge_summaries_date; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_discharge_summaries_date ON clinical.discharge_summaries USING btree (discharge_date DESC);


--
-- Name: idx_discharge_summaries_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_discharge_summaries_encounter ON clinical.discharge_summaries USING btree (encounter_id);


--
-- Name: idx_discharge_summaries_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_discharge_summaries_patient ON clinical.discharge_summaries USING btree (patient_id);


--
-- Name: idx_discharge_summaries_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_discharge_summaries_status ON clinical.discharge_summaries USING btree (status);


--
-- Name: idx_discharge_summaries_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_discharge_summaries_tenant ON clinical.discharge_summaries USING btree (tenant_id);


--
-- Name: idx_ectm_active_by_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ectm_active_by_encounter ON clinical.encounter_care_team_members USING btree (tenant_id, encounter_id, role_code, from_ts) WHERE (to_ts IS NULL);


--
-- Name: idx_ectm_member_practitioner; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ectm_member_practitioner ON clinical.encounter_care_team_members USING btree (tenant_id, practitioner_id) WHERE (practitioner_id IS NOT NULL);


--
-- Name: idx_ectm_member_user; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ectm_member_user ON clinical.encounter_care_team_members USING btree (tenant_id, user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_ectm_tenant_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ectm_tenant_encounter ON clinical.encounter_care_team_members USING btree (tenant_id, encounter_id);


--
-- Name: idx_ectm_tenant_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ectm_tenant_patient ON clinical.encounter_care_team_members USING btree (tenant_id, patient_id);


--
-- Name: idx_encounters_class; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_class ON clinical.encounters USING btree (tenant_id, class);


--
-- Name: idx_encounters_location; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_location ON clinical.encounters USING btree (location_id);


--
-- Name: idx_encounters_mlc; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_mlc ON clinical.encounters USING btree (tenant_id, mlc_flag) WHERE (mlc_flag = true);


--
-- Name: idx_encounters_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_patient ON clinical.encounters USING btree (patient_id);


--
-- Name: idx_encounters_period; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_period ON clinical.encounters USING btree (tenant_id, period_start DESC);


--
-- Name: idx_encounters_practitioner; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_practitioner ON clinical.encounters USING btree (primary_practitioner_id);


--
-- Name: idx_encounters_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_status ON clinical.encounters USING btree (tenant_id, status);


--
-- Name: idx_encounters_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_tenant ON clinical.encounters USING btree (tenant_id);


--
-- Name: idx_encounters_tenant_class_period; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_tenant_class_period ON clinical.encounters USING btree (tenant_id, class, period_start DESC);


--
-- Name: idx_encounters_tenant_patient_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_encounters_tenant_patient_status ON clinical.encounters USING btree (tenant_id, patient_id, status) WHERE (status = ANY (ARRAY['in-progress'::public.fhir_encounter_status, 'finished'::public.fhir_encounter_status]));


--
-- Name: idx_episode_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_episode_patient ON clinical.episode_of_care USING btree (patient_id);


--
-- Name: idx_episode_period; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_episode_period ON clinical.episode_of_care USING btree (tenant_id, period_start DESC);


--
-- Name: idx_episode_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_episode_status ON clinical.episode_of_care USING btree (tenant_id, status);


--
-- Name: idx_episode_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_episode_tenant ON clinical.episode_of_care USING btree (tenant_id);


--
-- Name: idx_ext_fulfill_tenant_resource; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ext_fulfill_tenant_resource ON clinical.external_fulfillments USING btree (tenant_id, internal_resource_type, internal_resource_id);


--
-- Name: idx_ext_fulfill_tenant_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ext_fulfill_tenant_status ON clinical.external_fulfillments USING btree (tenant_id, status, scheduled_at);


--
-- Name: idx_handovers_nurse; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_handovers_nurse ON clinical.shift_handovers USING btree (handing_over_nurse_id);


--
-- Name: idx_handovers_shift_date; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_handovers_shift_date ON clinical.shift_handovers USING btree (shift_date DESC);


--
-- Name: idx_handovers_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_handovers_tenant ON clinical.shift_handovers USING btree (tenant_id);


--
-- Name: idx_handovers_ward; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_handovers_ward ON clinical.shift_handovers USING btree (ward_id);


--
-- Name: idx_icu_beds_icu_unit; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_icu_beds_icu_unit ON clinical.icu_beds USING btree (icu_unit_id);


--
-- Name: idx_icu_beds_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_icu_beds_patient ON clinical.icu_beds USING btree (patient_id) WHERE (patient_id IS NOT NULL);


--
-- Name: idx_icu_beds_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_icu_beds_status ON clinical.icu_beds USING btree (status);


--
-- Name: idx_icu_beds_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_icu_beds_tenant ON clinical.icu_beds USING btree (tenant_id);


--
-- Name: idx_locations_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_locations_tenant ON clinical.locations USING btree (tenant_id);


--
-- Name: idx_locations_type; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_locations_type ON clinical.locations USING btree (physical_type);


--
-- Name: idx_med_admin_med_request; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_med_admin_med_request ON clinical.medication_administrations USING btree (medication_request_id);


--
-- Name: idx_med_admin_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_med_admin_patient ON clinical.medication_administrations USING btree (patient_id);


--
-- Name: idx_med_admin_scheduled; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_med_admin_scheduled ON clinical.medication_administrations USING btree (scheduled_time) WHERE ((status)::text = 'scheduled'::text);


--
-- Name: idx_med_admin_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_med_admin_status ON clinical.medication_administrations USING btree (status);


--
-- Name: idx_med_admin_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_med_admin_tenant ON clinical.medication_administrations USING btree (tenant_id);


--
-- Name: idx_medrequests_authored; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_authored ON clinical.medication_requests USING btree (tenant_id, authored_on DESC);


--
-- Name: idx_medrequests_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_encounter ON clinical.medication_requests USING btree (encounter_id);


--
-- Name: idx_medrequests_medication; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_medication ON clinical.medication_requests USING gin (medication);


--
-- Name: idx_medrequests_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_patient ON clinical.medication_requests USING btree (patient_id);


--
-- Name: idx_medrequests_requester; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_requester ON clinical.medication_requests USING btree (requester_id);


--
-- Name: idx_medrequests_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_status ON clinical.medication_requests USING btree (status);


--
-- Name: idx_medrequests_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_tenant ON clinical.medication_requests USING btree (tenant_id);


--
-- Name: idx_medrequests_tenant_patient_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_medrequests_tenant_patient_status ON clinical.medication_requests USING btree (tenant_id, patient_id, status);


--
-- Name: idx_mlc_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_mlc_encounter ON clinical.medico_legal_cases USING btree (encounter_id);


--
-- Name: idx_mlc_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_mlc_patient ON clinical.medico_legal_cases USING btree (patient_id);


--
-- Name: idx_mlc_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_mlc_status ON clinical.medico_legal_cases USING btree (status);


--
-- Name: idx_mlc_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_mlc_tenant ON clinical.medico_legal_cases USING btree (tenant_id);


--
-- Name: idx_notes_author; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_author ON clinical.clinical_notes USING btree (author_id);


--
-- Name: idx_notes_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_encounter ON clinical.clinical_notes USING btree (encounter_id);


--
-- Name: idx_notes_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_patient ON clinical.clinical_notes USING btree (patient_id);


--
-- Name: idx_notes_search; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_search ON clinical.clinical_notes USING gin (search_content);


--
-- Name: idx_notes_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_tenant ON clinical.clinical_notes USING btree (tenant_id);


--
-- Name: idx_notes_type; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_notes_type ON clinical.clinical_notes USING btree (note_type);


--
-- Name: idx_nursing_tasks_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_encounter ON clinical.nursing_tasks USING btree (encounter_id);


--
-- Name: idx_nursing_tasks_nurse; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_nurse ON clinical.nursing_tasks USING btree (assigned_to_nurse_id);


--
-- Name: idx_nursing_tasks_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_patient ON clinical.nursing_tasks USING btree (patient_id);


--
-- Name: idx_nursing_tasks_scheduled; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_scheduled ON clinical.nursing_tasks USING btree (scheduled_time) WHERE ((status)::text = 'pending'::text);


--
-- Name: idx_nursing_tasks_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_status ON clinical.nursing_tasks USING btree (status);


--
-- Name: idx_nursing_tasks_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_nursing_tasks_tenant ON clinical.nursing_tasks USING btree (tenant_id);


--
-- Name: idx_observations_category; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_category ON clinical.observations USING gin (category);


--
-- Name: idx_observations_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_code ON clinical.observations USING gin (code);


--
-- Name: idx_observations_effective; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_effective ON clinical.observations USING btree (tenant_id, effective_date_time DESC);


--
-- Name: idx_observations_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_encounter ON clinical.observations USING btree (encounter_id);


--
-- Name: idx_observations_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_patient ON clinical.observations USING btree (patient_id);


--
-- Name: idx_observations_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_tenant ON clinical.observations USING btree (tenant_id);


--
-- Name: idx_observations_tenant_patient_category; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_tenant_patient_category ON clinical.observations USING btree (tenant_id, patient_id, category) WHERE (category IS NOT NULL);


--
-- Name: idx_observations_value; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_observations_value ON clinical.observations USING gin (value);


--
-- Name: idx_ot_location; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ot_location ON clinical.operation_theatres USING btree (location_id);


--
-- Name: idx_ot_specialties; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ot_specialties ON clinical.operation_theatres USING gin (specialties);


--
-- Name: idx_ot_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ot_status ON clinical.operation_theatres USING btree (status);


--
-- Name: idx_ot_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_ot_tenant ON clinical.operation_theatres USING btree (tenant_id);


--
-- Name: idx_patient_consent_tenant_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_consent_tenant_patient ON clinical.patient_consent_directives USING btree (tenant_id, patient_id, effective_from);


--
-- Name: idx_patient_identifiers_tenant_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_identifiers_tenant_patient ON clinical.patient_identifiers USING btree (tenant_id, patient_id);


--
-- Name: idx_patient_identifiers_tenant_type; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_identifiers_tenant_type ON clinical.patient_identifiers USING btree (tenant_id, identifier_type);


--
-- Name: idx_patient_merge_source_when_merged; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_merge_source_when_merged ON ONLY clinical.patient_merge_events USING btree (tenant_id, source_patient_id, event_at) WHERE (status = 'merged'::text);


--
-- Name: idx_patient_merge_tenant_source; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_merge_tenant_source ON ONLY clinical.patient_merge_events USING btree (tenant_id, source_patient_id, event_at);


--
-- Name: idx_patient_merge_tenant_target; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_merge_tenant_target ON ONLY clinical.patient_merge_events USING btree (tenant_id, target_patient_id, event_at);


--
-- Name: idx_patient_merge_undo_merge_event; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_merge_undo_merge_event ON clinical.patient_merge_undo_events USING btree (merge_event_id, merge_event_at);


--
-- Name: idx_patient_sensitivity_tenant_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patient_sensitivity_tenant_patient ON clinical.patient_sensitivity USING btree (tenant_id, patient_id);


--
-- Name: idx_patients_abha; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_abha ON clinical.patients USING btree (abha_number) WHERE (abha_number IS NOT NULL);


--
-- Name: idx_patients_dob; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_dob ON clinical.patients USING btree (tenant_id, birth_date);


--
-- Name: idx_patients_merged_into; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_merged_into ON clinical.patients USING btree (tenant_id, merged_into_patient_id) WHERE (merged_into_patient_id IS NOT NULL);


--
-- Name: idx_patients_mrn; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_mrn ON clinical.patients USING btree (tenant_id, mrn);


--
-- Name: idx_patients_name; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_name ON clinical.patients USING gin (search_name public.gin_trgm_ops);


--
-- Name: idx_patients_phone; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_phone ON clinical.patients USING btree (tenant_id, search_phone);


--
-- Name: idx_patients_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_patients_tenant ON clinical.patients USING btree (tenant_id);


--
-- Name: idx_practitioners_hpr; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_practitioners_hpr ON clinical.practitioners USING btree (hpr_id) WHERE (hpr_id IS NOT NULL);


--
-- Name: idx_practitioners_specialties; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_practitioners_specialties ON clinical.practitioners USING gin (specialties);


--
-- Name: idx_practitioners_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_practitioners_tenant ON clinical.practitioners USING btree (tenant_id);


--
-- Name: idx_practitioners_user; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_practitioners_user ON clinical.practitioners USING btree (user_id);


--
-- Name: idx_resource_sensitivity_tenant_resource; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_resource_sensitivity_tenant_resource ON clinical.resource_sensitivity USING btree (tenant_id, resource_type, resource_id);


--
-- Name: idx_sensitive_access_log_tenant_resource; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_sensitive_access_log_tenant_resource ON clinical.sensitive_access_log USING btree (tenant_id, resource_type, resource_id);


--
-- Name: idx_sensitive_access_log_tenant_time; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_sensitive_access_log_tenant_time ON clinical.sensitive_access_log USING btree (tenant_id, accessed_at);


--
-- Name: idx_sensitivity_labels_tenant_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_sensitivity_labels_tenant_code ON clinical.sensitivity_labels USING btree (tenant_id, code);


--
-- Name: idx_service_requests_category; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_category ON clinical.service_requests USING gin (category);


--
-- Name: idx_service_requests_code; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_code ON clinical.service_requests USING gin (code);


--
-- Name: idx_service_requests_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_encounter ON clinical.service_requests USING btree (encounter_id);


--
-- Name: idx_service_requests_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_patient ON clinical.service_requests USING btree (patient_id);


--
-- Name: idx_service_requests_requester; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_requester ON clinical.service_requests USING btree (requester_id);


--
-- Name: idx_service_requests_requisition; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_requisition ON clinical.service_requests USING btree (requisition);


--
-- Name: idx_service_requests_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_status ON clinical.service_requests USING btree (status);


--
-- Name: idx_service_requests_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_tenant ON clinical.service_requests USING btree (tenant_id);


--
-- Name: idx_service_requests_tenant_status_category; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_service_requests_tenant_status_category ON clinical.service_requests USING btree (tenant_id, status, category) WHERE ((status)::text = ANY ((ARRAY['draft'::character varying, 'active'::character varying])::text[]));


--
-- Name: idx_surgeries_encounter; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_encounter ON clinical.surgeries USING btree (encounter_id);


--
-- Name: idx_surgeries_ot; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_ot ON clinical.surgeries USING btree (ot_id);


--
-- Name: idx_surgeries_patient; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_patient ON clinical.surgeries USING btree (patient_id);


--
-- Name: idx_surgeries_scheduled; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_scheduled ON clinical.surgeries USING btree (scheduled_start_time) WHERE ((status)::text = 'scheduled'::text);


--
-- Name: idx_surgeries_status; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_status ON clinical.surgeries USING btree (status);


--
-- Name: idx_surgeries_surgeon; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_surgeon ON clinical.surgeries USING btree (primary_surgeon_id);


--
-- Name: idx_surgeries_tenant; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX idx_surgeries_tenant ON clinical.surgeries USING btree (tenant_id);


--
-- Name: patient_merge_events_default_tenant_id_source_patient_id_e_idx1; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX patient_merge_events_default_tenant_id_source_patient_id_e_idx1 ON clinical.patient_merge_events_default USING btree (tenant_id, source_patient_id, event_at);


--
-- Name: patient_merge_events_default_tenant_id_source_patient_id_ev_idx; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX patient_merge_events_default_tenant_id_source_patient_id_ev_idx ON clinical.patient_merge_events_default USING btree (tenant_id, source_patient_id, event_at) WHERE (status = 'merged'::text);


--
-- Name: patient_merge_events_default_tenant_id_target_patient_id_ev_idx; Type: INDEX; Schema: clinical; Owner: -
--

CREATE INDEX patient_merge_events_default_tenant_id_target_patient_id_ev_idx ON clinical.patient_merge_events_default USING btree (tenant_id, target_patient_id, event_at);


--
-- Name: ux_patient_identifiers_patient_type_system_valuehash; Type: INDEX; Schema: clinical; Owner: -
--

CREATE UNIQUE INDEX ux_patient_identifiers_patient_type_system_valuehash ON clinical.patient_identifiers USING btree (tenant_id, patient_id, identifier_type, COALESCE(system, ''::text), COALESCE(value_hash, ''::text));


--
-- Name: ux_patient_identifiers_tenant_type_system_valuehash; Type: INDEX; Schema: clinical; Owner: -
--

CREATE UNIQUE INDEX ux_patient_identifiers_tenant_type_system_valuehash ON clinical.patient_identifiers USING btree (tenant_id, identifier_type, COALESCE(system, ''::text), value_hash) WHERE (value_hash IS NOT NULL);


--
-- Name: idx_campaigns_scheduled; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_campaigns_scheduled ON communication.bulk_campaigns USING btree (scheduled_for) WHERE ((status)::text = 'scheduled'::text);


--
-- Name: idx_campaigns_status; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_campaigns_status ON communication.bulk_campaigns USING btree (status);


--
-- Name: idx_campaigns_tenant; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_campaigns_tenant ON communication.bulk_campaigns USING btree (tenant_id);


--
-- Name: idx_channels_tenant; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_channels_tenant ON communication.notification_channels USING btree (tenant_id);


--
-- Name: idx_channels_type; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_channels_type ON communication.notification_channels USING btree (channel_type);


--
-- Name: idx_notifications_tenant; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_notifications_tenant ON ONLY communication.notifications USING btree (tenant_id);


--
-- Name: idx_templates_channel; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_templates_channel ON communication.notification_templates USING btree (channel_type);


--
-- Name: idx_templates_code; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_templates_code ON communication.notification_templates USING btree (code);


--
-- Name: idx_templates_event; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_templates_event ON communication.notification_templates USING btree (event_type);


--
-- Name: idx_templates_tenant; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX idx_templates_tenant ON communication.notification_templates USING btree (tenant_id);


--
-- Name: notifications_y2024m12_tenant_id_idx; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX notifications_y2024m12_tenant_id_idx ON communication.notifications_y2024m12 USING btree (tenant_id);


--
-- Name: notifications_y2025m01_tenant_id_idx; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX notifications_y2025m01_tenant_id_idx ON communication.notifications_y2025m01 USING btree (tenant_id);


--
-- Name: notifications_y2025m02_tenant_id_idx; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX notifications_y2025m02_tenant_id_idx ON communication.notifications_y2025m02 USING btree (tenant_id);


--
-- Name: notifications_y2025m03_tenant_id_idx; Type: INDEX; Schema: communication; Owner: -
--

CREATE INDEX notifications_y2025m03_tenant_id_idx ON communication.notifications_y2025m03 USING btree (tenant_id);


--
-- Name: ux_user_notification_preferences; Type: INDEX; Schema: communication; Owner: -
--

CREATE UNIQUE INDEX ux_user_notification_preferences ON communication.user_notification_preferences USING btree (tenant_id, COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(patient_id, '00000000-0000-0000-0000-000000000000'::uuid), category);


--
-- Name: idx_audit_logs_resource; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_audit_logs_resource ON ONLY core.audit_logs USING btree (resource_type, resource_id);


--
-- Name: audit_logs_y2024m12_resource_type_resource_id_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2024m12_resource_type_resource_id_idx ON core.audit_logs_y2024m12 USING btree (resource_type, resource_id);


--
-- Name: idx_audit_logs_tenant_time; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_audit_logs_tenant_time ON ONLY core.audit_logs USING btree (tenant_id, occurred_at DESC);


--
-- Name: audit_logs_y2024m12_tenant_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2024m12_tenant_id_occurred_at_idx ON core.audit_logs_y2024m12 USING btree (tenant_id, occurred_at DESC);


--
-- Name: idx_audit_logs_user; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_audit_logs_user ON ONLY core.audit_logs USING btree (user_id, occurred_at DESC);


--
-- Name: audit_logs_y2024m12_user_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2024m12_user_id_occurred_at_idx ON core.audit_logs_y2024m12 USING btree (user_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m01_resource_type_resource_id_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m01_resource_type_resource_id_idx ON core.audit_logs_y2025m01 USING btree (resource_type, resource_id);


--
-- Name: audit_logs_y2025m01_tenant_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m01_tenant_id_occurred_at_idx ON core.audit_logs_y2025m01 USING btree (tenant_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m01_user_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m01_user_id_occurred_at_idx ON core.audit_logs_y2025m01 USING btree (user_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m02_resource_type_resource_id_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m02_resource_type_resource_id_idx ON core.audit_logs_y2025m02 USING btree (resource_type, resource_id);


--
-- Name: audit_logs_y2025m02_tenant_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m02_tenant_id_occurred_at_idx ON core.audit_logs_y2025m02 USING btree (tenant_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m02_user_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m02_user_id_occurred_at_idx ON core.audit_logs_y2025m02 USING btree (user_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m03_resource_type_resource_id_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m03_resource_type_resource_id_idx ON core.audit_logs_y2025m03 USING btree (resource_type, resource_id);


--
-- Name: audit_logs_y2025m03_tenant_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m03_tenant_id_occurred_at_idx ON core.audit_logs_y2025m03 USING btree (tenant_id, occurred_at DESC);


--
-- Name: audit_logs_y2025m03_user_id_occurred_at_idx; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX audit_logs_y2025m03_user_id_occurred_at_idx ON core.audit_logs_y2025m03 USING btree (user_id, occurred_at DESC);


--
-- Name: idx_api_clients_client_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_api_clients_client_id ON core.api_clients USING btree (client_id);


--
-- Name: idx_api_clients_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_api_clients_tenant ON core.api_clients USING btree (tenant_id);


--
-- Name: idx_api_keys_client; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_api_keys_client ON core.api_keys USING btree (api_client_id);


--
-- Name: idx_api_keys_prefix; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_api_keys_prefix ON core.api_keys USING btree (key_prefix) WHERE (is_active = true);


--
-- Name: idx_api_keys_user; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_api_keys_user ON core.api_keys USING btree (user_id);


--
-- Name: idx_consent_artifact; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_consent_artifact ON core.consent_logs USING btree (consent_artifact_id) WHERE (consent_artifact_id IS NOT NULL);


--
-- Name: idx_consent_hiu; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_consent_hiu ON core.consent_logs USING btree (hiu_id) WHERE (hiu_id IS NOT NULL);


--
-- Name: idx_consent_patient; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_consent_patient ON core.consent_logs USING btree (tenant_id, patient_id);


--
-- Name: idx_consent_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_consent_status ON core.consent_logs USING btree (status) WHERE ((status)::text = 'granted'::text);


--
-- Name: idx_deletion_requests_patient; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_deletion_requests_patient ON core.data_deletion_requests USING btree (patient_id);


--
-- Name: idx_deletion_requests_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_deletion_requests_status ON core.data_deletion_requests USING btree (status);


--
-- Name: idx_deletion_requests_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_deletion_requests_tenant ON core.data_deletion_requests USING btree (tenant_id);


--
-- Name: idx_ext_agreements_tenant_org; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_ext_agreements_tenant_org ON core.external_service_agreements USING btree (tenant_id, external_org_id);


--
-- Name: idx_external_orgs_tenant_name; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_external_orgs_tenant_name ON core.external_organizations USING btree (tenant_id, name);


--
-- Name: idx_external_orgs_tenant_type; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_external_orgs_tenant_type ON core.external_organizations USING btree (tenant_id, org_type);


--
-- Name: idx_external_pract_tenant_name; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_external_pract_tenant_name ON core.external_practitioners USING btree (tenant_id, full_name);


--
-- Name: idx_external_pract_tenant_org; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_external_pract_tenant_org ON core.external_practitioners USING btree (tenant_id, external_org_id);


--
-- Name: idx_org_members_org_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_org_members_org_id ON core.organization_members USING btree (org_id);


--
-- Name: idx_org_members_user_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_org_members_user_id ON core.organization_members USING btree (user_id);


--
-- Name: idx_org_tenants_org_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_org_tenants_org_id ON core.organization_tenant_memberships USING btree (org_id);


--
-- Name: idx_org_tenants_tenant_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_org_tenants_tenant_id ON core.organization_tenant_memberships USING btree (tenant_id);


--
-- Name: idx_otp_expires; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_otp_expires ON core.otp_verifications USING btree (expires_at) WHERE ((status)::text = 'pending'::text);


--
-- Name: idx_otp_user; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_otp_user ON core.otp_verifications USING btree (user_id, status);


--
-- Name: idx_password_policies_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_password_policies_tenant ON core.password_policies USING btree (tenant_id);


--
-- Name: idx_retention_schema; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_retention_schema ON core.retention_policies USING btree (schema_name, table_name);


--
-- Name: idx_retention_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_retention_tenant ON core.retention_policies USING btree (tenant_id);


--
-- Name: idx_role_permissions_role; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_role_permissions_role ON core.role_permissions USING btree (role_id);


--
-- Name: idx_roles_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_roles_tenant ON core.roles USING btree (tenant_id);


--
-- Name: idx_schema_versions_applied_at; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_schema_versions_applied_at ON core.schema_versions USING btree (applied_at DESC);


--
-- Name: idx_sessions_expires; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_sessions_expires ON core.user_sessions USING btree (expires_at) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_sessions_token; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_sessions_token ON core.user_sessions USING btree (session_token) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_sessions_user ON core.user_sessions USING btree (user_id, status);


--
-- Name: idx_tenant_subscriptions_period; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenant_subscriptions_period ON core.tenant_subscriptions USING btree (current_period_end);


--
-- Name: idx_tenant_subscriptions_status; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenant_subscriptions_status ON core.tenant_subscriptions USING btree (status);


--
-- Name: idx_tenant_subscriptions_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenant_subscriptions_tenant ON core.tenant_subscriptions USING btree (tenant_id);


--
-- Name: idx_tenants_active; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenants_active ON core.tenants USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_tenants_code; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenants_code ON core.tenants USING btree (code);


--
-- Name: idx_tenants_hfr; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenants_hfr ON core.tenants USING btree (hfr_id) WHERE (hfr_id IS NOT NULL);


--
-- Name: idx_tenants_org_id; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_tenants_org_id ON core.tenants USING btree (org_id);


--
-- Name: idx_usage_metrics_billing; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_usage_metrics_billing ON core.usage_metrics USING btree (is_billable, billed_at) WHERE ((is_billable = true) AND (billed_at IS NULL));


--
-- Name: idx_usage_metrics_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_usage_metrics_tenant ON core.usage_metrics USING btree (tenant_id, period_start DESC);


--
-- Name: idx_user_roles_role; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_user_roles_role ON core.user_roles USING btree (role_id);


--
-- Name: idx_user_roles_user; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_user_roles_user ON core.user_roles USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_users_email ON core.users USING btree (tenant_id, email);


--
-- Name: idx_users_external; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_users_external ON core.users USING btree (external_id) WHERE (external_id IS NOT NULL);


--
-- Name: idx_users_tenant; Type: INDEX; Schema: core; Owner: -
--

CREATE INDEX idx_users_tenant ON core.users USING btree (tenant_id);


--
-- Name: ux_system_configurations; Type: INDEX; Schema: core; Owner: -
--

CREATE UNIQUE INDEX ux_system_configurations ON core.system_configurations USING btree (scope, COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), COALESCE(user_id, '00000000-0000-0000-0000-000000000000'::uuid), config_key);


--
-- Name: idx_doc_access_document; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_access_document ON documents.document_access_log USING btree (document_id);


--
-- Name: idx_doc_access_time; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_access_time ON documents.document_access_log USING btree (tenant_id, accessed_at DESC);


--
-- Name: idx_doc_access_type; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_access_type ON documents.document_access_log USING btree (access_type);


--
-- Name: idx_doc_access_user; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_access_user ON documents.document_access_log USING btree (user_id);


--
-- Name: idx_doc_types_category; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_types_category ON documents.document_types USING btree (category);


--
-- Name: idx_doc_types_tenant; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_types_tenant ON documents.document_types USING btree (tenant_id);


--
-- Name: idx_doc_versions_document; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_doc_versions_document ON documents.document_versions USING btree (document_id);


--
-- Name: idx_documents_encounter; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_encounter ON documents.documents USING btree (encounter_id) WHERE (encounter_id IS NOT NULL);


--
-- Name: idx_documents_entity; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_entity ON documents.documents USING btree (entity_type, entity_id);


--
-- Name: idx_documents_hash; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_hash ON documents.documents USING btree (content_hash);


--
-- Name: idx_documents_patient; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_patient ON documents.documents USING btree (patient_id) WHERE (patient_id IS NOT NULL);


--
-- Name: idx_documents_status; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_status ON documents.documents USING btree (status);


--
-- Name: idx_documents_tags; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_tags ON documents.documents USING gin (tags);


--
-- Name: idx_documents_tenant; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_tenant ON documents.documents USING btree (tenant_id);


--
-- Name: idx_documents_type; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_type ON documents.documents USING btree (document_type_id);


--
-- Name: idx_documents_user; Type: INDEX; Schema: documents; Owner: -
--

CREATE INDEX idx_documents_user ON documents.documents USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: ux_document_types; Type: INDEX; Schema: documents; Owner: -
--

CREATE UNIQUE INDEX ux_document_types ON documents.document_types USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), code);


--
-- Name: idx_imaging_orders_accession; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_accession ON imaging.imaging_orders USING btree (accession_number);


--
-- Name: idx_imaging_orders_encounter; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_encounter ON imaging.imaging_orders USING btree (encounter_id);


--
-- Name: idx_imaging_orders_external_org; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_external_org ON imaging.imaging_orders USING btree (tenant_id, external_org_id) WHERE (external_org_id IS NOT NULL);


--
-- Name: idx_imaging_orders_modality; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_modality ON imaging.imaging_orders USING btree (modality);


--
-- Name: idx_imaging_orders_patient; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_patient ON imaging.imaging_orders USING btree (patient_id);


--
-- Name: idx_imaging_orders_requester; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_requester ON imaging.imaging_orders USING btree (requester_id);


--
-- Name: idx_imaging_orders_scheduled; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_scheduled ON imaging.imaging_orders USING btree (scheduled_date_time) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_imaging_orders_status; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_status ON imaging.imaging_orders USING btree (status);


--
-- Name: idx_imaging_orders_tenant; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_tenant ON imaging.imaging_orders USING btree (tenant_id);


--
-- Name: idx_imaging_orders_worklist; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_orders_worklist ON imaging.imaging_orders USING btree (worklist_status) WHERE ((worklist_status)::text = 'pending'::text);


--
-- Name: idx_imaging_studies_accession; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_accession ON imaging.imaging_studies USING btree (accession_number);


--
-- Name: idx_imaging_studies_critical; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_critical ON imaging.imaging_studies USING btree (has_critical_finding) WHERE (has_critical_finding = true);


--
-- Name: idx_imaging_studies_date; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_date ON imaging.imaging_studies USING btree (study_date DESC);


--
-- Name: idx_imaging_studies_dicom_uid; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_dicom_uid ON imaging.imaging_studies USING btree (dicom_study_uid);


--
-- Name: idx_imaging_studies_encounter; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_encounter ON imaging.imaging_studies USING btree (encounter_id);


--
-- Name: idx_imaging_studies_modalities; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_modalities ON imaging.imaging_studies USING gin (modalities_in_study);


--
-- Name: idx_imaging_studies_order; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_order ON imaging.imaging_studies USING btree (imaging_order_id);


--
-- Name: idx_imaging_studies_orthanc; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_orthanc ON imaging.imaging_studies USING btree (orthanc_study_id);


--
-- Name: idx_imaging_studies_patient; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_patient ON imaging.imaging_studies USING btree (patient_id);


--
-- Name: idx_imaging_studies_tenant; Type: INDEX; Schema: imaging; Owner: -
--

CREATE INDEX idx_imaging_studies_tenant ON imaging.imaging_studies USING btree (tenant_id);


--
-- Name: idx_hl7_message_log_tenant; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_hl7_message_log_tenant ON ONLY integration.hl7_message_log USING btree (tenant_id);


--
-- Name: hl7_message_log_y2024m12_tenant_id_idx; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX hl7_message_log_y2024m12_tenant_id_idx ON integration.hl7_message_log_y2024m12 USING btree (tenant_id);


--
-- Name: hl7_message_log_y2025m01_tenant_id_idx; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX hl7_message_log_y2025m01_tenant_id_idx ON integration.hl7_message_log_y2025m01 USING btree (tenant_id);


--
-- Name: hl7_message_log_y2025m02_tenant_id_idx; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX hl7_message_log_y2025m02_tenant_id_idx ON integration.hl7_message_log_y2025m02 USING btree (tenant_id);


--
-- Name: hl7_message_log_y2025m03_tenant_id_idx; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX hl7_message_log_y2025m03_tenant_id_idx ON integration.hl7_message_log_y2025m03 USING btree (tenant_id);


--
-- Name: idx_webhook_deliveries_event; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhook_deliveries_event ON integration.webhook_deliveries USING btree (event_type, event_id);


--
-- Name: idx_webhook_deliveries_retry; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhook_deliveries_retry ON integration.webhook_deliveries USING btree (next_retry_at) WHERE ((status)::text = 'failed'::text);


--
-- Name: idx_webhook_deliveries_status; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhook_deliveries_status ON integration.webhook_deliveries USING btree (status);


--
-- Name: idx_webhook_deliveries_subscription; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhook_deliveries_subscription ON integration.webhook_deliveries USING btree (subscription_id);


--
-- Name: idx_webhook_deliveries_tenant_time; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhook_deliveries_tenant_time ON integration.webhook_deliveries USING btree (tenant_id, created_at DESC);


--
-- Name: idx_webhooks_active; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhooks_active ON integration.webhook_subscriptions USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_webhooks_events; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhooks_events ON integration.webhook_subscriptions USING gin (event_types);


--
-- Name: idx_webhooks_tenant; Type: INDEX; Schema: integration; Owner: -
--

CREATE INDEX idx_webhooks_tenant ON integration.webhook_subscriptions USING btree (tenant_id);


--
-- Name: ux_integration_credentials; Type: INDEX; Schema: integration; Owner: -
--

CREATE UNIQUE INDEX ux_integration_credentials ON integration.integration_credentials USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), code);


--
-- Name: idx_batches_tenant_item_expiry; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_batches_tenant_item_expiry ON inventory.batches USING btree (tenant_id, item_id, expiry_date) WHERE (quantity_available > (0)::numeric);


--
-- Name: idx_categories_parent; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_categories_parent ON inventory.item_categories USING btree (parent_id);


--
-- Name: idx_categories_path; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_categories_path ON inventory.item_categories USING btree (path);


--
-- Name: idx_categories_tenant; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_categories_tenant ON inventory.item_categories USING btree (tenant_id);


--
-- Name: idx_items_barcode; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_barcode ON inventory.items USING btree (barcode) WHERE (barcode IS NOT NULL);


--
-- Name: idx_items_category; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_category ON inventory.items USING btree (category_id);


--
-- Name: idx_items_code; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_code ON inventory.items USING gin (code) WHERE (code IS NOT NULL);


--
-- Name: idx_items_name; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_name ON inventory.items USING gin (name public.gin_trgm_ops);


--
-- Name: idx_items_search; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_search ON inventory.items USING gin (search_terms);


--
-- Name: idx_items_sku; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_sku ON inventory.items USING btree (tenant_id, sku);


--
-- Name: idx_items_tenant; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_items_tenant ON inventory.items USING btree (tenant_id);


--
-- Name: idx_po_status; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_po_status ON inventory.purchase_orders USING btree (status);


--
-- Name: idx_po_supplier; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_po_supplier ON inventory.purchase_orders USING btree (supplier_id);


--
-- Name: idx_po_tenant; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_po_tenant ON inventory.purchase_orders USING btree (tenant_id);


--
-- Name: idx_poitems_item; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_poitems_item ON inventory.purchase_order_items USING btree (item_id);


--
-- Name: idx_poitems_po; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_poitems_po ON inventory.purchase_order_items USING btree (purchase_order_id);


--
-- Name: idx_stockledger_tenant_item_date; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_stockledger_tenant_item_date ON ONLY inventory.stock_ledgers USING btree (tenant_id, item_id, created_at DESC);


--
-- Name: idx_stockloc_tenant; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_stockloc_tenant ON inventory.stock_locations USING btree (tenant_id);


--
-- Name: idx_suppliers_name; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_suppliers_name ON inventory.suppliers USING gin (name public.gin_trgm_ops);


--
-- Name: idx_suppliers_tenant; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX idx_suppliers_tenant ON inventory.suppliers USING btree (tenant_id);


--
-- Name: stock_ledgers_y2024m12_tenant_id_item_id_created_at_idx; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX stock_ledgers_y2024m12_tenant_id_item_id_created_at_idx ON inventory.stock_ledgers_y2024m12 USING btree (tenant_id, item_id, created_at DESC);


--
-- Name: stock_ledgers_y2025m01_tenant_id_item_id_created_at_idx; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX stock_ledgers_y2025m01_tenant_id_item_id_created_at_idx ON inventory.stock_ledgers_y2025m01 USING btree (tenant_id, item_id, created_at DESC);


--
-- Name: stock_ledgers_y2025m02_tenant_id_item_id_created_at_idx; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX stock_ledgers_y2025m02_tenant_id_item_id_created_at_idx ON inventory.stock_ledgers_y2025m02 USING btree (tenant_id, item_id, created_at DESC);


--
-- Name: stock_ledgers_y2025m03_tenant_id_item_id_created_at_idx; Type: INDEX; Schema: inventory; Owner: -
--

CREATE INDEX stock_ledgers_y2025m03_tenant_id_item_id_created_at_idx ON inventory.stock_ledgers_y2025m03 USING btree (tenant_id, item_id, created_at DESC);


--
-- Name: ux_current_stock; Type: INDEX; Schema: inventory; Owner: -
--

CREATE UNIQUE INDEX ux_current_stock ON inventory.current_stock USING btree (tenant_id, item_id, COALESCE(location_id, '00000000-0000-0000-0000-000000000000'::uuid));


--
-- Name: idx_alert_config_active; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_alert_config_active ON laboratory.alert_configurations USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_alert_config_tenant; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_alert_config_tenant ON laboratory.alert_configurations USING btree (tenant_id);


--
-- Name: idx_alert_config_test; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_alert_config_test ON laboratory.alert_configurations USING gin (test_code);


--
-- Name: idx_qc_date; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_qc_date ON laboratory.quality_controls USING btree (qc_date DESC);


--
-- Name: idx_qc_machine; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_qc_machine ON laboratory.quality_controls USING btree (machine_id) WHERE (machine_id IS NOT NULL);


--
-- Name: idx_qc_status; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_qc_status ON laboratory.quality_controls USING btree (status);


--
-- Name: idx_qc_tenant; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_qc_tenant ON laboratory.quality_controls USING btree (tenant_id);


--
-- Name: idx_qc_test; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_qc_test ON laboratory.quality_controls USING gin (test_code);


--
-- Name: idx_samples_barcode; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_barcode ON laboratory.samples USING btree (barcode) WHERE (barcode IS NOT NULL);


--
-- Name: idx_samples_collected; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_collected ON laboratory.samples USING btree (tenant_id, collected_at DESC);


--
-- Name: idx_samples_machine; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_machine ON laboratory.samples USING btree (machine_id, machine_interface_status) WHERE (machine_id IS NOT NULL);


--
-- Name: idx_samples_patient; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_patient ON laboratory.samples USING btree (patient_id);


--
-- Name: idx_samples_service_request; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_service_request ON laboratory.samples USING btree (service_request_id);


--
-- Name: idx_samples_status; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_status ON laboratory.samples USING btree (status);


--
-- Name: idx_samples_tenant; Type: INDEX; Schema: laboratory; Owner: -
--

CREATE INDEX idx_samples_tenant ON laboratory.samples USING btree (tenant_id);


--
-- Name: idx_appointments_checked_in; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_checked_in ON scheduling.appointments USING btree (tenant_id, checked_in_at DESC) WHERE (checked_in_at IS NOT NULL);


--
-- Name: idx_appointments_patient; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_patient ON scheduling.appointments USING btree (patient_id);


--
-- Name: idx_appointments_practitioner; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_practitioner ON scheduling.appointments USING btree (practitioner_id);


--
-- Name: idx_appointments_slot; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_slot ON scheduling.appointments USING btree (slot_id);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_status ON scheduling.appointments USING btree (status);


--
-- Name: idx_appointments_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_tenant ON scheduling.appointments USING btree (tenant_id);


--
-- Name: idx_appointments_tenant_practitioner_time; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_tenant_practitioner_time ON scheduling.appointments USING btree (tenant_id, practitioner_id, start_time);


--
-- Name: idx_appointments_tenant_status_date; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_tenant_status_date ON scheduling.appointments USING btree (tenant_id, status, (((start_time AT TIME ZONE 'UTC'::text))::date));


--
-- Name: idx_appointments_time; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appointments_time ON scheduling.appointments USING btree (tenant_id, start_time, end_time);


--
-- Name: idx_appt_history_appointment; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_appt_history_appointment ON scheduling.appointment_history USING btree (appointment_id);


--
-- Name: idx_blocks_practitioner; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_blocks_practitioner ON scheduling.block_schedules USING btree (practitioner_id);


--
-- Name: idx_blocks_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_blocks_tenant ON scheduling.block_schedules USING btree (tenant_id);


--
-- Name: idx_blocks_time; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_blocks_time ON scheduling.block_schedules USING btree (start_time, end_time);


--
-- Name: idx_queue_tokens_issued; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_issued ON scheduling.queue_tokens USING btree (issued_at DESC);


--
-- Name: idx_queue_tokens_patient; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_patient ON scheduling.queue_tokens USING btree (patient_id);


--
-- Name: idx_queue_tokens_queue; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_queue ON scheduling.queue_tokens USING btree (queue_id);


--
-- Name: idx_queue_tokens_status; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_status ON scheduling.queue_tokens USING btree (status);


--
-- Name: idx_queue_tokens_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_tenant ON scheduling.queue_tokens USING btree (tenant_id);


--
-- Name: idx_queue_tokens_waiting; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queue_tokens_waiting ON scheduling.queue_tokens USING btree (queue_id, token_sequence) WHERE ((status)::text = 'waiting'::text);


--
-- Name: idx_queues_active; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queues_active ON scheduling.queues USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_queues_location; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queues_location ON scheduling.queues USING btree (location_id);


--
-- Name: idx_queues_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_queues_tenant ON scheduling.queues USING btree (tenant_id);


--
-- Name: idx_schedules_horizon; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_schedules_horizon ON scheduling.schedules USING btree (planning_horizon_start, planning_horizon_end);


--
-- Name: idx_schedules_location; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_schedules_location ON scheduling.schedules USING btree (location_id);


--
-- Name: idx_schedules_practitioner; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_schedules_practitioner ON scheduling.schedules USING btree (practitioner_id);


--
-- Name: idx_schedules_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_schedules_tenant ON scheduling.schedules USING btree (tenant_id);


--
-- Name: idx_slots_schedule; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_slots_schedule ON scheduling.slots USING btree (schedule_id);


--
-- Name: idx_slots_status; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_slots_status ON scheduling.slots USING btree (status) WHERE ((status)::text = 'free'::text);


--
-- Name: idx_slots_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_slots_tenant ON scheduling.slots USING btree (tenant_id);


--
-- Name: idx_slots_time; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_slots_time ON scheduling.slots USING btree (tenant_id, start_time, end_time);


--
-- Name: idx_waitlist_date; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_waitlist_date ON scheduling.waitlist USING btree (preferred_date_start);


--
-- Name: idx_waitlist_patient; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_waitlist_patient ON scheduling.waitlist USING btree (patient_id);


--
-- Name: idx_waitlist_status; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_waitlist_status ON scheduling.waitlist USING btree (status) WHERE ((status)::text = 'waiting'::text);


--
-- Name: idx_waitlist_tenant; Type: INDEX; Schema: scheduling; Owner: -
--

CREATE INDEX idx_waitlist_tenant ON scheduling.waitlist USING btree (tenant_id);


--
-- Name: ux_code_systems; Type: INDEX; Schema: terminology; Owner: -
--

CREATE UNIQUE INDEX ux_code_systems ON terminology.code_systems USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), identifier);


--
-- Name: ux_concepts; Type: INDEX; Schema: terminology; Owner: -
--

CREATE UNIQUE INDEX ux_concepts ON terminology.concepts USING btree (COALESCE(tenant_id, '00000000-0000-0000-0000-000000000000'::uuid), code);


--
-- Name: idx_wh_fact_encounters_org_tenant_start; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX idx_wh_fact_encounters_org_tenant_start ON ONLY warehouse.fact_encounters USING btree (org_id, tenant_id, start_at);


--
-- Name: fact_encounters_2025_01_org_id_tenant_id_start_at_idx; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX fact_encounters_2025_01_org_id_tenant_id_start_at_idx ON warehouse.fact_encounters_2025_01 USING btree (org_id, tenant_id, start_at);


--
-- Name: idx_wh_dim_patients_org_tenant; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX idx_wh_dim_patients_org_tenant ON warehouse.dim_patients USING btree (org_id, tenant_id);


--
-- Name: idx_wh_dim_tenants_org; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX idx_wh_dim_tenants_org ON warehouse.dim_tenants USING btree (org_id);


--
-- Name: idx_wh_fact_invoices_org_tenant_date; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX idx_wh_fact_invoices_org_tenant_date ON warehouse.fact_invoices USING btree (org_id, tenant_id, invoice_date);


--
-- Name: idx_wh_fact_stock_org_tenant_time; Type: INDEX; Schema: warehouse; Owner: -
--

CREATE INDEX idx_wh_fact_stock_org_tenant_time ON ONLY warehouse.fact_stock_movements USING btree (org_id, tenant_id, occurred_at);


--
-- Name: patient_merge_events_default_pkey; Type: INDEX ATTACH; Schema: clinical; Owner: -
--

ALTER INDEX clinical.patient_merge_events_pkey ATTACH PARTITION clinical.patient_merge_events_default_pkey;


--
-- Name: patient_merge_events_default_tenant_id_source_patient_id_e_idx1; Type: INDEX ATTACH; Schema: clinical; Owner: -
--

ALTER INDEX clinical.idx_patient_merge_tenant_source ATTACH PARTITION clinical.patient_merge_events_default_tenant_id_source_patient_id_e_idx1;


--
-- Name: patient_merge_events_default_tenant_id_source_patient_id_ev_idx; Type: INDEX ATTACH; Schema: clinical; Owner: -
--

ALTER INDEX clinical.idx_patient_merge_source_when_merged ATTACH PARTITION clinical.patient_merge_events_default_tenant_id_source_patient_id_ev_idx;


--
-- Name: patient_merge_events_default_tenant_id_target_patient_id_ev_idx; Type: INDEX ATTACH; Schema: clinical; Owner: -
--

ALTER INDEX clinical.idx_patient_merge_tenant_target ATTACH PARTITION clinical.patient_merge_events_default_tenant_id_target_patient_id_ev_idx;


--
-- Name: notifications_y2024m12_pkey; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.notifications_pkey ATTACH PARTITION communication.notifications_y2024m12_pkey;


--
-- Name: notifications_y2024m12_tenant_id_idx; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.idx_notifications_tenant ATTACH PARTITION communication.notifications_y2024m12_tenant_id_idx;


--
-- Name: notifications_y2025m01_pkey; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.notifications_pkey ATTACH PARTITION communication.notifications_y2025m01_pkey;


--
-- Name: notifications_y2025m01_tenant_id_idx; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.idx_notifications_tenant ATTACH PARTITION communication.notifications_y2025m01_tenant_id_idx;


--
-- Name: notifications_y2025m02_pkey; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.notifications_pkey ATTACH PARTITION communication.notifications_y2025m02_pkey;


--
-- Name: notifications_y2025m02_tenant_id_idx; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.idx_notifications_tenant ATTACH PARTITION communication.notifications_y2025m02_tenant_id_idx;


--
-- Name: notifications_y2025m03_pkey; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.notifications_pkey ATTACH PARTITION communication.notifications_y2025m03_pkey;


--
-- Name: notifications_y2025m03_tenant_id_idx; Type: INDEX ATTACH; Schema: communication; Owner: -
--

ALTER INDEX communication.idx_notifications_tenant ATTACH PARTITION communication.notifications_y2025m03_tenant_id_idx;


--
-- Name: audit_logs_y2024m12_pkey; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.audit_logs_pkey ATTACH PARTITION core.audit_logs_y2024m12_pkey;


--
-- Name: audit_logs_y2024m12_resource_type_resource_id_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_resource ATTACH PARTITION core.audit_logs_y2024m12_resource_type_resource_id_idx;


--
-- Name: audit_logs_y2024m12_tenant_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_tenant_time ATTACH PARTITION core.audit_logs_y2024m12_tenant_id_occurred_at_idx;


--
-- Name: audit_logs_y2024m12_user_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_user ATTACH PARTITION core.audit_logs_y2024m12_user_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m01_pkey; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.audit_logs_pkey ATTACH PARTITION core.audit_logs_y2025m01_pkey;


--
-- Name: audit_logs_y2025m01_resource_type_resource_id_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_resource ATTACH PARTITION core.audit_logs_y2025m01_resource_type_resource_id_idx;


--
-- Name: audit_logs_y2025m01_tenant_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_tenant_time ATTACH PARTITION core.audit_logs_y2025m01_tenant_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m01_user_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_user ATTACH PARTITION core.audit_logs_y2025m01_user_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m02_pkey; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.audit_logs_pkey ATTACH PARTITION core.audit_logs_y2025m02_pkey;


--
-- Name: audit_logs_y2025m02_resource_type_resource_id_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_resource ATTACH PARTITION core.audit_logs_y2025m02_resource_type_resource_id_idx;


--
-- Name: audit_logs_y2025m02_tenant_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_tenant_time ATTACH PARTITION core.audit_logs_y2025m02_tenant_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m02_user_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_user ATTACH PARTITION core.audit_logs_y2025m02_user_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m03_pkey; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.audit_logs_pkey ATTACH PARTITION core.audit_logs_y2025m03_pkey;


--
-- Name: audit_logs_y2025m03_resource_type_resource_id_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_resource ATTACH PARTITION core.audit_logs_y2025m03_resource_type_resource_id_idx;


--
-- Name: audit_logs_y2025m03_tenant_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_tenant_time ATTACH PARTITION core.audit_logs_y2025m03_tenant_id_occurred_at_idx;


--
-- Name: audit_logs_y2025m03_user_id_occurred_at_idx; Type: INDEX ATTACH; Schema: core; Owner: -
--

ALTER INDEX core.idx_audit_logs_user ATTACH PARTITION core.audit_logs_y2025m03_user_id_occurred_at_idx;


--
-- Name: hl7_message_log_y2024m12_pkey; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.hl7_message_log_pkey ATTACH PARTITION integration.hl7_message_log_y2024m12_pkey;


--
-- Name: hl7_message_log_y2024m12_tenant_id_idx; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.idx_hl7_message_log_tenant ATTACH PARTITION integration.hl7_message_log_y2024m12_tenant_id_idx;


--
-- Name: hl7_message_log_y2025m01_pkey; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.hl7_message_log_pkey ATTACH PARTITION integration.hl7_message_log_y2025m01_pkey;


--
-- Name: hl7_message_log_y2025m01_tenant_id_idx; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.idx_hl7_message_log_tenant ATTACH PARTITION integration.hl7_message_log_y2025m01_tenant_id_idx;


--
-- Name: hl7_message_log_y2025m02_pkey; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.hl7_message_log_pkey ATTACH PARTITION integration.hl7_message_log_y2025m02_pkey;


--
-- Name: hl7_message_log_y2025m02_tenant_id_idx; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.idx_hl7_message_log_tenant ATTACH PARTITION integration.hl7_message_log_y2025m02_tenant_id_idx;


--
-- Name: hl7_message_log_y2025m03_pkey; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.hl7_message_log_pkey ATTACH PARTITION integration.hl7_message_log_y2025m03_pkey;


--
-- Name: hl7_message_log_y2025m03_tenant_id_idx; Type: INDEX ATTACH; Schema: integration; Owner: -
--

ALTER INDEX integration.idx_hl7_message_log_tenant ATTACH PARTITION integration.hl7_message_log_y2025m03_tenant_id_idx;


--
-- Name: stock_ledgers_y2024m12_pkey; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.stock_ledgers_pkey ATTACH PARTITION inventory.stock_ledgers_y2024m12_pkey;


--
-- Name: stock_ledgers_y2024m12_tenant_id_item_id_created_at_idx; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.idx_stockledger_tenant_item_date ATTACH PARTITION inventory.stock_ledgers_y2024m12_tenant_id_item_id_created_at_idx;


--
-- Name: stock_ledgers_y2025m01_pkey; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.stock_ledgers_pkey ATTACH PARTITION inventory.stock_ledgers_y2025m01_pkey;


--
-- Name: stock_ledgers_y2025m01_tenant_id_item_id_created_at_idx; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.idx_stockledger_tenant_item_date ATTACH PARTITION inventory.stock_ledgers_y2025m01_tenant_id_item_id_created_at_idx;


--
-- Name: stock_ledgers_y2025m02_pkey; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.stock_ledgers_pkey ATTACH PARTITION inventory.stock_ledgers_y2025m02_pkey;


--
-- Name: stock_ledgers_y2025m02_tenant_id_item_id_created_at_idx; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.idx_stockledger_tenant_item_date ATTACH PARTITION inventory.stock_ledgers_y2025m02_tenant_id_item_id_created_at_idx;


--
-- Name: stock_ledgers_y2025m03_pkey; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.stock_ledgers_pkey ATTACH PARTITION inventory.stock_ledgers_y2025m03_pkey;


--
-- Name: stock_ledgers_y2025m03_tenant_id_item_id_created_at_idx; Type: INDEX ATTACH; Schema: inventory; Owner: -
--

ALTER INDEX inventory.idx_stockledger_tenant_item_date ATTACH PARTITION inventory.stock_ledgers_y2025m03_tenant_id_item_id_created_at_idx;


--
-- Name: fact_encounters_2025_01_org_id_tenant_id_start_at_idx; Type: INDEX ATTACH; Schema: warehouse; Owner: -
--

ALTER INDEX warehouse.idx_wh_fact_encounters_org_tenant_start ATTACH PARTITION warehouse.fact_encounters_2025_01_org_id_tenant_id_start_at_idx;


--
-- Name: fact_encounters_2025_01_pkey; Type: INDEX ATTACH; Schema: warehouse; Owner: -
--

ALTER INDEX warehouse.fact_encounters_pkey ATTACH PARTITION warehouse.fact_encounters_2025_01_pkey;


--
-- Name: abdm_registrations trg_abdm_reg_updated_at; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_abdm_reg_updated_at BEFORE UPDATE ON abdm.abdm_registrations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: abdm_care_contexts trg_care_context_updated_at; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_care_context_updated_at BEFORE UPDATE ON abdm.abdm_care_contexts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: hiu_data_requests trg_hiu_requests_updated_at; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_hiu_requests_updated_at BEFORE UPDATE ON abdm.hiu_data_requests FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: abdm_care_contexts trg_require_tenant_context_abdm_care_contexts; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_abdm_care_contexts BEFORE INSERT OR DELETE OR UPDATE ON abdm.abdm_care_contexts FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: abdm_registrations trg_require_tenant_context_abdm_registrations; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_abdm_registrations BEFORE INSERT OR DELETE OR UPDATE ON abdm.abdm_registrations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: hiu_data_requests trg_require_tenant_context_hiu_data_requests; Type: TRIGGER; Schema: abdm; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_hiu_data_requests BEFORE INSERT OR DELETE OR UPDATE ON abdm.hiu_data_requests FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: accounts trg_accounts_updated_at; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_accounts_updated_at BEFORE UPDATE ON billing.accounts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: insurance_claims trg_claims_updated_at; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_claims_updated_at BEFORE UPDATE ON billing.insurance_claims FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: insurance_policies trg_insurance_policies_updated_at; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_insurance_policies_updated_at BEFORE UPDATE ON billing.insurance_policies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: invoices trg_invoices_updated_at; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_invoices_updated_at BEFORE UPDATE ON billing.invoices FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: pre_authorizations trg_preauth_updated_at; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_preauth_updated_at BEFORE UPDATE ON billing.pre_authorizations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: accounts trg_require_tenant_context_accounts; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_accounts BEFORE INSERT OR DELETE OR UPDATE ON billing.accounts FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: insurance_claims trg_require_tenant_context_insurance_claims; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_insurance_claims BEFORE INSERT OR DELETE OR UPDATE ON billing.insurance_claims FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: insurance_companies trg_require_tenant_context_insurance_companies; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_insurance_companies BEFORE INSERT OR DELETE OR UPDATE ON billing.insurance_companies FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: insurance_policies trg_require_tenant_context_insurance_policies; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_insurance_policies BEFORE INSERT OR DELETE OR UPDATE ON billing.insurance_policies FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: invoice_line_items trg_require_tenant_context_invoice_line_items; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_invoice_line_items BEFORE INSERT OR DELETE OR UPDATE ON billing.invoice_line_items FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: invoices trg_require_tenant_context_invoices; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_invoices BEFORE INSERT OR DELETE OR UPDATE ON billing.invoices FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: payment_allocations trg_require_tenant_context_payment_allocations; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_payment_allocations BEFORE INSERT OR DELETE OR UPDATE ON billing.payment_allocations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: payments trg_require_tenant_context_payments; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_payments BEFORE INSERT OR DELETE OR UPDATE ON billing.payments FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: pre_authorizations trg_require_tenant_context_pre_authorizations; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_pre_authorizations BEFORE INSERT OR DELETE OR UPDATE ON billing.pre_authorizations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: price_list_items trg_require_tenant_context_price_list_items; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_price_list_items BEFORE INSERT OR DELETE OR UPDATE ON billing.price_list_items FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: price_lists trg_require_tenant_context_price_lists; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_price_lists BEFORE INSERT OR DELETE OR UPDATE ON billing.price_lists FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: service_masters trg_require_tenant_context_service_masters; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_service_masters BEFORE INSERT OR DELETE OR UPDATE ON billing.service_masters FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: invoices trg_validate_invoice_totals; Type: TRIGGER; Schema: billing; Owner: -
--

CREATE TRIGGER trg_validate_invoice_totals BEFORE INSERT OR UPDATE ON billing.invoices FOR EACH ROW EXECUTE FUNCTION billing.validate_invoice_totals();


--
-- Name: donors trg_donors_updated_at; Type: TRIGGER; Schema: blood_bank; Owner: -
--

CREATE TRIGGER trg_donors_updated_at BEFORE UPDATE ON blood_bank.donors FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: blood_units trg_require_tenant_context_blood_units; Type: TRIGGER; Schema: blood_bank; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_blood_units BEFORE INSERT OR DELETE OR UPDATE ON blood_bank.blood_units FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: cross_matches trg_require_tenant_context_cross_matches; Type: TRIGGER; Schema: blood_bank; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_cross_matches BEFORE INSERT OR DELETE OR UPDATE ON blood_bank.cross_matches FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: donors trg_require_tenant_context_donors; Type: TRIGGER; Schema: blood_bank; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_donors BEFORE INSERT OR DELETE OR UPDATE ON blood_bank.donors FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: transfusions trg_require_tenant_context_transfusions; Type: TRIGGER; Schema: blood_bank; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_transfusions BEFORE INSERT OR DELETE OR UPDATE ON blood_bank.transfusions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_merge_events trg_apply_patient_merge_event; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_apply_patient_merge_event AFTER INSERT ON clinical.patient_merge_events FOR EACH ROW EXECUTE FUNCTION clinical.apply_patient_merge_event();


--
-- Name: patient_merge_undo_events trg_apply_patient_unmerge_event; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_apply_patient_unmerge_event AFTER INSERT ON clinical.patient_merge_undo_events FOR EACH ROW EXECUTE FUNCTION clinical.apply_patient_unmerge_event();


--
-- Name: care_plans trg_care_plans_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_care_plans_updated_at BEFORE UPDATE ON clinical.care_plans FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: conditions trg_conditions_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_conditions_updated_at BEFORE UPDATE ON clinical.conditions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: discharge_summaries trg_discharge_summaries_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_discharge_summaries_updated_at BEFORE UPDATE ON clinical.discharge_summaries FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: encounters trg_encounters_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_encounters_updated_at BEFORE UPDATE ON clinical.encounters FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: break_glass_sessions trg_enforce_break_glass_user; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_enforce_break_glass_user BEFORE INSERT OR UPDATE ON clinical.break_glass_sessions FOR EACH ROW EXECUTE FUNCTION clinical.enforce_break_glass_user();


--
-- Name: icu_beds trg_icu_beds_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_icu_beds_updated_at BEFORE UPDATE ON clinical.icu_beds FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: medication_requests trg_medrequests_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_medrequests_updated_at BEFORE UPDATE ON clinical.medication_requests FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: encounter_care_team_members trg_normalize_encounter_care_team_members; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_normalize_encounter_care_team_members BEFORE INSERT OR UPDATE ON clinical.encounter_care_team_members FOR EACH ROW EXECUTE FUNCTION clinical.normalize_encounter_care_team_member();


--
-- Name: clinical_notes trg_notes_search; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_notes_search BEFORE INSERT OR UPDATE ON clinical.clinical_notes FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('search_content', 'pg_catalog.english', 'content');


--
-- Name: nursing_tasks trg_nursing_tasks_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_nursing_tasks_updated_at BEFORE UPDATE ON clinical.nursing_tasks FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: observations trg_observations_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_observations_updated_at BEFORE UPDATE ON clinical.observations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: operation_theatres trg_ot_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_ot_updated_at BEFORE UPDATE ON clinical.operation_theatres FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: patients trg_patients_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_patients_updated_at BEFORE UPDATE ON clinical.patients FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: allergy_intolerances trg_require_tenant_context_allergy_intolerances; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_allergy_intolerances BEFORE INSERT OR DELETE OR UPDATE ON clinical.allergy_intolerances FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: anesthesia_records trg_require_tenant_context_anesthesia_records; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_anesthesia_records BEFORE INSERT OR DELETE OR UPDATE ON clinical.anesthesia_records FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: beds trg_require_tenant_context_beds; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_beds BEFORE INSERT OR DELETE OR UPDATE ON clinical.beds FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: break_glass_sessions trg_require_tenant_context_break_glass_sessions; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_break_glass_sessions BEFORE INSERT OR DELETE OR UPDATE ON clinical.break_glass_sessions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: care_plans trg_require_tenant_context_care_plans; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_care_plans BEFORE INSERT OR DELETE OR UPDATE ON clinical.care_plans FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: clinical_notes trg_require_tenant_context_clinical_notes; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_clinical_notes BEFORE INSERT OR DELETE OR UPDATE ON clinical.clinical_notes FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: conditions trg_require_tenant_context_conditions; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_conditions BEFORE INSERT OR DELETE OR UPDATE ON clinical.conditions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: diagnostic_reports trg_require_tenant_context_diagnostic_reports; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_diagnostic_reports BEFORE INSERT OR DELETE OR UPDATE ON clinical.diagnostic_reports FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: discharge_summaries trg_require_tenant_context_discharge_summaries; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_discharge_summaries BEFORE INSERT OR DELETE OR UPDATE ON clinical.discharge_summaries FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: encounter_care_team_members trg_require_tenant_context_encounter_care_team_members; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_encounter_care_team_members BEFORE INSERT OR DELETE OR UPDATE ON clinical.encounter_care_team_members FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: encounters trg_require_tenant_context_encounters; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_encounters BEFORE INSERT OR DELETE OR UPDATE ON clinical.encounters FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: episode_of_care trg_require_tenant_context_episode_of_care; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_episode_of_care BEFORE INSERT OR DELETE OR UPDATE ON clinical.episode_of_care FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: external_fulfillments trg_require_tenant_context_external_fulfillments; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_external_fulfillments BEFORE INSERT OR DELETE OR UPDATE ON clinical.external_fulfillments FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: icu_beds trg_require_tenant_context_icu_beds; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_icu_beds BEFORE INSERT OR DELETE OR UPDATE ON clinical.icu_beds FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: locations trg_require_tenant_context_locations; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_locations BEFORE INSERT OR DELETE OR UPDATE ON clinical.locations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: medication_administrations trg_require_tenant_context_medication_administrations; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_medication_administrations BEFORE INSERT OR DELETE OR UPDATE ON clinical.medication_administrations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: medication_requests trg_require_tenant_context_medication_requests; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_medication_requests BEFORE INSERT OR DELETE OR UPDATE ON clinical.medication_requests FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: medico_legal_cases trg_require_tenant_context_medico_legal_cases; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_medico_legal_cases BEFORE INSERT OR DELETE OR UPDATE ON clinical.medico_legal_cases FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: nursing_tasks trg_require_tenant_context_nursing_tasks; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_nursing_tasks BEFORE INSERT OR DELETE OR UPDATE ON clinical.nursing_tasks FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: observations trg_require_tenant_context_observations; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_observations BEFORE INSERT OR DELETE OR UPDATE ON clinical.observations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: operation_theatres trg_require_tenant_context_operation_theatres; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_operation_theatres BEFORE INSERT OR DELETE OR UPDATE ON clinical.operation_theatres FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_consent_directives trg_require_tenant_context_patient_consent_directives; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patient_consent_directives BEFORE INSERT OR DELETE OR UPDATE ON clinical.patient_consent_directives FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_identifiers trg_require_tenant_context_patient_identifiers; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patient_identifiers BEFORE INSERT OR DELETE OR UPDATE ON clinical.patient_identifiers FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_merge_events trg_require_tenant_context_patient_merge_events; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patient_merge_events BEFORE INSERT OR DELETE OR UPDATE ON clinical.patient_merge_events FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_merge_undo_events trg_require_tenant_context_patient_merge_undo_events; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patient_merge_undo_events BEFORE INSERT OR DELETE OR UPDATE ON clinical.patient_merge_undo_events FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patient_sensitivity trg_require_tenant_context_patient_sensitivity; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patient_sensitivity BEFORE INSERT OR DELETE OR UPDATE ON clinical.patient_sensitivity FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: patients trg_require_tenant_context_patients; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_patients BEFORE INSERT OR DELETE OR UPDATE ON clinical.patients FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: practitioners trg_require_tenant_context_practitioners; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_practitioners BEFORE INSERT OR DELETE OR UPDATE ON clinical.practitioners FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: resource_sensitivity trg_require_tenant_context_resource_sensitivity; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_resource_sensitivity BEFORE INSERT OR DELETE OR UPDATE ON clinical.resource_sensitivity FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: sensitive_access_log trg_require_tenant_context_sensitive_access_log; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_sensitive_access_log BEFORE INSERT OR DELETE OR UPDATE ON clinical.sensitive_access_log FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: sensitivity_labels trg_require_tenant_context_sensitivity_labels; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_sensitivity_labels BEFORE INSERT OR DELETE OR UPDATE ON clinical.sensitivity_labels FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: service_requests trg_require_tenant_context_service_requests; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_service_requests BEFORE INSERT OR DELETE OR UPDATE ON clinical.service_requests FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: shift_handovers trg_require_tenant_context_shift_handovers; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_shift_handovers BEFORE INSERT OR DELETE OR UPDATE ON clinical.shift_handovers FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: surgeries trg_require_tenant_context_surgeries; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_surgeries BEFORE INSERT OR DELETE OR UPDATE ON clinical.surgeries FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: service_requests trg_service_requests_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_service_requests_updated_at BEFORE UPDATE ON clinical.service_requests FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: surgeries trg_surgeries_updated_at; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_surgeries_updated_at BEFORE UPDATE ON clinical.surgeries FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: break_glass_sessions trg_update_updated_at_break_glass_sessions; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_update_updated_at_break_glass_sessions BEFORE UPDATE ON clinical.break_glass_sessions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: encounter_care_team_members trg_update_updated_at_encounter_care_team_members; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_update_updated_at_encounter_care_team_members BEFORE UPDATE ON clinical.encounter_care_team_members FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: patient_identifiers trg_update_updated_at_patient_identifiers; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_update_updated_at_patient_identifiers BEFORE UPDATE ON clinical.patient_identifiers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: patient_merge_events trg_update_updated_at_patient_merge_events; Type: TRIGGER; Schema: clinical; Owner: -
--

CREATE TRIGGER trg_update_updated_at_patient_merge_events BEFORE UPDATE ON clinical.patient_merge_events FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: bulk_campaigns trg_campaigns_updated_at; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_campaigns_updated_at BEFORE UPDATE ON communication.bulk_campaigns FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: bulk_campaigns trg_require_tenant_context_bulk_campaigns; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_bulk_campaigns BEFORE INSERT OR DELETE OR UPDATE ON communication.bulk_campaigns FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: notification_channels trg_require_tenant_context_notification_channels; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_notification_channels BEFORE INSERT OR DELETE OR UPDATE ON communication.notification_channels FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: notification_logs trg_require_tenant_context_notification_logs; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_notification_logs BEFORE INSERT OR DELETE OR UPDATE ON communication.notification_logs FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: notification_templates trg_require_tenant_context_notification_templates; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_notification_templates BEFORE INSERT OR DELETE OR UPDATE ON communication.notification_templates FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: notifications trg_require_tenant_context_notifications; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_notifications BEFORE INSERT OR DELETE OR UPDATE ON communication.notifications FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: user_notification_preferences trg_require_tenant_context_user_notification_preferences; Type: TRIGGER; Schema: communication; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_user_notification_preferences BEFORE INSERT OR DELETE OR UPDATE ON communication.user_notification_preferences FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: users trg_check_user_limit; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_check_user_limit BEFORE INSERT ON core.users FOR EACH ROW EXECUTE FUNCTION core.check_user_limit();


--
-- Name: organization_members trg_require_org_context_org_members; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_org_context_org_members BEFORE INSERT OR DELETE OR UPDATE ON core.organization_members FOR EACH ROW EXECUTE FUNCTION public.require_org_context();


--
-- Name: organization_tenant_memberships trg_require_org_context_org_tenants; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_org_context_org_tenants BEFORE INSERT OR DELETE OR UPDATE ON core.organization_tenant_memberships FOR EACH ROW EXECUTE FUNCTION public.require_org_context();


--
-- Name: api_clients trg_require_tenant_context_api_clients; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_api_clients BEFORE INSERT OR DELETE OR UPDATE ON core.api_clients FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: api_keys trg_require_tenant_context_api_keys; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_api_keys BEFORE INSERT OR DELETE OR UPDATE ON core.api_keys FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: audit_logs trg_require_tenant_context_audit_logs; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_audit_logs BEFORE INSERT OR DELETE OR UPDATE ON core.audit_logs FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: consent_logs trg_require_tenant_context_consent_logs; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_consent_logs BEFORE INSERT OR DELETE OR UPDATE ON core.consent_logs FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: data_deletion_requests trg_require_tenant_context_data_deletion_requests; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_data_deletion_requests BEFORE INSERT OR DELETE OR UPDATE ON core.data_deletion_requests FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: external_organizations trg_require_tenant_context_external_organizations; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_external_organizations BEFORE INSERT OR DELETE OR UPDATE ON core.external_organizations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: external_practitioners trg_require_tenant_context_external_practitioners; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_external_practitioners BEFORE INSERT OR DELETE OR UPDATE ON core.external_practitioners FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: external_service_agreements trg_require_tenant_context_external_service_agreements; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_external_service_agreements BEFORE INSERT OR DELETE OR UPDATE ON core.external_service_agreements FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: otp_verifications trg_require_tenant_context_otp_verifications; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_otp_verifications BEFORE INSERT OR DELETE OR UPDATE ON core.otp_verifications FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: password_policies trg_require_tenant_context_password_policies; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_password_policies BEFORE INSERT OR DELETE OR UPDATE ON core.password_policies FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: retention_policies trg_require_tenant_context_retention_policies; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_retention_policies BEFORE INSERT OR DELETE OR UPDATE ON core.retention_policies FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: roles trg_require_tenant_context_roles; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_roles BEFORE INSERT OR DELETE OR UPDATE ON core.roles FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: system_configurations trg_require_tenant_context_system_configurations; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_system_configurations BEFORE INSERT OR DELETE OR UPDATE ON core.system_configurations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: tenant_subscriptions trg_require_tenant_context_tenant_subscriptions; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_tenant_subscriptions BEFORE INSERT OR DELETE OR UPDATE ON core.tenant_subscriptions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: usage_metrics trg_require_tenant_context_usage_metrics; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_usage_metrics BEFORE INSERT OR DELETE OR UPDATE ON core.usage_metrics FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: user_roles trg_require_tenant_context_user_roles; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_user_roles BEFORE INSERT OR DELETE OR UPDATE ON core.user_roles FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: user_sessions trg_require_tenant_context_user_sessions; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_user_sessions BEFORE INSERT OR DELETE OR UPDATE ON core.user_sessions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: users trg_require_tenant_context_users; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_users BEFORE INSERT OR DELETE OR UPDATE ON core.users FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: external_organizations trg_update_updated_at_external_organizations; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_update_updated_at_external_organizations BEFORE UPDATE ON core.external_organizations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: external_practitioners trg_update_updated_at_external_practitioners; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_update_updated_at_external_practitioners BEFORE UPDATE ON core.external_practitioners FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: organization_tenant_memberships trg_update_updated_at_org_tenant_memberships; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_update_updated_at_org_tenant_memberships BEFORE UPDATE ON core.organization_tenant_memberships FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: organization_members trg_update_updated_at_organization_members; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_update_updated_at_organization_members BEFORE UPDATE ON core.organization_members FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: organizations trg_update_updated_at_organizations; Type: TRIGGER; Schema: core; Owner: -
--

CREATE TRIGGER trg_update_updated_at_organizations BEFORE UPDATE ON core.organizations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: documents trg_documents_updated_at; Type: TRIGGER; Schema: documents; Owner: -
--

CREATE TRIGGER trg_documents_updated_at BEFORE UPDATE ON documents.documents FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: document_access_log trg_require_tenant_context_document_access_log; Type: TRIGGER; Schema: documents; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_document_access_log BEFORE INSERT OR DELETE OR UPDATE ON documents.document_access_log FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: document_types trg_require_tenant_context_document_types; Type: TRIGGER; Schema: documents; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_document_types BEFORE INSERT OR DELETE OR UPDATE ON documents.document_types FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: document_versions trg_require_tenant_context_document_versions; Type: TRIGGER; Schema: documents; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_document_versions BEFORE INSERT OR DELETE OR UPDATE ON documents.document_versions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: documents trg_require_tenant_context_documents; Type: TRIGGER; Schema: documents; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_documents BEFORE INSERT OR DELETE OR UPDATE ON documents.documents FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: imaging_orders trg_imaging_orders_updated_at; Type: TRIGGER; Schema: imaging; Owner: -
--

CREATE TRIGGER trg_imaging_orders_updated_at BEFORE UPDATE ON imaging.imaging_orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: imaging_studies trg_imaging_studies_updated_at; Type: TRIGGER; Schema: imaging; Owner: -
--

CREATE TRIGGER trg_imaging_studies_updated_at BEFORE UPDATE ON imaging.imaging_studies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: imaging_orders trg_require_tenant_context_imaging_orders; Type: TRIGGER; Schema: imaging; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_imaging_orders BEFORE INSERT OR DELETE OR UPDATE ON imaging.imaging_orders FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: imaging_studies trg_require_tenant_context_imaging_studies; Type: TRIGGER; Schema: imaging; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_imaging_studies BEFORE INSERT OR DELETE OR UPDATE ON imaging.imaging_studies FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: hl7_message_log trg_require_tenant_context_hl7_message_log; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_hl7_message_log BEFORE INSERT OR DELETE OR UPDATE ON integration.hl7_message_log FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: integration_credentials trg_require_tenant_context_integration_credentials; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_integration_credentials BEFORE INSERT OR DELETE OR UPDATE ON integration.integration_credentials FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: integration_endpoints trg_require_tenant_context_integration_endpoints; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_integration_endpoints BEFORE INSERT OR DELETE OR UPDATE ON integration.integration_endpoints FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: webhook_deliveries trg_require_tenant_context_webhook_deliveries; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_webhook_deliveries BEFORE INSERT OR DELETE OR UPDATE ON integration.webhook_deliveries FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: webhook_subscriptions trg_require_tenant_context_webhook_subscriptions; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_webhook_subscriptions BEFORE INSERT OR DELETE OR UPDATE ON integration.webhook_subscriptions FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: webhook_subscriptions trg_webhooks_updated_at; Type: TRIGGER; Schema: integration; Owner: -
--

CREATE TRIGGER trg_webhooks_updated_at BEFORE UPDATE ON integration.webhook_subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: items trg_items_search; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_items_search BEFORE INSERT OR UPDATE ON inventory.items FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('search_terms', 'pg_catalog.english', 'name', 'generic_name', 'brand_name', 'sku');


--
-- Name: batches trg_require_tenant_context_batches; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_batches BEFORE INSERT OR DELETE OR UPDATE ON inventory.batches FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: current_stock trg_require_tenant_context_current_stock; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_current_stock BEFORE INSERT OR DELETE OR UPDATE ON inventory.current_stock FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: item_categories trg_require_tenant_context_item_categories; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_item_categories BEFORE INSERT OR DELETE OR UPDATE ON inventory.item_categories FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: items trg_require_tenant_context_items; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_items BEFORE INSERT OR DELETE OR UPDATE ON inventory.items FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: purchase_order_items trg_require_tenant_context_purchase_order_items; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_purchase_order_items BEFORE INSERT OR DELETE OR UPDATE ON inventory.purchase_order_items FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: purchase_orders trg_require_tenant_context_purchase_orders; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_purchase_orders BEFORE INSERT OR DELETE OR UPDATE ON inventory.purchase_orders FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: stock_ledgers trg_require_tenant_context_stock_ledgers; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_stock_ledgers BEFORE INSERT OR DELETE OR UPDATE ON inventory.stock_ledgers FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: stock_locations trg_require_tenant_context_stock_locations; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_stock_locations BEFORE INSERT OR DELETE OR UPDATE ON inventory.stock_locations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: suppliers trg_require_tenant_context_suppliers; Type: TRIGGER; Schema: inventory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_suppliers BEFORE INSERT OR DELETE OR UPDATE ON inventory.suppliers FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: alert_configurations trg_alert_config_updated_at; Type: TRIGGER; Schema: laboratory; Owner: -
--

CREATE TRIGGER trg_alert_config_updated_at BEFORE UPDATE ON laboratory.alert_configurations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: alert_configurations trg_require_tenant_context_alert_configurations; Type: TRIGGER; Schema: laboratory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_alert_configurations BEFORE INSERT OR DELETE OR UPDATE ON laboratory.alert_configurations FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: quality_controls trg_require_tenant_context_quality_controls; Type: TRIGGER; Schema: laboratory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_quality_controls BEFORE INSERT OR DELETE OR UPDATE ON laboratory.quality_controls FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: samples trg_require_tenant_context_samples; Type: TRIGGER; Schema: laboratory; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_samples BEFORE INSERT OR DELETE OR UPDATE ON laboratory.samples FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: samples trg_samples_updated_at; Type: TRIGGER; Schema: laboratory; Owner: -
--

CREATE TRIGGER trg_samples_updated_at BEFORE UPDATE ON laboratory.samples FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: appointments trg_appointments_updated_at; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_appointments_updated_at BEFORE UPDATE ON scheduling.appointments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: queue_tokens trg_queue_tokens_updated_at; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_queue_tokens_updated_at BEFORE UPDATE ON scheduling.queue_tokens FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: queues trg_queues_updated_at; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_queues_updated_at BEFORE UPDATE ON scheduling.queues FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: appointment_history trg_require_tenant_context_appointment_history; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_appointment_history BEFORE INSERT OR DELETE OR UPDATE ON scheduling.appointment_history FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: appointments trg_require_tenant_context_appointments; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_appointments BEFORE INSERT OR DELETE OR UPDATE ON scheduling.appointments FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: block_schedules trg_require_tenant_context_block_schedules; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_block_schedules BEFORE INSERT OR DELETE OR UPDATE ON scheduling.block_schedules FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: queue_tokens trg_require_tenant_context_queue_tokens; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_queue_tokens BEFORE INSERT OR DELETE OR UPDATE ON scheduling.queue_tokens FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: queues trg_require_tenant_context_queues; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_queues BEFORE INSERT OR DELETE OR UPDATE ON scheduling.queues FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: schedules trg_require_tenant_context_schedules; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_schedules BEFORE INSERT OR DELETE OR UPDATE ON scheduling.schedules FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: slots trg_require_tenant_context_slots; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_slots BEFORE INSERT OR DELETE OR UPDATE ON scheduling.slots FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: waitlist trg_require_tenant_context_waitlist; Type: TRIGGER; Schema: scheduling; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_waitlist BEFORE INSERT OR DELETE OR UPDATE ON scheduling.waitlist FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: code_systems trg_require_tenant_context_code_systems; Type: TRIGGER; Schema: terminology; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_code_systems BEFORE INSERT OR DELETE OR UPDATE ON terminology.code_systems FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: concept_maps trg_require_tenant_context_concept_maps; Type: TRIGGER; Schema: terminology; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_concept_maps BEFORE INSERT OR DELETE OR UPDATE ON terminology.concept_maps FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: concepts trg_require_tenant_context_concepts; Type: TRIGGER; Schema: terminology; Owner: -
--

CREATE TRIGGER trg_require_tenant_context_concepts BEFORE INSERT OR DELETE OR UPDATE ON terminology.concepts FOR EACH ROW EXECUTE FUNCTION public.require_tenant_context();


--
-- Name: abdm_care_contexts abdm_care_contexts_hip_facility_id_fkey; Type: FK CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_hip_facility_id_fkey FOREIGN KEY (hip_facility_id) REFERENCES core.tenants(id);


--
-- Name: abdm_care_contexts abdm_care_contexts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_care_contexts
    ADD CONSTRAINT abdm_care_contexts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: abdm_registrations abdm_registrations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.abdm_registrations
    ADD CONSTRAINT abdm_registrations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: hiu_data_requests hiu_data_requests_hiu_facility_id_fkey; Type: FK CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_hiu_facility_id_fkey FOREIGN KEY (hiu_facility_id) REFERENCES core.tenants(id);


--
-- Name: hiu_data_requests hiu_data_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: abdm; Owner: -
--

ALTER TABLE ONLY abdm.hiu_data_requests
    ADD CONSTRAINT hiu_data_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: accounts accounts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.accounts
    ADD CONSTRAINT accounts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: insurance_claims insurance_claims_insurance_company_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_insurance_company_id_fkey__tenant FOREIGN KEY (tenant_id, insurance_company_id) REFERENCES billing.insurance_companies(tenant_id, id);


--
-- Name: insurance_claims insurance_claims_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_claims
    ADD CONSTRAINT insurance_claims_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: insurance_companies insurance_companies_price_list_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_companies
    ADD CONSTRAINT insurance_companies_price_list_id_fkey__tenant FOREIGN KEY (tenant_id, price_list_id) REFERENCES billing.price_lists(tenant_id, id);


--
-- Name: insurance_companies insurance_companies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_companies
    ADD CONSTRAINT insurance_companies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: insurance_policies insurance_policies_insurance_company_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_policies
    ADD CONSTRAINT insurance_policies_insurance_company_id_fkey__tenant FOREIGN KEY (tenant_id, insurance_company_id) REFERENCES billing.insurance_companies(tenant_id, id);


--
-- Name: insurance_policies insurance_policies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.insurance_policies
    ADD CONSTRAINT insurance_policies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: invoice_line_items invoice_line_items_invoice_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_line_items
    ADD CONSTRAINT invoice_line_items_invoice_id_fkey__tenant FOREIGN KEY (tenant_id, invoice_id) REFERENCES billing.invoices(tenant_id, id);


--
-- Name: invoice_line_items invoice_line_items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoice_line_items
    ADD CONSTRAINT invoice_line_items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: invoices invoices_account_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_account_id_fkey__tenant FOREIGN KEY (tenant_id, account_id) REFERENCES billing.accounts(tenant_id, id);


--
-- Name: invoices invoices_price_list_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_price_list_id_fkey__tenant FOREIGN KEY (tenant_id, price_list_id) REFERENCES billing.price_lists(tenant_id, id);


--
-- Name: invoices invoices_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.invoices
    ADD CONSTRAINT invoices_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: payment_allocations payment_allocations_invoice_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_invoice_id_fkey__tenant FOREIGN KEY (tenant_id, invoice_id) REFERENCES billing.invoices(tenant_id, id);


--
-- Name: payment_allocations payment_allocations_payment_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_payment_id_fkey__tenant FOREIGN KEY (tenant_id, payment_id) REFERENCES billing.payments(tenant_id, id);


--
-- Name: payment_allocations payment_allocations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payment_allocations
    ADD CONSTRAINT payment_allocations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: payments payments_account_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_account_id_fkey__tenant FOREIGN KEY (tenant_id, account_id) REFERENCES billing.accounts(tenant_id, id);


--
-- Name: payments payments_invoice_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_invoice_id_fkey__tenant FOREIGN KEY (tenant_id, invoice_id) REFERENCES billing.invoices(tenant_id, id);


--
-- Name: payments payments_original_payment_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_original_payment_id_fkey__tenant FOREIGN KEY (tenant_id, original_payment_id) REFERENCES billing.payments(tenant_id, id);


--
-- Name: payments payments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: pre_authorizations pre_authorizations_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: pre_authorizations pre_authorizations_insurance_company_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_insurance_company_id_fkey__tenant FOREIGN KEY (tenant_id, insurance_company_id) REFERENCES billing.insurance_companies(tenant_id, id);


--
-- Name: pre_authorizations pre_authorizations_insurance_policy_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_insurance_policy_id_fkey__tenant FOREIGN KEY (tenant_id, insurance_policy_id) REFERENCES billing.insurance_policies(tenant_id, id);


--
-- Name: pre_authorizations pre_authorizations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.pre_authorizations
    ADD CONSTRAINT pre_authorizations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: price_list_items price_list_items_price_list_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_price_list_id_fkey__tenant FOREIGN KEY (tenant_id, price_list_id) REFERENCES billing.price_lists(tenant_id, id);


--
-- Name: price_list_items price_list_items_service_id_fkey__tenant; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_service_id_fkey__tenant FOREIGN KEY (tenant_id, service_id) REFERENCES billing.service_masters(tenant_id, id);


--
-- Name: price_list_items price_list_items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_list_items
    ADD CONSTRAINT price_list_items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: price_lists price_lists_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.price_lists
    ADD CONSTRAINT price_lists_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: service_masters service_masters_tenant_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: -
--

ALTER TABLE ONLY billing.service_masters
    ADD CONSTRAINT service_masters_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: blood_units blood_units_donor_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_donor_id_fkey__tenant FOREIGN KEY (tenant_id, donor_id) REFERENCES blood_bank.donors(tenant_id, id);


--
-- Name: blood_units blood_units_tenant_id_fkey; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.blood_units
    ADD CONSTRAINT blood_units_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: cross_matches cross_matches_blood_unit_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.cross_matches
    ADD CONSTRAINT cross_matches_blood_unit_id_fkey__tenant FOREIGN KEY (tenant_id, blood_unit_id) REFERENCES blood_bank.blood_units(tenant_id, id);


--
-- Name: cross_matches cross_matches_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.cross_matches
    ADD CONSTRAINT cross_matches_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: cross_matches cross_matches_tenant_id_fkey; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.cross_matches
    ADD CONSTRAINT cross_matches_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: donors donors_tenant_id_fkey; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.donors
    ADD CONSTRAINT donors_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: transfusions transfusions_blood_unit_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_blood_unit_id_fkey__tenant FOREIGN KEY (tenant_id, blood_unit_id) REFERENCES blood_bank.blood_units(tenant_id, id);


--
-- Name: transfusions transfusions_cross_match_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_cross_match_id_fkey__tenant FOREIGN KEY (tenant_id, cross_match_id) REFERENCES blood_bank.cross_matches(tenant_id, id);


--
-- Name: transfusions transfusions_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: transfusions transfusions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: blood_bank; Owner: -
--

ALTER TABLE ONLY blood_bank.transfusions
    ADD CONSTRAINT transfusions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: allergy_intolerances allergy_intolerances_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.allergy_intolerances
    ADD CONSTRAINT allergy_intolerances_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: allergy_intolerances allergy_intolerances_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.allergy_intolerances
    ADD CONSTRAINT allergy_intolerances_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: allergy_intolerances allergy_intolerances_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.allergy_intolerances
    ADD CONSTRAINT allergy_intolerances_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: anesthesia_records anesthesia_records_surgery_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.anesthesia_records
    ADD CONSTRAINT anesthesia_records_surgery_id_fkey__tenant FOREIGN KEY (tenant_id, surgery_id) REFERENCES clinical.surgeries(tenant_id, id);


--
-- Name: anesthesia_records anesthesia_records_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.anesthesia_records
    ADD CONSTRAINT anesthesia_records_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: beds beds_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.beds
    ADD CONSTRAINT beds_location_id_fkey__tenant FOREIGN KEY (tenant_id, location_id) REFERENCES clinical.locations(tenant_id, id);


--
-- Name: beds beds_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.beds
    ADD CONSTRAINT beds_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: break_glass_sessions bg_approved_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.break_glass_sessions
    ADD CONSTRAINT bg_approved_by_fk FOREIGN KEY (tenant_id, approved_by) REFERENCES core.users(tenant_id, id);


--
-- Name: break_glass_sessions bg_user_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.break_glass_sessions
    ADD CONSTRAINT bg_user_fk FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: care_plans care_plans_author_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_author_id_fkey__tenant FOREIGN KEY (tenant_id, author_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: care_plans care_plans_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: care_plans care_plans_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: care_plans care_plans_replaces_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_replaces_fkey__tenant FOREIGN KEY (tenant_id, replaces) REFERENCES clinical.care_plans(tenant_id, id);


--
-- Name: care_plans care_plans_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.care_plans
    ADD CONSTRAINT care_plans_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: clinical_notes clinical_notes_amended_from_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_amended_from_fkey__tenant FOREIGN KEY (tenant_id, amended_from) REFERENCES clinical.clinical_notes(tenant_id, id);


--
-- Name: clinical_notes clinical_notes_author_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_author_id_fkey__tenant FOREIGN KEY (tenant_id, author_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: clinical_notes clinical_notes_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: clinical_notes clinical_notes_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: clinical_notes clinical_notes_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.clinical_notes
    ADD CONSTRAINT clinical_notes_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: conditions conditions_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: conditions conditions_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: conditions conditions_recorder_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_recorder_id_fkey__tenant FOREIGN KEY (tenant_id, recorder_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: conditions conditions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.conditions
    ADD CONSTRAINT conditions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: diagnostic_reports diagnostic_reports_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: diagnostic_reports diagnostic_reports_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: diagnostic_reports diagnostic_reports_performer_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_performer_id_fkey__tenant FOREIGN KEY (tenant_id, performer_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: diagnostic_reports diagnostic_reports_results_interpreter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_results_interpreter_id_fkey__tenant FOREIGN KEY (tenant_id, results_interpreter_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: diagnostic_reports diagnostic_reports_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.diagnostic_reports
    ADD CONSTRAINT diagnostic_reports_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: discharge_summaries discharge_summaries_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: discharge_summaries discharge_summaries_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: discharge_summaries discharge_summaries_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.discharge_summaries
    ADD CONSTRAINT discharge_summaries_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: encounter_care_team_members ectm_assigned_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT ectm_assigned_by_fk FOREIGN KEY (tenant_id, assigned_by) REFERENCES core.users(tenant_id, id);


--
-- Name: encounter_care_team_members ectm_encounter_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT ectm_encounter_fk FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id) ON DELETE CASCADE;


--
-- Name: encounter_care_team_members ectm_patient_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT ectm_patient_fk FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: encounter_care_team_members ectm_practitioner_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT ectm_practitioner_fk FOREIGN KEY (tenant_id, practitioner_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: encounter_care_team_members ectm_user_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounter_care_team_members
    ADD CONSTRAINT ectm_user_fk FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: encounters encounters_bed_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_bed_id_fkey__tenant FOREIGN KEY (tenant_id, bed_id) REFERENCES clinical.beds(tenant_id, id);


--
-- Name: encounters encounters_episode_of_care_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_episode_of_care_id_fkey__tenant FOREIGN KEY (tenant_id, episode_of_care_id) REFERENCES clinical.episode_of_care(tenant_id, id);


--
-- Name: encounters encounters_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_location_id_fkey__tenant FOREIGN KEY (tenant_id, location_id) REFERENCES clinical.locations(tenant_id, id);


--
-- Name: encounters encounters_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: encounters encounters_primary_practitioner_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_primary_practitioner_id_fkey__tenant FOREIGN KEY (tenant_id, primary_practitioner_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: encounters encounters_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.encounters
    ADD CONSTRAINT encounters_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: episode_of_care episode_of_care_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.episode_of_care
    ADD CONSTRAINT episode_of_care_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: episode_of_care episode_of_care_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.episode_of_care
    ADD CONSTRAINT episode_of_care_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: external_fulfillments ext_fulfill_org_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.external_fulfillments
    ADD CONSTRAINT ext_fulfill_org_fk FOREIGN KEY (tenant_id, external_org_id) REFERENCES core.external_organizations(tenant_id, id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: external_fulfillments ext_fulfill_pract_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.external_fulfillments
    ADD CONSTRAINT ext_fulfill_pract_fk FOREIGN KEY (tenant_id, external_practitioner_id) REFERENCES core.external_practitioners(tenant_id, id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: medication_administrations fk_tenant_46ca9e6eae92a0f9; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT fk_tenant_46ca9e6eae92a0f9 FOREIGN KEY (tenant_id, medication_request_id) REFERENCES clinical.medication_requests(tenant_id, id) NOT VALID;


--
-- Name: icu_beds icu_beds_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.icu_beds
    ADD CONSTRAINT icu_beds_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: locations locations_part_of_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.locations
    ADD CONSTRAINT locations_part_of_fkey__tenant FOREIGN KEY (tenant_id, part_of) REFERENCES clinical.locations(tenant_id, id);


--
-- Name: locations locations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.locations
    ADD CONSTRAINT locations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: medication_administrations medication_administrations_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT medication_administrations_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: medication_administrations medication_administrations_medication_request_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT medication_administrations_medication_request_id_fkey FOREIGN KEY (medication_request_id) REFERENCES clinical.medication_requests(id);


--
-- Name: medication_administrations medication_administrations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_administrations
    ADD CONSTRAINT medication_administrations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: medication_requests medication_requests_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: medication_requests medication_requests_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: medication_requests medication_requests_prior_prescription_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_prior_prescription_id_fkey__tenant FOREIGN KEY (tenant_id, prior_prescription_id) REFERENCES clinical.medication_requests(tenant_id, id);


--
-- Name: medication_requests medication_requests_requester_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_requester_id_fkey__tenant FOREIGN KEY (tenant_id, requester_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: medication_requests medication_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medication_requests
    ADD CONSTRAINT medication_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: medico_legal_cases medico_legal_cases_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: medico_legal_cases medico_legal_cases_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: medico_legal_cases medico_legal_cases_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.medico_legal_cases
    ADD CONSTRAINT medico_legal_cases_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: nursing_tasks nursing_tasks_care_plan_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.nursing_tasks
    ADD CONSTRAINT nursing_tasks_care_plan_id_fkey__tenant FOREIGN KEY (tenant_id, care_plan_id) REFERENCES clinical.care_plans(tenant_id, id);


--
-- Name: nursing_tasks nursing_tasks_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.nursing_tasks
    ADD CONSTRAINT nursing_tasks_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: nursing_tasks nursing_tasks_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.nursing_tasks
    ADD CONSTRAINT nursing_tasks_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: observations observations_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: observations observations_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: observations observations_performer_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_performer_id_fkey__tenant FOREIGN KEY (tenant_id, performer_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: observations observations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.observations
    ADD CONSTRAINT observations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: operation_theatres operation_theatres_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.operation_theatres
    ADD CONSTRAINT operation_theatres_location_id_fkey__tenant FOREIGN KEY (tenant_id, location_id) REFERENCES clinical.locations(tenant_id, id);


--
-- Name: operation_theatres operation_theatres_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.operation_theatres
    ADD CONSTRAINT operation_theatres_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: patient_consent_directives patient_consent_label_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_consent_directives
    ADD CONSTRAINT patient_consent_label_fk FOREIGN KEY (tenant_id, label_code) REFERENCES clinical.sensitivity_labels(tenant_id, code) ON DELETE RESTRICT;


--
-- Name: patient_consent_directives patient_consent_patient_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_consent_directives
    ADD CONSTRAINT patient_consent_patient_fk FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id) ON DELETE CASCADE;


--
-- Name: patient_consent_directives patient_consent_recorded_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_consent_directives
    ADD CONSTRAINT patient_consent_recorded_by_fk FOREIGN KEY (tenant_id, recorded_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_identifiers patient_identifiers_patient_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_identifiers
    ADD CONSTRAINT patient_identifiers_patient_fk FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id) ON DELETE CASCADE;


--
-- Name: patient_identifiers patient_identifiers_verified_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_identifiers
    ADD CONSTRAINT patient_identifiers_verified_by_fk FOREIGN KEY (tenant_id, verified_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_merge_events patient_merge_approved_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_approved_by_fk FOREIGN KEY (tenant_id, approved_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_merge_events patient_merge_performed_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_performed_by_fk FOREIGN KEY (tenant_id, performed_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_merge_events patient_merge_requested_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_requested_by_fk FOREIGN KEY (tenant_id, requested_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_merge_events patient_merge_source_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_source_fk FOREIGN KEY (tenant_id, source_patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: patient_merge_events patient_merge_target_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events
    ADD CONSTRAINT patient_merge_target_fk FOREIGN KEY (tenant_id, target_patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: patient_merge_undo_events patient_merge_undo_events_merge_event_id_merge_event_at_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_undo_events
    ADD CONSTRAINT patient_merge_undo_events_merge_event_id_merge_event_at_fkey FOREIGN KEY (merge_event_id, merge_event_at) REFERENCES clinical.patient_merge_events(id, event_at) ON DELETE CASCADE;


--
-- Name: patient_merge_undo_events patient_merge_undo_performed_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_merge_undo_events
    ADD CONSTRAINT patient_merge_undo_performed_by_fk FOREIGN KEY (tenant_id, performed_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_sensitivity patient_sensitivity_applied_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_sensitivity
    ADD CONSTRAINT patient_sensitivity_applied_by_fk FOREIGN KEY (tenant_id, applied_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patient_sensitivity patient_sensitivity_label_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_sensitivity
    ADD CONSTRAINT patient_sensitivity_label_fk FOREIGN KEY (tenant_id, label_code) REFERENCES clinical.sensitivity_labels(tenant_id, code) ON DELETE RESTRICT;


--
-- Name: patient_sensitivity patient_sensitivity_patient_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patient_sensitivity
    ADD CONSTRAINT patient_sensitivity_patient_fk FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id) ON DELETE CASCADE;


--
-- Name: patients patients_merged_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_merged_by_fk FOREIGN KEY (tenant_id, merged_by) REFERENCES core.users(tenant_id, id);


--
-- Name: patients patients_merged_into_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_merged_into_fk FOREIGN KEY (tenant_id, merged_into_patient_id) REFERENCES clinical.patients(tenant_id, id) DEFERRABLE;


--
-- Name: patients patients_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.patients
    ADD CONSTRAINT patients_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: practitioners practitioners_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: practitioners practitioners_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.practitioners
    ADD CONSTRAINT practitioners_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: resource_sensitivity resource_sensitivity_applied_by_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.resource_sensitivity
    ADD CONSTRAINT resource_sensitivity_applied_by_fk FOREIGN KEY (tenant_id, applied_by) REFERENCES core.users(tenant_id, id);


--
-- Name: resource_sensitivity resource_sensitivity_label_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.resource_sensitivity
    ADD CONSTRAINT resource_sensitivity_label_fk FOREIGN KEY (tenant_id, label_code) REFERENCES clinical.sensitivity_labels(tenant_id, code) ON DELETE RESTRICT;


--
-- Name: sensitive_access_log sensitive_access_log_bg_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.sensitive_access_log
    ADD CONSTRAINT sensitive_access_log_bg_fk FOREIGN KEY (tenant_id, break_glass_session_id) REFERENCES clinical.break_glass_sessions(tenant_id, id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: sensitive_access_log sensitive_access_log_user_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.sensitive_access_log
    ADD CONSTRAINT sensitive_access_log_user_fk FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: service_requests service_requests_based_on_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_based_on_fkey__tenant FOREIGN KEY (tenant_id, based_on) REFERENCES clinical.service_requests(tenant_id, id);


--
-- Name: service_requests service_requests_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: service_requests service_requests_patient_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_patient_id_fkey__tenant FOREIGN KEY (tenant_id, patient_id) REFERENCES clinical.patients(tenant_id, id);


--
-- Name: service_requests service_requests_performer_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_performer_location_id_fkey__tenant FOREIGN KEY (tenant_id, performer_location_id) REFERENCES clinical.locations(tenant_id, id);


--
-- Name: service_requests service_requests_replaces_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_replaces_fkey__tenant FOREIGN KEY (tenant_id, replaces) REFERENCES clinical.service_requests(tenant_id, id);


--
-- Name: service_requests service_requests_requester_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_requester_id_fkey__tenant FOREIGN KEY (tenant_id, requester_id) REFERENCES clinical.practitioners(tenant_id, id);


--
-- Name: service_requests service_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.service_requests
    ADD CONSTRAINT service_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: shift_handovers shift_handovers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.shift_handovers
    ADD CONSTRAINT shift_handovers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: surgeries surgeries_encounter_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_encounter_id_fkey__tenant FOREIGN KEY (tenant_id, encounter_id) REFERENCES clinical.encounters(tenant_id, id);


--
-- Name: surgeries surgeries_external_org_fk; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_external_org_fk FOREIGN KEY (tenant_id, external_org_id) REFERENCES core.external_organizations(tenant_id, id) DEFERRABLE;


--
-- Name: surgeries surgeries_ot_id_fkey__tenant; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_ot_id_fkey__tenant FOREIGN KEY (tenant_id, ot_id) REFERENCES clinical.operation_theatres(tenant_id, id);


--
-- Name: surgeries surgeries_tenant_id_fkey; Type: FK CONSTRAINT; Schema: clinical; Owner: -
--

ALTER TABLE ONLY clinical.surgeries
    ADD CONSTRAINT surgeries_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: bulk_campaigns bulk_campaigns_template_id_fkey__tenant; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.bulk_campaigns
    ADD CONSTRAINT bulk_campaigns_template_id_fkey__tenant FOREIGN KEY (tenant_id, template_id) REFERENCES communication.notification_templates(tenant_id, id);


--
-- Name: bulk_campaigns bulk_campaigns_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.bulk_campaigns
    ADD CONSTRAINT bulk_campaigns_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: notification_channels notification_channels_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_channels
    ADD CONSTRAINT notification_channels_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: notification_logs notification_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_logs
    ADD CONSTRAINT notification_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: notification_templates notification_templates_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.notification_templates
    ADD CONSTRAINT notification_templates_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: notifications notifications_template_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications
    ADD CONSTRAINT notifications_template_id_fkey FOREIGN KEY (template_id) REFERENCES communication.notification_templates(id);


--
-- Name: notifications notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications
    ADD CONSTRAINT notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: user_notification_preferences user_notification_preferences_tenant_id_fkey; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: user_notification_preferences user_notification_preferences_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: communication; Owner: -
--

ALTER TABLE ONLY communication.user_notification_preferences
    ADD CONSTRAINT user_notification_preferences_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: api_clients api_clients_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_clients
    ADD CONSTRAINT api_clients_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: api_keys api_keys_api_client_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_keys
    ADD CONSTRAINT api_keys_api_client_id_fkey__tenant FOREIGN KEY (tenant_id, api_client_id) REFERENCES core.api_clients(tenant_id, id);


--
-- Name: api_keys api_keys_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_keys
    ADD CONSTRAINT api_keys_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: api_keys api_keys_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.api_keys
    ADD CONSTRAINT api_keys_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: audit_logs audit_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs
    ADD CONSTRAINT audit_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: audit_logs_y2024m12 audit_logs_y2024m12_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2024m12
    ADD CONSTRAINT audit_logs_y2024m12_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: audit_logs_y2025m01 audit_logs_y2025m01_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m01
    ADD CONSTRAINT audit_logs_y2025m01_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: audit_logs_y2025m02 audit_logs_y2025m02_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m02
    ADD CONSTRAINT audit_logs_y2025m02_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: audit_logs_y2025m03 audit_logs_y2025m03_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.audit_logs_y2025m03
    ADD CONSTRAINT audit_logs_y2025m03_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: consent_logs consent_logs_data_fiduciary_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.consent_logs
    ADD CONSTRAINT consent_logs_data_fiduciary_id_fkey FOREIGN KEY (data_fiduciary_id) REFERENCES core.tenants(id);


--
-- Name: consent_logs consent_logs_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.consent_logs
    ADD CONSTRAINT consent_logs_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: data_deletion_requests data_deletion_requests_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.data_deletion_requests
    ADD CONSTRAINT data_deletion_requests_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: external_service_agreements ext_agreement_org_fk; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_service_agreements
    ADD CONSTRAINT ext_agreement_org_fk FOREIGN KEY (tenant_id, external_org_id) REFERENCES core.external_organizations(tenant_id, id) ON DELETE CASCADE;


--
-- Name: external_organizations external_orgs_tenant_fk; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_organizations
    ADD CONSTRAINT external_orgs_tenant_fk FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: external_practitioners external_pract_org_fk; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_practitioners
    ADD CONSTRAINT external_pract_org_fk FOREIGN KEY (tenant_id, external_org_id) REFERENCES core.external_organizations(tenant_id, id) ON DELETE SET NULL DEFERRABLE;


--
-- Name: external_practitioners external_pract_tenant_fk; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.external_practitioners
    ADD CONSTRAINT external_pract_tenant_fk FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: organization_members organization_members_org_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_members
    ADD CONSTRAINT organization_members_org_id_fkey FOREIGN KEY (org_id) REFERENCES core.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_user_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_members
    ADD CONSTRAINT organization_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES core.users(id) ON DELETE CASCADE;


--
-- Name: organization_tenant_memberships organization_tenant_memberships_org_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_tenant_memberships
    ADD CONSTRAINT organization_tenant_memberships_org_id_fkey FOREIGN KEY (org_id) REFERENCES core.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_tenant_memberships organization_tenant_memberships_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.organization_tenant_memberships
    ADD CONSTRAINT organization_tenant_memberships_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id) ON DELETE CASCADE;


--
-- Name: otp_verifications otp_verifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.otp_verifications
    ADD CONSTRAINT otp_verifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: otp_verifications otp_verifications_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.otp_verifications
    ADD CONSTRAINT otp_verifications_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: password_policies password_policies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.password_policies
    ADD CONSTRAINT password_policies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: retention_policies retention_policies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.retention_policies
    ADD CONSTRAINT retention_policies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES core.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES core.roles(id) ON DELETE CASCADE;


--
-- Name: roles roles_parent_role_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.roles
    ADD CONSTRAINT roles_parent_role_id_fkey__tenant FOREIGN KEY (tenant_id, parent_role_id) REFERENCES core.roles(tenant_id, id);


--
-- Name: roles roles_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.roles
    ADD CONSTRAINT roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: subscription_plans subscription_plans_api_rate_limit_tier_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.subscription_plans
    ADD CONSTRAINT subscription_plans_api_rate_limit_tier_fkey FOREIGN KEY (api_rate_limit_tier) REFERENCES core.api_rate_limits(tier_name);


--
-- Name: system_configurations system_configurations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.system_configurations
    ADD CONSTRAINT system_configurations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: system_configurations system_configurations_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.system_configurations
    ADD CONSTRAINT system_configurations_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: tenant_subscriptions tenant_subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_subscriptions
    ADD CONSTRAINT tenant_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES core.subscription_plans(id);


--
-- Name: tenant_subscriptions tenant_subscriptions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenant_subscriptions
    ADD CONSTRAINT tenant_subscriptions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: tenants tenants_org_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.tenants
    ADD CONSTRAINT tenants_org_id_fkey FOREIGN KEY (org_id) REFERENCES core.organizations(id);


--
-- Name: usage_metrics usage_metrics_subscription_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usage_metrics
    ADD CONSTRAINT usage_metrics_subscription_id_fkey__tenant FOREIGN KEY (tenant_id, subscription_id) REFERENCES core.tenant_subscriptions(tenant_id, id);


--
-- Name: usage_metrics usage_metrics_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.usage_metrics
    ADD CONSTRAINT usage_metrics_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: user_roles user_roles_assigned_by_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_assigned_by_fkey__tenant FOREIGN KEY (tenant_id, assigned_by) REFERENCES core.users(tenant_id, id);


--
-- Name: user_roles user_roles_role_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey__tenant FOREIGN KEY (tenant_id, role_id) REFERENCES core.roles(tenant_id, id);


--
-- Name: user_roles user_roles_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: user_roles user_roles_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: user_sessions user_sessions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_sessions
    ADD CONSTRAINT user_sessions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: user_sessions user_sessions_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: users users_tenant_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: -
--

ALTER TABLE ONLY core.users
    ADD CONSTRAINT users_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: document_access_log document_access_log_document_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_access_log
    ADD CONSTRAINT document_access_log_document_id_fkey__tenant FOREIGN KEY (tenant_id, document_id) REFERENCES documents.documents(tenant_id, id);


--
-- Name: document_access_log document_access_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_access_log
    ADD CONSTRAINT document_access_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: document_access_log document_access_log_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_access_log
    ADD CONSTRAINT document_access_log_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: document_types document_types_tenant_id_fkey; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_types
    ADD CONSTRAINT document_types_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: document_versions document_versions_document_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_document_id_fkey__tenant FOREIGN KEY (tenant_id, document_id) REFERENCES documents.documents(tenant_id, id);


--
-- Name: document_versions document_versions_previous_version_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_previous_version_id_fkey__tenant FOREIGN KEY (tenant_id, previous_version_id) REFERENCES documents.document_versions(tenant_id, id);


--
-- Name: document_versions document_versions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.document_versions
    ADD CONSTRAINT document_versions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: documents documents_document_type_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_document_type_id_fkey__tenant FOREIGN KEY (tenant_id, document_type_id) REFERENCES documents.document_types(tenant_id, id);


--
-- Name: documents documents_parent_document_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_parent_document_id_fkey__tenant FOREIGN KEY (tenant_id, parent_document_id) REFERENCES documents.documents(tenant_id, id);


--
-- Name: documents documents_tenant_id_fkey; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: documents documents_user_id_fkey__tenant; Type: FK CONSTRAINT; Schema: documents; Owner: -
--

ALTER TABLE ONLY documents.documents
    ADD CONSTRAINT documents_user_id_fkey__tenant FOREIGN KEY (tenant_id, user_id) REFERENCES core.users(tenant_id, id);


--
-- Name: imaging_orders imaging_orders_external_org_fk; Type: FK CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_external_org_fk FOREIGN KEY (tenant_id, external_org_id) REFERENCES core.external_organizations(tenant_id, id) DEFERRABLE;


--
-- Name: imaging_orders imaging_orders_external_pract_fk; Type: FK CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_external_pract_fk FOREIGN KEY (tenant_id, external_practitioner_id) REFERENCES core.external_practitioners(tenant_id, id) DEFERRABLE;


--
-- Name: imaging_orders imaging_orders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_orders
    ADD CONSTRAINT imaging_orders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: imaging_studies imaging_studies_imaging_order_id_fkey__tenant; Type: FK CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_studies
    ADD CONSTRAINT imaging_studies_imaging_order_id_fkey__tenant FOREIGN KEY (tenant_id, imaging_order_id) REFERENCES imaging.imaging_orders(tenant_id, id);


--
-- Name: imaging_studies imaging_studies_tenant_id_fkey; Type: FK CONSTRAINT; Schema: imaging; Owner: -
--

ALTER TABLE ONLY imaging.imaging_studies
    ADD CONSTRAINT imaging_studies_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: hl7_message_log hl7_message_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log
    ADD CONSTRAINT hl7_message_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: integration_credentials integration_credentials_endpoint_id_fkey__tenant; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credentials
    ADD CONSTRAINT integration_credentials_endpoint_id_fkey__tenant FOREIGN KEY (tenant_id, endpoint_id) REFERENCES integration.integration_endpoints(tenant_id, id);


--
-- Name: integration_credentials integration_credentials_tenant_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_credentials
    ADD CONSTRAINT integration_credentials_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: integration_endpoints integration_endpoints_tenant_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.integration_endpoints
    ADD CONSTRAINT integration_endpoints_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: webhook_deliveries webhook_deliveries_subscription_id_fkey__tenant; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_subscription_id_fkey__tenant FOREIGN KEY (tenant_id, subscription_id) REFERENCES integration.webhook_subscriptions(tenant_id, id);


--
-- Name: webhook_deliveries webhook_deliveries_tenant_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_deliveries
    ADD CONSTRAINT webhook_deliveries_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: webhook_subscriptions webhook_subscriptions_tenant_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: -
--

ALTER TABLE ONLY integration.webhook_subscriptions
    ADD CONSTRAINT webhook_subscriptions_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: batches batches_item_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_item_id_fkey__tenant FOREIGN KEY (tenant_id, item_id) REFERENCES inventory.items(tenant_id, id);


--
-- Name: batches batches_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_location_id_fkey__tenant FOREIGN KEY (tenant_id, location_id) REFERENCES inventory.stock_locations(tenant_id, id);


--
-- Name: batches batches_supplier_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_supplier_id_fkey__tenant FOREIGN KEY (tenant_id, supplier_id) REFERENCES inventory.suppliers(tenant_id, id);


--
-- Name: batches batches_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.batches
    ADD CONSTRAINT batches_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: current_stock current_stock_item_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.current_stock
    ADD CONSTRAINT current_stock_item_id_fkey__tenant FOREIGN KEY (tenant_id, item_id) REFERENCES inventory.items(tenant_id, id);


--
-- Name: current_stock current_stock_location_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.current_stock
    ADD CONSTRAINT current_stock_location_id_fkey__tenant FOREIGN KEY (tenant_id, location_id) REFERENCES inventory.stock_locations(tenant_id, id);


--
-- Name: current_stock current_stock_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.current_stock
    ADD CONSTRAINT current_stock_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: item_categories item_categories_parent_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.item_categories
    ADD CONSTRAINT item_categories_parent_id_fkey__tenant FOREIGN KEY (tenant_id, parent_id) REFERENCES inventory.item_categories(tenant_id, id);


--
-- Name: item_categories item_categories_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.item_categories
    ADD CONSTRAINT item_categories_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: items items_category_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.items
    ADD CONSTRAINT items_category_id_fkey__tenant FOREIGN KEY (tenant_id, category_id) REFERENCES inventory.item_categories(tenant_id, id);


--
-- Name: items items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.items
    ADD CONSTRAINT items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: purchase_order_items purchase_order_items_item_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_order_items
    ADD CONSTRAINT purchase_order_items_item_id_fkey__tenant FOREIGN KEY (tenant_id, item_id) REFERENCES inventory.items(tenant_id, id);


--
-- Name: purchase_order_items purchase_order_items_purchase_order_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey__tenant FOREIGN KEY (tenant_id, purchase_order_id) REFERENCES inventory.purchase_orders(tenant_id, id);


--
-- Name: purchase_order_items purchase_order_items_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_order_items
    ADD CONSTRAINT purchase_order_items_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: purchase_orders purchase_orders_supplier_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_fkey__tenant FOREIGN KEY (tenant_id, supplier_id) REFERENCES inventory.suppliers(tenant_id, id);


--
-- Name: purchase_orders purchase_orders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.purchase_orders
    ADD CONSTRAINT purchase_orders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: stock_ledgers stock_ledgers_batch_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers
    ADD CONSTRAINT stock_ledgers_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES inventory.batches(id);


--
-- Name: stock_ledgers stock_ledgers_item_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers
    ADD CONSTRAINT stock_ledgers_item_id_fkey FOREIGN KEY (item_id) REFERENCES inventory.items(id);


--
-- Name: stock_ledgers stock_ledgers_location_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers
    ADD CONSTRAINT stock_ledgers_location_id_fkey FOREIGN KEY (location_id) REFERENCES inventory.stock_locations(id);


--
-- Name: stock_ledgers stock_ledgers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers
    ADD CONSTRAINT stock_ledgers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: stock_locations stock_locations_parent_id_fkey__tenant; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_locations
    ADD CONSTRAINT stock_locations_parent_id_fkey__tenant FOREIGN KEY (tenant_id, parent_id) REFERENCES inventory.stock_locations(tenant_id, id);


--
-- Name: stock_locations stock_locations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.stock_locations
    ADD CONSTRAINT stock_locations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: suppliers suppliers_tenant_id_fkey; Type: FK CONSTRAINT; Schema: inventory; Owner: -
--

ALTER TABLE ONLY inventory.suppliers
    ADD CONSTRAINT suppliers_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: alert_configurations alert_configurations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.alert_configurations
    ADD CONSTRAINT alert_configurations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: quality_controls quality_controls_tenant_id_fkey; Type: FK CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.quality_controls
    ADD CONSTRAINT quality_controls_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: samples samples_tenant_id_fkey; Type: FK CONSTRAINT; Schema: laboratory; Owner: -
--

ALTER TABLE ONLY laboratory.samples
    ADD CONSTRAINT samples_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: appointment_history appointment_history_appointment_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointment_history
    ADD CONSTRAINT appointment_history_appointment_id_fkey__tenant FOREIGN KEY (tenant_id, appointment_id) REFERENCES scheduling.appointments(tenant_id, id);


--
-- Name: appointment_history appointment_history_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointment_history
    ADD CONSTRAINT appointment_history_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: appointments appointments_slot_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointments
    ADD CONSTRAINT appointments_slot_id_fkey__tenant FOREIGN KEY (tenant_id, slot_id) REFERENCES scheduling.slots(tenant_id, id);


--
-- Name: appointments appointments_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.appointments
    ADD CONSTRAINT appointments_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: block_schedules block_schedules_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.block_schedules
    ADD CONSTRAINT block_schedules_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: queue_tokens queue_tokens_queue_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queue_tokens
    ADD CONSTRAINT queue_tokens_queue_id_fkey__tenant FOREIGN KEY (tenant_id, queue_id) REFERENCES scheduling.queues(tenant_id, id);


--
-- Name: queue_tokens queue_tokens_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queue_tokens
    ADD CONSTRAINT queue_tokens_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: queues queues_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.queues
    ADD CONSTRAINT queues_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: schedules schedules_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.schedules
    ADD CONSTRAINT schedules_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: slots slots_schedule_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.slots
    ADD CONSTRAINT slots_schedule_id_fkey__tenant FOREIGN KEY (tenant_id, schedule_id) REFERENCES scheduling.schedules(tenant_id, id);


--
-- Name: slots slots_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.slots
    ADD CONSTRAINT slots_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: waitlist waitlist_offered_appointment_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.waitlist
    ADD CONSTRAINT waitlist_offered_appointment_id_fkey__tenant FOREIGN KEY (tenant_id, offered_appointment_id) REFERENCES scheduling.appointments(tenant_id, id);


--
-- Name: waitlist waitlist_scheduled_appointment_id_fkey__tenant; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.waitlist
    ADD CONSTRAINT waitlist_scheduled_appointment_id_fkey__tenant FOREIGN KEY (tenant_id, scheduled_appointment_id) REFERENCES scheduling.appointments(tenant_id, id);


--
-- Name: waitlist waitlist_tenant_id_fkey; Type: FK CONSTRAINT; Schema: scheduling; Owner: -
--

ALTER TABLE ONLY scheduling.waitlist
    ADD CONSTRAINT waitlist_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: code_systems code_systems_tenant_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.code_systems
    ADD CONSTRAINT code_systems_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: concept_map_elements concept_map_elements_concept_map_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concept_map_elements
    ADD CONSTRAINT concept_map_elements_concept_map_id_fkey FOREIGN KEY (concept_map_id) REFERENCES terminology.concept_maps(id) ON DELETE CASCADE;


--
-- Name: concept_maps concept_maps_tenant_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concept_maps
    ADD CONSTRAINT concept_maps_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: concepts concepts_code_system_id_fkey__tenant; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concepts
    ADD CONSTRAINT concepts_code_system_id_fkey__tenant FOREIGN KEY (tenant_id, code_system_id) REFERENCES terminology.code_systems(tenant_id, id);


--
-- Name: concepts concepts_parent_concept_id_fkey__tenant; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concepts
    ADD CONSTRAINT concepts_parent_concept_id_fkey__tenant FOREIGN KEY (tenant_id, parent_concept_id) REFERENCES terminology.concepts(tenant_id, id);


--
-- Name: concepts concepts_tenant_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.concepts
    ADD CONSTRAINT concepts_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: value_set_concepts value_set_concepts_concept_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_set_concepts
    ADD CONSTRAINT value_set_concepts_concept_id_fkey FOREIGN KEY (concept_id) REFERENCES terminology.concepts(id);


--
-- Name: value_set_concepts value_set_concepts_value_set_id_fkey; Type: FK CONSTRAINT; Schema: terminology; Owner: -
--

ALTER TABLE ONLY terminology.value_set_concepts
    ADD CONSTRAINT value_set_concepts_value_set_id_fkey FOREIGN KEY (value_set_id) REFERENCES terminology.value_sets(id) ON DELETE CASCADE;


--
-- Name: dim_patients dim_patients_org_id_tenant_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_patients
    ADD CONSTRAINT dim_patients_org_id_tenant_id_fkey FOREIGN KEY (org_id, tenant_id) REFERENCES warehouse.dim_tenants(org_id, tenant_id);


--
-- Name: dim_tenants dim_tenants_org_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_tenants
    ADD CONSTRAINT dim_tenants_org_id_fkey FOREIGN KEY (org_id) REFERENCES core.organizations(id);


--
-- Name: dim_tenants dim_tenants_tenant_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.dim_tenants
    ADD CONSTRAINT dim_tenants_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES core.tenants(id);


--
-- Name: fact_encounters fact_encounters_org_id_tenant_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_encounters
    ADD CONSTRAINT fact_encounters_org_id_tenant_id_fkey FOREIGN KEY (org_id, tenant_id) REFERENCES warehouse.dim_tenants(org_id, tenant_id);


--
-- Name: fact_encounters fact_encounters_org_id_tenant_id_patient_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_encounters
    ADD CONSTRAINT fact_encounters_org_id_tenant_id_patient_id_fkey FOREIGN KEY (org_id, tenant_id, patient_id) REFERENCES warehouse.dim_patients(org_id, tenant_id, patient_id);


--
-- Name: fact_invoices fact_invoices_org_id_tenant_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_invoices
    ADD CONSTRAINT fact_invoices_org_id_tenant_id_fkey FOREIGN KEY (org_id, tenant_id) REFERENCES warehouse.dim_tenants(org_id, tenant_id);


--
-- Name: fact_invoices fact_invoices_org_id_tenant_id_patient_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE ONLY warehouse.fact_invoices
    ADD CONSTRAINT fact_invoices_org_id_tenant_id_patient_id_fkey FOREIGN KEY (org_id, tenant_id, patient_id) REFERENCES warehouse.dim_patients(org_id, tenant_id, patient_id);


--
-- Name: fact_stock_movements fact_stock_movements_org_id_tenant_id_fkey; Type: FK CONSTRAINT; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_stock_movements
    ADD CONSTRAINT fact_stock_movements_org_id_tenant_id_fkey FOREIGN KEY (org_id, tenant_id) REFERENCES warehouse.dim_tenants(org_id, tenant_id);


--
-- Name: abdm_care_contexts; Type: ROW SECURITY; Schema: abdm; Owner: -
--

ALTER TABLE abdm.abdm_care_contexts ENABLE ROW LEVEL SECURITY;

--
-- Name: abdm_registrations; Type: ROW SECURITY; Schema: abdm; Owner: -
--

ALTER TABLE abdm.abdm_registrations ENABLE ROW LEVEL SECURITY;

--
-- Name: hiu_data_requests; Type: ROW SECURITY; Schema: abdm; Owner: -
--

ALTER TABLE abdm.hiu_data_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: abdm_care_contexts tenant_isolation_abdm_care_contexts; Type: POLICY; Schema: abdm; Owner: -
--

CREATE POLICY tenant_isolation_abdm_care_contexts ON abdm.abdm_care_contexts USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: abdm_registrations tenant_isolation_abdm_registrations; Type: POLICY; Schema: abdm; Owner: -
--

CREATE POLICY tenant_isolation_abdm_registrations ON abdm.abdm_registrations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hiu_data_requests tenant_isolation_hiu_data_requests; Type: POLICY; Schema: abdm; Owner: -
--

CREATE POLICY tenant_isolation_hiu_data_requests ON abdm.hiu_data_requests USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: accounts; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.accounts ENABLE ROW LEVEL SECURITY;

--
-- Name: insurance_claims; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.insurance_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: insurance_companies; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.insurance_companies ENABLE ROW LEVEL SECURITY;

--
-- Name: insurance_policies; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.insurance_policies ENABLE ROW LEVEL SECURITY;

--
-- Name: invoice_line_items; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.invoice_line_items ENABLE ROW LEVEL SECURITY;

--
-- Name: invoices; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: payment_allocations; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.payment_allocations ENABLE ROW LEVEL SECURITY;

--
-- Name: payments; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.payments ENABLE ROW LEVEL SECURITY;

--
-- Name: pre_authorizations; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.pre_authorizations ENABLE ROW LEVEL SECURITY;

--
-- Name: price_list_items; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.price_list_items ENABLE ROW LEVEL SECURITY;

--
-- Name: price_lists; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.price_lists ENABLE ROW LEVEL SECURITY;

--
-- Name: service_masters; Type: ROW SECURITY; Schema: billing; Owner: -
--

ALTER TABLE billing.service_masters ENABLE ROW LEVEL SECURITY;

--
-- Name: accounts tenant_isolation_accounts; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_accounts ON billing.accounts USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: insurance_claims tenant_isolation_insurance_claims; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_insurance_claims ON billing.insurance_claims USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: insurance_companies tenant_isolation_insurance_companies; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_insurance_companies ON billing.insurance_companies USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: insurance_policies tenant_isolation_insurance_policies; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_insurance_policies ON billing.insurance_policies USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: invoice_line_items tenant_isolation_invoice_line_items; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_invoice_line_items ON billing.invoice_line_items USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: invoices tenant_isolation_invoices; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_invoices ON billing.invoices USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: payment_allocations tenant_isolation_payment_allocations; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_payment_allocations ON billing.payment_allocations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: payments tenant_isolation_payments; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_payments ON billing.payments USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: pre_authorizations tenant_isolation_pre_authorizations; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_pre_authorizations ON billing.pre_authorizations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: price_list_items tenant_isolation_price_list_items; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_price_list_items ON billing.price_list_items USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: price_lists tenant_isolation_price_lists; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_price_lists ON billing.price_lists USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: service_masters tenant_isolation_service_masters; Type: POLICY; Schema: billing; Owner: -
--

CREATE POLICY tenant_isolation_service_masters ON billing.service_masters USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: blood_units; Type: ROW SECURITY; Schema: blood_bank; Owner: -
--

ALTER TABLE blood_bank.blood_units ENABLE ROW LEVEL SECURITY;

--
-- Name: cross_matches; Type: ROW SECURITY; Schema: blood_bank; Owner: -
--

ALTER TABLE blood_bank.cross_matches ENABLE ROW LEVEL SECURITY;

--
-- Name: donors; Type: ROW SECURITY; Schema: blood_bank; Owner: -
--

ALTER TABLE blood_bank.donors ENABLE ROW LEVEL SECURITY;

--
-- Name: blood_units tenant_isolation_blood_units; Type: POLICY; Schema: blood_bank; Owner: -
--

CREATE POLICY tenant_isolation_blood_units ON blood_bank.blood_units USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: cross_matches tenant_isolation_cross_matches; Type: POLICY; Schema: blood_bank; Owner: -
--

CREATE POLICY tenant_isolation_cross_matches ON blood_bank.cross_matches USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: donors tenant_isolation_donors; Type: POLICY; Schema: blood_bank; Owner: -
--

CREATE POLICY tenant_isolation_donors ON blood_bank.donors USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: transfusions tenant_isolation_transfusions; Type: POLICY; Schema: blood_bank; Owner: -
--

CREATE POLICY tenant_isolation_transfusions ON blood_bank.transfusions USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: transfusions; Type: ROW SECURITY; Schema: blood_bank; Owner: -
--

ALTER TABLE blood_bank.transfusions ENABLE ROW LEVEL SECURITY;

--
-- Name: allergy_intolerances; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.allergy_intolerances ENABLE ROW LEVEL SECURITY;

--
-- Name: anesthesia_records; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.anesthesia_records ENABLE ROW LEVEL SECURITY;

--
-- Name: beds; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.beds ENABLE ROW LEVEL SECURITY;

--
-- Name: break_glass_sessions; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.break_glass_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: care_plans; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.care_plans ENABLE ROW LEVEL SECURITY;

--
-- Name: clinical_notes; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.clinical_notes ENABLE ROW LEVEL SECURITY;

--
-- Name: conditions; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.conditions ENABLE ROW LEVEL SECURITY;

--
-- Name: diagnostic_reports; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.diagnostic_reports ENABLE ROW LEVEL SECURITY;

--
-- Name: discharge_summaries; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.discharge_summaries ENABLE ROW LEVEL SECURITY;

--
-- Name: encounter_care_team_members; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.encounter_care_team_members ENABLE ROW LEVEL SECURITY;

--
-- Name: encounters; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.encounters ENABLE ROW LEVEL SECURITY;

--
-- Name: episode_of_care; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.episode_of_care ENABLE ROW LEVEL SECURITY;

--
-- Name: external_fulfillments; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.external_fulfillments ENABLE ROW LEVEL SECURITY;

--
-- Name: icu_beds; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.icu_beds ENABLE ROW LEVEL SECURITY;

--
-- Name: locations; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.locations ENABLE ROW LEVEL SECURITY;

--
-- Name: medication_administrations; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.medication_administrations ENABLE ROW LEVEL SECURITY;

--
-- Name: medication_requests; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.medication_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: medico_legal_cases; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.medico_legal_cases ENABLE ROW LEVEL SECURITY;

--
-- Name: nursing_tasks; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.nursing_tasks ENABLE ROW LEVEL SECURITY;

--
-- Name: observations; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.observations ENABLE ROW LEVEL SECURITY;

--
-- Name: operation_theatres; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.operation_theatres ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_consent_directives; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_consent_directives ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_identifiers; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_identifiers ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_merge_events; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_events ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_merge_undo_events; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_merge_undo_events ENABLE ROW LEVEL SECURITY;

--
-- Name: patient_sensitivity; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patient_sensitivity ENABLE ROW LEVEL SECURITY;

--
-- Name: patients; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.patients ENABLE ROW LEVEL SECURITY;

--
-- Name: practitioners; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.practitioners ENABLE ROW LEVEL SECURITY;

--
-- Name: resource_sensitivity; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.resource_sensitivity ENABLE ROW LEVEL SECURITY;

--
-- Name: sensitive_access_log; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.sensitive_access_log ENABLE ROW LEVEL SECURITY;

--
-- Name: sensitivity_labels; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.sensitivity_labels ENABLE ROW LEVEL SECURITY;

--
-- Name: service_requests; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.service_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: shift_handovers; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.shift_handovers ENABLE ROW LEVEL SECURITY;

--
-- Name: surgeries; Type: ROW SECURITY; Schema: clinical; Owner: -
--

ALTER TABLE clinical.surgeries ENABLE ROW LEVEL SECURITY;

--
-- Name: allergy_intolerances tenant_isolation_allergy_intolerances; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_allergy_intolerances ON clinical.allergy_intolerances USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: anesthesia_records tenant_isolation_anesthesia_records; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_anesthesia_records ON clinical.anesthesia_records USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: beds tenant_isolation_beds; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_beds ON clinical.beds USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: break_glass_sessions tenant_isolation_break_glass_sessions; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_break_glass_sessions ON clinical.break_glass_sessions USING (((tenant_id = public.current_tenant_id()) AND (public.has_admin_access() OR (user_id = public.current_user_id())))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (public.has_admin_access() OR (user_id = public.current_user_id()))));


--
-- Name: care_plans tenant_isolation_care_plans; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_care_plans ON clinical.care_plans USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: clinical_notes tenant_isolation_clinical_notes; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_clinical_notes ON clinical.clinical_notes USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.clinical_notes'::text, id)))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.clinical_notes'::text, id))))));


--
-- Name: conditions tenant_isolation_conditions; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_conditions ON clinical.conditions USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: diagnostic_reports tenant_isolation_diagnostic_reports; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_diagnostic_reports ON clinical.diagnostic_reports USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.diagnostic_reports'::text, id)))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.diagnostic_reports'::text, id))))));


--
-- Name: discharge_summaries tenant_isolation_discharge_summaries; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_discharge_summaries ON clinical.discharge_summaries USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.discharge_summaries'::text, id)))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.discharge_summaries'::text, id))))));


--
-- Name: encounter_care_team_members tenant_isolation_encounter_care_team_members; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_encounter_care_team_members ON clinical.encounter_care_team_members USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: encounters tenant_isolation_encounters; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_encounters ON clinical.encounters USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: episode_of_care tenant_isolation_episode_of_care; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_episode_of_care ON clinical.episode_of_care USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: external_fulfillments tenant_isolation_external_fulfillments; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_external_fulfillments ON clinical.external_fulfillments USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: icu_beds tenant_isolation_icu_beds; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_icu_beds ON clinical.icu_beds USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: locations tenant_isolation_locations; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_locations ON clinical.locations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: medication_administrations tenant_isolation_medication_administrations; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_medication_administrations ON clinical.medication_administrations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: medication_requests tenant_isolation_medication_requests; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_medication_requests ON clinical.medication_requests USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: medico_legal_cases tenant_isolation_medico_legal_cases; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_medico_legal_cases ON clinical.medico_legal_cases USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: nursing_tasks tenant_isolation_nursing_tasks; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_nursing_tasks ON clinical.nursing_tasks USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: observations tenant_isolation_observations; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_observations ON clinical.observations USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.observations'::text, id)))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'clinical.observations'::text, id))))));


--
-- Name: operation_theatres tenant_isolation_operation_theatres; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_operation_theatres ON clinical.operation_theatres USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patient_consent_directives tenant_isolation_patient_consent_directives; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patient_consent_directives ON clinical.patient_consent_directives USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patient_identifiers tenant_isolation_patient_identifiers; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patient_identifiers ON clinical.patient_identifiers USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patient_merge_events tenant_isolation_patient_merge_events; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patient_merge_events ON clinical.patient_merge_events USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patient_merge_undo_events tenant_isolation_patient_merge_undo_events; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patient_merge_undo_events ON clinical.patient_merge_undo_events USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patient_sensitivity tenant_isolation_patient_sensitivity; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patient_sensitivity ON clinical.patient_sensitivity USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: patients tenant_isolation_patients; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_patients ON clinical.patients USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: practitioners tenant_isolation_practitioners; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_practitioners ON clinical.practitioners USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: resource_sensitivity tenant_isolation_resource_sensitivity; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_resource_sensitivity ON clinical.resource_sensitivity USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: sensitive_access_log tenant_isolation_sensitive_access_log; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_sensitive_access_log ON clinical.sensitive_access_log USING (((tenant_id = public.current_tenant_id()) AND (public.has_admin_access() OR (user_id = public.current_user_id())))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (public.has_admin_access() OR (user_id = public.current_user_id()))));


--
-- Name: sensitivity_labels tenant_isolation_sensitivity_labels; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_sensitivity_labels ON clinical.sensitivity_labels USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: service_requests tenant_isolation_service_requests; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_service_requests ON clinical.service_requests USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: shift_handovers tenant_isolation_shift_handovers; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_shift_handovers ON clinical.shift_handovers USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: surgeries tenant_isolation_surgeries; Type: POLICY; Schema: clinical; Owner: -
--

CREATE POLICY tenant_isolation_surgeries ON clinical.surgeries USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: bulk_campaigns; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.bulk_campaigns ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_channels; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notification_channels ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_logs; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notification_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: notification_templates; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notification_templates ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications_y2024m12; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications_y2024m12 ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications_y2025m01; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications_y2025m01 ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications_y2025m02; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications_y2025m02 ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications_y2025m03; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.notifications_y2025m03 ENABLE ROW LEVEL SECURITY;

--
-- Name: bulk_campaigns tenant_isolation_bulk_campaigns; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_bulk_campaigns ON communication.bulk_campaigns USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notification_channels tenant_isolation_notification_channels; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notification_channels ON communication.notification_channels USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: notification_logs tenant_isolation_notification_logs; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notification_logs ON communication.notification_logs USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notification_templates tenant_isolation_notification_templates; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notification_templates ON communication.notification_templates USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: notifications tenant_isolation_notifications; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notifications ON communication.notifications USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notifications_y2024m12 tenant_isolation_notifications_y2024m12; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notifications_y2024m12 ON communication.notifications_y2024m12 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notifications_y2025m01 tenant_isolation_notifications_y2025m01; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notifications_y2025m01 ON communication.notifications_y2025m01 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notifications_y2025m02 tenant_isolation_notifications_y2025m02; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notifications_y2025m02 ON communication.notifications_y2025m02 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: notifications_y2025m03 tenant_isolation_notifications_y2025m03; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_notifications_y2025m03 ON communication.notifications_y2025m03 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: user_notification_preferences tenant_isolation_user_notification_preferences; Type: POLICY; Schema: communication; Owner: -
--

CREATE POLICY tenant_isolation_user_notification_preferences ON communication.user_notification_preferences USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: user_notification_preferences; Type: ROW SECURITY; Schema: communication; Owner: -
--

ALTER TABLE communication.user_notification_preferences ENABLE ROW LEVEL SECURITY;

--
-- Name: api_clients; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.api_clients ENABLE ROW LEVEL SECURITY;

--
-- Name: api_keys; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.api_keys ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs_y2024m12; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs_y2024m12 ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs_y2025m01; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs_y2025m01 ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs_y2025m02; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs_y2025m02 ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_logs_y2025m03; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.audit_logs_y2025m03 ENABLE ROW LEVEL SECURITY;

--
-- Name: consent_logs; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.consent_logs ENABLE ROW LEVEL SECURITY;

--
-- Name: data_deletion_requests; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.data_deletion_requests ENABLE ROW LEVEL SECURITY;

--
-- Name: external_organizations; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.external_organizations ENABLE ROW LEVEL SECURITY;

--
-- Name: external_practitioners; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.external_practitioners ENABLE ROW LEVEL SECURITY;

--
-- Name: external_service_agreements; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.external_service_agreements ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_members org_isolation_org_members; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY org_isolation_org_members ON core.organization_members USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: organization_tenant_memberships org_isolation_org_tenant; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY org_isolation_org_tenant ON core.organization_tenant_memberships USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: organizations org_isolation_organizations; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY org_isolation_organizations ON core.organizations USING ((id = public.current_org_id())) WITH CHECK ((id = public.current_org_id()));


--
-- Name: organization_members; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.organization_members ENABLE ROW LEVEL SECURITY;

--
-- Name: organization_tenant_memberships; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.organization_tenant_memberships ENABLE ROW LEVEL SECURITY;

--
-- Name: organizations; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.organizations ENABLE ROW LEVEL SECURITY;

--
-- Name: otp_verifications; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.otp_verifications ENABLE ROW LEVEL SECURITY;

--
-- Name: password_policies; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.password_policies ENABLE ROW LEVEL SECURITY;

--
-- Name: retention_policies; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.retention_policies ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.roles ENABLE ROW LEVEL SECURITY;

--
-- Name: system_configurations; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.system_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: api_clients tenant_isolation_api_clients; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_api_clients ON core.api_clients USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: api_keys tenant_isolation_api_keys; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_api_keys ON core.api_keys USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: audit_logs tenant_isolation_audit; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_audit ON core.audit_logs USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: audit_logs_y2024m12 tenant_isolation_audit_logs_y2024m12; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_audit_logs_y2024m12 ON core.audit_logs_y2024m12 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: audit_logs_y2025m01 tenant_isolation_audit_logs_y2025m01; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_audit_logs_y2025m01 ON core.audit_logs_y2025m01 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: audit_logs_y2025m02 tenant_isolation_audit_logs_y2025m02; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_audit_logs_y2025m02 ON core.audit_logs_y2025m02 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: audit_logs_y2025m03 tenant_isolation_audit_logs_y2025m03; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_audit_logs_y2025m03 ON core.audit_logs_y2025m03 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: consent_logs tenant_isolation_consent; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_consent ON core.consent_logs USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: data_deletion_requests tenant_isolation_data_deletion_requests; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_data_deletion_requests ON core.data_deletion_requests USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: external_organizations tenant_isolation_external_organizations; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_external_organizations ON core.external_organizations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: external_practitioners tenant_isolation_external_practitioners; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_external_practitioners ON core.external_practitioners USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: external_service_agreements tenant_isolation_external_service_agreements; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_external_service_agreements ON core.external_service_agreements USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: otp_verifications tenant_isolation_otp_verifications; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_otp_verifications ON core.otp_verifications USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: password_policies tenant_isolation_password_policies; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_password_policies ON core.password_policies USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: retention_policies tenant_isolation_retention_policies; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_retention_policies ON core.retention_policies USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: roles tenant_isolation_roles; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_roles ON core.roles USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: system_configurations tenant_isolation_system_configurations; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_system_configurations ON core.system_configurations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_subscriptions tenant_isolation_tenant_subscriptions; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_tenant_subscriptions ON core.tenant_subscriptions USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: usage_metrics tenant_isolation_usage_metrics; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_usage_metrics ON core.usage_metrics USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: user_roles tenant_isolation_user_roles; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_user_roles ON core.user_roles USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: user_sessions tenant_isolation_user_sessions; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_user_sessions ON core.user_sessions USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: users tenant_isolation_users; Type: POLICY; Schema: core; Owner: -
--

CREATE POLICY tenant_isolation_users ON core.users USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: tenant_subscriptions; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.tenant_subscriptions ENABLE ROW LEVEL SECURITY;

--
-- Name: usage_metrics; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.usage_metrics ENABLE ROW LEVEL SECURITY;

--
-- Name: user_roles; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.user_roles ENABLE ROW LEVEL SECURITY;

--
-- Name: user_sessions; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.user_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: core; Owner: -
--

ALTER TABLE core.users ENABLE ROW LEVEL SECURITY;

--
-- Name: document_access_log; Type: ROW SECURITY; Schema: documents; Owner: -
--

ALTER TABLE documents.document_access_log ENABLE ROW LEVEL SECURITY;

--
-- Name: document_types; Type: ROW SECURITY; Schema: documents; Owner: -
--

ALTER TABLE documents.document_types ENABLE ROW LEVEL SECURITY;

--
-- Name: document_versions; Type: ROW SECURITY; Schema: documents; Owner: -
--

ALTER TABLE documents.document_versions ENABLE ROW LEVEL SECURITY;

--
-- Name: documents; Type: ROW SECURITY; Schema: documents; Owner: -
--

ALTER TABLE documents.documents ENABLE ROW LEVEL SECURITY;

--
-- Name: document_access_log tenant_isolation_document_access_log; Type: POLICY; Schema: documents; Owner: -
--

CREATE POLICY tenant_isolation_document_access_log ON documents.document_access_log USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: document_types tenant_isolation_document_types; Type: POLICY; Schema: documents; Owner: -
--

CREATE POLICY tenant_isolation_document_types ON documents.document_types USING (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL))) WITH CHECK (((tenant_id = public.current_tenant_id()) OR (tenant_id IS NULL)));


--
-- Name: document_versions tenant_isolation_document_versions; Type: POLICY; Schema: documents; Owner: -
--

CREATE POLICY tenant_isolation_document_versions ON documents.document_versions USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR (NOT clinical.is_resource_sensitive(tenant_id, 'documents.document_versions'::text, id))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR (NOT clinical.is_resource_sensitive(tenant_id, 'documents.document_versions'::text, id)))));


--
-- Name: documents tenant_isolation_documents; Type: POLICY; Schema: documents; Owner: -
--

CREATE POLICY tenant_isolation_documents ON documents.documents USING (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'documents.documents'::text, id)))))) WITH CHECK (((tenant_id = public.current_tenant_id()) AND (clinical.can_access_sensitive(tenant_id) OR ((NOT clinical.is_patient_sensitive(tenant_id, patient_id)) AND (NOT clinical.is_resource_sensitive(tenant_id, 'documents.documents'::text, id))))));


--
-- Name: imaging_orders; Type: ROW SECURITY; Schema: imaging; Owner: -
--

ALTER TABLE imaging.imaging_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: imaging_studies; Type: ROW SECURITY; Schema: imaging; Owner: -
--

ALTER TABLE imaging.imaging_studies ENABLE ROW LEVEL SECURITY;

--
-- Name: imaging_orders tenant_isolation_imaging_orders; Type: POLICY; Schema: imaging; Owner: -
--

CREATE POLICY tenant_isolation_imaging_orders ON imaging.imaging_orders USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: imaging_studies tenant_isolation_imaging_studies; Type: POLICY; Schema: imaging; Owner: -
--

CREATE POLICY tenant_isolation_imaging_studies ON imaging.imaging_studies USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hl7_message_log; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log ENABLE ROW LEVEL SECURITY;

--
-- Name: hl7_message_log_y2024m12; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log_y2024m12 ENABLE ROW LEVEL SECURITY;

--
-- Name: hl7_message_log_y2025m01; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log_y2025m01 ENABLE ROW LEVEL SECURITY;

--
-- Name: hl7_message_log_y2025m02; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log_y2025m02 ENABLE ROW LEVEL SECURITY;

--
-- Name: hl7_message_log_y2025m03; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.hl7_message_log_y2025m03 ENABLE ROW LEVEL SECURITY;

--
-- Name: integration_credentials; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.integration_credentials ENABLE ROW LEVEL SECURITY;

--
-- Name: integration_endpoints; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.integration_endpoints ENABLE ROW LEVEL SECURITY;

--
-- Name: hl7_message_log tenant_isolation_hl7_message_log; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_hl7_message_log ON integration.hl7_message_log USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hl7_message_log_y2024m12 tenant_isolation_hl7_message_log_y2024m12; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_hl7_message_log_y2024m12 ON integration.hl7_message_log_y2024m12 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hl7_message_log_y2025m01 tenant_isolation_hl7_message_log_y2025m01; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_hl7_message_log_y2025m01 ON integration.hl7_message_log_y2025m01 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hl7_message_log_y2025m02 tenant_isolation_hl7_message_log_y2025m02; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_hl7_message_log_y2025m02 ON integration.hl7_message_log_y2025m02 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: hl7_message_log_y2025m03 tenant_isolation_hl7_message_log_y2025m03; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_hl7_message_log_y2025m03 ON integration.hl7_message_log_y2025m03 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: integration_credentials tenant_isolation_integration_credentials; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_integration_credentials ON integration.integration_credentials USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: integration_endpoints tenant_isolation_integration_endpoints; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_integration_endpoints ON integration.integration_endpoints USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: webhook_deliveries tenant_isolation_webhook_deliveries; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_webhook_deliveries ON integration.webhook_deliveries USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: webhook_subscriptions tenant_isolation_webhook_subscriptions; Type: POLICY; Schema: integration; Owner: -
--

CREATE POLICY tenant_isolation_webhook_subscriptions ON integration.webhook_subscriptions USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: webhook_deliveries; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.webhook_deliveries ENABLE ROW LEVEL SECURITY;

--
-- Name: webhook_subscriptions; Type: ROW SECURITY; Schema: integration; Owner: -
--

ALTER TABLE integration.webhook_subscriptions ENABLE ROW LEVEL SECURITY;

--
-- Name: batches; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.batches ENABLE ROW LEVEL SECURITY;

--
-- Name: current_stock; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.current_stock ENABLE ROW LEVEL SECURITY;

--
-- Name: item_categories; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.item_categories ENABLE ROW LEVEL SECURITY;

--
-- Name: items; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.items ENABLE ROW LEVEL SECURITY;

--
-- Name: purchase_order_items; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.purchase_order_items ENABLE ROW LEVEL SECURITY;

--
-- Name: purchase_orders; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.purchase_orders ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_ledgers; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_ledgers_y2024m12; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers_y2024m12 ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_ledgers_y2025m01; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers_y2025m01 ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_ledgers_y2025m02; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers_y2025m02 ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_ledgers_y2025m03; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_ledgers_y2025m03 ENABLE ROW LEVEL SECURITY;

--
-- Name: stock_locations; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.stock_locations ENABLE ROW LEVEL SECURITY;

--
-- Name: suppliers; Type: ROW SECURITY; Schema: inventory; Owner: -
--

ALTER TABLE inventory.suppliers ENABLE ROW LEVEL SECURITY;

--
-- Name: batches tenant_isolation_batches; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_batches ON inventory.batches USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: current_stock tenant_isolation_current_stock; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_current_stock ON inventory.current_stock USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: item_categories tenant_isolation_item_categories; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_item_categories ON inventory.item_categories USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: items tenant_isolation_items; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_items ON inventory.items USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: purchase_order_items tenant_isolation_purchase_order_items; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_purchase_order_items ON inventory.purchase_order_items USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: purchase_orders tenant_isolation_purchase_orders; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_purchase_orders ON inventory.purchase_orders USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_ledgers tenant_isolation_stock_ledgers; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_ledgers ON inventory.stock_ledgers USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_ledgers_y2024m12 tenant_isolation_stock_ledgers_y2024m12; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_ledgers_y2024m12 ON inventory.stock_ledgers_y2024m12 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_ledgers_y2025m01 tenant_isolation_stock_ledgers_y2025m01; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_ledgers_y2025m01 ON inventory.stock_ledgers_y2025m01 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_ledgers_y2025m02 tenant_isolation_stock_ledgers_y2025m02; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_ledgers_y2025m02 ON inventory.stock_ledgers_y2025m02 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_ledgers_y2025m03 tenant_isolation_stock_ledgers_y2025m03; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_ledgers_y2025m03 ON inventory.stock_ledgers_y2025m03 USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: stock_locations tenant_isolation_stock_locations; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_stock_locations ON inventory.stock_locations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: suppliers tenant_isolation_suppliers; Type: POLICY; Schema: inventory; Owner: -
--

CREATE POLICY tenant_isolation_suppliers ON inventory.suppliers USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: alert_configurations; Type: ROW SECURITY; Schema: laboratory; Owner: -
--

ALTER TABLE laboratory.alert_configurations ENABLE ROW LEVEL SECURITY;

--
-- Name: quality_controls; Type: ROW SECURITY; Schema: laboratory; Owner: -
--

ALTER TABLE laboratory.quality_controls ENABLE ROW LEVEL SECURITY;

--
-- Name: samples; Type: ROW SECURITY; Schema: laboratory; Owner: -
--

ALTER TABLE laboratory.samples ENABLE ROW LEVEL SECURITY;

--
-- Name: alert_configurations tenant_isolation_alert_configurations; Type: POLICY; Schema: laboratory; Owner: -
--

CREATE POLICY tenant_isolation_alert_configurations ON laboratory.alert_configurations USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: quality_controls tenant_isolation_quality_controls; Type: POLICY; Schema: laboratory; Owner: -
--

CREATE POLICY tenant_isolation_quality_controls ON laboratory.quality_controls USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: samples tenant_isolation_samples; Type: POLICY; Schema: laboratory; Owner: -
--

CREATE POLICY tenant_isolation_samples ON laboratory.samples USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: appointment_history; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.appointment_history ENABLE ROW LEVEL SECURITY;

--
-- Name: appointments; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.appointments ENABLE ROW LEVEL SECURITY;

--
-- Name: block_schedules; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.block_schedules ENABLE ROW LEVEL SECURITY;

--
-- Name: queue_tokens; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.queue_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: queues; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.queues ENABLE ROW LEVEL SECURITY;

--
-- Name: schedules; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.schedules ENABLE ROW LEVEL SECURITY;

--
-- Name: slots; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.slots ENABLE ROW LEVEL SECURITY;

--
-- Name: appointment_history tenant_isolation_appointment_history; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_appointment_history ON scheduling.appointment_history USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: appointments tenant_isolation_appointments; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_appointments ON scheduling.appointments USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: block_schedules tenant_isolation_block_schedules; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_block_schedules ON scheduling.block_schedules USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: queue_tokens tenant_isolation_queue_tokens; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_queue_tokens ON scheduling.queue_tokens USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: queues tenant_isolation_queues; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_queues ON scheduling.queues USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: schedules tenant_isolation_schedules; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_schedules ON scheduling.schedules USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: slots tenant_isolation_slots; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_slots ON scheduling.slots USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: waitlist tenant_isolation_waitlist; Type: POLICY; Schema: scheduling; Owner: -
--

CREATE POLICY tenant_isolation_waitlist ON scheduling.waitlist USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: waitlist; Type: ROW SECURITY; Schema: scheduling; Owner: -
--

ALTER TABLE scheduling.waitlist ENABLE ROW LEVEL SECURITY;

--
-- Name: code_systems; Type: ROW SECURITY; Schema: terminology; Owner: -
--

ALTER TABLE terminology.code_systems ENABLE ROW LEVEL SECURITY;

--
-- Name: concept_maps; Type: ROW SECURITY; Schema: terminology; Owner: -
--

ALTER TABLE terminology.concept_maps ENABLE ROW LEVEL SECURITY;

--
-- Name: concepts; Type: ROW SECURITY; Schema: terminology; Owner: -
--

ALTER TABLE terminology.concepts ENABLE ROW LEVEL SECURITY;

--
-- Name: code_systems tenant_isolation_code_systems; Type: POLICY; Schema: terminology; Owner: -
--

CREATE POLICY tenant_isolation_code_systems ON terminology.code_systems USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: concept_maps tenant_isolation_concept_maps; Type: POLICY; Schema: terminology; Owner: -
--

CREATE POLICY tenant_isolation_concept_maps ON terminology.concept_maps USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: concepts tenant_isolation_concepts; Type: POLICY; Schema: terminology; Owner: -
--

CREATE POLICY tenant_isolation_concepts ON terminology.concepts USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: dim_patients; Type: ROW SECURITY; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.dim_patients ENABLE ROW LEVEL SECURITY;

--
-- Name: dim_tenants; Type: ROW SECURITY; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.dim_tenants ENABLE ROW LEVEL SECURITY;

--
-- Name: fact_encounters; Type: ROW SECURITY; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_encounters ENABLE ROW LEVEL SECURITY;

--
-- Name: fact_invoices; Type: ROW SECURITY; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: fact_stock_movements; Type: ROW SECURITY; Schema: warehouse; Owner: -
--

ALTER TABLE warehouse.fact_stock_movements ENABLE ROW LEVEL SECURITY;

--
-- Name: dim_patients wh_ingest_all_dim_patients; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_ingest_all_dim_patients ON warehouse.dim_patients TO warehouse_ingest USING (true) WITH CHECK (true);


--
-- Name: dim_tenants wh_ingest_all_dim_tenants; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_ingest_all_dim_tenants ON warehouse.dim_tenants TO warehouse_ingest USING (true) WITH CHECK (true);


--
-- Name: fact_encounters wh_ingest_all_fact_encounters; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_ingest_all_fact_encounters ON warehouse.fact_encounters TO warehouse_ingest USING (true) WITH CHECK (true);


--
-- Name: fact_invoices wh_ingest_all_fact_invoices; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_ingest_all_fact_invoices ON warehouse.fact_invoices TO warehouse_ingest USING (true) WITH CHECK (true);


--
-- Name: fact_stock_movements wh_ingest_all_fact_stock_movements; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_ingest_all_fact_stock_movements ON warehouse.fact_stock_movements TO warehouse_ingest USING (true) WITH CHECK (true);


--
-- Name: dim_patients wh_org_scope_dim_patients; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_org_scope_dim_patients ON warehouse.dim_patients USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: dim_tenants wh_org_scope_dim_tenants; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_org_scope_dim_tenants ON warehouse.dim_tenants USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: fact_encounters wh_org_scope_fact_encounters; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_org_scope_fact_encounters ON warehouse.fact_encounters USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: fact_invoices wh_org_scope_fact_invoices; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_org_scope_fact_invoices ON warehouse.fact_invoices USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


--
-- Name: fact_stock_movements wh_org_scope_fact_stock_movements; Type: POLICY; Schema: warehouse; Owner: -
--

CREATE POLICY wh_org_scope_fact_stock_movements ON warehouse.fact_stock_movements USING ((org_id = public.current_org_id())) WITH CHECK ((org_id = public.current_org_id()));


-- ============================================================================
-- END OF COMPLETE HIMS PLATFORM SCHEMA
-- ============================================================================
-- 
-- This migration creates the complete production-ready HIMS Platform schema.
-- For future changes, use incremental migrations (V002, V003, etc.).
-- ============================================================================
