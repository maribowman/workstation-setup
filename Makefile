all:
	@read -p "BECOME username: " username; \
	ansible-playbook playbook.yaml -u username --ask-become-pass
