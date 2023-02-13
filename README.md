# o11y-terraform-ansible-testing

Requires ansible-galaxy to install otel agent using the collection https://docs.splunk.com/Observability/gdi/opentelemetry/deployments/deployments-linux-ansible.html

Install by running the following on the machine running Terraform and Ansible:

    ansible-galaxy collection install signalfx.splunk_otel_collector

Update the collection by running the following:

    ansible-galaxy collection install -U signalfx.splunk_otel_collector

Ansible macOS Fork Errors:

    Fix for current session
    export "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES"

    Fix all future sessions
    echo "OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES" >> .bash_profile

Connecting to windows instances using Ansible on macOS requires pyminrm
    pip install "pywinrm>=0.3.0"

Example Ansible Test Command (ran from the parent directory)
    ansible-playbook -i modules/instances/otel_agent_hosts modules/instances/otel-agent.yml --extra-vars 'realm=eu0 accesstoken=XXX galaxy_otel=yes'
