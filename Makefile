WEB_CONTAINER := `docker compose ps | grep web | cut -d ' ' -f1`

target: project

project:
	docker compose ps | grep -E '.web.[1-9].*(Up|running)' || docker compose up -d

bind: project
	docker attach $(WEB_CONTAINER)

rc: project
	docker compose exec -it web rails console

ash: project
	docker compose exec -it web ash

psql: project
	docker compose exec -it db psql -U postgres s95_dev

checkup:
	rubocop --display-only-fail-level-offenses --fail-level=error && \
	rubocop --only Lint/Debugger

build:
	docker compose run --rm web bundle lock
	docker compose build web
	docker images --filter "dangling=true" -q | xargs docker rmi > /dev/null 2>&1 || echo "\nThere were images tagged as <none> in use"

clean_logs:
	rm ./log/capistrano.log
	touch ./log/capistrano.log
	rm ./log/bullet.log
	touch ./log/bullet.log
