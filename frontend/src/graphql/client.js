import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";

// Dynamically determine the GraphQL endpoint
const getGraphQLEndpoint = () => {
  const currentProtocol = window.location.protocol;
  const currentHost = window.location.hostname;
  const currentPort = window.location.port;

  // In production (deployed on Pi via nginx), use the proxy at /graphql
  // This avoids CORS issues since it's same-origin
  if (currentPort === '' || currentPort === '80' || currentPort === '443') {
    // Production: use nginx proxy (same origin)
    return `${currentProtocol}//${currentHost}/graphql`;
  }

  // Development: connect directly to backend port 3001
  return `${currentProtocol}//${currentHost}:3001/graphql`;
};

const httpLink = createHttpLink({
  uri: getGraphQLEndpoint(),
  credentials: "same-origin",
});

const client = new ApolloClient({
  link: httpLink,
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          habits: {
            merge(existing = [], incoming) {
              return incoming;
            },
          },
        },
      },
      Habit: {
        keyFields: ["externalId"],
      },
    },
  }),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: "cache-and-network",
      errorPolicy: "all",
    },
    query: {
      fetchPolicy: "network-only",
      errorPolicy: "all",
    },
    mutate: {
      errorPolicy: "all",
    },
  },
});

export default client;
