-- NOTE: this needs to be run as a user with CREATE ANY CONTEXT privilege.
-- Change "myschema" to be the name of the owner of the security_pkg package.
create context ctx using myschema.security_pkg accessed globally;
