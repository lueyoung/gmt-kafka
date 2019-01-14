SHELL=/bin/bash
MANIFEST=./manifest
CONF=./conf
SCRIPTS=./scripts
NAME=kafka
NAMESPACE=default
LABELS_KEY=app
LABELS_VALUE=${NAME}
IMAGE_PULL_POLICY=IfNotPresent
SCRIPTS_CM=${NAME}-scripts
CONF_CM=${NAME}-conf
ENV_CM=${NAME}-env
IMAGE=wurstmeister/kafka:latest
ZOO=zoo

all: deploy

build:
	@docker build -t ${IMAGE2} .
	@docker build -t ${IMAGE4} .
	@docker build -t ${IMAGE5} -f Dockerfile.${NAME5} .
	@docker build -t ${IMAGE6} -f Dockerfile.${NAME6} .

push:
	@docker push ${IMAGE2}
	@docker push ${IMAGE4}
	@docker push ${IMAGE5}
	@docker push ${IMAGE6}

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

deploy: OP=create
deploy: cp sed
	@kubectl -n ${NAMESPACE} ${OP} configmap $(SCRIPTS_CM) --from-file ${SCRIPTS}/.
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CONF_CM) --from-file ${CONF}/.
	@kubectl ${OP} -f ${MANIFEST}/.

clean: OP=delete
clean:
	@kubectl -n ${NAMESPACE} ${OP} configmap $(SCRIPTS_CM)
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CONF_CM)
	@kubectl ${OP} -f ${MANIFEST}/.

mkcm: OP=create
mkcm:
	-@kubectl -n ${NAMESPACE} delete configmap $(CM_NAME)
	@kubectl -n ${NAMESPACE} ${OP} configmap $(CM_NAME) --from-file ${CONF}/. --from-file ${SCRIPTS}/.

status:
	-@kubectl exec -it zoo1-0 -- zkServer.sh status
	-@kubectl exec -it zoo2-0 -- zkServer.sh status
	@kubectl exec -it zoo3-0 -- zkServer.sh status
