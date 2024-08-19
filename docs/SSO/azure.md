# Azure SSO Setup

Here are the steps to setup SSO with the platform

1. Create an application in the azure panel. 
2. Navigate to Enterprise Applications
3. Find manage, then single sign-on
4. Select SAML
5. Enter in the `Entity ID` and the `Reply URL` from the sso1 step in the infrastructure
6. By using "add a claim" option under attributes, add in the `displayname` attribute
7. By using "add a group claim" option under attributes, Add in the group attribute and select "Groups assigned to the application" and "Cloud-only Group Display names"
8. Add in users and user groups to the users section
9. test to see if those users can login to the website