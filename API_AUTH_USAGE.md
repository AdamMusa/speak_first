# API Authentication Endpoints Usage Guide

## Base URL

By default, the Phoenix server runs on:

- **Development**: `http://localhost:4000`
- **Production**: Configured via `PHX_HOST` environment variable

## Endpoints

### 1. Register a New User

**Endpoint:** `POST /api/auth/register`

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "yourpassword123"
}
```

**Success Response (201 Created):**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com"
  },
  "access_token": "encoded_access_token_here",
  "refresh_token": "encoded_refresh_token_here"
}
```

**Error Response (422 Unprocessable Entity):**

```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["can't be blank"]
  }
}
```

---

### 2. Login

**Endpoint:** `POST /api/auth/login`

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "yourpassword123"
}
```

**Success Response (200 OK):**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com"
  },
  "access_token": "encoded_access_token_here",
  "refresh_token": "encoded_refresh_token_here"
}
```

**Error Response (401 Unauthorized):**

```json
{
  "error": "Invalid email or password"
}
```

---

### 3. Refresh Access Token

**Endpoint:** `POST /api/auth/refresh`

**Request Body:**

```json
{
  "refresh_token": "encoded_refresh_token_here"
}
```

**Success Response (200 OK):**

```json
{
  "access_token": "new_encoded_access_token",
  "refresh_token": "new_encoded_refresh_token"
}
```

**Error Response (401 Unauthorized):**

```json
{
  "error": "Invalid or expired refresh token"
}
```

---

## Examples

### Using cURL

#### Register:

```bash
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "yourpassword123"
  }'
```

#### Login:

```bash
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "yourpassword123"
  }'
```

#### Refresh Token:

```bash
# Refresh an access token
curl -X POST http://localhost:4000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "your_refresh_token_here"
  }'
```

#### Using the Access Token:

```bash
# Store the access token from the response
ACCESS_TOKEN="your_access_token_here"

# Use it in subsequent requests
curl -X GET http://localhost:4000/api/some-protected-endpoint \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

---

### Using JavaScript (Fetch API)

```javascript
// Register
async function register(email, password) {
  const response = await fetch("http://localhost:4000/api/auth/register", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email: email,
      password: password,
    }),
  });

  if (response.ok) {
    const data = await response.json();
    console.log("User:", data.user);
    console.log("Access Token:", data.access_token);
    console.log("Refresh Token:", data.refresh_token);
    // Store tokens for future requests
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);
    return data;
  } else {
    const error = await response.json();
    console.error("Error:", error);
    throw error;
  }
}

// Login
async function login(email, password) {
  const response = await fetch("http://localhost:4000/api/auth/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email: email,
      password: password,
    }),
  });

  if (response.ok) {
    const data = await response.json();
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);
    return data;
  } else {
    const error = await response.json();
    console.error("Login failed:", error);
    throw error;
  }
}

// Refresh access token
async function refreshAccessToken(refreshToken) {
  const response = await fetch("http://localhost:4000/api/auth/refresh", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      refresh_token: refreshToken,
    }),
  });

  if (response.ok) {
    const data = await response.json();
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);
    return data;
  } else {
    const error = await response.json();
    console.error("Token refresh failed:", error);
    throw error;
  }
}

// Making authenticated requests with automatic token refresh
async function makeAuthenticatedRequest(url) {
  let accessToken = localStorage.getItem("access_token");

  // Try the request with current access token
  let response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  // If access token expired (401), try to refresh
  if (response.status === 401) {
    const refreshToken = localStorage.getItem("refresh_token");
    if (refreshToken) {
      try {
        const tokenData = await refreshAccessToken(refreshToken);
        accessToken = tokenData.access_token;

        // Retry the original request with new access token
        response = await fetch(url, {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });
      } catch (error) {
        // Refresh failed, redirect to login
        console.error("Failed to refresh token:", error);
        // Handle login redirect here
        throw error;
      }
    }
  }

  return response.json();
}

// Usage
register("user@example.com", "yourpassword123")
  .then((data) => console.log("Registered:", data))
  .catch((error) => console.error("Registration failed:", error));
```

---

### Using Python (requests library)

```python
import requests

BASE_URL = "http://localhost:4000"

# Register
def register(email, password):
    response = requests.post(
        f"{BASE_URL}/api/auth/register",
        json={
            "email": email,
            "password": password
        }
    )
    response.raise_for_status()
    data = response.json()
    print(f"User ID: {data['user']['id']}")
    print(f"Email: {data['user']['email']}")
    print(f"Access Token: {data['access_token']}")
    print(f"Refresh Token: {data['refresh_token']}")
    return data

# Refresh token
def refresh_token(refresh_token):
    response = requests.post(
        f"{BASE_URL}/api/auth/refresh",
        json={
            "refresh_token": refresh_token
        }
    )
    response.raise_for_status()
    data = response.json()
    print(f"New Access Token: {data['access_token']}")
    print(f"New Refresh Token: {data['refresh_token']}")
    return data

# Login
def login(email, password):
    response = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={
            "email": email,
            "password": password
        }
    )
    response.raise_for_status()
    data = response.json()
    return data

# Making authenticated requests with automatic token refresh
def make_authenticated_request(url, access_token, refresh_token=None):
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)

    # If access token expired, try to refresh
    if response.status_code == 401 and refresh_token:
        try:
            token_data = refresh_token(refresh_token)
            # Retry with new access token
            headers = {"Authorization": f"Bearer {token_data['access_token']}"}
            response = requests.get(url, headers=headers)
            return response.json(), token_data
        except Exception as e:
            print(f"Token refresh failed: {e}")
            raise

    response.raise_for_status()
    return response.json()

# Usage
try:
    # Register
    result = register("user@example.com", "yourpassword123")
    access_token = result["access_token"]
    refresh_token_value = result["refresh_token"]

    # Or login
    # result = login("user@example.com", "yourpassword123")
    # access_token = result["access_token"]
    # refresh_token_value = result["refresh_token"]

    # Use tokens for authenticated requests
    # data, new_tokens = make_authenticated_request(
    #     f"{BASE_URL}/api/protected",
    #     access_token,
    #     refresh_token_value
    # )

except requests.exceptions.HTTPError as e:
    error_data = e.response.json()
    print(f"Error: {error_data}")
```

---

### Using Postman

1. **Create a new request**
2. **Set method to POST**
3. **URL:** `http://localhost:4000/api/auth/register` or `/api/auth/login`
4. **Headers:**
   - `Content-Type: application/json`
5. **Body (select raw JSON):**
   ```json
   {
     "email": "user@example.com",
     "password": "yourpassword123"
   }
   ```
6. **Send the request**

---

### Using HTTPie

```bash
# Register
http POST localhost:4000/api/auth/register \
  email=user@example.com \
  password=yourpassword123

# Login
http POST localhost:4000/api/auth/login \
  email=user@example.com \
  password=yourpassword123

# Using token
http GET localhost:4000/api/some-endpoint \
  "Authorization:Bearer your_token_here"
```

---

## Password Requirements

- **Minimum length:** 12 characters
- **Maximum length:** 72 characters
- **Note:** The password is automatically hashed using Bcrypt before storage

## Token Usage

### Access Tokens

- **Purpose**: Used to authenticate API requests
- **Validity**: 15 minutes
- **Storage**: Store securely (e.g., in memory or localStorage for web apps)
- **Usage**: Include in requests using the `Authorization` header:
  ```
  Authorization: Bearer <access_token>
  ```

### Refresh Tokens

- **Purpose**: Used to obtain new access tokens when they expire
- **Validity**: 14 days
- **Storage**: Store securely (e.g., in secure httpOnly cookies or secure storage)
- **Usage**: Send to `/api/auth/refresh` endpoint to get new tokens
- **Security**: Refresh tokens are one-time use - a new refresh token is issued each time you refresh

### Token Refresh Flow

1. When your access token expires (after 15 minutes), you'll receive a 401 Unauthorized response
2. Use your refresh token to get a new access token and refresh token via `POST /api/auth/refresh`
3. Update your stored tokens with the new values
4. Retry the original request with the new access token

## Error Handling

### Common Status Codes:

- **200 OK** - Login successful
- **201 Created** - Registration successful
- **400 Bad Request** - Missing required fields (email or password)
- **401 Unauthorized** - Invalid email or password
- **422 Unprocessable Entity** - Validation errors (duplicate email, invalid format, etc.)

### Example Error Response:

```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["can't be blank", "should be at least 12 character(s)"]
  }
}
```

---

## Testing the Endpoints

Start your Phoenix server:

```bash
mix phx.server
```

Then test with curl:

```bash
# Test registration
curl -X POST http://localhost:4000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpassword123"}'

# Test login
curl -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpassword123"}'

# Test refresh token (replace with actual refresh_token from login response)
curl -X POST http://localhost:4000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"your_refresh_token_here"}'
```
