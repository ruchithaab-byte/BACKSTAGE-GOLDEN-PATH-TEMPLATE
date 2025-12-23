# API Testing Guide

## Prerequisites

1. Start the backend service:
   ```bash
   cd backend-monolith
   mvn spring-boot:run
   ```

2. Ensure database is running and migrations are applied:
   ```bash
   docker-compose up -d postgres
   mvn flyway:migrate
   ```

3. Get a JWT token (for authenticated endpoints):
   - Use the login endpoint to get a token
   - Or use a mock token for development

---

## Authentication API

### 1. Health Check

```bash
curl -X GET http://localhost:8080/api/v1/auth/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "auth"
}
```

---

### 2. Login (Mock)

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected Response:**
```json
{
  "token": "mock-jwt-token",
  "message": "Login successful (mock implementation)",
  "note": "Replace with actual Scalekit integration"
}
```

**For Real Login (Future):**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

---

### 3. Get Current User Profile

```bash
# Replace TOKEN with actual JWT token from login
TOKEN="mock-jwt-token"

curl -X GET http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Expected Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "tenantId": "550e8400-e29b-41d4-a716-446655440001",
  "email": "doctor@hospital.com",
  "name": "Dr. John Doe",
  "lastLoginAt": "2025-01-21T10:30:00Z"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "UNAUTHORIZED",
  "message": "Invalid or expired token",
  "timestamp": "2025-01-21T10:30:00Z"
}
```

---

### 4. Validate Token

```bash
TOKEN="mock-jwt-token"

curl -X POST http://localhost:8080/api/v1/auth/validate \
  -H "Content-Type: application/json" \
  -d "{
    \"token\": \"$TOKEN\"
  }"
```

**Expected Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "tenantId": "550e8400-e29b-41d4-a716-446655440001",
  "email": "doctor@hospital.com",
  "name": "Dr. John Doe"
}
```

---

## Clinical API (Patients)

### 1. Health Check

```bash
curl -X GET http://localhost:8080/api/v1/patients/health
```

**Expected Response:**
```
patient service is healthy
```

---

### 2. Register New Patient

```bash
TOKEN="mock-jwt-token"
TENANT_ID="550e8400-e29b-41d4-a716-446655440001"

curl -X POST http://localhost:8080/api/v1/patients \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "mrn": "MRN-2025-001",
    "name": {
      "use": "official",
      "family": "Doe",
      "given": ["John"]
    },
    "gender": "male",
    "birthDate": "1980-01-15",
    "telecom": [
      {
        "system": "phone",
        "value": "+91-9876543210",
        "use": "mobile"
      }
    ],
    "address": [
      {
        "use": "home",
        "line": ["123 Main Street"],
        "city": "Mumbai",
        "state": "Maharashtra",
        "postalCode": "400001",
        "country": "IND"
      }
    ]
  }'
```

**Expected Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "tenantId": "550e8400-e29b-41d4-a716-446655440001",
  "mrn": "MRN-2025-001",
  "name": {
    "use": "official",
    "family": "Doe",
    "given": ["John"]
  },
  "gender": "male",
  "birthDate": "1980-01-15",
  "isActive": true,
  "createdAt": "2025-01-21T10:30:00Z",
  "updatedAt": "2025-01-21T10:30:00Z"
}
```

**Error Response (409 Conflict - MRN exists):**
```json
{
  "error": "CONFLICT",
  "message": "Patient with MRN MRN-2025-001 already exists",
  "timestamp": "2025-01-21T10:30:00Z"
}
```

---

### 3. Register Patient with ABHA

```bash
TOKEN="mock-jwt-token"
TENANT_ID="550e8400-e29b-41d4-a716-446655440001"

curl -X POST http://localhost:8080/api/v1/patients \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "mrn": "MRN-2025-002",
    "name": {
      "use": "official",
      "family": "Smith",
      "given": ["Jane"]
    },
    "gender": "female",
    "birthDate": "1990-05-20",
    "abhaNumber": "123456789012",
    "abhaAddress": "jane.smith@abdm",
    "telecom": [
      {
        "system": "phone",
        "value": "+91-9876543211",
        "use": "mobile"
      }
    ]
  }'
```

---

### 4. Get Patient by ID

```bash
TOKEN="mock-jwt-token"
TENANT_ID="550e8400-e29b-41d4-a716-446655440001"
PATIENT_ID="550e8400-e29b-41d4-a716-446655440000"

curl -X GET http://localhost:8080/api/v1/patients/$PATIENT_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json"
```

**Expected Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "tenantId": "550e8400-e29b-41d4-a716-446655440001",
  "mrn": "MRN-2025-001",
  "name": {
    "use": "official",
    "family": "Doe",
    "given": ["John"]
  },
  "gender": "male",
  "birthDate": "1980-01-15",
  "isActive": true,
  "createdAt": "2025-01-21T10:30:00Z",
  "updatedAt": "2025-01-21T10:30:00Z"
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "NOT_FOUND",
  "message": "Patient not found",
  "timestamp": "2025-01-21T10:30:00Z"
}
```

---

### 5. Search Patients by Name

```bash
TOKEN="mock-jwt-token"
TENANT_ID="550e8400-e29b-41d4-a716-446655440001"

curl -X GET "http://localhost:8080/api/v1/patients/search?name=John" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json"
```

**Expected Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "mrn": "MRN-2025-001",
    "name": {
      "family": "Doe",
      "given": ["John"]
    },
    "gender": "male",
    "birthDate": "1980-01-15",
    "isActive": true
  }
]
```

---

## End-to-End Steel Thread Test

### Complete Flow Test

```bash
# 1. Login (Get Token)
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{}' | jq -r '.token')

echo "Token: $TOKEN"

# 2. Get Tenant ID from token (or set manually)
TENANT_ID="550e8400-e29b-41d4-a716-446655440001"

# 3. Create Patient
PATIENT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/patients \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "mrn": "MRN-STEEL-001",
    "name": {
      "use": "official",
      "family": "Test",
      "given": ["Steel", "Thread"]
    },
    "gender": "male",
    "birthDate": "1990-01-01",
    "telecom": [
      {
        "system": "phone",
        "value": "+91-9999999999",
        "use": "mobile"
      }
    ]
  }')

PATIENT_ID=$(echo $PATIENT_RESPONSE | jq -r '.id')
echo "Created Patient ID: $PATIENT_ID"

# 4. Verify Patient in Postgres (with correct Tenant ID)
# Connect to Postgres and verify:
# SELECT id, tenant_id, mrn FROM clinical.patients WHERE id = '$PATIENT_ID';

# 5. Search Patient
curl -X GET "http://localhost:8080/api/v1/patients/search?name=Steel" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -H "Content-Type: application/json"

# 6. Verify Audit Log entry
# Check Kafka topic: audit.events
# Or check audit log table in database
```

---

## Swagger UI

Access interactive API documentation at:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **OpenAPI JSON**: http://localhost:8080/v3/api-docs

---

## Troubleshooting

### 401 Unauthorized
- Ensure JWT token is valid
- Check token is in Authorization header: `Bearer <token>`
- Verify token hasn't expired

### 403 Forbidden
- Check tenant context is set
- Verify RLS policies are working
- Ensure user has proper permissions

### 404 Not Found
- Verify patient ID exists
- Check tenant isolation (patient belongs to your tenant)
- Verify database migrations are applied

### 500 Internal Server Error
- Check application logs
- Verify database connection
- Ensure all required services are running

---

## Notes

- All authenticated endpoints require `Authorization: Bearer <token>` header
- Tenant context is set via `X-Tenant-ID` header or JWT token
- RLS policies automatically filter results by tenant
- All operations are audited and published to Kafka

