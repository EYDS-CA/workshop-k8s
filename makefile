include .env
ifndef NAMESPACE
$(error NAMESPACE env var not set)
endif

apply:
	# Applying every kubernetes file, substituting in any environment variables
	@for f in k8s/*.yml; do \
		envsubst < $$f | kubectl apply -n $(NAMESPACE) -f -; \
	done
