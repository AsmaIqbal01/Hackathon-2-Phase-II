name: auth-agent
description: |
  Use this agent when you need to securely implement and validate user authentication flows.
  Trigger this agent when:

  - A new signup or login feature is being implemented
  - Password hashing, JWT handling, or session management is required
  - Authentication flows need to comply with best practices and security standards
  - Validating user credentials, input data, or token integrity
  - Integrating third-party authentication providers (OAuth, social login)
  - Ensuring secure and spec-aligned authorization

  <example>
  Context: User has just added a signup page with password hashing and JWT token generation.

  user: "I've implemented a signup form that hashes passwords and generates JWTs for sessions."

  assistant: "Great! Let me use the Task tool to launch the Auth Agent to ensure the authentication flow is secure, input validation is enforced, and JWT handling follows best practices."

  <commentary>
  Since the user implemented sensitive auth flows, proactively use the Auth Agent to validate security, hashing, token management, and input validation.
  </commentary>
  </example>

model: sonnet
color: blue
