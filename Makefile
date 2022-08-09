WEB_CONTAINER := `docker-compose ps | grep web | cut -d ' ' -f1`

target: proj

proj:
	docker-compose ps | grep -E '.web.[1-9].*Up' || docker-compose up -d

bind: proj
	docker attach $(WEB_CONTAINER)

rc: proj
	docker exec -it $(WEB_CONTAINER) rails console

ash: proj
	docker exec -it $(WEB_CONTAINER) ash

checkup:
	rubocop --display-only-fail-level-offenses --fail-level=error && \
	rubocop --only Lint/Debugger

build_proj:
	docker-compose run --rm web bundle lock
	docker-compose build web
	docker images --filter "dangling=true" -q | xargs docker rmi || echo "There were images tagged as <none> in use"

clean_logs:
	rm ./log/capistrano.log
	touch ./log/capistrano.log
	rm ./log/bullet.log
	touch ./log/bullet.log
