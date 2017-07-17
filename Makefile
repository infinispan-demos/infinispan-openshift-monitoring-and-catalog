start-openshift:
		./oc/oc cluster up --metrics=true --service-catalog --version=latest
		#./oc/oc cluster up --metrics=true --version=latest
		./oc/oc login -u system:admin
		./oc/oc adm policy add-cluster-role-to-user cluster-admin developer
		./oc/oc login -u developer -p developer
.PHONY: start-openshift

discover-templates:
		./oc/oc adm policy add-cluster-role-to-group system:openshift:templateservicebroker-client system:unauthenticated system:authenticated
.PHONY: discover-templates

