proj:
	docker-compose ps | grep -E 'kuzminki.run.web.*Up' || docker-compose up -d
	docker attach `docker-compose ps | grep web | cut -d ' ' -f1`

checkup:
	rubocop --display-only-fail-level-offenses --fail-level=error && \
	rubocop --only Lint/Debugger

build_proj:
	docker-compose run --rm web bundle lock
	docker-compose build web
	docker images --filter "dangling=true" -q | xargs docker rmi || echo "There were images tagged as <none> in use"

rconsole:
	docker exec -it `docker-compose ps | grep web | cut -d ' ' -f1` rails console

ash:
	docker exec -it `docker-compose ps | grep web | cut -d ' ' -f1` ash

clean_logs:
	rm ./log/development.log
	touch ./log/development.log
	rm ./log/test.log
	touch ./log/test.log
	rm ./log/bullet.log
	touch ./log/bullet.log
