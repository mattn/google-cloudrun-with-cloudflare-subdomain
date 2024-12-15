package main

import (
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "")
	})
	addr := ":8989"
	if port := os.Getenv("PORT"); port != "" {
		addr = ":" + port
	}
	e.Logger.Fatal(e.Start(addr))
}
