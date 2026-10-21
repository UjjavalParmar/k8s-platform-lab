.PHONY: up down check aws-reset

up:
	./scripts/kind-up.sh
	docker start ministack mailpit
	timeout 60s sh -c 'until aws s3api list-buckets --endpoint-url=http://localhost:4566 >/dev/null 2>&1; do sleep 1; done'
	aws s3api head-bucket --bucket tfstate --endpoint-url=http://localhost:4566 2>/dev/null || aws s3 mb s3://tfstate --endpoint-url=http://localhost:4566
	aws s3api put-bucket-versioning --bucket tfstate --versioning-configuration Status=Enabled --endpoint-url=http://localhost:4566

check:
	aws s3api head-bucket --bucket tfstate --endpoint-url=http://localhost:4566

down:
	kind delete cluster --name lab
	docker stop ministack mailpit

aws-reset:
	curl -s -X POST localhost:4566/_ministack/reset
