package com.smartsys.es_client;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Collection;
import java.util.Random;

import javax.net.ssl.SSLContext;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.elasticsearch.client.RestClient;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.TransportUtils;
import co.elastic.clients.transport.rest_client.RestClientTransport;

@SpringBootApplication
public class EsClientApplication {

	public static void main(String[] args) {
		SpringApplication.run(EsClientApplication.class, args);
	}

	@Bean
	CommandLineRunner commandLineRunner(
	) {
		return args -> {
			createSecureClient();	
		};
	}

	public void createSecureClient() throws IOException  {
		// Create the low-level client
        String host = "https://localhost";
        int port = 9200;
        String login = "elastic";
        String password = "changeme";

        //tag::create-secure-client-cert
        File certFile = new File("/Users/nkacel/Workspace/dev/training/smart-elasticsearch-elk/crt/es01.crt");

        SSLContext sslContext = TransportUtils
            .sslContextFromHttpCaCrt(certFile); // <1>

        BasicCredentialsProvider credsProv = new BasicCredentialsProvider(); // <2>
        credsProv.setCredentials(
            AuthScope.ANY, new UsernamePasswordCredentials(login, password)
        );

        RestClient restClient = RestClient
            .builder(new HttpHost(host, port, "https")) // <3>
            .setHttpClientConfigCallback(hc -> hc
                .setSSLContext(sslContext) // <4>
                .setDefaultCredentialsProvider(credsProv)
            )
            .build();

        // Create the transport and the API client
        ElasticsearchTransport transport = new RestClientTransport(restClient, new JacksonJsonpMapper());
        ElasticsearchClient esClient = new ElasticsearchClient(transport);

        // Use the client...
		/*
		 SearchResponse<Product> search = esClient.search(s -> s
    		.index("products")
    		.query(q -> q
        	.term(t -> t
            	.field("name")
            	.value(v -> v.stringValue("bicycle"))
        	)),
    Product.class);

			for (Hit<Product> hit: search.hits().hits()) {
    			processProduct(hit.source());
			}
		 */
		

        // Close the client, also closing the underlying transport object and network connections.
        esClient.close();
        //end::create-secure-client-cert
	}

}
