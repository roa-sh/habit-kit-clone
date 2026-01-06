import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";

// Dynamically determine the GraphQL endpoint
const getGraphQLEndpoint = () => {
  const currentHost = window.location.hostname;
  const currentProtocol = window.location.protocol;

  // For development: always use the hostname where frontend is accessed
  // If accessing from Mac (localhost), backend is localhost:3001
  // If accessing from Pi (192.168.40.39), backend is also on Mac at same IP:3001
  const apiHost = currentHost;

  return `${currentProtocol}//${apiHost}:3001/graphql`;
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
