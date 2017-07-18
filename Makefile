start-openshift:
	./oc/oc cluster up --metrics=true --service-catalog --version=latest
	#./oc/oc cluster up --metrics=true --version=latest
	./oc/oc login -u system:admin
	./oc/oc adm policy add-cluster-role-to-user cluster-admin developer
	./oc/oc login -u developer -p developer
.PHONY: start-openshift

cleanup:
	./oc/oc cluster down
	# https://gist.github.com/bastman/5b57ddb3c11942094f8d0a97d461b430
	docker rm $(docker ps -qa --no-trunc --filter "status=exited") || true
.PHONY: cleanup

add-templates:
	rm -rf infinispan-centos7.json
	rm -rf infinispan-ephemeral.json
	rm -rf infinispan-persistent.json

	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/6fead26f24e6c106e146befeda7a26c0b1c31c38/imagestreams/infinispan-centos7.json
	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/6fead26f24e6c106e146befeda7a26c0b1c31c38/templates/infinispan-ephemeral.json
	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/6fead26f24e6c106e146befeda7a26c0b1c31c38/templates/infinispan-persistent.json
	
	./oc/oc project openshift
	./oc/oc create -f infinispan-centos7.json || true
	./oc/oc create -f infinispan-ephemeral.json || true
	./oc/oc create -f infinispan-persistent.json || true
	./oc/oc replace -f infinispan-centos7.json || true
	./oc/oc replace -f infinispan-ephemeral.json || true
	./oc/oc replace -f infinispan-persistent.json || true
	./oc/oc adm policy add-cluster-role-to-group system:openshift:templateservicebroker-client system:unauthenticated system:authenticated
	./oc/oc project myproject
.PHONY: add-templates

