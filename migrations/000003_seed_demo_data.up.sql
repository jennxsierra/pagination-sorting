-- migrations/000003_seed_demo_data.up.sql
-- Seed demo data for MAS.

-- ==============================
-- REFERENCE TABLES
-- ==============================

INSERT INTO contact_type (contact_type_id, contact_type_name) VALUES
  (1, 'email'),
  (2, 'phone')
ON CONFLICT (contact_type_id) DO NOTHING;

INSERT INTO specialty (specialty_id, specialty_name) VALUES
  (1, 'General Practice'),
  (2, 'Pediatrics')
ON CONFLICT (specialty_id) DO NOTHING;

INSERT INTO appt_type (appt_type_id, appt_type_name) VALUES
  (1, 'Consultation'),
  (2, 'Follow-up')
ON CONFLICT (appt_type_id) DO NOTHING;

INSERT INTO cancellation_reason (reason_id, reason_name) VALUES
  (1, 'Patient request'),
  (2, 'Provider unavailable')
ON CONFLICT (reason_id) DO NOTHING;

-- ==============================
-- PERSONS
-- ==============================

INSERT INTO person (person_id, first_name, last_name, date_of_birth, gender, created_at) VALUES
  (1001, 'Maya',  'Lopez',  '1999-04-12', 'female', NOW()),
  (1002, 'Aaron', 'Young',  '1986-09-03', 'male',   NOW()),
  (1003, 'Dina',  'Chan',   '2001-01-28', 'female', NOW()),
  (1004, 'Noah',  'Singh',  '1990-07-19', 'male',   NOW())
ON CONFLICT (person_id) DO NOTHING;

-- ==============================
-- ROLES
-- ==============================

INSERT INTO provider (provider_id, license_no) VALUES
  (1001, 'LIC-1001'),
  (1004, 'LIC-1004')
ON CONFLICT (provider_id) DO NOTHING;

INSERT INTO staff (staff_id, staff_no) VALUES
  (1002, 'STF-1002')
ON CONFLICT (staff_id) DO NOTHING;

INSERT INTO patient (patient_id, patient_no, ssn) VALUES
  (1003, 'PAT-1003', '999-10-1003')
ON CONFLICT (patient_id) DO NOTHING;

-- ==============================
-- CONTACTS
-- ==============================

INSERT INTO person_contact (person_contact_id, contact_value, is_primary, person_id, contact_type_id) VALUES
  (2001, 'maya.lopez@clinic.test',   TRUE,  1001, 1),
  (2002, '501-600-1001',             FALSE, 1001, 2),
  (2003, 'aaron.young@clinic.test',  TRUE,  1002, 1),
  (2004, '501-600-1003',             TRUE,  1003, 2),
  (2005, 'noah.singh@clinic.test',   TRUE,  1004, 1)
ON CONFLICT (person_contact_id) DO NOTHING;

-- ==============================
-- PROVIDER SPECIALTIES
-- ==============================

INSERT INTO provider_specialty (provider_id, specialty_id) VALUES
  (1001, 1),
  (1004, 2)
ON CONFLICT DO NOTHING;

-- ==============================
-- APPOINTMENTS
-- ==============================

-- Appointment 1 (active) with provider 1001
INSERT INTO appointment (
  appointment_id, start_time, end_time, created_at, updated_at, reason,
  patient_id, provider_id, created_by, appt_type_id
) VALUES (
  3001,
  TIMESTAMPTZ '2026-03-02 09:00:00-06',
  TIMESTAMPTZ '2026-03-02 09:30:00-06',
  NOW(),
  NULL,
  'Annual checkup',
  1003, 1001, 1002, 1
)
ON CONFLICT (appointment_id) DO NOTHING;

-- Appointment 2 (cancelled) with provider 1004
INSERT INTO appointment (
  appointment_id, start_time, end_time, created_at, updated_at, reason,
  patient_id, provider_id, created_by, appt_type_id
) VALUES (
  3002,
  TIMESTAMPTZ '2026-03-02 10:00:00-06',
  TIMESTAMPTZ '2026-03-02 10:15:00-06',
  NOW(),
  NULL,
  'Follow-up blood pressure',
  1003, 1004, 1002, 2
)
ON CONFLICT (appointment_id) DO NOTHING;

-- ==============================
-- CANCELLATION
-- ==============================

INSERT INTO appt_cancellation (
  appointment_id, cancelled_at, note, reason_id, recorded_by
) VALUES (
  3002,
  NOW(),
  'Provider became unavailable.',
  2,
  1002
)
ON CONFLICT (appointment_id) DO NOTHING;