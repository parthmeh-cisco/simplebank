DB_URL=postgresql://root:secret@localhost:5432/simple_bank?sslmode=disable
MYSQL_DB_URL=mysql://root:secret@tcp(localhost:3306)/simple_bank

network:
	docker network create bank-network

postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:latest

mysql:
	docker run --name mysql -p 3306:3306  -e MYSQL_ROOT_PASSWORD=secret -d mysql:latest

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb simple_bank

createdb-mysql:
	docker exec -it mysql mysql -uroot -psecret -e 'CREATE DATABASE simple_bank'

dropdb-mysql:
	docker exec -it mysql mysql -uroot -psecret -e 'DROP DATABASE simple_bank'

migrateup:
	migrate -path db/migration -database "$(DB_URL)" -verbose up

migrateup-mysql:
	migrate -path db/migration -database "$(MYSQL_DB_URL)" -verbose up

migrateup1:
	migrate -path db/migration -database "$(DB_URL)" -verbose up 1

migrateup1-mysql:
	migrate -path db/migration -database "$(MYSQL_DB_URL)" -verbose up 1

migratedown:
	migrate -path db/migration -database "$(DB_URL)" -verbose down

migratedown-mysql:
	migrate -path db/migration -database "$(MYSQL_DB_URL)" -verbose down

migratedown1:
	migrate -path db/migration -database "$(DB_URL)" -verbose down 1

migratedown1-mysql:
	migrate -path db/migration -database "$(MYSQL_DB_URL)" -verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/parthmeh-cisco/simplebank/db/sqlc Store
	mockgen -package mockwk -destination worker/mock/distributor.go github.com/parthmeh-cisco/simplebank/worker TaskDistributor

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto
	statik -src=./doc/swagger -dest=./doc

evans:
	evans --host localhost --port 9090 -r repl

redis:
	docker run --name redis -p 6379:6379 -d redis:7-alpine

.PHONY: network postgres createdb dropdb createdb-mysql dropdb-mysql migrateup migrateup-mysql migratedown migratedown-mysql migrateup1 migrateup1-mysql migratedown1 migratedown1-mysql new_migration db_docs db_schema sqlc test server mock proto evans redis