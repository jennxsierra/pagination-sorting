-- migrations/000003_seed_demo_data.down.sql
-- Remove seeded demo data.

-- Cancellations
DELETE FROM appt_cancellation
WHERE appointment_id IN (3002);

-- Appointments
DELETE FROM appointment
WHERE appointment_id IN (3001, 3002);

-- Provider specialties
DELETE FROM provider_specialty
WHERE (provider_id, specialty_id) IN ((1001, 1), (1004, 2));

-- Contacts
DELETE FROM person_contact
WHERE person_contact_id IN (2001, 2002, 2003, 2004, 2005);

-- Roles
DELETE FROM patient
WHERE patient_id IN (1003);

DELETE FROM staff
WHERE staff_id IN (1002);

DELETE FROM provider
WHERE provider_id IN (1001, 1004);

-- Persons
DELETE FROM person
WHERE person_id IN (1001, 1002, 1003, 1004);

-- Reference tables
DELETE FROM cancellation_reason
WHERE reason_id IN (1, 2);

DELETE FROM appt_type
WHERE appt_type_id IN (1, 2);

DELETE FROM specialty
WHERE specialty_id IN (1, 2);

DELETE FROM contact_type
WHERE contact_type_id IN (1, 2);