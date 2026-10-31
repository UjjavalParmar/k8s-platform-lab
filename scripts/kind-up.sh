#!/usr/bin/env bash
set  -euo pipefail
CLUSTER=lab; REG=kind-registry; PORT=5001


[ "$(docker inspect -f '{{.State.Running}}' $REG 2>/dev/null)" = true ] || \
  docker run -d --restart=always -p 127.0.0.1:$PORT:5000 --network bridge --name $REG registry:3

kind get clusters | grep -qx $CLUSTER || kind create cluster --name $CLUSTER --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 30080
        hostPort: 30080
  - role: worker
  - role: worker
EOF


for node in $(kind get nodes --name $CLUSTER); do
  docker exec "$node" mkdir -p /etc/containerd/certs.d/localhost:$PORT
  echo "[host.\"http://$REG:5000\"]" | docker exec -i "$node" cp /dev/stdin /etc/containerd/certs.d/localhost:$PORT/hosts.toml
done

[ "$(docker inspect -f '{{json .NetworkSettings.Networks.kind}}' $REG)" != null ] || docker network connect kind $REG

kubectl --context kind-$CLUSTER apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:$PORT"
EOF
