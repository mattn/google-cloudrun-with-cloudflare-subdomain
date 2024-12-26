package main

import (
	"net/http"
	"os"

	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()
	e.GET("/", func(c echo.Context) error {
		if c.Request().Header.Get("accept") == "application/json" {
			return c.JSON(http.StatusOK, struct {
				Content string `json:"content"`
			}{
				Content: "💩",
			})
		}
		return c.String(http.StatusOK, "💩")
	})
	addr := ":8080"
	if port := os.Getenv("PORT"); port != "" {
		addr = ":" + port
	}
	e.Logger.Fatal(e.Start(addr))
}
