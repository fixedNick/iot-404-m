package main

import (
	integration_test "server/tests/integration"

	"github.com/joho/godotenv"
)

func main() {
	godotenv.Load([]string{"../env/test/.env.go.app", "../env/test/.env.db"}...)
	integration_test.Test_FullFlow_WindGet()
}
