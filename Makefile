.PHONY: up down aws-reset
up:        ; ./scripts/kind-up.sh && docker start ministack mailpit
down:      ; kind delete cluster --name lab
aws-reset: ; curl -s -X POST localhost:4566/_ministack/reset
