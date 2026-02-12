-- Create the database
CREATE DATABASE eschool;

-- Create a user and allow connections from any IP
CREATE USER 'Your_user'@'%' IDENTIFIED BY 'YourPassword';

-- Grant all privileges on the new database to the user
GRANT ALL PRIVILEGES ON eschool.* TO 'Your_user'@'%';

-- Apply changes
FLUSH PRIVILEGES;
EXIT;
