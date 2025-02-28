 # Azure SSO Setup

Here are the steps to setup SSO with the platform

1. Create an application in the azure panel (App registrations --> New Registration)
2. Navigate to Enterprise Applications
3. Find manage, then single sign-on
4. Select SAML
5. Enter in the `Entity ID` and the `Reply URL` from the sso1 step from the infrastructure
6. You should see the following in the claims list (many of these should already be present):
   * Display Name - Used to determine display name for user
     * Claim Name: `http://schemas.microsoft.com/identity/claims/displayname/name`
     * Value: user.displayname
   * Groups - Used to determine permission groups
     * By using "add a group claim" option under attributes, Add in the group attribute and select "Groups assigned to 
     the application" and "Cloud-only Group Display names"
       * Claim Name: `http://schemas.microsoft.com/ws/2008/06/identity/claims/groups`
       * Value: user.groups [ApplicationGroup]
   * Mail - Used to get email address to allow for messaging (potentially), audit trails, etc.
     * Claim Name: `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress`
     * Value: user.mail
   * Given Name - Used for in-app display of the person's name (potential)
     * Claim Name: `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname`
     * Value: user.givenname 
   * User Principal Name - Used for a unique user reference
     * Claim Name: `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name`
     * Value: user.userprincipalname
   * Surname - Used in combination with Given Name
     * Claim Name: `http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname`
     * Value: user.surname
7. Copy the App Federation Metadata URL in the SAML certificates section and use this in the sso2 
infrastructure setup step (e.g. sso2_azure)
8. Add in users and user groups to the users section
9. test to see if those users can login to the website