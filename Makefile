export SHELL := /bin/bash

## directory where htpasswds are stored
htpasswddir=/home/hannes/NOSKE_USERMANAGEMENT/HTPASSWDS

namespace=noske4wibarabanno

## IMPORTANT: adapt THIS:
environment=wibarab

# update VARS
update: project_398_VARIABLES.in.txt
	git_update_CICD_vars.sh 398

# clean up log files etc.
clean:
	rm -fv *.log
	rm -fv updated_secret4*.yaml

### get passwd-secret from cluster2 and store it to $htpasswddir
pwget:
	@echo -e "\n# get current passwds and store it in file \n\n ${htpasswddir}/htpasswd_${environment}_$$(date +%F)_downld.txt \n\n and copy its content to \n\n\t htpasswd_${environment} \n";
	@cd ${htpasswddir} && \
	kubectl get secret -n ${namespace} htpasswd-${environment} -o yaml | yq .data.htpasswd  | base64 --decode > htpasswd_${environment}_$$(date +%F)_downld.txt && \
	cp -fv htpasswd_${environment}_$$(date +%F)_downld.txt htpasswd_${environment}
	
### update the htpasswd-secret: it is detrimental that there is a file (or usually: a symbolic link) "htpasswd" in the local directory
pwput:
	@echo -e "\n# creating a secret from file 'htpasswd', store it to \n#\n# \t updated_secret4${environment}.yaml \n# \n# and push it to the cluster using kubectl\n"
	kubectl create secret -n ${namespace} generic htpasswd-${environment} --from-file=htpasswd --dry-run=client -o yaml | tee updated_secret4${environment}.yaml  && \
	yq .data.htpasswd updated_secret4${environment}.yaml | base64 --decode && \
	echo -e "\n\n------------------------------------\n" && \
	echo -e "\n\n Calling: \n\n     kubectl apply -f updated_secret4${environment}.yaml \n" && \
	kubectl apply -f updated_secret4${environment}.yaml
	
.PHONY: update clean pwget pwput
