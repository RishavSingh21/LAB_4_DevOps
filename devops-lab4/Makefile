test:
	cd app && pip install -q -r requirements-dev.txt && pytest --cov=app --cov-fail-under=80
lint:
	cd app && flake8 .
bluegreen:
	bash blue-green/demo.sh
canary:
	bash canary/canary.sh
canary-bad:
	CANARY_ERROR_RATE=0.5 bash canary/canary.sh
dr:
	bash dr/failover.sh
secrets:
	bash secrets/demo.sh
gitops:
	bash gitops/setup.sh
