include .env
ifndef NAMESPACE
$(error NAMESPACE env var not set)
endif



apply:
	# Applying every kubernetes file, substituting in any environment variables
	@for f in k8s/*.yml; do \
		envsubst < $$f | kubectl apply -n $(NAMESPACE) -f -; \
	done

nginx-build: 
	docker build -t $(ACR_REPO)/$(NAMESPACE)/$(IMAGE):latest ./services/custom-nginx

nginx-push: nginx-build
	docker push $(ACR_REPO)/$(NAMESPACE)/$(IMAGE):latest
