ENDPOINTS=api/{user,workspaces,teams,snippets,hook_events}.json

all: repos $(shell echo $(ENDPOINTS))

repos/%:
	git clone git@bitbucket.org:$*.git $@

repos: api/repositories.json
	cat $< \
	    | jq -r 'map(.full_name) | @tsv' \
	    | xargs printf 'repos/%s\n' \
	    | xargs $(MAKE) -j

api/%.json: credentials
	@mkdir -p $(@D)
	@curl -f -u "$(shell cat $<)" \
	    "https://api.bitbucket.org/2.0/$*?role=member&pagelen=100" \
	    | jq ".values" \
	    > $@

clean:
	rm -r api

.PHONY: repos

