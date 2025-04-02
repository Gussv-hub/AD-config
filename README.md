# user-injector
Scripts used to populate an AD with some OU and users.

Before injecting users on our Windows Server we need to check some steps of the configuration.
We are going to do that with 3 differents scripts, execute them in that order :

Script 1 (1_setup_server) :
- Check the computer name and rename it.
- Check if the IP address is static or not.
- Restart computer.

Script 2 (2_install_adds) :
- Check if ADDS is already installed, if not then install it.
- Define a domain name.
- Promote the server as a Domain controller.
- Restart computer.

Script 3 (3_configure_ad) :
- Create OUs (users and administrators).
- import CSV file.
- Check for duplicated data.
- Create the accounts on specified OU.
- Apply account options (password, etc).