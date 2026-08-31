CREATE TABLE public.appointment_analysis
(
    visit_id INT,
    patient_id INT,
    department_name VARCHAR(100),
    patient_name VARCHAR(100),
    appointment_date DATE,
    arrival_time TIME,
    appointment_time TIME,
    admission_time TIME
);

CREATE TABLE public.hospital_records
(
    patient_id INT,
    patient_name VARCHAR(100),
    bmi INT,
    family_history_of_hypertension TEXT,
    department_name VARCHAR(100),
    Days_in_the_hospital INT
);

CREATE TABLE public.lab_results
(
    result_id INT,
    visit_id INT,
    test_name VARCHAR(100),
    test_date DATE,
    result_value NUMERIC
);

CREATE TABLE public.outpatient_visits
(
    visit_id INT,
    patient_id INT,
    visit_date DATE,
    doctor_name VARCHAR(100),
    reason_for_visit VARCHAR(100),
    diagnosis VARCHAR(100),
    medication_prescribed VARCHAR(100),
    smoker_status TEXT
);

CREATE TABLE public.patients_table
(
    patient_id INT,
    patient_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(100),
    address VARCHAR(255)
);

ALTER TABLE public.hospital_records OWNER to postgres;
ALTER TABLE public.appointment_analysis OWNER to postgres;
ALTER TABLE public.lab_results OWNER to postgres;
ALTER TABLE public.outpatient_visits OWNER to postgres;
ALTER TABLE public.patients_table OWNER to postgres;
