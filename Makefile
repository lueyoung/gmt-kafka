SHELL=/bin/bash
MANIFEST=./manifest
CONF=./conf
SCRIPTS=./scripts
NAME=kafka
NAMESPACE=default
LOCAL_REGISTRY=gmt.reg.me/test
LABELS_KEY=app
LABELS_VALUE=${NAME}
IMAGE_PULL_POLICY=Always
SCRIPTS_CM=${NAME}-scripts
CONF_CM=${NAME}-conf
ENV_CM=${NAME}-env
IMAGE=wurstmeister/kafka:latest
IMAGE=${LOCAL_REGISTRY}/${NAME}:latest
DISCOVERY=zoo
ZOO=zoo1:2181,zoo2:2181,zoo3:2181
SERVICE_ACCOUNT=admin

all: build push deploy

build:
	@docker build -t ${IMAGE} .

push:
	@docker push ${IMAGE}

cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.labels.key}}"?"${LABELS_KEY}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.labels.value}}"?"${LABELS_VALUE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.scripts.cm}}"?"${SCRIPTS_CM}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.conf.cm}}"?"${CONF_CM}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.env.cm}}"?"${ENV_CM}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.zoo}}"?"${ZOO}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.service.account}}"?"${SERVICE_ACCOUNT}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.discovery}}"?"${DISCOVERY}"?g

deploy: OP=create
deploy: cp sed
	@kubectl -n ${NAMESPACE} ${OP} configmap $(SCRIPTS_CM) --from-file ${SCRIPTS}/.
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CONF_CM) --from-file ${CONF}/.
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml
	@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml

clean: OP=delete
clean:
	@kubectl -n ${NAMESPACE} ${OP} configmap $(SCRIPTS_CM)
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CONF_CM)
	@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml

cleani-rbac: OP=delete
clean-rbac:
	@kubectl ${OP} -f ${MANIFEST}/rbac.yaml

mkcm: OP=create
mkcm:
	-@kubectl -n ${NAMESPACE} delete configmap $(CM_NAME)
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CM_NAME) --from-file ${CONF}/. --from-file ${SCRIPTS}/.

status:
	-@kubectl exec -it zoo1-0 -- zkServer.sh status
	-@kubectl exec -it zoo2-0 -- zkServer.sh status
	@kubectl exec -it zoo3-0 -- zkServer.sh status
