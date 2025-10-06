# o11y-terraform-ansible-testing

Requires ansible-galaxy to install otel agent using the collection https://docs.splunk.com/Observability/gdi/opentelemetry/deployments/deployments-linux-ansible.html

Install by running the following on the machine running Terraform and Ansible:

    ansible-galaxy collection install signalfx.splunk_otel_collector

Update the collection by running the following:

    ansible-galaxy collection install -U signalfx.splunk_otel_collector

Also requires ansible.posix collection

    ansible-galaxy collection install ansible.posix

Ansible macOS Fork Errors:

    Fix for current session
    export "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES"

    Fix all future sessions
    echo "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES" >> .bash_profile
<!-- 
Connecting to windows instances using Ansible on macOS requires pyminrm
    pip install "pywinrm>=0.3.0" -->

Ansible Test Commands (ran from the parent directory) to enable Ansible roles to be ran in isolation post TF Deploy
    ansible-playbook -i modules/instances/otel_agent_hosts modules/instances/ansible_role_otel_agent.yaml --extra-vars 'galaxy_otel=yes'
    ansible-playbook -i modules/instances/otel_agent_hosts modules/instances/ansible_role_otel_agent.yaml --extra-vars 'galaxy_otel=no'
    ansible-playbook -i modules/instances/use_gateway_hosts modules/instances/ansible_role_use_gateway.yaml
    ansible-playbook -i modules/instances/mysql_hosts modules/instances/ansible_role_mysql.yaml
    ansible-playbook -i modules/instances/hostname_hosts modules/instances/ansible_role_hostname.yaml
Warning: As the mysql role modifies the default otel install, if you manually re-apply the galaxy-otel role, you will need to then re-apply the mysql role as well.
