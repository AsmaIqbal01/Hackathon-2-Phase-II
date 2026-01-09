name: auth-skill
description: Implement secure authentication systems for web applications, including signup, signin, password hashing, JWT tokens, and robust auth integration.
---

# Auth Skill

## Purpose
This skill provides all functionality required to implement **secure user authentication**. It can be used by any agent that requires authentication features, ensuring consistency, security, and best practices.

---

## Core Responsibilities

1. **User Signup**
   - Accept new user data (email, password, etc.)  
   - Hash passwords securely before storing in the database  
   - Validate input for correctness and security  
   - Handle duplicate accounts gracefully  

2. **User Signin**
   - Validate user credentials securely  
   - Compare passwords using secure hash verification  
   - Generate JWT tokens upon successful login  
   - Implement proper error handling for failed logins  

3. **Password Management**
   - Use strong password hashing algorithms (e.g., bcrypt, Argon2)  
   - Provide mechanisms for password reset securely  
   - Ensure sensitive data is never logged or exposed  

4. **JWT Token Management**
   - Generate signed JWT tokens for authenticated sessions  
   - Validate and verify JWT tokens on protected routes  
   - Support token expiration and refresh mechanisms  

5. **Authentication Integration**
   - Protect API endpoints and routes with authentication middleware  
   - Enforce role-based access control (RBAC) if required  
   - Ensure seamless integration with database and backend logic  
   - Follow security best practices to prevent common vulnerabilities (e.g., token forgery, replay attacks)  

---

## Best Practices

- Always hash passwords before storing  
- Never return sensitive information in API responses  
- Use environment variables to store secret keys  
- Implement proper token expiration and revocation  
- Validate all inputs to prevent injection attacks  
- Keep authentication logic modular and reusable  

---

