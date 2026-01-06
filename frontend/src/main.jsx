import React from "react";
import ReactDOM from "react-dom/client";
import { ApolloProvider } from "@apollo/client";
import client from "./graphql/client";
import App from "./App.jsx";
import "./index.css";
import "./debug.css";

// Enable debug mode with ?debug=1
if (new URLSearchParams(window.location.search).get("debug") === "1") {
  document.documentElement.setAttribute("data-debug", "true");
}

// Service worker will be automatically registered by vite-plugin-pwa

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>
);
