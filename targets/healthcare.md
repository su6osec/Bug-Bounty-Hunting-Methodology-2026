# Healthcare & MedTech — Target Guide

> HIPAA-regulated apps in the US and GDPR in EU mean any PHI (Protected Health Information) exposure is automatically Critical. The compliance angle elevates every finding.

---

## High-Value Attack Surface

**Patient data (PHI)** — Medical records, diagnoses, prescriptions, lab results

**Doctor/provider portals** — Different access tier from patient portals, often higher privilege

**Appointment scheduling** — Patient enumeration via booking flow

**Prescription management** — Drug ordering, refills, pharmacy integration

**Insurance/billing** — Claims data, member IDs, coverage information

**Medical device APIs** — IoT-connected devices (insulin pumps, monitors) — safety-critical

**FHIR/HL7 APIs** — Standardized health data exchange APIs, often under-tested

---

## Phase 1 — Recon Focus

```bash
# Healthcare subdomain patterns
api., fhir., hl7., portal., patient., provider., doctor.,
admin., emr., ehr., billing., pharmacy., telehealth.,
pacs., imaging., labs., results., appointments.

# FHIR API discovery (standard health data API)
/fhir/r4/, /fhir/stu3/, /api/fhir/
/fhir/r4/Patient
/fhir/r4/Observation
/fhir/r4/MedicationRequest

# HL7 endpoints
/hl7/, /api/hl7/

# Look for legacy systems (older hospitals)
/cgi-bin/, /asp/, classic ASP/PHP stack = more vulns

# Find patient portals
portal., myhealth., mychart., patientaccess.
```

---

## Phase 2 — High-Impact Tests

### IDOR on Patient Records
```bash
# Patient IDs are often sequential or predictable
GET /api/patients/12345/records   → try 12344, 12346
GET /api/appointments/APT-001     → try APT-002
GET /api/results/lab/RES-789      → try RES-788

# FHIR resource IDOR
GET /fhir/r4/Patient/1234         → try 1235
GET /fhir/r4/Observation?patient=1234  → change patient ID

# Insurance/member ID enumeration
GET /api/claims?member_id=M123456  → try M123455, M123457
```

### Cross-Role Access
```bash
# Healthcare apps often have:
# Patient, Nurse, Doctor, Admin, Billing, Pharmacist roles

# Test if patient can access doctor-level endpoints
GET /provider/api/all-patients    # with patient token
GET /admin/api/users              # with patient token

# Test if one doctor can access another's patients
# (should be restricted to care team only)
GET /api/patients?doctor_id=DR_002
Authorization: Bearer DR_001_TOKEN
```

### Appointment IDOR + Enumeration
```bash
# Appointments expose:
# - Patient names
# - Patient contact info
# - Diagnosis codes
# - Doctor names

# Test appointment booking for information disclosure
GET /api/appointments/public?date=2026-01-15&doctor_id=DR_001

# Check if appointment confirmation emails/SMS leak PHI
# Medical condition in subject line = HIPAA violation

# Test cancellation IDOR
POST /api/appointments/APT_VICTIM/cancel
Authorization: Bearer ATTACKER_TOKEN
```

### FHIR API Abuse
```bash
# FHIR APIs follow a standard — bulk access endpoints are common
# FHIR Bulk Export
GET /fhir/r4/$export

# All patients (should require admin)
GET /fhir/r4/Patient?_count=1000

# Search by partial name (patient enumeration)
GET /fhir/r4/Patient?name=Smith

# Observation (lab results) bulk access
GET /fhir/r4/Observation?patient=PATIENT_ID

# Medication request (prescriptions)
GET /fhir/r4/MedicationRequest?patient=PATIENT_ID

# Check: does the FHIR API enforce OAuth scopes?
# Smart on FHIR scope: patient/*.read, user/*.read
```

### Prescription / Medication Manipulation
```bash
# Can a patient view someone else's prescription?
GET /api/prescriptions/RX-12345   # not yours

# Can a patient modify medication dosage?
PUT /api/prescriptions/RX-12345
{"dosage": "10mg", "refills": 999}

# Pharmacy order IDOR
POST /api/pharmacy/refill
{"prescription_id": "RX-VICTIM"}
```

---

## Phase 3 — PHI Exfiltration Vectors

```bash
# Search functionality leaking PHI
# Search for patient by partial name/DOB
GET /api/search?q=John+D&dob=1990

# Export functionality
GET /api/export/records?patient_id=ALL   # bulk export
GET /api/reports/billing?date_range=all_time

# PDF/report generation SSRF
POST /api/generate-report
{"template": "patient_summary", "url": "http://169.254.169.254/"}

# Image/DICOM viewer SSRF
GET /api/imaging/fetch?url=http://169.254.169.254/

# Audit log access
# Can a patient read the audit log? (who accessed their records?)
# Can a provider read audit logs of other providers?
```

---

## Compliance-Driven Severity

Healthcare bugs get escalated severity because of regulatory consequences:

**Any PHI exposure (one patient record)** → Critical (HIPAA breach)

**Bulk PHI access (100+ patients)** → Critical + mandatory reporting

**Cross-patient data access** → Critical

**Authentication bypass on patient portal** → Critical

**Prescription manipulation** → Critical (patient safety risk)

**Medical device API unauthorized access** → Critical (patient safety)

**Appointment disclosure (name + condition)** → High (HIPAA)

**Username enumeration via appointment booking** → Medium–High

---

## Medical Device API Testing

```bash
# IoT medical devices (insulin pumps, monitors, pacemaker apps)
# are the highest-risk targets — patient safety implications

# Test authentication
# Hardcoded credentials in mobile companion app
# Unencrypted Bluetooth communication
# Unauthenticated API endpoints

# Look for:
# Cleartext transmission of vital signs
# Unauthorized command injection to device
# Device firmware download endpoints (reverse engineering)

# Report all findings to both the bug bounty program AND
# relevant health authority (FDA in US) if patient safety is at risk
```
