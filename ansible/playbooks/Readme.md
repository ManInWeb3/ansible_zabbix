


## Ansible comands
```
ansible-playbook -i ./inventory.lst ./playbooks/create_ansible_user.yml -u USERNAME -k --ask-become-pass --vault-password-file=ansible-vault.pass
```
to request vault password use **--ask-vault-pass** instead of --vault-password-file=ansible-vault.pass

Install zabbix-agent to the group
```
ansible-playbook -i ./inventory.lst ./playbooks/install_zabbix-agent.yml --vault-password-file=ansible-vault.pass
```

Update zabbix-agent configs only on 1 host
```
ansible-playbook -i ./inventory.lst ./playbooks/configure_zabbix-agent.yml --vault-password-file=ansible-vault.pass --limit='XXXXXXXXXXXX'
```

