package org.workspace7.moviestore;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.infinispan.client.hotrod.RemoteCache;
import org.infinispan.client.hotrod.RemoteCacheManager;
import org.infinispan.client.hotrod.configuration.ConfigurationBuilder;
import org.infinispan.spring.starter.remote.InfinispanRemoteConfigurer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@SpringBootApplication
@EnableAutoConfiguration
public class MonitoringDemo {

    @Configuration
    public static class HotRodConfiguration {

        @Bean
        public InfinispanRemoteConfigurer configuration() {
            return () -> new ConfigurationBuilder()
                  .addServers(System.getenv("SERVER_LIST"))
//                  .security()
//                    .authentication()
//                    .enable()
//                        .username(System.getenv("USERNAME"))
//                        .password(System.getenv("PASSWORD").toCharArray())
                  .build();
        }
    }

    public static void main(String... args) throws InterruptedException {
        ConfigurableApplicationContext context = SpringApplication.run(MonitoringDemo.class, args);

        RemoteCacheManager remoteCacheManager = context.getBean(RemoteCacheManager.class);
        RemoteCache<String, String> cache = remoteCacheManager.getCache();

        cache.put(Long.toString(System.currentTimeMillis()), "Yeah, Infinispan is cool!");

        AtomicInteger numOfEntries = new AtomicInteger();
        cache.entrySet().forEach(e -> {
            System.out.println(numOfEntries.getAndIncrement() + " " + e);
        });
        System.out.println("Toal entries: " + numOfEntries.get());

        TimeUnit.HOURS.sleep(1);
    }
}
