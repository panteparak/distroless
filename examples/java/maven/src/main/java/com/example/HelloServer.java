package com.example;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

/**
 * Simple HTTP server example using Maven for dependency management.
 */
public class HelloServer {
    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", new HelloHandler());
        server.setExecutor(null);

        System.out.println("Server running on port " + port);
        server.start();
    }

    static class HelloHandler implements HttpHandler {
        @Override
        public void handle(HttpExchange exchange) throws IOException {
            String response = String.format(
                "{\"message\": \"Hello from distroless Java with Maven!\", " +
                "\"javaVersion\": \"%s\", " +
                "\"path\": \"%s\", " +
                "\"method\": \"%s\"}",
                System.getProperty("java.version"),
                exchange.getRequestURI().getPath(),
                exchange.getRequestMethod()
            );

            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(200, response.length());

            try (OutputStream os = exchange.getResponseBody()) {
                os.write(response.getBytes());
            }

            System.out.println("[HTTP] " + exchange.getRequestMethod() + " " + exchange.getRequestURI());
        }
    }
}
