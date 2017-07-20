TEMPLATES_SHA1 ?= 6176084

start-openshift:
	./oc/oc cluster up --metrics=true --service-catalog
	#./oc/oc cluster up --metrics=true --version=latest
	./oc/oc login -u system:admin
	./oc/oc adm policy add-cluster-role-to-user cluster-admin developer
	./oc/oc login -u developer -p developer
.PHONY: start-openshift

stop-openshift:
	./oc/oc cluster down
.PHONY: stop-openshift

add-hosa:
	./oc/oc delete all,secrets,sa,templates,configmaps,daemonsets,clusterroles --selector=metrics-infra=agent -n default
	./oc/oc delete clusterroles hawkular-openshift-agent

	# http://www.hawkular.org/blog/2017/03/25/collecting-application-metrics-openshift.html
	rm -rf hawkular-openshift-agent-configmap.yaml
	rm -rf hawkular-openshift-agent.yaml
	
	wget https://raw.githubusercontent.com/jpkrohling/hawkular-openshift-agent/188a762c62855d7adfdb0244f2dcef45d81323ee/deploy/openshift/hawkular-openshift-agent-configmap.yaml
	wget https://raw.githubusercontent.com/hawkular/hawkular-openshift-agent/master/deploy/openshift/hawkular-openshift-agent.yaml

	./oc/oc create -f hawkular-openshift-agent-configmap.yaml -n default || true
	./oc/oc process -f hawkular-openshift-agent.yaml -p IMAGE_VERSION=latest | ./oc/oc create -n default -f - || true
	./oc/oc adm policy add-cluster-role-to-user hawkular-openshift-agent system:serviceaccount:default:hawkular-openshift-agent || true
.PHONY: add-hosa

add-templates:
	rm -rf infinispan-centos7.json
	rm -rf infinispan-ephemeral.json
	rm -rf infinispan-persistent.json

	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/${TEMPLATES_SHA1}/imagestreams/infinispan-centos7.json
	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/${TEMPLATES_SHA1}/templates/infinispan-ephemeral.json
	wget https://raw.githubusercontent.com/slaskawi/infinispan-openshift-templates/${TEMPLATES_SHA1}/templates/infinispan-persistent.json
	
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

