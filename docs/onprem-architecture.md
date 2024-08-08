> [!NOTE]
> This file is kept just to generate a PNG image with the architecture of the OnPrem installation. The content is not used in the documentation.
> To generate the graph, go to https://mermaid.live, copy the content and save the image as `onprem-architecture.png`

```mermaid
graph LR
    Postgres[("Postgres")]
    Mongo[("Mongo")]
    Nats
    SMTPServer["SMTP Server"]
    Ory["Ory Ecosystem\n(AuthZ / AuthN)"]
    TracetestAPI["Cloud/Core API"]
    TracetestWorkers["Tracetest\nWorkers"]
    TracetestFrontend["Frontend"]
    User

    User --> TracetestFrontend
    User --> Ory
    User --> TracetestAPI

    subgraph Tracetest
        TracetestFrontend --> TracetestAPI      

        TracetestAPI --> Nats
        TracetestWorkers --> Nats

        TracetestFrontend --> Ory
        TracetestAPI --> Ory
    end
    
    subgraph ExternalDependencies["External Deps"]
        TracetestAPI --> SMTPServer
        Ory --> Postgres
        TracetestAPI --> Postgres
        TracetestAPI --> Mongo
    end
```