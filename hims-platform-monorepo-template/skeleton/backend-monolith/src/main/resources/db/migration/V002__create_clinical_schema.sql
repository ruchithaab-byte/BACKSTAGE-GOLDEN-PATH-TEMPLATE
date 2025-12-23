-- =================================================================================
-- Clinical Module Schema Definition
-- Version: 1.0 (Production Grade: RLS, Indexes, Constraints)
-- Dependencies: Core schema (V001), public.current_tenant_id() function
-- =================================================================================

SET search_path TO public;

-- 1. Schema Setup
CREATE SCHEMA IF NOT EXISTS clinical;

-- 2. Create ENUM types (if not already exists from core schema)
DO $$ BEGIN
    CREATE TYPE public.fhir_gender AS ENUM ('male', 'female', 'other', 'unknown');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE public.data_sovereignty_region AS ENUM ('INDIA_LOCAL', 'INDIA_GOVT', 'EU_CENTRAL', 'US_HIPAA');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Create Patients Table
CREATE TABLE IF NOT EXISTS clinical.patients (
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
    CONSTRAINT chk_patients_not_merge_into_self CHECK (((merged_into_patient_id IS NULL) OR (merged_into_patient_id <> id))),
    CONSTRAINT pk_patients PRIMARY KEY (id),
    CONSTRAINT uq_patients_tenant_mrn UNIQUE (tenant_id, mrn)
);

-- 4. Enable RLS
ALTER TABLE clinical.patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical.patients FORCE ROW LEVEL SECURITY;

-- 5. Create RLS Policy
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'clinical' 
          AND tablename = 'patients' 
          AND policyname = 'tenant_isolation_patients'
    ) THEN
        CREATE POLICY tenant_isolation_patients ON clinical.patients
            FOR ALL
            USING (tenant_id = public.current_tenant_id())
            WITH CHECK (tenant_id = public.current_tenant_id());
    END IF;
END $$;

-- 6. Apply Tenant Context Trigger (uses core function)
DROP TRIGGER IF EXISTS trg_patients_context ON clinical.patients;
CREATE TRIGGER trg_patients_context 
    BEFORE INSERT OR UPDATE OR DELETE ON clinical.patients 
    FOR EACH ROW 
    EXECUTE FUNCTION core.trg_enforce_tenant_context();

-- 7. Create Indexes
CREATE INDEX IF NOT EXISTS idx_patients_tenant_mrn ON clinical.patients(tenant_id, mrn);
CREATE INDEX IF NOT EXISTS idx_patients_search_name ON clinical.patients(tenant_id, search_name);
CREATE INDEX IF NOT EXISTS idx_patients_search_phone ON clinical.patients(tenant_id, search_phone);
CREATE INDEX IF NOT EXISTS idx_patients_abha_number ON clinical.patients(tenant_id, abha_number) WHERE abha_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_patients_abha_address ON clinical.patients(tenant_id, abha_address) WHERE abha_address IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_patients_general_practitioner ON clinical.patients(tenant_id, general_practitioner_id) WHERE general_practitioner_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_patients_active ON clinical.patients(tenant_id, is_active) WHERE is_active = true;

-- 8. Comments
COMMENT ON TABLE clinical.patients IS 'Patient records in the clinical module. FHIR-aligned structure with ABHA integration.';
COMMENT ON COLUMN clinical.patients.search_name IS 'Generated column for efficient name searching (family + given[0])';
COMMENT ON COLUMN clinical.patients.search_phone IS 'Extracted phone number from telecom array for efficient searching';

